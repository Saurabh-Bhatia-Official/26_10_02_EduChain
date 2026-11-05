import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_frontend/providers/navigation_provider.dart';

void main() {
  group('NavigationProvider Route Resolution Tests', () {
    test('Initial page is home', () {
      final nav = NavigationProvider();
      expect(nav.currentPage, 'home');
      expect(nav.currentTab, isNull);
    });

    test('Navigate to login routes by role', () {
      final nav = NavigationProvider();
      nav.navigateTo('login', {'role': 'student'});
      expect(nav.currentPage, 'student-login');

      nav.navigateTo('login', {'role': 'teacher'});
      expect(nav.currentPage, 'teacher-login');

      nav.navigateTo('login', {'role': 'admin'});
      expect(nav.currentPage, 'admin-login');

      nav.navigateTo('login', {'role': 'institute'});
      expect(nav.currentPage, 'institute-login');

      nav.navigateTo('login');
      expect(nav.currentPage, 'select-role');
    });

    test('Navigate to registration routes by role', () {
      final nav = NavigationProvider();
      nav.navigateTo('register', {'role': 'student'});
      expect(nav.currentPage, 'student-register');

      nav.navigateTo('register', {'role': 'teacher'});
      expect(nav.currentPage, 'teacher-register');

      nav.navigateTo('register', {'role': 'institute'});
      expect(nav.currentPage, 'institute-register');
    });

    test('Portal tabs routing', () {
      final nav = NavigationProvider();
      nav.navigateTo('student-dashboard');
      expect(nav.currentPage, 'student-portal');
      expect(nav.currentTab, 'dashboard');

      nav.navigateTo('student-grades');
      expect(nav.currentPage, 'student-portal');
      expect(nav.currentTab, 'grades');

      nav.navigateTo('teacher-classes');
      expect(nav.currentPage, 'teacher-portal');
      expect(nav.currentTab, 'classes');

      nav.navigateTo('admin-student-records');
      expect(nav.currentPage, 'admin-portal');
      expect(nav.currentTab, 'student-records');
    });
  });
}

