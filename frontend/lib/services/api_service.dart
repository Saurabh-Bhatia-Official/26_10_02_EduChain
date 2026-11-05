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

  Future<Map<String, String>> _getHeaders([Map<String, String>? customHeaders]) async {
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

  Future<dynamic> request(String endpoint, {String method = 'GET', dynamic body, Map<String, String>? headers}) async {
    final cleanEndpoint = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    final uri = Uri.parse('$_baseUrl$cleanEndpoint');
    final reqHeaders = await _getHeaders(headers);

    try {
      http.Response response;
      switch (method.toUpperCase()) {
        case 'POST':
          response = await http.post(uri, headers: reqHeaders, body: jsonEncode(body ?? {})).timeout(ApiConfig.timeoutDuration);
          break;
        case 'PUT':
          response = await http.put(uri, headers: reqHeaders, body: jsonEncode(body ?? {})).timeout(ApiConfig.timeoutDuration);
          break;
        case 'DELETE':
          response = await http.delete(uri, headers: reqHeaders).timeout(ApiConfig.timeoutDuration);
          break;
        case 'GET':
        default:
          response = await http.get(uri, headers: reqHeaders).timeout(ApiConfig.timeoutDuration);
          break;
      }

      final dynamic responseData = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (responseData is Map<String, dynamic> && responseData['success'] == false) {
          throw Exception(responseData['message'] ?? 'Request failed');
        }
        return responseData;
      } else {
        String errMsg = 'Request failed with status ${response.statusCode}';
        if (responseData is Map<String, dynamic> && responseData['message'] != null) {
          errMsg = responseData['message'];
        }
        throw Exception(errMsg);
      }
    } catch (e) {
      // If offline fallback enabled and it's a GET or offline fallback is appropriate
      if (ApiConfig.isOfflineFallbackEnabled) {
        return _handleOfflineFallback(endpoint, method: method, body: body, error: e);
      }
      rethrow;
    }
  }

  // Fallback replicating React's api.js handleOfflineFallback
  dynamic _handleOfflineFallback(String endpoint, {required String method, dynamic body, required Object error}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final bodyMap = body is Map<String, dynamic> ? body : <String, dynamic>{};

    // 1. Institute Login Fallback
    if (endpoint.contains('/auth/institute/login') ||
        (endpoint.contains('/auth/login') && bodyMap['role'] == 'institute')) {
      final code = (bodyMap['instituteCode']?.toString().isNotEmpty == true
              ? bodyMap['instituteCode'].toString()
              : 'INST-2025')
          .toUpperCase();
      return {
        'success': true,
        'token': 'mock-jwt-institute-${DateTime.now().millisecondsSinceEpoch}',
        'user': {
          'id': 'inst_$code',
          'name': 'Institute Administrator',
          'email': bodyMap['email'] ?? 'admin@apex.edu',
          'role': 'institute',
          'instituteCode': code,
          'instituteName': bodyMap['instituteName'] ??
              (code == 'INST-2025' ? 'Apex Institute of Technology' : 'Institute of Advanced Technology ($code)'),
          'isVerified': true,
          'verificationStatus': 'Officially Verified',
          'verificationId': 'VRF-${code.replaceAll(RegExp(r'[^A-Z0-9]'), '')}-2025',
          'verificationDate': 'Academic Session 2025–2026',
          'accreditation': 'AICTE & UGC Recognized • Grade A+ NAAC Accredited',
          'establishedYear': '2008',
          'campusLocation': 'Central Academic Campus',
          'studentCount': 1420,
          'facultyCount': 86,
          'departmentCount': 8,
          'activeSemester': 'Academic Year 2025–2026',
        },
        'message': 'Institute authenticated successfully.',
      };
    }

    // 2. Role-based Login Fallback
    if (endpoint.contains('/auth/login') || endpoint.contains('/auth/admin/login')) {
      final role = endpoint.contains('/auth/admin/login') ? 'admin' : (bodyMap['role']?.toString().toLowerCase() ?? 'student');
      final isStudent = role == 'student';
      final isTeacher = role == 'teacher';

      Map<String, dynamic> userObj;
      if (isStudent) {
        userObj = {
          'id': 'std_1023',
          'email': bodyMap['email'] ?? 'rahul@institute.com',
          'role': 'student',
          'name': 'Rahul Sharma',
          'rollNumber': '1023',
          'className': 'BCA - Sem 3',
          'course': 'Bachelor of Computer Applications',
          'semester': 'Semester 3',
          'instituteCode': bodyMap['instituteCode'] ?? 'INST-2025',
          'instituteName': 'Apex Institute of Technology',
          'gender': 'Male',
          'dob': '12-05-2005',
          'bloodGroup': 'B+',
          'admissionYear': '2023',
          'fatherName': 'Rakesh Sharma',
          'fatherPhone': '+91 98765 43210',
          'fatherEmail': 'rakesh@example.com',
          'motherName': 'Pooja Sharma',
          'motherPhone': '+91 98765 43211',
          'motherEmail': 'pooja@example.com',
          'address': '123, Green Park, Delhi - 110016',
        };
      } else if (isTeacher) {
        userObj = {
          'id': 'ins_001',
          'email': bodyMap['email'] ?? 'amit.sharma@institute.com',
          'role': 'teacher',
          'name': 'Dr. Amit Sharma',
          'instructorId': 'INS-001',
          'designation': 'Assistant Professor',
          'department': 'Computer Science',
          'phone': '+91 98765 43210',
          'qualification': 'Ph.D - Computer Science',
          'experience': '5 Years',
          'about':
              'Passionate educator with 5+ years of experience in teaching and research. Focused on building strong technical foundations.',
          'instituteCode': bodyMap['instituteCode'] ?? 'INST-2025',
          'instituteName': 'Apex Institute of Technology',
        };
      } else {
        userObj = {
          'id': 'adm_001',
          'email': bodyMap['email'] ?? 'amit.kumar@institute.com',
          'role': 'admin',
          'name': 'Amit Kumar',
          'designation': 'System Administrator',
          'phone': '+91 98765 43210',
          'instituteCode': bodyMap['instituteCode'] ?? 'INST-2025',
          'instituteName': 'Apex Institute of Technology',
        };
      }

      return {
        'success': true,
        'token': 'mock-jwt-$role-${DateTime.now().millisecondsSinceEpoch}',
        'user': userObj,
        'message': '$role signed in successfully.',
      };
    }

    // 3. Institute Registration Fallback
    if (endpoint.contains('/auth/register/institute')) {
      final generatedCode = 'INST-${1000 + DateTime.now().microsecond % 9000}';
      return {
        'success': true,
        'token': 'mock-jwt-institute-${DateTime.now().millisecondsSinceEpoch}',
        'user': {
          'id': 'inst_${DateTime.now().millisecondsSinceEpoch}',
          'instituteName': bodyMap['instituteName'] ?? 'Apex Institute of Technology',
          'instituteType': bodyMap['instituteType'] ?? 'College',
          'name': bodyMap['adminName'] ?? 'Institute Administrator',
          'email': bodyMap['adminEmail'] ?? bodyMap['instituteEmail'],
          'role': 'institute',
          'instituteCode': generatedCode,
          'isVerified': true,
          'verificationStatus': 'Officially Verified',
          'verificationId': 'VRF-${generatedCode.replaceAll(RegExp(r'[^A-Z0-9]'), '')}-2025',
          'verificationDate': 'Academic Session 2025–2026',
          'accreditation': 'AICTE & UGC Recognized • Grade A+ NAAC Accredited',
          'campusLocation': bodyMap['address'] ?? 'Academic Campus',
          'studentCount': 0,
          'facultyCount': 0,
          'departmentCount': 1,
        },
        'message': 'Institute account registered successfully!',
      };
    }

    // 4. Student Registration Fallback
    if (endpoint.contains('/auth/register/student')) {
      return {
        'success': true,
        'token': 'mock-jwt-student-${DateTime.now().millisecondsSinceEpoch}',
        'user': {
          'id': 'std_${DateTime.now().millisecondsSinceEpoch}',
          'name': bodyMap['fullName'] ?? bodyMap['name'],
          'email': bodyMap['email'],
          'role': 'student',
          'rollNumber': bodyMap['rollNumber'],
          'course': bodyMap['course'],
          'className': bodyMap['course'],
          'instituteCode': bodyMap['instituteCode'],
          'instituteName': 'Apex Institute of Technology',
        },
        'message': 'Student registered successfully! Verification pending.',
      };
    }

    // 5. Teacher Registration Fallback
    if (endpoint.contains('/auth/register/teacher')) {
      return {
        'success': true,
        'token': 'mock-jwt-teacher-${DateTime.now().millisecondsSinceEpoch}',
        'user': {
          'id': 'tch_${DateTime.now().millisecondsSinceEpoch}',
          'name': bodyMap['fullName'] ?? bodyMap['name'],
          'email': bodyMap['email'],
          'role': 'teacher',
          'instructorId': bodyMap['employeeId'],
          'department': bodyMap['department'],
          'instituteCode': bodyMap['instituteCode'],
          'instituteName': 'Apex Institute of Technology',
        },
        'message': 'Teacher registered successfully! Verification pending.',
      };
    }

    // 6. Forgot Password Fallback
    if (endpoint.contains('/auth/forgot-password')) {
      return {
        'success': true,
        'message': 'Password reset instructions sent to ${bodyMap['email'] ?? 'your email'}.',
      };
    }

    // 7. Students Endpoint Fallback
    if (endpoint.contains('/students')) {
      if (method == 'POST') {
        return {
          'id': 'std_${DateTime.now().millisecondsSinceEpoch}',
          'status': 'Active',
          'role': 'student',
          ...bodyMap,
        };
      }
      if (method == 'PUT') {
        final id = endpoint.split('/').last;
        return {'id': id, ...bodyMap};
      }
      if (method == 'DELETE') {
        return {'success': true, 'message': 'Student deleted successfully'};
      }
      return [
        {
          'id': '1',
          'name': 'Rahul Sharma',
          'email': 'rahul.sharma@example.com',
          'rollNumber': 'BCA-301',
          'className': 'BCA - Sem 3',
          'course': 'BCA',
          'department': 'Computer Science',
          'semester': '3',
          'phone': '+91 98765 43210',
          'address': '123 Green Park, Delhi',
          'fatherName': 'Rajesh Sharma',
          'fatherPhone': '+91 98765 43210',
          'status': 'Active'
        },
        {
          'id': '2',
          'name': 'Priya Singh',
          'email': 'priya.singh@example.com',
          'rollNumber': 'BCA-302',
          'className': 'BCA - Sem 3',
          'course': 'BCA',
          'department': 'Computer Science',
          'semester': '3',
          'phone': '+91 98765 43212',
          'address': '45 Lake View, Delhi',
          'fatherName': 'Manoj Singh',
          'fatherPhone': '+91 98765 43212',
          'status': 'Active'
        },
        {
          'id': '3',
          'name': 'Amit Kumar',
          'email': 'amit.kumar@example.com',
          'rollNumber': 'BCA-303',
          'className': 'BCA - Sem 3',
          'course': 'BCA',
          'department': 'Computer Science',
          'semester': '3',
          'phone': '+91 98765 43214',
          'address': '78 Sector 15, Delhi',
          'fatherName': 'Suresh Kumar',
          'fatherPhone': '+91 98765 43214',
          'status': 'Active'
        }
      ];
    }

    // 8. Instructors Endpoint Fallback
    if (endpoint.contains('/instructors')) {
      if (method == 'POST') {
        return {
          'id': 'ins_${DateTime.now().millisecondsSinceEpoch}',
          'status': 'Active',
          'role': 'teacher',
          ...bodyMap,
        };
      }
      if (method == 'PUT') {
        final id = endpoint.split('/').last;
        return {'id': id, ...bodyMap};
      }
      if (method == 'DELETE') {
        return {'success': true, 'message': 'Instructor deleted successfully'};
      }
      return [
        {
          'id': '1',
          'name': 'Dr. Amit Sharma',
          'email': 'amit.sharma@institute.com',
          'instructorId': 'INS-001',
          'department': 'Computer Science',
          'designation': 'Assistant Professor',
          'phone': '+91 98765 43210',
          'qualification': 'Ph.D - Computer Science',
          'experience': '5 Years',
          'status': 'Active'
        },
        {
          'id': '2',
          'name': 'Prof. Sunita Rao',
          'email': 'sunita.rao@institute.com',
          'instructorId': 'INS-002',
          'department': 'Mathematics',
          'designation': 'Associate Professor',
          'phone': '+91 98765 43218',
          'qualification': 'M.Sc, M.Phil - Applied Maths',
          'experience': '8 Years',
          'status': 'Active'
        }
      ];
    }

    // 9. Dashboard Fallback
    if (endpoint.contains('/dashboard/admin')) {
      return {
        'totalStudents': 3,
        'totalInstructors': 2,
        'totalInstitutes': 1,
        'activeClasses': 18,
        'attendanceRate': 92.4,
        'systemStatus': 'Healthy & Connected',
        'recentStudents': [],
        'recentInstructors': []
      };
    }

    if (endpoint.contains('/dashboard/instructor')) {
      return {
        'assignedCourses': 4,
        'totalStudents': 48,
        'upcomingLectures': 3,
        'pendingAssignments': 12,
        'averageClassRating': 4.8,
        'enrolledStudents': []
      };
    }

    throw error;
  }

  // Auth Operations
  Future<Map<String, dynamic>> loginInstitute({required String instituteCode, required String email, required String password}) async {
    final res = await request('/auth/institute/login', method: 'POST', body: {
      'instituteCode': instituteCode,
      'email': email,
      'password': password,
      'role': 'institute',
    });
    if (res is Map<String, dynamic>) {
      if (res['token'] != null) await StorageService.saveToken(res['token'].toString());
      if (res['user'] != null) await StorageService.saveUser(UserModel.fromJson(res['user']));
      return res;
    }
    return {'success': true};
  }

  Future<Map<String, dynamic>> loginAdmin({required String email, required String password, String? instituteCode}) async {
    final res = await request('/auth/admin/login', method: 'POST', body: {
      'email': email,
      'password': password,
      'role': 'admin',
      'instituteCode': instituteCode ?? 'INST-2025',
    });
    if (res is Map<String, dynamic>) {
      if (res['token'] != null) await StorageService.saveToken(res['token'].toString());
      if (res['user'] != null) await StorageService.saveUser(UserModel.fromJson(res['user']));
      return res;
    }
    return {'success': true};
  }

  Future<Map<String, dynamic>> loginRole({required String email, required String password, required String role, String? instituteCode}) async {
    if (role == 'admin') {
      return loginAdmin(email: email, password: password, instituteCode: instituteCode);
    }
    if (role == 'institute') {
      return loginInstitute(instituteCode: instituteCode ?? 'INST-2025', email: email, password: password);
    }
    final res = await request('/auth/login', method: 'POST', body: {
      'email': email,
      'password': password,
      'role': role,
      'instituteCode': instituteCode ?? 'INST-2025',
    });
    if (res is Map<String, dynamic>) {
      if (res['token'] != null) await StorageService.saveToken(res['token'].toString());
      if (res['user'] != null) await StorageService.saveUser(UserModel.fromJson(res['user']));
      return res;
    }
    return {'success': true};
  }

  Future<Map<String, dynamic>> registerInstitute(Map<String, dynamic> data) async {
    final res = await request('/auth/register/institute', method: 'POST', body: data);
    if (res is Map<String, dynamic>) {
      if (res['token'] != null) await StorageService.saveToken(res['token'].toString());
      if (res['user'] != null) await StorageService.saveUser(UserModel.fromJson(res['user']));
      return res;
    }
    return {'success': true};
  }

  Future<Map<String, dynamic>> registerStudent(Map<String, dynamic> data) async {
    final res = await request('/auth/register/student', method: 'POST', body: data);
    if (res is Map<String, dynamic>) {
      if (res['token'] != null) await StorageService.saveToken(res['token'].toString());
      if (res['user'] != null) await StorageService.saveUser(UserModel.fromJson(res['user']));
      return res;
    }
    return {'success': true};
  }

  Future<Map<String, dynamic>> registerTeacher(Map<String, dynamic> data) async {
    final res = await request('/auth/register/teacher', method: 'POST', body: data);
    if (res is Map<String, dynamic>) {
      if (res['token'] != null) await StorageService.saveToken(res['token'].toString());
      if (res['user'] != null) await StorageService.saveUser(UserModel.fromJson(res['user']));
      return res;
    }
    return {'success': true};
  }

  Future<Map<String, dynamic>> forgotPassword({required String email, required String role}) async {
    final res = await request('/auth/forgot-password', method: 'POST', body: {'email': email, 'role': role});
    return res is Map<String, dynamic> ? res : {'success': true, 'message': 'Instructions sent'};
  }

  Future<void> logout() async {
    await StorageService.clearSession();
  }

  // Student CRUD
  Future<List<StudentModel>> getStudents([String search = '']) async {
    final endpoint = '/students${search.isNotEmpty ? '?search=${Uri.encodeComponent(search)}' : ''}';
    final res = await request(endpoint);
    if (res is List) {
      return res.map((item) => StudentModel.fromJson(item as Map<String, dynamic>)).toList();
    }
    if (res is Map<String, dynamic> && res['data'] is List) {
      return (res['data'] as List).map((item) => StudentModel.fromJson(item as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<StudentModel> getStudentById(String id) async {
    final res = await request('/students/$id');
    return StudentModel.fromJson(res as Map<String, dynamic>);
  }

  Future<StudentModel> createStudent(StudentModel student) async {
    final res = await request('/students', method: 'POST', body: student.toJson());
    return StudentModel.fromJson(res as Map<String, dynamic>);
  }

  Future<StudentModel> updateStudent(String id, StudentModel student) async {
    final res = await request('/students/$id', method: 'PUT', body: student.toJson());
    return StudentModel.fromJson(res as Map<String, dynamic>);
  }

  Future<void> deleteStudent(String id) async {
    await request('/students/$id', method: 'DELETE');
  }

  // Instructor CRUD
  Future<List<InstructorModel>> getInstructors([String search = '']) async {
    final endpoint = '/instructors${search.isNotEmpty ? '?search=${Uri.encodeComponent(search)}' : ''}';
    final res = await request(endpoint);
    if (res is List) {
      return res.map((item) => InstructorModel.fromJson(item as Map<String, dynamic>)).toList();
    }
    if (res is Map<String, dynamic> && res['data'] is List) {
      return (res['data'] as List).map((item) => InstructorModel.fromJson(item as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<InstructorModel> getInstructorById(String id) async {
    final res = await request('/instructors/$id');
    return InstructorModel.fromJson(res as Map<String, dynamic>);
  }

  Future<InstructorModel> createInstructor(InstructorModel instructor) async {
    final res = await request('/instructors', method: 'POST', body: instructor.toJson());
    return InstructorModel.fromJson(res as Map<String, dynamic>);
  }

  Future<InstructorModel> updateInstructor(String id, InstructorModel instructor) async {
    final res = await request('/instructors/$id', method: 'PUT', body: instructor.toJson());
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

  Future<InstructorDashboardStatsModel> getInstructorDashboardStats(String id) async {
    final res = await request('/dashboard/instructor/$id');
    return InstructorDashboardStatsModel.fromJson(res as Map<String, dynamic>);
  }
}

