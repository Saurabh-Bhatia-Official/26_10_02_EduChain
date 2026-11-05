import 'package:flutter/material.dart';

class NavigationProvider with ChangeNotifier {
  String _currentPage = 'home';
  String? _currentTab;
  Map<String, dynamic> _pageParams = {};

  String get currentPage => _currentPage;
  String? get currentTab => _currentTab;
  Map<String, dynamic> get pageParams => _pageParams;

  void navigateTo(String page, [Map<String, dynamic>? params]) {
    String targetPage = page;
    if (page == 'login') {
      final role = params?['role'];
      if (role == 'admin') {
        targetPage = 'admin-login';
      } else if (role == 'teacher') {
        targetPage = 'teacher-login';
      } else if (role == 'student') {
        targetPage = 'student-login';
      } else if (role == 'institute') {
        targetPage = 'institute-login';
      } else {
        targetPage = 'select-role';
      }
    } else if (page == 'register') {
      final role = params?['role'];
      if (role == 'teacher') {
        targetPage = 'teacher-register';
      } else if (role == 'student') {
        targetPage = 'student-register';
      } else if (role == 'institute' || role == 'admin') {
        targetPage = 'institute-register';
      } else {
        targetPage = 'select-role';
      }
    }

    // Check if navigating to a portal tab
    if (targetPage.startsWith('student-') &&
        targetPage != 'student-login' &&
        targetPage != 'student-register') {
      _currentTab = targetPage.replaceFirst('student-', '');
      _currentPage = 'student-portal';
    } else if ((targetPage.startsWith('teacher-') || targetPage.startsWith('instructor-')) &&
        targetPage != 'teacher-login' &&
        targetPage != 'teacher-register') {
      _currentTab = targetPage.replaceFirst('teacher-', '').replaceFirst('instructor-', '');
      _currentPage = 'teacher-portal';
    } else if (targetPage.startsWith('admin-') && targetPage != 'admin-login') {
      _currentTab = targetPage.replaceFirst('admin-', '');
      _currentPage = 'admin-portal';
    } else {
      _currentPage = targetPage;
      _currentTab = null;
    }

    _pageParams = params ?? {};
    notifyListeners();
  }

  void setPortalTab(String tab) {
    _currentTab = tab;
    notifyListeners();
  }
}

