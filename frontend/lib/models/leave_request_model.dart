class LeaveRequestModel {
  final String id;
  final String studentName;
  final String studentId;
  final String category;
  final String startDate;
  final String endDate;
  final String days;
  final String reason;
  String status; // 'Pending', 'Approved', 'Rejected'
  final String submittedOn;
  String? reviewedBy;
  String? reviewedOn;

  LeaveRequestModel({
    required this.id,
    required this.studentName,
    required this.studentId,
    required this.category,
    required this.startDate,
    required this.endDate,
    required this.days,
    required this.reason,
    required this.status,
    required this.submittedOn,
    this.reviewedBy,
    this.reviewedOn,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'studentName': studentName,
      'studentId': studentId,
      'category': category,
      'startDate': startDate,
      'endDate': endDate,
      'days': days,
      'reason': reason,
      'status': status,
      'submittedOn': submittedOn,
      'reviewedBy': reviewedBy,
      'reviewedOn': reviewedOn,
    };
  }

  factory LeaveRequestModel.fromMap(Map<String, dynamic> map) {
    return LeaveRequestModel(
      id: map['id'] ?? '',
      studentName: map['studentName'] ?? '',
      studentId: map['studentId'] ?? '',
      category: map['category'] ?? 'Medical Leave',
      startDate: map['startDate'] ?? '',
      endDate: map['endDate'] ?? '',
      days: map['days'] ?? '1 Day',
      reason: map['reason'] ?? '',
      status: map['status'] ?? 'Pending',
      submittedOn: map['submittedOn'] ?? '',
      reviewedBy: map['reviewedBy'],
      reviewedOn: map['reviewedOn'],
    );
  }
}
