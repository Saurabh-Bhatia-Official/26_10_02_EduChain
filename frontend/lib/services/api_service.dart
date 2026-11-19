import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/user_model.dart';
import '../models/student_model.dart';
import '../models/instructor_model.dart';
import '../models/dashboard_stats_model.dart';
import 'storage_service.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

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

    try {
      http.Response response;
      switch (method.toUpperCase()) {
        case 'POST':
          response = await http
              .post(uri, headers: reqHeaders, body: jsonEncode(body ?? {}))
              .timeout(ApiConfig.timeoutDuration);
          break;
        case 'PUT':
          response = await http
              .put(uri, headers: reqHeaders, body: jsonEncode(body ?? {}))
              .timeout(ApiConfig.timeoutDuration);
          break;
        case 'DELETE':
          response = await http
              .delete(uri, headers: reqHeaders)
              .timeout(ApiConfig.timeoutDuration);
          break;
        case 'GET':
        default:
          response = await http
              .get(uri, headers: reqHeaders)
              .timeout(ApiConfig.timeoutDuration);
          break;
      }

      final dynamic responseData = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (responseData is Map<String, dynamic> &&
            responseData['success'] == false) {
          throw Exception(responseData['message'] ?? 'Request failed');
        }
        return responseData;
      } else {
        String errMsg = 'Request failed with status ${response.statusCode}';
        if (responseData is Map<String, dynamic> &&
            responseData['message'] != null) {
          errMsg = responseData['message'];
        }
        throw Exception(errMsg);
      }
    } catch (_) {
      rethrow;
    }
  }

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
      if (res['token'] != null)
        await StorageService.saveToken(res['token'].toString());
      if (res['user'] != null)
        await StorageService.saveUser(UserModel.fromJson(res['user']));
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
        'instituteCode': instituteCode ?? 'INST-2025',
      },
    );
    if (res is Map<String, dynamic>) {
      if (res['token'] != null)
        await StorageService.saveToken(res['token'].toString());
      if (res['user'] != null)
        await StorageService.saveUser(UserModel.fromJson(res['user']));
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
        instituteCode: instituteCode ?? 'INST-2025',
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
        'instituteCode': instituteCode ?? 'INST-2025',
      },
    );
    if (res is Map<String, dynamic>) {
      if (res['token'] != null)
        await StorageService.saveToken(res['token'].toString());
      if (res['user'] != null)
        await StorageService.saveUser(UserModel.fromJson(res['user']));
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
      if (res['token'] != null)
        await StorageService.saveToken(res['token'].toString());
      if (res['user'] != null)
        await StorageService.saveUser(UserModel.fromJson(res['user']));
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
      if (res['token'] != null)
        await StorageService.saveToken(res['token'].toString());
      if (res['user'] != null)
        await StorageService.saveUser(UserModel.fromJson(res['user']));
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
      if (res['token'] != null)
        await StorageService.saveToken(res['token'].toString());
      if (res['user'] != null)
        await StorageService.saveUser(UserModel.fromJson(res['user']));
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
}
