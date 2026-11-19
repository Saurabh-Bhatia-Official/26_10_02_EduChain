class LectureSlotModel {
  final String id;
  final String day;
  final String timeSlot;
  final String subject;
  final String subjectCode;
  final String instructor;
  final String room;
  final String className;
  final String semester;
  final String status;

  LectureSlotModel({
    required this.id,
    required this.day,
    required this.timeSlot,
    required this.subject,
    required this.subjectCode,
    required this.instructor,
    required this.room,
    required this.className,
    required this.semester,
    this.status = 'Scheduled',
  });

  LectureSlotModel copyWith({
    String? id,
    String? day,
    String? timeSlot,
    String? subject,
    String? subjectCode,
    String? instructor,
    String? room,
    String? className,
    String? semester,
    String? status,
  }) {
    return LectureSlotModel(
      id: id ?? this.id,
      day: day ?? this.day,
      timeSlot: timeSlot ?? this.timeSlot,
      subject: subject ?? this.subject,
      subjectCode: subjectCode ?? this.subjectCode,
      instructor: instructor ?? this.instructor,
      room: room ?? this.room,
      className: className ?? this.className,
      semester: semester ?? this.semester,
      status: status ?? this.status,
    );
  }

  factory LectureSlotModel.fromJson(Map<String, dynamic> json) {
    return LectureSlotModel(
      id: json['id']?.toString() ?? '',
      day: json['day']?.toString() ?? 'Mon',
      timeSlot: json['timeSlot']?.toString() ?? '09:00 AM - 10:00 AM',
      subject: json['subject']?.toString() ?? '',
      subjectCode: json['subjectCode']?.toString() ?? '',
      instructor: json['instructor']?.toString() ?? '',
      room: json['room']?.toString() ?? '',
      className:
          json['className']?.toString() ??
          json['class']?.toString() ??
          'BCA-301',
      semester: json['semester']?.toString() ?? '3',
      status: json['status']?.toString() ?? 'Scheduled',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'day': day,
      'timeSlot': timeSlot,
      'subject': subject,
      'subjectCode': subjectCode,
      'instructor': instructor,
      'room': room,
      'className': className,
      'semester': semester,
      'status': status,
    };
  }
}
