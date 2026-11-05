class StudentModel {
  final String id;
  final String name;
  final String email;
  final String rollNumber;
  final String className;
  final String course;
  final String? department;
  final String? semester;
  final String? phone;
  final String? address;
  final String? gender;
  final String? dob;
  final String? fatherName;
  final String? fatherPhone;
  final String? fatherEmail;
  final String? motherName;
  final String? motherPhone;
  final String? motherEmail;
  final String? status;
  final String? instituteCode;
  final String? instituteName;

  StudentModel({
    required this.id,
    required this.name,
    required this.email,
    required this.rollNumber,
    required this.className,
    required this.course,
    this.department,
    this.semester,
    this.phone,
    this.address,
    this.gender,
    this.dob,
    this.fatherName,
    this.fatherPhone,
    this.fatherEmail,
    this.motherName,
    this.motherPhone,
    this.motherEmail,
    this.status = 'Active',
    this.instituteCode,
    this.instituteName,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      id: json['id']?.toString() ?? json['userId']?.toString() ?? '',
      name: json['name']?.toString() ?? json['fullName']?.toString() ?? 'Student',
      email: json['email']?.toString() ?? '',
      rollNumber: json['rollNumber']?.toString() ?? '',
      className: json['className']?.toString() ?? json['course']?.toString() ?? '',
      course: json['course']?.toString() ?? json['className']?.toString() ?? '',
      department: json['department']?.toString(),
      semester: json['semester']?.toString() ?? '1',
      phone: json['phone']?.toString() ?? json['phoneNumber']?.toString(),
      address: json['address']?.toString(),
      gender: json['gender']?.toString(),
      dob: json['dob']?.toString(),
      fatherName: json['fatherName']?.toString(),
      fatherPhone: json['fatherPhone']?.toString(),
      fatherEmail: json['fatherEmail']?.toString(),
      motherName: json['motherName']?.toString(),
      motherPhone: json['motherPhone']?.toString(),
      motherEmail: json['motherEmail']?.toString(),
      status: json['status']?.toString() ?? 'Active',
      instituteCode: json['instituteCode']?.toString(),
      instituteName: json['instituteName']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'name': name,
      'fullName': name,
      'email': email,
      'rollNumber': rollNumber,
      'className': className,
      'course': course,
      'department': department ?? course,
      'semester': semester ?? 'Semester 1',
      'phone': phone ?? '',
      'address': address ?? '',
      'gender': gender ?? 'Not Specified',
      'dob': dob ?? '2005-01-01',
      'fatherName': fatherName ?? '',
      'fatherPhone': fatherPhone ?? '',
      'fatherEmail': fatherEmail ?? '',
      'motherName': motherName ?? '',
      'motherPhone': motherPhone ?? '',
      'motherEmail': motherEmail ?? '',
      'status': status ?? 'Active',
      'instituteCode': instituteCode ?? 'INST-2025',
      'instituteName': instituteName ?? 'Apex Institute of Technology',
      'role': 'student',
    };
  }
}

