import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  bool get isAuthenticated => _currentUser != null;
  bool get isInstitute => _currentUser?.role == 'institute';
  bool get isAdmin => _currentUser?.role == 'admin';
  bool get isTeacher => _currentUser?.role == 'teacher';
  bool get isStudent => _currentUser?.role == 'student';

  Future<void> initAuth() async {
    _isLoading = true;
    notifyListeners();
    try {
      _currentUser = await StorageService.getUser();
    } catch (_) {
      _currentUser = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setCurrentUser(UserModel? user) {
    _currentUser = user;
    if (user != null) {
      StorageService.saveUser(user);
    }
    notifyListeners();
  }

  Future<bool> loginInstitute({
    required String instituteCode,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final res = await _apiService.loginInstitute(
        instituteCode: instituteCode,
        email: email,
        password: password,
      );
      if (res['user'] != null) {
        _currentUser = UserModel.fromJson(res['user']);
        notifyListeners();
        return true;
      }
      throw Exception(res['message'] ?? 'Authentication failed');
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> loginRole({
    required String email,
    required String password,
    required String role,
    String? instituteCode,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final res = await _apiService.loginRole(
        email: email,
        password: password,
        role: role,
        instituteCode: instituteCode,
      );
      if (res['user'] != null) {
        _currentUser = UserModel.fromJson(res['user']);
        notifyListeners();
        return true;
      }
      throw Exception(res['message'] ?? 'Authentication failed');
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> registerInstitute(Map<String, dynamic> data) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final res = await _apiService.registerInstitute(data);
      if (res['user'] != null) {
        _currentUser = UserModel.fromJson(res['user']);
        notifyListeners();
        return true;
      }
      throw Exception(res['message'] ?? 'Registration failed');
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> registerStudent(Map<String, dynamic> data) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final res = await _apiService.registerStudent(data);
      if (res['user'] != null) {
        _currentUser = UserModel.fromJson(res['user']);
        notifyListeners();
        return true;
      }
      throw Exception(res['message'] ?? 'Registration failed');
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> registerTeacher(Map<String, dynamic> data) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final res = await _apiService.registerTeacher(data);
      if (res['user'] != null) {
        _currentUser = UserModel.fromJson(res['user']);
        notifyListeners();
        return true;
      }
      throw Exception(res['message'] ?? 'Registration failed');
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String> forgotPassword({required String email, required String role}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final res = await _apiService.forgotPassword(email: email, role: role);
      return res['message'] ?? 'Reset instructions sent successfully.';
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _apiService.logout();
    _currentUser = null;
    notifyListeners();
  }
}

