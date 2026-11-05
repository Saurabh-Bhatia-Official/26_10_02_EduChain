class UserModel {
  final String id;
  final String name;
  final String email;
  final String role; // 'institute', 'admin', 'teacher', 'student'
  final String? instituteCode;
  final String? instituteName;
  final String? instituteType;
  final String? rollNumber;
  final String? className;
  final String? course;
  final String? semester;
  final String? department;
  final String? instructorId;
  final String? designation;
  final String? phone;
  final String? address;
  final String? gender;
  final String? dob;
  final String? bloodGroup;
  final String? admissionYear;
  final String? fatherName;
  final String? fatherPhone;
  final String? fatherEmail;
  final String? fatherOccupation;
  final String? motherName;
  final String? motherPhone;
  final String? motherEmail;
  final String? motherOccupation;
  final String? qualification;
  final String? experience;
  final String? about;
  final bool? isVerified;
  final String? verificationStatus;
  final String? verificationId;
  final String? verificationDate;
  final String? accreditation;
  final String? campusLocation;
  final int? studentCount;
  final int? facultyCount;
  final int? departmentCount;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.instituteCode,
    this.instituteName,
    this.instituteType,
    this.rollNumber,
    this.className,
    this.course,
    this.semester,
    this.department,
    this.instructorId,
    this.designation,
    this.phone,
    this.address,
    this.gender,
    this.dob,
    this.bloodGroup,
    this.admissionYear,
    this.fatherName,
    this.fatherPhone,
    this.fatherEmail,
    this.fatherOccupation,
    this.motherName,
    this.motherPhone,
    this.motherEmail,
    this.motherOccupation,
    this.qualification,
    this.experience,
    this.about,
    this.isVerified,
    this.verificationStatus,
    this.verificationId,
    this.verificationDate,
    this.accreditation,
    this.campusLocation,
    this.studentCount,
    this.facultyCount,
    this.departmentCount,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? json['userId']?.toString() ?? 'usr_${DateTime.now().millisecondsSinceEpoch}',
      name: json['name']?.toString() ?? json['fullName']?.toString() ?? 'User',
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString().toLowerCase() ?? 'student',
      instituteCode: json['instituteCode']?.toString(),
      instituteName: json['instituteName']?.toString(),
      instituteType: json['instituteType']?.toString(),
      rollNumber: json['rollNumber']?.toString(),
      className: json['className']?.toString(),
      course: json['course']?.toString(),
      semester: json['semester']?.toString(),
      department: json['department']?.toString(),
      instructorId: json['instructorId']?.toString(),
      designation: json['designation']?.toString() ?? json['title']?.toString(),
      phone: json['phone']?.toString() ?? json['phoneNumber']?.toString(),
      address: json['address']?.toString(),
      gender: json['gender']?.toString(),
      dob: json['dob']?.toString(),
      bloodGroup: json['bloodGroup']?.toString(),
      admissionYear: json['admissionYear']?.toString(),
      fatherName: json['fatherName']?.toString(),
      fatherPhone: json['fatherPhone']?.toString(),
      fatherEmail: json['fatherEmail']?.toString(),
      fatherOccupation: json['fatherOccupation']?.toString(),
      motherName: json['motherName']?.toString(),
      motherPhone: json['motherPhone']?.toString(),
      motherEmail: json['motherEmail']?.toString(),
      motherOccupation: json['motherOccupation']?.toString(),
      qualification: json['qualification']?.toString(),
      experience: json['experience']?.toString(),
      about: json['about']?.toString(),
      isVerified: json['isVerified'] == true,
      verificationStatus: json['verificationStatus']?.toString(),
      verificationId: json['verificationId']?.toString(),
      verificationDate: json['verificationDate']?.toString(),
      accreditation: json['accreditation']?.toString(),
      campusLocation: json['campusLocation']?.toString(),
      studentCount: json['studentCount'] is int ? json['studentCount'] : int.tryParse(json['studentCount']?.toString() ?? ''),
      facultyCount: json['facultyCount'] is int ? json['facultyCount'] : int.tryParse(json['facultyCount']?.toString() ?? ''),
      departmentCount: json['departmentCount'] is int ? json['departmentCount'] : int.tryParse(json['departmentCount']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'instituteCode': instituteCode,
      'instituteName': instituteName,
      'instituteType': instituteType,
      'rollNumber': rollNumber,
      'className': className,
      'course': course,
      'semester': semester,
      'department': department,
      'instructorId': instructorId,
      'designation': designation,
      'phone': phone,
      'address': address,
      'gender': gender,
      'dob': dob,
      'bloodGroup': bloodGroup,
      'admissionYear': admissionYear,
      'fatherName': fatherName,
      'fatherPhone': fatherPhone,
      'fatherEmail': fatherEmail,
      'fatherOccupation': fatherOccupation,
      'motherName': motherName,
      'motherPhone': motherPhone,
      'motherEmail': motherEmail,
      'motherOccupation': motherOccupation,
      'qualification': qualification,
      'experience': experience,
      'about': about,
      'isVerified': isVerified,
      'verificationStatus': verificationStatus,
      'verificationId': verificationId,
      'verificationDate': verificationDate,
      'accreditation': accreditation,
      'campusLocation': campusLocation,
      'studentCount': studentCount,
      'facultyCount': facultyCount,
      'departmentCount': departmentCount,
    };
  }
}

