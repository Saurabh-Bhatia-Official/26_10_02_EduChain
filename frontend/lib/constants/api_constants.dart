import '../config/api_config.dart';

/// Central API Constants for the EduChain Flutter application.
/// Provides direct references to both Localhost and Production endpoints.
class ApiConstants {
  // Predefined URLs
  static const String localhostBaseUrl = ApiConfig.localhostBaseUrl;
  static const String localhostRootUrl = ApiConfig.localhostRootUrl;
  static const String androidEmulatorBaseUrl = ApiConfig.androidEmulatorBaseUrl;
  static const String productionBaseUrl = ApiConfig.productionBaseUrl;
  static const String productionRootUrl = ApiConfig.productionRootUrl;

  // Active Dynamic URL
  static String get baseUrl => ApiConfig.baseUrl;
  static String get rootUrl => ApiConfig.rootUrl;
  static bool get isProduction => ApiConfig.isProduction;

  // Common API Endpoints
  static const String authLogin = '/auth/login';
  static const String authAdminLogin = '/auth/admin/login';
  static const String authInstituteLogin = '/auth/institute/login';
  static const String authRegisterStudent = '/auth/register/student';
  static const String authRegisterTeacher = '/auth/register/teacher';
  static const String authRegisterInstitute = '/auth/register/institute';
  static const String authForgotPassword = '/auth/forgot-password';

  static const String databaseHealth = '/db/health';
  static const String databaseConsole = '/db/console';

  static const String students = '/students';
  static const String instructors = '/instructors';
  static const String courses = '/courses';
  static const String batches = '/batches';
  static const String classrooms = '/classrooms';
  static const String assignments = '/assignments';
  static const String exams = '/portal/exams';
  static const String announcements = '/portal/announcements';
  static const String leaves = '/portal/leaves';
  static const String liveClasses = '/live-classes';
  static const String adminDashboard = '/dashboard/admin';
}
