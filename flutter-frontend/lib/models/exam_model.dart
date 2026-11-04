class ExamModel {
  final String id;
  final String title;
  final String courseCode;
  final String courseName;
  final String date;
  final String time;
  final String room;
  final int durationMinutes;
  final int totalMarks;
  final String status; // 'Upcoming', 'Live', 'Completed'
  final String? syllabus;
  final int? score;

  ExamModel({
    required this.id,
    required this.title,
    required this.courseCode,
    required this.courseName,
    required this.date,
    required this.time,
    required this.room,
    required this.durationMinutes,
    required this.totalMarks,
    this.status = 'Upcoming',
    this.syllabus,
    this.score,
  });

  factory ExamModel.fromJson(Map<String, dynamic> json) {
    return ExamModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Examination',
      courseCode: json['courseCode']?.toString() ?? 'CS-301',
      courseName: json['courseName']?.toString() ?? 'Database Management Systems',
      date: json['date']?.toString() ?? 'May 10, 2025',
      time: json['time']?.toString() ?? '09:00 AM - 12:00 PM',
      room: json['room']?.toString() ?? 'Hall 101',
      durationMinutes: (json['durationMinutes'] as num?)?.toInt() ?? 180,
      totalMarks: (json['totalMarks'] as num?)?.toInt() ?? 100,
      status: json['status']?.toString() ?? 'Upcoming',
      syllabus: json['syllabus']?.toString() ?? 'Units 1 to 4: ER Diagrams, SQL, Relational Algebra, Normalization',
      score: (json['score'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'courseCode': courseCode,
      'courseName': courseName,
      'date': date,
      'time': time,
      'room': room,
      'durationMinutes': durationMinutes,
      'totalMarks': totalMarks,
      'status': status,
      'syllabus': syllabus,
      if (score != null) 'score': score,
    };
  }
}

