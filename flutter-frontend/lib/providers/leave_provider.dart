import 'package:material_ui/material_ui.dart';
import '../models/leave_request_model.dart';

class LeaveProvider with ChangeNotifier {
  final List<LeaveRequestModel> _leaves = [
    LeaveRequestModel(
      id: 'LEV-2026-101',
      studentName: 'Rahul Sharma',
      studentId: 'STU-1023',
      category: 'Medical Leave',
      startDate: '16/11/2026',
      endDate: '18/11/2026',
      days: '3 Days',
      reason: 'Diagnosed with viral fever. Physician recommended medical rest and medication.',
      status: 'Pending',
      submittedOn: 'Today, 08:30 AM',
    ),
    LeaveRequestModel(
      id: 'LEV-2026-102',
      studentName: 'Priya Sundaram',
      studentId: 'STU-1088',
      category: 'Academic Conference',
      startDate: '20/11/2026',
      endDate: '22/11/2026',
      days: '3 Days',
      reason: 'Invited to present student research paper on ML Algorithms at Tech Conclave.',
      status: 'Pending',
      submittedOn: 'Today, 09:15 AM',
    ),
    LeaveRequestModel(
      id: 'LEV-2025-081',
      studentName: 'Rahul Sharma',
      studentId: 'STU-1023',
      category: 'Medical Leave',
      startDate: '12/04/2025',
      endDate: '14/04/2025',
      days: '3 Days',
      reason: 'Severe food poisoning and treatment under campus medical officer.',
      status: 'Approved',
      submittedOn: '11 Apr 2025',
      reviewedBy: 'Dr. Neha Verma',
      reviewedOn: '11 Apr 2025',
    ),
    LeaveRequestModel(
      id: 'LEV-2025-064',
      studentName: 'Rahul Sharma',
      studentId: 'STU-1023',
      category: 'Official Sports / Cultural',
      startDate: '20/03/2025',
      endDate: '21/03/2025',
      days: '2 Days',
      reason: 'Representing institute football team at Inter-University State Championship.',
      status: 'Approved',
      submittedOn: '18 Mar 2025',
      reviewedBy: 'Dr. Neha Verma',
      reviewedOn: '19 Mar 2025',
    ),
    LeaveRequestModel(
      id: 'LEV-2025-055',
      studentName: 'Aarav Patel',
      studentId: 'STU-1045',
      category: 'Personal Leave',
      startDate: '05/02/2025',
      endDate: '08/02/2025',
      days: '4 Days',
      reason: 'Attending cousin wedding ceremony in hometown without prior department permission.',
      status: 'Rejected',
      submittedOn: '04 Feb 2025',
      reviewedBy: 'Dr. Neha Verma',
      reviewedOn: '05 Feb 2025',
    ),
  ];

  List<LeaveRequestModel> get leaves => List.unmodifiable(_leaves);

  int get pendingCount => _leaves.where((l) => l.status == 'Pending').length;
  int get approvedCount => _leaves.where((l) => l.status == 'Approved').length;
  int get rejectedCount => _leaves.where((l) => l.status == 'Rejected').length;

  List<LeaveRequestModel> getStudentLeaves(String studentIdOrName) {
    return _leaves.where((l) =>
      l.studentId.toLowerCase() == studentIdOrName.toLowerCase() ||
      l.studentName.toLowerCase().contains(studentIdOrName.toLowerCase())
    ).toList();
  }

  String applyLeave({
    required String studentName,
    required String studentId,
    required String category,
    required String startDate,
    required String endDate,
    required String days,
    required String reason,
  }) {
    final newId = 'LEV-${DateTime.now().year}-${100 + _leaves.length + 1}';
    final newRequest = LeaveRequestModel(
      id: newId,
      studentName: studentName,
      studentId: studentId,
      category: category,
      startDate: startDate,
      endDate: endDate,
      days: days,
      reason: reason,
      status: 'Pending',
      submittedOn: 'Just now',
    );

    _leaves.insert(0, newRequest);
    notifyListeners();
    return newId;
  }

  void updateLeaveStatus(String id, String newStatus, {String reviewer = 'Dr. Neha Verma'}) {
    final index = _leaves.indexWhere((l) => l.id == id);
    if (index != -1) {
      _leaves[index].status = newStatus;
      _leaves[index].reviewedBy = reviewer;
      _leaves[index].reviewedOn = 'Just now';
      notifyListeners();
    }
  }
}
