class InstructorModel {
  final String id;
  final String name;
  final String email;
  final String instructorId;
  final String department;
  final String designation;
  final String? phone;
  final String? qualification;
  final String? experience;
  final String? about;
  final String? status;
  final String? instituteCode;
  final String? instituteName;
  final String? initialPassword;

  InstructorModel({
    required this.id,
    required this.name,
    required this.email,
    required this.instructorId,
    required this.department,
    required this.designation,
    this.phone,
    this.qualification,
    this.experience,
    this.about,
    this.status = 'Active',
    this.instituteCode,
    this.instituteName,
    this.initialPassword,
  });

  factory InstructorModel.fromJson(Map<String, dynamic> json) {
    return InstructorModel(
      id: json['id']?.toString() ?? json['userId']?.toString() ?? '',
      name: json['name']?.toString() ?? json['fullName']?.toString() ?? 'Faculty Member',
      email: json['email']?.toString() ?? '',
      instructorId: json['instructorId']?.toString() ?? json['employeeId']?.toString() ?? '',
      department: json['department']?.toString() ?? 'Computer Science',
      designation: json['designation']?.toString() ?? json['title']?.toString() ?? 'Assistant Professor',
      phone: json['phone']?.toString() ?? json['phoneNumber']?.toString(),
      qualification: json['qualification']?.toString(),
      experience: json['experience']?.toString(),
      about: json['about']?.toString(),
      status: json['status']?.toString() ?? 'Active',
      instituteCode: json['instituteCode']?.toString(),
      instituteName: json['instituteName']?.toString(),
      initialPassword: json['initialPassword']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'name': name,
      'fullName': name,
      'email': email,
      'instructorId': instructorId,
      'department': department,
      'designation': designation,
      'phone': phone ?? '',
      'qualification': qualification ?? '',
      'experience': experience ?? '',
      'about': about ?? '',
      'status': status ?? 'Active',
      if (instituteCode != null) 'instituteCode': instituteCode,
      if (instituteName != null) 'instituteName': instituteName,
      'role': 'teacher',
      if (initialPassword != null && initialPassword!.isNotEmpty)
        'password': initialPassword,
    };
  }
}

