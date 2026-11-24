import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/user_model.dart';
import '../models/student_model.dart';
import '../models/instructor_model.dart';
import '../models/dashboard_stats_model.dart';
import 'storage_service.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal(http.Client());
  factory ApiService() => _instance;
  factory ApiService.withClient(http.Client client) =>
      ApiService._internal(client);
  ApiService._internal(this._client);

  final http.Client _client;

  String get _baseUrl => ApiConfig.baseUrl;

  Future<Map<String, String>> _getHeaders([
    Map<String, String>? customHeaders,
  ]) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    final token = await StorageService.getToken();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    if (customHeaders != null) {
      headers.addAll(customHeaders);
    }
    return headers;
  }

  Future<dynamic> request(
    String endpoint, {
    String method = 'GET',
    dynamic body,
    Map<String, String>? headers,
  }) async {
    final cleanEndpoint = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    final uri = Uri.parse('$_baseUrl$cleanEndpoint');
    final reqHeaders = await _getHeaders(headers);
    final isAnnouncementsRequest = cleanEndpoint.startsWith(
      '/portal/announcements',
    );
    final allowOfflineFallback =
        ApiConfig.isOfflineFallbackEnabled &&
        !cleanEndpoint.startsWith('/auth/');

    try {
      http.Response response;
      switch (method.toUpperCase()) {
        case 'POST':
          response = await _client
              .post(uri, headers: reqHeaders, body: jsonEncode(body ?? {}))
              .timeout(ApiConfig.timeoutDuration);
          break;
        case 'PUT':
          response = await _client
              .put(uri, headers: reqHeaders, body: jsonEncode(body ?? {}))
              .timeout(ApiConfig.timeoutDuration);
          break;
        case 'DELETE':
          response = await _client
              .delete(uri, headers: reqHeaders)
              .timeout(ApiConfig.timeoutDuration);
          break;
        case 'GET':
        default:
          response = await _client
              .get(uri, headers: reqHeaders)
              .timeout(ApiConfig.timeoutDuration);
          break;
      }

      if (response.statusCode == 204) return null;
      dynamic responseData;
      if (response.body.isNotEmpty) {
        try {
          responseData = jsonDecode(response.body);
        } on FormatException {
          if (!isAnnouncementsRequest) rethrow;
          responseData = null;
        }
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (responseData is Map<String, dynamic> &&
            responseData['success'] == false) {
          throw Exception(responseData['message'] ?? 'Request failed');
        }
        return responseData;
      } else {
        if (response.statusCode == 401 &&
            cleanEndpoint.startsWith('/portal/')) {
          await StorageService.clearSession();
        }
        final responseMessage = responseData is Map<String, dynamic>
            ? responseData['message']?.toString()
            : null;
        String errMsg;
        if (isAnnouncementsRequest && response.statusCode == 401) {
          errMsg = 'Your session is invalid. Please sign in again.';
        } else if (isAnnouncementsRequest && response.statusCode == 403) {
          errMsg =
              'Your account does not have permission to view announcements.';
        } else if (isAnnouncementsRequest && response.statusCode >= 500) {
          errMsg =
              'The announcements service is temporarily unavailable. Please try again.';
        } else if (responseMessage != null && responseMessage.isNotEmpty) {
          errMsg = responseMessage;
        } else {
          errMsg = 'Request failed with status ${response.statusCode}';
        }
        throw Exception(errMsg);
      }
    } on http.ClientException catch (error) {
      if (isAnnouncementsRequest) {
        throw Exception(
          'Could not connect to the announcements service. Check the API URL and server, then retry.',
        );
      }
      // If offline fallback enabled and it's a GET or offline fallback is appropriate
      if (allowOfflineFallback) {
        return _handleOfflineFallback(
          endpoint,
          method: method,
          body: body,
          error: error,
        );
      }
      rethrow;
    } on TimeoutException catch (error) {
      if (isAnnouncementsRequest) {
        throw Exception(
          'The announcements service took too long to respond. Please retry.',
        );
      }
      if (allowOfflineFallback) {
        return _handleOfflineFallback(
          endpoint,
          method: method,
          body: body,
          error: error,
        );
      }
      rethrow;
    } catch (e) {
      if (isAnnouncementsRequest) rethrow;
      if (allowOfflineFallback) {
        return _handleOfflineFallback(
          endpoint,
          method: method,
          body: body,
          error: e,
        );
      }
      rethrow;
    }
  }

  // Production execution: no mock fallback allowed
  dynamic _handleOfflineFallback(
    String endpoint, {
    required String method,
    dynamic body,
    required Object error,
  }) async {
    throw error;
  }

  // Auth Operations
  Future<Map<String, dynamic>> loginInstitute({
    required String instituteCode,
    required String email,
    required String password,
  }) async {
    final res = await request(
      '/auth/institute/login',
      method: 'POST',
      body: {
        'instituteCode': instituteCode,
        'email': email,
        'password': password,
        'role': 'institute',
      },
    );
    if (res is Map<String, dynamic>) {
      if (res['token'] != null) {
        await StorageService.saveToken(res['token'].toString());
      }
      if (res['user'] != null) {
        await StorageService.saveUser(UserModel.fromJson(res['user']));
      }
      return res;
    }
    return {'success': true};
  }

  Future<Map<String, dynamic>> loginAdmin({
    required String email,
    required String password,
    String? instituteCode,
  }) async {
    final res = await request(
      '/auth/admin/login',
      method: 'POST',
      body: {
        'email': email,
        'password': password,
        'role': 'admin',
        if (instituteCode != null && instituteCode.isNotEmpty) 'instituteCode': instituteCode,
      },
    );
    if (res is Map<String, dynamic>) {
      if (res['token'] != null) {
        await StorageService.saveToken(res['token'].toString());
      }
      if (res['user'] != null) {
        await StorageService.saveUser(UserModel.fromJson(res['user']));
      }
      return res;
    }
    return {'success': true};
  }

  Future<Map<String, dynamic>> loginRole({
    required String email,
    required String password,
    required String role,
    String? instituteCode,
  }) async {
    if (role == 'admin') {
      return loginAdmin(
        email: email,
        password: password,
        instituteCode: instituteCode,
      );
    }
    if (role == 'institute') {
      return loginInstitute(
        instituteCode: instituteCode ?? '',
        email: email,
        password: password,
      );
    }
    final res = await request(
      '/auth/login',
      method: 'POST',
      body: {
        'email': email,
        'password': password,
        'role': role,
        if (instituteCode != null && instituteCode.isNotEmpty) 'instituteCode': instituteCode,
      },
    );
    if (res is Map<String, dynamic>) {
      if (res['token'] != null) {
        await StorageService.saveToken(res['token'].toString());
      }
      if (res['user'] != null) {
        await StorageService.saveUser(UserModel.fromJson(res['user']));
      }
      return res;
    }
    return {'success': true};
  }

  Future<Map<String, dynamic>> registerInstitute(
    Map<String, dynamic> data,
  ) async {
    final res = await request(
      '/auth/register/institute',
      method: 'POST',
      body: data,
    );
    if (res is Map<String, dynamic>) {
      if (res['token'] != null) {
        await StorageService.saveToken(res['token'].toString());
      }
      if (res['user'] != null) {
        await StorageService.saveUser(UserModel.fromJson(res['user']));
      }
      return res;
    }
    return {'success': true};
  }

  Future<Map<String, dynamic>> registerStudent(
    Map<String, dynamic> data,
  ) async {
    final res = await request(
      '/auth/register/student',
      method: 'POST',
      body: data,
    );
    if (res is Map<String, dynamic>) {
      if (res['token'] != null) {
        await StorageService.saveToken(res['token'].toString());
      }
      if (res['user'] != null) {
        await StorageService.saveUser(UserModel.fromJson(res['user']));
      }
      return res;
    }
    return {'success': true};
  }

  Future<Map<String, dynamic>> registerTeacher(
    Map<String, dynamic> data,
  ) async {
    final res = await request(
      '/auth/register/teacher',
      method: 'POST',
      body: data,
    );
    if (res is Map<String, dynamic>) {
      if (res['token'] != null) {
        await StorageService.saveToken(res['token'].toString());
      }
      if (res['user'] != null) {
        await StorageService.saveUser(UserModel.fromJson(res['user']));
      }
      return res;
    }
    return {'success': true};
  }

  Future<Map<String, dynamic>> forgotPassword({
    required String email,
    required String role,
  }) async {
    final res = await request(
      '/auth/forgot-password',
      method: 'POST',
      body: {'email': email, 'role': role},
    );
    return res is Map<String, dynamic>
        ? res
        : {'success': true, 'message': 'Instructions sent'};
  }

  Future<void> logout() async {
    await StorageService.clearSession();
  }

  // Student CRUD
  Future<List<StudentModel>> getStudents([String search = '']) async {
    final endpoint =
        '/students${search.isNotEmpty ? '?search=${Uri.encodeComponent(search)}' : ''}';
    final res = await request(endpoint);
    if (res is List) {
      return res
          .map((item) => StudentModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    if (res is Map<String, dynamic> && res['data'] is List) {
      return (res['data'] as List)
          .map((item) => StudentModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<StudentModel> getStudentById(String id) async {
    final res = await request('/students/$id');
    return StudentModel.fromJson(res as Map<String, dynamic>);
  }

  Future<StudentModel> createStudent(StudentModel student) async {
    final res = await request(
      '/students',
      method: 'POST',
      body: student.toJson(),
    );
    return StudentModel.fromJson(res as Map<String, dynamic>);
  }

  Future<StudentModel> updateStudent(String id, StudentModel student) async {
    final res = await request(
      '/students/$id',
      method: 'PUT',
      body: student.toJson(),
    );
    return StudentModel.fromJson(res as Map<String, dynamic>);
  }

  Future<void> deleteStudent(String id) async {
    await request('/students/$id', method: 'DELETE');
  }

  // Instructor CRUD
  Future<List<InstructorModel>> getInstructors([String search = '']) async {
    final endpoint =
        '/instructors${search.isNotEmpty ? '?search=${Uri.encodeComponent(search)}' : ''}';
    final res = await request(endpoint);
    if (res is List) {
      return res
          .map((item) => InstructorModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    if (res is Map<String, dynamic> && res['data'] is List) {
      return (res['data'] as List)
          .map((item) => InstructorModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<InstructorModel> getInstructorById(String id) async {
    final res = await request('/instructors/$id');
    return InstructorModel.fromJson(res as Map<String, dynamic>);
  }

  Future<InstructorModel> createInstructor(InstructorModel instructor) async {
    final res = await request(
      '/instructors',
      method: 'POST',
      body: instructor.toJson(),
    );
    return InstructorModel.fromJson(res as Map<String, dynamic>);
  }

  Future<InstructorModel> updateInstructor(
    String id,
    InstructorModel instructor,
  ) async {
    final res = await request(
      '/instructors/$id',
      method: 'PUT',
      body: instructor.toJson(),
    );
    return InstructorModel.fromJson(res as Map<String, dynamic>);
  }

  Future<void> deleteInstructor(String id) async {
    await request('/instructors/$id', method: 'DELETE');
  }

  Future<List<Map<String, dynamic>>> getAnnouncements() async {
    final response = await request('/portal/announcements');
    if (response is! List ||
        response.any((item) => item is! Map<String, dynamic>)) {
      throw Exception(
        'The announcements service returned an invalid response. Please retry.',
      );
    }
    return response.cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> saveAnnouncement(
    Map<String, dynamic> body, {
    String? id,
  }) async {
    return await request(
          '/portal/announcements${id == null ? '' : '/$id'}',
          method: id == null ? 'POST' : 'PUT',
          body: body,
        )
        as Map<String, dynamic>;
  }

  Future<void> deleteAnnouncement(String id) async {
    await request('/portal/announcements/$id', method: 'DELETE');
  }

  Future<void> markAnnouncementRead(String id) async {
    await request('/portal/announcements/$id/read', method: 'POST');
  }

  Future<List<Map<String, dynamic>>> getLeaves({
    String? status,
    String? applicantRole,
    String? search,
    String? from,
    String? to,
  }) async {
    final query = <String, String>{};
    if (status != null && status.isNotEmpty) query['status'] = status;
    if (applicantRole != null && applicantRole.isNotEmpty) {
      query['applicantRole'] = applicantRole;
    }
    if (search != null && search.isNotEmpty) query['search'] = search;
    if (from != null) query['from'] = from;
    if (to != null) query['to'] = to;
    final suffix = query.isEmpty ? '' : '?${Uri(queryParameters: query).query}';
    final response = await request('/portal/leaves$suffix');
    return (response as List).cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> submitLeave(Map<String, dynamic> body) async {
    return await request('/portal/leaves', method: 'POST', body: body)
        as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> decideLeave(
    String id,
    String decision,
    String remark,
  ) async {
    return await request(
          '/portal/leaves/$id/decision',
          method: 'POST',
          body: {'decision': decision, 'remark': remark},
        )
        as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> getNotifications() async {
    final response = await request('/portal/notifications');
    return (response as List).cast<Map<String, dynamic>>();
  }

  Future<int> getUnreadNotificationCount() async {
    final response =
        await request('/portal/notifications/unread-count')
            as Map<String, dynamic>;
    return int.tryParse(response['count'].toString()) ?? 0;
  }

  Future<void> markNotificationRead(String id) async {
    await request('/portal/notifications/$id/read', method: 'POST');
  }

  Future<Map<String, dynamic>> getAssignmentOptions() async {
    return await request('/portal/admin/assignment-options')
        as Map<String, dynamic>;
  }

  Future<void> assignTeacher(String studentId, String teacherId) async {
    await request(
      '/portal/admin/students/$studentId/teacher',
      method: 'PUT',
      body: {'teacherId': teacherId},
    );
  }

  Future<String> uploadLeaveDocument(Uint8List bytes, String fileName) async {
    final uri = Uri.parse('$_baseUrl/portal/leave-attachments');
    final multipart = http.MultipartRequest('POST', uri);
    final token = await StorageService.getToken();
    if (token != null && token.isNotEmpty) {
      multipart.headers['Authorization'] = 'Bearer $token';
    }
    multipart.files.add(
      http.MultipartFile.fromBytes('file', bytes, filename: fileName),
    );
    final streamed = await _client
        .send(multipart)
        .timeout(ApiConfig.timeoutDuration);
    final response = await http.Response.fromStream(streamed);
    final dynamic data = response.body.isEmpty
        ? null
        : jsonDecode(response.body);
    if (response.statusCode >= 200 &&
        response.statusCode < 300 &&
        data is Map<String, dynamic>) {
      return data['fileUrl']?.toString() ??
          (throw Exception('Upload response did not include a file URL.'));
    }
    final message = data is Map<String, dynamic>
        ? data['message']?.toString()
        : null;
    throw Exception(
      message ?? 'File upload failed with status ${response.statusCode}.',
    );
  }

  // Dashboard Stats
  Future<AdminDashboardStatsModel> getAdminDashboardStats() async {
    final res = await request('/dashboard/admin');
    return AdminDashboardStatsModel.fromJson(res as Map<String, dynamic>);
  }

  Future<InstructorDashboardStatsModel> getInstructorDashboardStats(
    String id,
  ) async {
    final res = await request('/dashboard/instructor/$id');
    return InstructorDashboardStatsModel.fromJson(res as Map<String, dynamic>);
  }

  // Online Examination
  Future<List<Map<String, dynamic>>> getExams() async {
    final response = await request('/portal/exams');
    if (response is List) {
      return response.cast<Map<String, dynamic>>();
    }
    return [];
  }

  Future<Map<String, dynamic>> getExamDetails(String id) async {
    final response = await request('/portal/exams/$id');
    return response as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> startExamAttempt(String id) async {
    final response = await request('/portal/exams/$id/start', method: 'POST');
    return response as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> saveExamAnswer(
    String id,
    String questionId,
    String selectedOption,
  ) async {
    final response = await request(
      '/portal/exams/$id/save-answer',
      method: 'POST',
      body: {
        'questionId': questionId,
        'selectedOption': selectedOption,
      },
    );
    return response as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> submitExam(
    String id,
    Map<String, dynamic> answers,
  ) async {
    final response = await request(
      '/portal/exams/$id/submit',
      method: 'POST',
      body: {'answers': answers},
    );
    return response as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getExamAttempt(String id) async {
    final response = await request('/portal/exams/$id/attempt');
    return response as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> releaseExamResults(String id, bool release) async {
    final response = await request(
      '/portal/exams/$id/release-results',
      method: 'PUT',
      body: {'release': release},
    );
    return response as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> getExamAttempts(String id) async {
    final response = await request('/portal/exams/$id/attempts');
    if (response is List) {
      return response.cast<Map<String, dynamic>>();
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> getExamQuestions({String? search, String? subject, String? className, String? chapter, String? topic, String? difficulty, String? questionType}) async {
    final filters = <String, String>{
      if (search?.trim().isNotEmpty == true) 'search': search!.trim(),
      if (subject?.trim().isNotEmpty == true) 'subject': subject!.trim(),
      if (className?.trim().isNotEmpty == true) 'className': className!.trim(),
      if (chapter?.trim().isNotEmpty == true) 'chapter': chapter!.trim(),
      if (topic?.trim().isNotEmpty == true) 'topic': topic!.trim(),
      if (difficulty?.trim().isNotEmpty == true) 'difficulty': difficulty!.trim(),
      if (questionType?.trim().isNotEmpty == true) 'questionType': questionType!.trim(),
    };
    final query = filters.isEmpty ? '' : '?${Uri(queryParameters: filters).query}';
    final response = await request('/exam-questions$query');
    return response is List ? response.cast<Map<String, dynamic>>() : [];
  }

  Future<Map<String, dynamic>> createExamQuestion(Map<String, dynamic> data) async {
    final response = await request('/exam-questions', method: 'POST', body: data);
    return response as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateExamQuestion(String id, Map<String, dynamic> data) async {
    final response = await request('/exam-questions/$id', method: 'PUT', body: data);
    return response as Map<String, dynamic>;
  }

  Future<void> deleteExamQuestion(String id) async {
    await request('/exam-questions/$id', method: 'DELETE');
  }

  Future<List<Map<String, dynamic>>> getExamQuestionVersions(String id) async {
    final response = await request('/exam-questions/$id/versions');
    return response is List ? response.cast<Map<String, dynamic>>() : [];
  }

  Future<Map<String, dynamic>> createExam(Map<String, dynamic> data) async {
    final response = await request('/portal/exams', method: 'POST', body: data);
    return response as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> deleteExam(String id) async {
    final response = await request('/portal/exams/$id', method: 'DELETE');
    return response as Map<String, dynamic>;
  }

  // ==========================================
  // LMS: GOOGLE CLASSROOM & LIVE CLASSES HUB
  // ==========================================

  Future<List<Map<String, dynamic>>> getClassrooms() async {
    final response = await request('/classrooms');
    if (response is List) {
      return response.cast<Map<String, dynamic>>();
    }
    return [];
  }

  Future<Map<String, dynamic>> getClassroomDetails(String id) async {
    final response = await request('/classrooms/$id');
    return response as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> createClassroom(Map<String, dynamic> data) async {
    final response = await request('/classrooms', method: 'POST', body: data);
    return response as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateClassroom(String id, Map<String, dynamic> data) async {
    final response = await request('/classrooms/$id', method: 'PUT', body: data);
    return response as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> joinClassroom(String code) async {
    final response = await request('/classrooms/join', method: 'POST', body: {'code': code});
    return response as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getClassroomMembers(String id) async {
    final response = await request('/classrooms/$id/members');
    return response as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateMemberStatus(String classroomId, String userId, String status) async {
    final response = await request(
      '/classrooms/$classroomId/members/$userId/status',
      method: 'POST',
      body: {'status': status},
    );
    return response as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> archiveClassroom(String id, bool archive) async {
    final response = await request('/classrooms/$id/archive', method: 'PUT', body: {'archive': archive});
    return response as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> getClassroomComments(
    String classroomId, {
    String targetType = 'STREAM_POST',
    String? targetId,
  }) async {
    String url = '/classrooms/$classroomId/comments?targetType=$targetType';
    if (targetId != null) {
      url += '&targetId=$targetId';
    }
    final response = await request(url);
    if (response is List) {
      return response.cast<Map<String, dynamic>>();
    }
    return [];
  }

  Future<Map<String, dynamic>> addClassroomComment(String classroomId, Map<String, dynamic> data) async {
    final response = await request('/classrooms/$classroomId/comments', method: 'POST', body: data);
    return response as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> postClassroomComment(String classroomId, Map<String, dynamic> data) =>
      addClassroomComment(classroomId, data);

  // Assignments
  Future<List<Map<String, dynamic>>> getAssignments(String classroomId, {String? topic}) async {
    String url = '/assignments/classroom/$classroomId';
    if (topic != null && topic.isNotEmpty) {
      url += '?topic=${Uri.encodeComponent(topic)}';
    }
    final response = await request(url);
    if (response is List) {
      return response.cast<Map<String, dynamic>>();
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> getClassroomAssignments(String classroomId, {String? topic}) =>
      getAssignments(classroomId, topic: topic);

  Future<Map<String, dynamic>> getAssignmentDetails(String id) async {
    final response = await request('/assignments/$id');
    return response as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> createAssignment(String classroomId, Map<String, dynamic> data) async {
    final response = await request('/assignments?classroomId=$classroomId', method: 'POST', body: data);
    return response as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> uploadAssignmentAttachment({
    required String classroomId,
    required String purpose,
    required Uint8List bytes,
    required String fileName,
  }) async {
    final uri = Uri.parse('$_baseUrl/assignments/attachments/upload').replace(
      queryParameters: {'classroomId': classroomId, 'purpose': purpose},
    );
    final multipart = http.MultipartRequest('POST', uri);
    final token = await StorageService.getToken();
    if (token != null && token.isNotEmpty) {
      multipart.headers['Authorization'] = 'Bearer $token';
    }
    multipart.files.add(http.MultipartFile.fromBytes('file', bytes, filename: fileName));
    final streamed = await _client.send(multipart).timeout(const Duration(minutes: 2));
    final response = await http.Response.fromStream(streamed);
    final data = response.body.isEmpty ? null : jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300 && data is Map<String, dynamic>) {
      return data;
    }
    final message = data is Map<String, dynamic> ? data['message']?.toString() : null;
    throw Exception(message ?? 'Assignment file upload failed with status ${response.statusCode}.');
  }

  Future<Map<String, dynamic>> updateAssignment(String id, Map<String, dynamic> data) async {
    final response = await request('/assignments/$id', method: 'PUT', body: data);
    return response as Map<String, dynamic>;
  }

  Future<void> deleteAssignment(String id) async {
    await request('/assignments/$id', method: 'DELETE');
  }

  Future<Map<String, dynamic>> uploadAssignmentFile(Uint8List bytes, String fileName, {required String classroomId, required String purpose}) async {
    return uploadAssignmentAttachment(
      classroomId: classroomId,
      purpose: purpose,
      bytes: bytes,
      fileName: fileName,
    );
  }

  Future<Map<String, dynamic>> submitAssignment(String id, Map<String, dynamic> data) async {
    final response = await request('/assignments/$id/submit', method: 'POST', body: data);
    return response as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> unsubmitAssignment(String id) async {
    final response = await request('/assignments/$id/unsubmit', method: 'POST');
    return response as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> deleteAttachment(String attachmentId) async {
    final response = await request('/assignments/attachments/$attachmentId', method: 'DELETE');
    return response as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getStudentTodoList() async {
    final response = await request('/assignments/to-do');
    return response as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> gradeSubmission(String submissionId, Map<String, dynamic> data) async {
    final response = await request('/assignments/submissions/$submissionId/grade', method: 'POST', body: data);
    return response as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getClassGradebook(String classroomId) async {
    final response = await request('/assignments/classroom/$classroomId/gradebook');
    return response as Map<String, dynamic>;
  }

  // Google Meet & Live Classes
  Future<Map<String, dynamic>> scheduleLiveClass(String classroomId, Map<String, dynamic> data) async {
    final response = await request('/live-classes?classroomId=$classroomId', method: 'POST', body: data);
    return response as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateLiveClass(String id, Map<String, dynamic> data) async {
    final response = await request('/live-classes/$id', method: 'PUT', body: data);
    return response as Map<String, dynamic>;
  }

  Future<void> deleteLiveClass(String id) async {
    await request('/live-classes/$id', method: 'DELETE');
  }

  Future<List<Map<String, dynamic>>> getClassroomLiveClasses(String classroomId) async {
    final response = await request('/live-classes/classroom/$classroomId');
    if (response is List) {
      return response.cast<Map<String, dynamic>>();
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> getUpcomingLiveClasses() async {
    final response = await request('/live-classes/upcoming');
    if (response is List) {
      return response.cast<Map<String, dynamic>>();
    }
    return [];
  }

  Future<Map<String, dynamic>> joinLiveClass(String id) async {
    final response = await request('/live-classes/$id/join', method: 'POST');
    return response as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> leaveLiveClass(String id) async {
    final response = await request('/live-classes/$id/leave', method: 'POST');
    return response as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateLiveClassStatus(String id, Map<String, dynamic> data) async {
    final response = await request('/live-classes/$id/status', method: 'PUT', body: data);
    return response as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getLiveClassAttendance(String id) async {
    final response = await request('/live-classes/$id/attendance');
    return response as Map<String, dynamic>;
  }

  // Public Discovery
  Future<List<Map<String, dynamic>>> searchPublicClassrooms({String? query}) async {
    String url = '/public/classrooms';
    if (query != null && query.isNotEmpty) {
      url += '?search=${Uri.encodeComponent(query)}';
    }
    final response = await request(url);
    if (response is List) {
      return response.cast<Map<String, dynamic>>();
    }
    return [];
  }

  // Student Dashboard Stats
  Future<Map<String, dynamic>> getStudentDashboardStats() async {
    final res = await request('/dashboard/student');
    return res as Map<String, dynamic>;
  }

  // Course, Batch & Enrollment Management
  Future<List<Map<String, dynamic>>> getCourses() async {
    final response = await request('/courses');
    if (response is List) {
      return response.cast<Map<String, dynamic>>();
    }
    return [];
  }

  Future<Map<String, dynamic>> createCourse(Map<String, dynamic> data) async {
    final response = await request('/courses', method: 'POST', body: data);
    return response as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> getBatches([String? courseId]) async {
    final url = courseId != null ? '/courses/$courseId/batches' : '/batches';
    final response = await request(url);
    if (response is List) {
      return response.cast<Map<String, dynamic>>();
    }
    return [];
  }

  Future<Map<String, dynamic>> createBatch(Map<String, dynamic> data) async {
    final response = await request('/batches', method: 'POST', body: data);
    return response as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> enrollStudent(Map<String, dynamic> data) async {
    final response = await request('/enrollments', method: 'POST', body: data);
    return response as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> getMyEnrollments() async {
    final response = await request('/enrollments/my');
    if (response is List) {
      return response.cast<Map<String, dynamic>>();
    }
    return [];
  }

  // LMS Online Classes & Google Meet Integration
  Future<List<Map<String, dynamic>>> getClasses() async {
    final response = await request('/classes');
    if (response is List) {
      return response.cast<Map<String, dynamic>>();
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> getUpcomingClasses() async {
    final response = await request('/classes/upcoming');
    if (response is List) {
      return response.cast<Map<String, dynamic>>();
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> getCompletedClasses() async {
    final response = await request('/classes/history');
    if (response is List) {
      return response.cast<Map<String, dynamic>>();
    }
    return [];
  }

  Future<Map<String, dynamic>> createClass(Map<String, dynamic> data) async {
    final response = await request('/classes', method: 'POST', body: data);
    return response as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateClass(String id, Map<String, dynamic> data) async {
    final response = await request('/classes/$id', method: 'PUT', body: data);
    return response as Map<String, dynamic>;
  }

  Future<void> deleteClass(String id) async {
    await request('/classes/$id', method: 'DELETE');
  }

  Future<Map<String, dynamic>> joinClass(String id) async {
    final response = await request('/classes/$id/join', method: 'POST');
    return response as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> generateMeetLink([Map<String, dynamic>? data]) async {
    final response = await request('/classes/generate-meet', method: 'POST', body: data ?? {});
    return response as Map<String, dynamic>;
  }

  // LMS Assignment Management Module
  Future<List<Map<String, dynamic>>> getMyAssignments() async {
    final response = await request('/assignments/my');
    if (response is List) {
      return response.cast<Map<String, dynamic>>();
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> getInstructorAssignments() async {
    final response = await request('/assignments/instructor');
    if (response is List) {
      return response.cast<Map<String, dynamic>>();
    }
    return [];
  }

  Future<Map<String, dynamic>> createAssignmentModule(Map<String, dynamic> data) async {
    final response = await request('/assignments', method: 'POST', body: data);
    return response as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> getAssignmentSubmissions(String assignmentId) async {
    final response = await request('/assignments/$assignmentId/submissions');
    if (response is List) {
      return response.cast<Map<String, dynamic>>();
    }
    return [];
  }

  Future<Map<String, dynamic>> evaluateSubmission(String submissionId, Map<String, dynamic> data) async {
    final response = await request('/assignments/submissions/$submissionId/evaluate', method: 'POST', body: data);
    return response as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> getMyResults() async {
    final response = await request('/assignments/my-results');
    if (response is List) {
      return response.cast<Map<String, dynamic>>();
    }
    return [];
  }

  Future<Map<String, dynamic>> submitAssignmentModule(String assignmentId, Map<String, dynamic> data) async {
    final response = await request('/assignments/$assignmentId/submit', method: 'POST', body: data);
    return response as Map<String, dynamic>;
  }
}
