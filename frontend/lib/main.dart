import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'constants/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/navigation_provider.dart';
import 'providers/student_provider.dart';
import 'providers/instructor_provider.dart';

import 'screens/home/home_screen.dart';
import 'screens/home/institute_home_screen.dart';
import 'screens/auth/institute_login_screen.dart';
import 'screens/auth/institute_registration_screen.dart';
import 'screens/auth/select_role_screen.dart';
import 'screens/auth/student_login_screen.dart';
import 'screens/auth/teacher_login_screen.dart';
import 'screens/auth/admin_login_screen.dart';
import 'screens/auth/student_registration_screen.dart';
import 'screens/auth/teacher_registration_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/student/student_portal_screen.dart';
import 'screens/teacher/teacher_portal_screen.dart';
import 'screens/admin/admin_portal_screen.dart';
import 'screens/crud/students_crud_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const EduChainApp());
}

class EduChainApp extends StatelessWidget {
  const EduChainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..initAuth()),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(create: (_) => StudentProvider()),
        ChangeNotifierProvider(create: (_) => InstructorProvider()),
      ],
      child: MaterialApp(
        title: 'EduChain - One Platform, Endless Possibilities',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const AppRootView(),
      ),
    );
  }
}

class AppRootView extends StatelessWidget {
  const AppRootView({super.key});

  @override
  Widget build(BuildContext context) {
    final nav = Provider.of<NavigationProvider>(context);
    final auth = Provider.of<AuthProvider>(context);
    final currentPage = nav.currentPage;

    final portalRole = currentPage == 'student-portal'
        ? 'student'
        : currentPage == 'teacher-portal'
        ? 'teacher'
        : currentPage == 'admin-portal' || currentPage == 'students-crud'
        ? 'admin'
        : null;
    if (portalRole != null) {
      if (auth.isLoading) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      if (!auth.isAuthenticated) {
        if (portalRole == 'student') return const StudentLoginScreen();
        if (portalRole == 'teacher') return const TeacherLoginScreen();
        return const AdminLoginScreen();
      }
      if (auth.currentUser?.role != portalRole) {
        final actualRole = auth.currentUser?.role;
        if (actualRole == 'student' ||
            actualRole == 'teacher' ||
            actualRole == 'admin') {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            nav.navigateTo('$actualRole-dashboard');
          });
        } else {
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => nav.navigateTo('home'),
          );
        }
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
    }

    // Direct Portal Views (Fullscreen with their own navigation and sidebars)
    if (currentPage == 'student-portal') {
      return StudentPortalScreen(
        initialTab: nav.currentTab ?? 'dashboard',
        initialTargetId: nav.pageParams['targetId']?.toString(),
      );
    }
    if (currentPage == 'teacher-portal') {
      return TeacherPortalScreen(
        initialTab: nav.currentTab ?? 'dashboard',
        initialTargetId: nav.pageParams['targetId']?.toString(),
      );
    }
    if (currentPage == 'admin-portal') {
      return AdminPortalScreen(
        initialTab: nav.currentTab ?? 'dashboard',
        initialTargetId: nav.pageParams['targetId']?.toString(),
      );
    }
    if (currentPage == 'institute-home') {
      return const InstituteHomeScreen();
    }
    if (currentPage == 'institute-login') {
      return const InstituteLoginScreen();
    }
    if (currentPage == 'institute-register') {
      return const InstituteRegistrationScreen();
    }
    if (currentPage == 'select-role') {
      final mode = nav.pageParams['mode']?.toString() ?? 'login';
      return SelectRoleScreen(initialMode: mode);
    }
    if (currentPage == 'student-login') {
      return const StudentLoginScreen();
    }
    if (currentPage == 'teacher-login') {
      return const TeacherLoginScreen();
    }
    if (currentPage == 'admin-login') {
      return const AdminLoginScreen();
    }
    if (currentPage == 'student-register') {
      return const StudentRegistrationScreen();
    }
    if (currentPage == 'teacher-register') {
      return const TeacherRegistrationScreen();
    }
    if (currentPage == 'forgot-password') {
      final role = nav.pageParams['role']?.toString() ?? 'student';
      return ForgotPasswordScreen(initialRole: role);
    }
    if (currentPage == 'students-crud') {
      return const StudentsCrudScreen();
    }

    // Default: Public Home Page with Navbar and Footer
    return const Scaffold(body: HomeScreen());
  }
}
