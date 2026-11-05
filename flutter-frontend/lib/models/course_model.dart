class CourseModel {
  final String id;
  final String code;
  final String name;
  final String department;
  final int credits;
  final String semester;
  final int studentsEnrolled;
  final double progress;
  final String status;
  final String instructor;

  CourseModel({
    required this.id,
    required this.code,
    required this.name,
    required this.department,
    required this.credits,
    required this.semester,
    required this.studentsEnrolled,
    required this.progress,
    this.status = 'Active',
    this.instructor = 'Dr. Amit Sharma',
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['id']?.toString() ?? '',
      code: json['code']?.toString() ?? 'CS-101',
      name: json['name']?.toString() ?? 'Course Name',
      department: json['department']?.toString() ?? 'Computer Science',
      credits: (json['credits'] as num?)?.toInt() ?? 4,
      semester: json['semester']?.toString() ?? 'Semester 3',
      studentsEnrolled: (json['studentsEnrolled'] as num?)?.toInt() ?? 48,
      progress: (json['progress'] as num?)?.toDouble() ?? 0.65,
      status: json['status']?.toString() ?? 'Active',
      instructor: json['instructor']?.toString() ?? 'Dr. Amit Sharma',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'department': department,
      'credits': credits,
      'semester': semester,
      'studentsEnrolled': studentsEnrolled,
      'progress': progress,
      'status': status,
      'instructor': instructor,
    };
  }
}

