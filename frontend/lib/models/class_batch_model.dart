class ClassBatchModel {
  final String id;
  final String name;
  final String code;
  final String department;
  final String semester;
  final String section;
  final int capacity;
  final int enrolled;
  final String instructor;
  final String room;
  final String status;

  ClassBatchModel({
    required this.id,
    required this.name,
    required this.code,
    required this.department,
    required this.semester,
    required this.section,
    required this.capacity,
    required this.enrolled,
    required this.instructor,
    required this.room,
    this.status = 'Active',
  });

  double get utilizationRate => capacity > 0 ? (enrolled / capacity) : 0.0;

  ClassBatchModel copyWith({
    String? id,
    String? name,
    String? code,
    String? department,
    String? semester,
    String? section,
    int? capacity,
    int? enrolled,
    String? instructor,
    String? room,
    String? status,
  }) {
    return ClassBatchModel(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      department: department ?? this.department,
      semester: semester ?? this.semester,
      section: section ?? this.section,
      capacity: capacity ?? this.capacity,
      enrolled: enrolled ?? this.enrolled,
      instructor: instructor ?? this.instructor,
      room: room ?? this.room,
      status: status ?? this.status,
    );
  }

  factory ClassBatchModel.fromJson(Map<String, dynamic> json) {
    return ClassBatchModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      department: json['department']?.toString() ?? 'Computer Science',
      semester: json['semester']?.toString() ?? 'Semester 3',
      section: json['section']?.toString() ?? 'Section A',
      capacity: (json['capacity'] as num?)?.toInt() ?? 60,
      enrolled: (json['enrolled'] as num?)?.toInt() ?? 0,
      instructor: json['instructor']?.toString() ?? 'Unassigned',
      room: json['room']?.toString() ?? 'Hall 101',
      status: json['status']?.toString() ?? 'Active',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'department': department,
      'semester': semester,
      'section': section,
      'capacity': capacity,
      'enrolled': enrolled,
      'instructor': instructor,
      'room': room,
      'status': status,
    };
  }
}
