import 'student_model.dart';
import 'instructor_model.dart';

class AdminDashboardStatsModel {
  final int totalStudents;
  final int totalInstructors;
  final int totalInstitutes;
  final int activeClasses;
  final double attendanceRate;
  final String systemStatus;
  final List<StudentModel> recentStudents;
  final List<InstructorModel> recentInstructors;

  AdminDashboardStatsModel({
    required this.totalStudents,
    required this.totalInstructors,
    required this.totalInstitutes,
    required this.activeClasses,
    required this.attendanceRate,
    required this.systemStatus,
    this.recentStudents = const [],
    this.recentInstructors = const [],
  });

  factory AdminDashboardStatsModel.fromJson(Map<String, dynamic> json) {
    List<StudentModel> students = [];
    if (json['recentStudents'] is List) {
      students = (json['recentStudents'] as List)
          .map((item) => StudentModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    List<InstructorModel> instructors = [];
    if (json['recentInstructors'] is List) {
      instructors = (json['recentInstructors'] as List)
          .map((item) => InstructorModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return AdminDashboardStatsModel(
      totalStudents: (json['totalStudents'] as num?)?.toInt() ?? 0,
      totalInstructors: (json['totalInstructors'] as num?)?.toInt() ?? 0,
      totalInstitutes: (json['totalInstitutes'] as num?)?.toInt() ?? 1,
      activeClasses: (json['activeClasses'] as num?)?.toInt() ?? 18,
      attendanceRate: (json['attendanceRate'] as num?)?.toDouble() ?? 92.4,
      systemStatus: json['systemStatus']?.toString() ?? 'Healthy & Connected',
      recentStudents: students,
      recentInstructors: instructors,
    );
  }
}

class InstructorDashboardStatsModel {
  final int assignedCourses;
  final int totalStudents;
  final int upcomingLectures;
  final int pendingAssignments;
  final double averageClassRating;
  final List<StudentModel> enrolledStudents;

  InstructorDashboardStatsModel({
    required this.assignedCourses,
    required this.totalStudents,
    required this.upcomingLectures,
    required this.pendingAssignments,
    required this.averageClassRating,
    this.enrolledStudents = const [],
  });

  factory InstructorDashboardStatsModel.fromJson(Map<String, dynamic> json) {
    List<StudentModel> students = [];
    if (json['enrolledStudents'] is List) {
      students = (json['enrolledStudents'] as List)
          .map((item) => StudentModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return InstructorDashboardStatsModel(
      assignedCourses: (json['assignedCourses'] as num?)?.toInt() ?? 4,
      totalStudents: (json['totalStudents'] as num?)?.toInt() ?? 0,
      upcomingLectures: (json['upcomingLectures'] as num?)?.toInt() ?? 3,
      pendingAssignments: (json['pendingAssignments'] as num?)?.toInt() ?? 12,
      averageClassRating: (json['averageClassRating'] as num?)?.toDouble() ?? 4.8,
      enrolledStudents: students,
    );
  }
}

