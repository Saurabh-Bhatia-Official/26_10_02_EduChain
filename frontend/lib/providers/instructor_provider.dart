import 'package:flutter/material.dart';
import '../models/instructor_model.dart';
import '../services/api_service.dart';

class InstructorProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<InstructorModel> _instructors = [];
  InstructorModel? _selectedInstructor;
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';

  List<InstructorModel> get instructors => _instructors;
  InstructorModel? get selectedInstructor => _selectedInstructor;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;

  Future<void> fetchInstructors([String query = '']) async {
    _isLoading = true;
    _errorMessage = null;
    _searchQuery = query;
    notifyListeners();
    try {
      _instructors = await _apiService.getInstructors(query);
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSelectedInstructor(InstructorModel? instructor) {
    _selectedInstructor = instructor;
    notifyListeners();
  }

  Future<bool> addInstructor(InstructorModel instructor) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final created = await _apiService.createInstructor(instructor);
      _instructors.insert(0, created);
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

  Future<bool> updateInstructor(String id, InstructorModel instructor) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final updated = await _apiService.updateInstructor(id, instructor);
      final index = _instructors.indexWhere((i) => i.id == id);
      if (index != -1) {
        _instructors[index] = updated;
      }
      if (_selectedInstructor?.id == id) {
        _selectedInstructor = updated;
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

  Future<bool> deleteInstructor(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _apiService.deleteInstructor(id);
      _instructors.removeWhere((i) => i.id == id);
      if (_selectedInstructor?.id == id) {
        _selectedInstructor = null;
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

