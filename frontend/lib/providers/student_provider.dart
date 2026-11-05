import 'package:flutter/material.dart';
import '../models/student_model.dart';
import '../services/api_service.dart';

class StudentProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<StudentModel> _students = [];
  StudentModel? _selectedStudent;
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';

  List<StudentModel> get students => _students;
  StudentModel? get selectedStudent => _selectedStudent;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;

  Future<void> fetchStudents([String query = '']) async {
    _isLoading = true;
    _errorMessage = null;
    _searchQuery = query;
    notifyListeners();
    try {
      _students = await _apiService.getStudents(query);
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSelectedStudent(StudentModel? student) {
    _selectedStudent = student;
    notifyListeners();
  }

  Future<bool> addStudent(StudentModel student) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final created = await _apiService.createStudent(student);
      _students.insert(0, created);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateStudent(String id, StudentModel student) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final updated = await _apiService.updateStudent(id, student);
      final index = _students.indexWhere((s) => s.id == id);
      if (index != -1) {
        _students[index] = updated;
      }
      if (_selectedStudent?.id == id) {
        _selectedStudent = updated;
      }
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteStudent(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _apiService.deleteStudent(id);
      _students.removeWhere((s) => s.id == id);
      if (_selectedStudent?.id == id) {
        _selectedStudent = null;
      }
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

