import 'package:material_ui/material_ui.dart';

class NavigationProvider with ChangeNotifier {
  String _currentPage = 'home';
  String? _currentTab;
  Map<String, dynamic> _pageParams = {};
  String _activeSection = 'home';
  String? _targetSection;

  String get currentPage => _currentPage;
  String? get currentTab => _currentTab;
  Map<String, dynamic> get pageParams => _pageParams;
  String get activeSection => _activeSection;
  String? get targetSection => _targetSection;

  void scrollToSection(String sectionId) {
    _activeSection = sectionId;
    _targetSection = sectionId;
    if (_currentPage != 'home') {
      _currentPage = 'home';
      _currentTab = null;
    }
    notifyListeners();
  }

  void setActiveSection(String sectionId) {
    if (_activeSection != sectionId) {
      _activeSection = sectionId;
      notifyListeners();
    }
  }

  void clearTargetSection() {
    _targetSection = null;
  }

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

