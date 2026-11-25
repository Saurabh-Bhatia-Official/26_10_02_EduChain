class LectureModel {
  final String id;
  final String title;
  final String courseCode;
  final String courseName;
  final String date;
  final String time;
  final String room;
  final String status; // 'Scheduled', 'In Progress', 'Completed'
  final String topic;
  final String? materialsUrl;

  LectureModel({
    required this.id,
    required this.title,
    required this.courseCode,
    required this.courseName,
    required this.date,
    required this.time,
    required this.room,
    this.status = 'Scheduled',
    required this.topic,
    this.materialsUrl,
  });

  factory LectureModel.fromJson(Map<String, dynamic> json) {
    return LectureModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Lecture',
      courseCode: json['courseCode']?.toString() ?? 'CS-301',
      courseName: json['courseName']?.toString() ?? 'Database Systems',
      date: json['date']?.toString() ?? 'May 04, 2025',
      time: json['time']?.toString() ?? '10:00 AM - 11:30 AM',
      room: json['room']?.toString() ?? 'Hall 302',
      status: json['status']?.toString() ?? 'Scheduled',
      topic: json['topic']?.toString() ?? 'Relational Schema & Normalization',
      materialsUrl: json['materialsUrl']?.toString(),
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
      'status': status,
      'topic': topic,
      'materialsUrl': materialsUrl,
    };
  }
}

