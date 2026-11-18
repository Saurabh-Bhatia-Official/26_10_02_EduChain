import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../widgets/status_badge.dart';

class FacultyWorkloadItem {
  final String id;
  final String name;
  final String instructorId;
  final String department;
  final String designation;
  final String email;
  final String phone;
  int weeklyHours;
  final int maxHours;
  List<String> assignedClasses;
  final double rating;
  final int totalReviews;
  String attendanceStatus; // 'Present', 'Absent', 'On Leave'
  final int activeProjects;

  FacultyWorkloadItem({
    required this.id,
    required this.name,
    required this.instructorId,
    required this.department,
    required this.designation,
    required this.email,
    required this.phone,
    required this.weeklyHours,
    this.maxHours = 22,
    required this.assignedClasses,
    required this.rating,
    required this.totalReviews,
    required this.attendanceStatus,
    this.activeProjects = 2,
  });

  double get loadPercentage => (weeklyHours / maxHours).clamp(0.0, 1.0);
}

class FacultyWorkloadScreen extends StatefulWidget {
  final Function(String screenName, {String? param})? onNavigate;

  const FacultyWorkloadScreen({super.key, this.onNavigate});

  @override
  State<FacultyWorkloadScreen> createState() => _FacultyWorkloadScreenState();
}

class _FacultyWorkloadScreenState extends State<FacultyWorkloadScreen> {
  String _selectedDept = 'All';
  String _selectedLoadFilter = 'All';
  String _searchQuery = '';

  late List<FacultyWorkloadItem> _workloadList;

  @override
  void initState() {
    super.initState();
    _initDefaultFacultyData();
  }

  void _initDefaultFacultyData() {
    _workloadList = [
      FacultyWorkloadItem(
        id: 'ins_1',
        name: 'Dr. Amit Sharma',
        instructorId: 'INS-001',
        department: 'Computer Science',
        designation: 'Professor & HOD',
        email: 'amit.sharma@institute.com',
        phone: '+91 98765 43210',
        weeklyHours: 18,
        maxHours: 22,
        assignedClasses: [
          'BCA-301 (DBMS)',
          'BCA-302 (DSA)',
          'MCA-101 (SE)',
          'MCA-102 (OS)',
        ],
        rating: 4.8,
        totalReviews: 142,
        attendanceStatus: 'Present',
        activeProjects: 4,
      ),
      FacultyWorkloadItem(
        id: 'ins_2',
        name: 'Prof. Sunita Rao',
        instructorId: 'INS-002',
        department: 'Mathematics',
        designation: 'Associate Professor',
        email: 'sunita.rao@institute.com',
        phone: '+91 98765 43218',
        weeklyHours: 16,
        maxHours: 20,
        assignedClasses: [
          'MATH-201 (Discrete Math)',
          'MATH-302 (Linear Algebra)',
          'MCA-203 (Stats)',
        ],
        rating: 4.9,
        totalReviews: 128,
        attendanceStatus: 'Present',
        activeProjects: 2,
      ),
      FacultyWorkloadItem(
        id: 'ins_3',
        name: 'Prof. Rajesh Gupta',
        instructorId: 'INS-003',
        department: 'Computer Science',
        designation: 'Associate Professor',
        email: 'rajesh.gupta@institute.com',
        phone: '+91 98765 43222',
        weeklyHours: 20,
        maxHours: 22,
        assignedClasses: [
          'CS-204 (OOP in C++)',
          'CS-305 (Web Tech)',
          'MCA-104 (Cloud)',
          'BCA-102 (C Prog)',
        ],
        rating: 4.7,
        totalReviews: 110,
        attendanceStatus: 'Present',
        activeProjects: 3,
      ),
      FacultyWorkloadItem(
        id: 'ins_4',
        name: 'Dr. Vikram Malhotra',
        instructorId: 'INS-004',
        department: 'Computer Science',
        designation: 'Assistant Professor',
        email: 'vikram.malhotra@institute.com',
        phone: '+91 98765 33445',
        weeklyHours: 14,
        maxHours: 20,
        assignedClasses: ['CS-401 (AI & ML)', 'CS-403 (Neural Nets)'],
        rating: 4.6,
        totalReviews: 89,
        attendanceStatus: 'On Leave',
        activeProjects: 1,
      ),
      FacultyWorkloadItem(
        id: 'ins_5',
        name: 'Dr. Neha Kapoor',
        instructorId: 'INS-005',
        department: 'Physics',
        designation: 'Assistant Professor',
        email: 'neha.kapoor@institute.com',
        phone: '+91 98765 99881',
        weeklyHours: 17,
        maxHours: 20,
        assignedClasses: [
          'PHY-101 (Mechanics)',
          'PHY-202 (Electrodynamics)',
          'PHY-301 (Quantum)',
        ],
        rating: 4.85,
        totalReviews: 95,
        attendanceStatus: 'Present',
        activeProjects: 2,
      ),
      FacultyWorkloadItem(
        id: 'ins_6',
        name: 'Prof. Ananya Sen',
        instructorId: 'INS-006',
        department: 'Commerce',
        designation: 'Lecturer',
        email: 'ananya.sen@institute.com',
        phone: '+91 98765 77665',
        weeklyHours: 12,
        maxHours: 18,
        assignedClasses: ['COM-101 (Accounting)', 'COM-202 (Finance)'],
        rating: 4.5,
        totalReviews: 64,
        attendanceStatus: 'Absent',
        activeProjects: 1,
      ),
    ];
  }

  List<FacultyWorkloadItem> get _filteredFaculty {
    return _workloadList.where((faculty) {
      if (_selectedDept != 'All' && faculty.department != _selectedDept) {
        return false;
      }
      if (_selectedLoadFilter == 'High' && faculty.weeklyHours < 18) {
        return false;
      }
      if (_selectedLoadFilter == 'Optimal' &&
          (faculty.weeklyHours < 15 || faculty.weeklyHours > 18)) {
        return false;
      }
      if (_selectedLoadFilter == 'Light' && faculty.weeklyHours >= 15) {
        return false;
      }
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final match =
            faculty.name.toLowerCase().contains(query) ||
            faculty.instructorId.toLowerCase().contains(query) ||
            faculty.department.toLowerCase().contains(query) ||
            faculty.designation.toLowerCase().contains(query);
        if (!match) return false;
      }
      return true;
    }).toList();
  }

  void _showWorkloadAdjustmentDialog(FacultyWorkloadItem faculty) {
    int hours = faculty.weeklyHours;
    String status = faculty.attendanceStatus;
    final classesController = TextEditingController(
      text: faculty.assignedClasses.join(', '),
    );

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.teacherPrimary.withValues(
                  alpha: 0.15,
                ),
                child: Text(
                  faculty.name.isNotEmpty ? faculty.name[0] : 'F',
                  style: const TextStyle(
                    color: AppColors.teacherPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Adjust Workload: ${faculty.name}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${faculty.instructorId} • ${faculty.department}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Weekly Teaching Hours Target',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.remove_circle_outline,
                        color: AppColors.primary,
                      ),
                      onPressed: hours > 2
                          ? () => setDialogState(() => hours--)
                          : null,
                    ),
                    Text(
                      '$hours Hours / Week',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.add_circle_outline,
                        color: AppColors.primary,
                      ),
                      onPressed: hours < 30
                          ? () => setDialogState(() => hours++)
                          : null,
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: hours > 20
                            ? AppColors.warningBg
                            : AppColors.successBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        hours > 20 ? 'High Load' : 'Balanced',
                        style: TextStyle(
                          color: hours > 20
                              ? AppColors.warning
                              : AppColors.success,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Attendance Status Today',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: status,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'Present',
                      child: Text('Present (Active on campus)'),
                    ),
                    DropdownMenuItem(value: 'Absent', child: Text('Absent')),
                    DropdownMenuItem(
                      value: 'On Leave',
                      child: Text('On Leave (Approved)'),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) setDialogState(() => status = val);
                  },
                ),
                const SizedBox(height: 16),
                const Text(
                  'Assigned Classes & Batches (comma separated)',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: classesController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    hintText: 'e.g. BCA-301, MCA-102, CS-204',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  faculty.weeklyHours = hours;
                  faculty.attendanceStatus = status;
                  faculty.assignedClasses = classesController.text
                      .split(',')
                      .map((c) => c.trim())
                      .where((c) => c.isNotEmpty)
                      .toList();
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Workload updated for ${faculty.name}!'),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.adminPrimary,
              ),
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  void _showFacultyDetailDialog(FacultyWorkloadItem faculty) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.teacherPrimary,
              radius: 22,
              child: Text(
                faculty.name.isNotEmpty ? faculty.name[0] : 'F',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    faculty.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    '${faculty.designation} • ${faculty.department}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.bgPage,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildMiniMetric(
                      'Weekly Load',
                      '${faculty.weeklyHours} hrs',
                      AppColors.primary,
                    ),
                    _buildMiniMetric(
                      'Rating',
                      '${faculty.rating} ★',
                      AppColors.accentOrange,
                    ),
                    _buildMiniMetric(
                      'Classes',
                      '${faculty.assignedClasses.length}',
                      AppColors.accentPurple,
                    ),
                    _buildMiniMetric(
                      'Projects',
                      '${faculty.activeProjects}',
                      AppColors.accentTeal,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Assigned Batches & Classes',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: faculty.assignedClasses
                    .map(
                      (cls) => Chip(
                        backgroundColor: AppColors.primaryLight,
                        label: Text(
                          cls,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                        avatar: const Icon(
                          Icons.school_outlined,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 18),
              const Text(
                'Contact Information',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(
                    Icons.email_outlined,
                    size: 16,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    faculty.email,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textMain,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    Icons.phone_outlined,
                    size: 16,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    faculty.phone,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textMain,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          OutlinedButton(
            onPressed: () {
              Navigator.pop(ctx);
              if (widget.onNavigate != null) {
                widget.onNavigate!('lecture-schedule');
              }
            },
            child: const Text('View Full Schedule'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.adminPrimary,
            ),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniMetric(String label, String val, Color color) {
    return Column(
      children: [
        Text(
          val,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 16,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Screen Header Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Faculty Workload & Performance Tracking',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textMain,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Monitor weekly teaching hours, classroom allocations, attendance, and student performance ratings.',
                    style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            if (!isMobile)
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Faculty workload summary exported to CSV!',
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.file_download_outlined, size: 16),
                    label: const Text('Export Summary'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Full Faculty Daily Report generated.'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.assessment_outlined, size: 16),
                    label: const Text('Daily Report'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.adminPrimary,
                    ),
                  ),
                ],
              ),
          ],
        ),
        const SizedBox(height: 20),

        // Sub Stat Bar (KPIs matching screenshots)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Wrap(
            spacing: 24,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Total Instructors: ',
                    style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                  ),
                  Text(
                    '186',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textMain,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Present: ',
                    style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                  ),
                  const Text(
                    '168',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textMain,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Absent: ',
                    style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                  ),
                  const Text(
                    '12',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textMain,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.warning,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'On Leave: ',
                    style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                  ),
                  const Text(
                    '6',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textMain,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.av_timer, size: 16, color: AppColors.primary),
                  SizedBox(width: 6),
                  Text(
                    'Avg Teaching Load: ',
                    style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                  ),
                  Text(
                    '18.4 hrs/wk',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textMain,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Attendance Donut & Workload Distribution Cards
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 850;
            return Flex(
              direction: isWide ? Axis.horizontal : Axis.vertical,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Attendance Overview Donut Card
                Expanded(
                  flex: isWide ? 4 : 0,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Attendance Overview',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: 110,
                                  height: 110,
                                  child: CircularProgressIndicator(
                                    value: 0.903,
                                    strokeWidth: 10,
                                    backgroundColor: AppColors.bgSurface,
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                          AppColors.success,
                                        ),
                                  ),
                                ),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Text(
                                      '90.3%',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.textMain,
                                      ),
                                    ),
                                    Text(
                                      'Present',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(width: 24),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLegendRow(
                                  AppColors.success,
                                  'Present',
                                  '168 (90%)',
                                ),
                                const SizedBox(height: 8),
                                _buildLegendRow(
                                  AppColors.error,
                                  'Absent',
                                  '12 (6%)',
                                ),
                                const SizedBox(height: 8),
                                _buildLegendRow(
                                  AppColors.warning,
                                  'On Leave',
                                  '6 (4%)',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: isWide ? 16 : 0, height: isWide ? 0 : 16),

                // Workload Distribution Summary Card
                Expanded(
                  flex: isWide ? 6 : 0,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text(
                              'Weekly Workload Distribution',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              'Standard: 16–20 hrs',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildWorkloadBar(
                          'Optimal (16–20 hrs/week)',
                          0.76,
                          '76% (141 Faculty)',
                          AppColors.primary,
                        ),
                        const SizedBox(height: 12),
                        _buildWorkloadBar(
                          'Heavy Load (>20 hrs/week)',
                          0.12,
                          '12% (22 Faculty)',
                          AppColors.accentOrange,
                        ),
                        const SizedBox(height: 12),
                        _buildWorkloadBar(
                          'Underutilized (<16 hrs/week)',
                          0.12,
                          '12% (23 Faculty)',
                          AppColors.accentPurple,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 24),

        // Controls Toolbar
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Wrap(
            spacing: 14,
            runSpacing: 12,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              // Search input
              SizedBox(
                width: 280,
                child: TextField(
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: const InputDecoration(
                    hintText: 'Search faculty name, ID...',
                    prefixIcon: Icon(Icons.search, size: 20),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                  ),
                ),
              ),

              // Filter Dropdowns
              Wrap(
                spacing: 12,
                runSpacing: 10,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  DropdownButton<String>(
                    value: _selectedDept,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(
                        value: 'All',
                        child: Text('All Departments'),
                      ),
                      DropdownMenuItem(
                        value: 'Computer Science',
                        child: Text('Computer Science'),
                      ),
                      DropdownMenuItem(
                        value: 'Mathematics',
                        child: Text('Mathematics'),
                      ),
                      DropdownMenuItem(
                        value: 'Physics',
                        child: Text('Physics'),
                      ),
                      DropdownMenuItem(
                        value: 'Commerce',
                        child: Text('Commerce'),
                      ),
                    ],
                    onChanged: (v) =>
                        setState(() => _selectedDept = v ?? 'All'),
                  ),
                  DropdownButton<String>(
                    value: _selectedLoadFilter,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(
                        value: 'All',
                        child: Text('All Load Levels'),
                      ),
                      DropdownMenuItem(
                        value: 'Optimal',
                        child: Text('Optimal (15-18h)'),
                      ),
                      DropdownMenuItem(
                        value: 'High',
                        child: Text('High Load (>18h)'),
                      ),
                      DropdownMenuItem(
                        value: 'Light',
                        child: Text('Light Load (<15h)'),
                      ),
                    ],
                    onChanged: (v) =>
                        setState(() => _selectedLoadFilter = v ?? 'All'),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Interactive Faculty Table / Card List
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Faculty Roster (${_filteredFaculty.length} Instructors)',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'Live Academic Tracking',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppColors.border),

              if (_filteredFaculty.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(
                    child: Text(
                      'No faculty instructors matched the criteria.',
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _filteredFaculty.length,
                  separatorBuilder: (_, _) =>
                      const Divider(height: 1, color: AppColors.borderLight),
                  itemBuilder: (context, index) {
                    final faculty = _filteredFaculty[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          // Avatar
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: AppColors.teacherPrimary
                                .withValues(alpha: 0.15),
                            child: Text(
                              faculty.name.isNotEmpty ? faculty.name[0] : 'T',
                              style: const TextStyle(
                                color: AppColors.teacherPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),

                          // Name and Designation
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  faculty.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                    color: AppColors.textMain,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${faculty.instructorId} • ${faculty.designation} • ${faculty.department}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Weekly Teaching Hours with progress bar
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      '${faculty.weeklyHours} hrs/wk',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                        color: AppColors.textMain,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '/ ${faculty.maxHours} max',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textLight,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: faculty.loadPercentage,
                                    minHeight: 6,
                                    backgroundColor: AppColors.bgSurface,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      faculty.weeklyHours > 20
                                          ? AppColors.accentOrange
                                          : AppColors.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 14),

                          // Rating
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star,
                                color: AppColors.accentOrange,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                faculty.rating.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 16),

                          // Attendance Badge
                          StatusBadge(
                            label: faculty.attendanceStatus,
                            status: faculty.attendanceStatus == 'Present'
                                ? 'active'
                                : (faculty.attendanceStatus == 'On Leave'
                                      ? 'warning'
                                      : 'inactive'),
                          ),
                          const SizedBox(width: 14),

                          // Action Buttons
                          IconButton(
                            icon: const Icon(
                              Icons.edit_calendar_outlined,
                              size: 18,
                              color: AppColors.primary,
                            ),
                            tooltip: 'Adjust Workload',
                            onPressed: () =>
                                _showWorkloadAdjustmentDialog(faculty),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.visibility_outlined,
                              size: 18,
                              color: AppColors.textMuted,
                            ),
                            tooltip: 'View Profile & Batches',
                            onPressed: () => _showFacultyDetailDialog(faculty),
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLegendRow(Color color, String label, String val) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
        ),
        Text(
          val,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.textMain,
          ),
        ),
      ],
    );
  }

  Widget _buildWorkloadBar(
    String title,
    double fraction,
    String label,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textMain,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: fraction,
            minHeight: 7,
            backgroundColor: AppColors.bgSurface,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
