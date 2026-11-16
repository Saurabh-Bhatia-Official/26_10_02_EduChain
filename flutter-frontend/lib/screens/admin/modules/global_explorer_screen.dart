import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../widgets/status_badge.dart';

class GlobalExplorerScreen extends StatefulWidget {
  final Function(String screenName, {String? param})? onNavigate;

  const GlobalExplorerScreen({super.key, this.onNavigate});

  @override
  State<GlobalExplorerScreen> createState() => _GlobalExplorerScreenState();
}

class _GlobalExplorerScreenState extends State<GlobalExplorerScreen> {
  String _activeTab = 'Students'; // 'Students', 'Instructors', 'Classes'
  String _searchQuery = '';
  String _selectedDept = 'All';
  String _selectedStatus = 'All';

  // Sample cross-module datasets
  final List<Map<String, dynamic>> _studentsData = [
    {
      'id': 'std_1',
      'name': 'Rahul Sharma',
      'rollNo': 'BCA-301',
      'department': 'Computer Science',
      'course': 'Bachelor of Computer Applications',
      'semester': 'Semester 3',
      'status': 'Active',
      'attendance': 92,
      'advisor': 'Dr. Amit Sharma',
      'email': 'rahul.sharma@example.com',
      'phone': '+91 98765 43210',
      'enrolledClasses': ['Database Systems (BCA-301)', 'Data Structures (BCA-302)', 'Operating Systems (BCA-303)'],
    },
    {
      'id': 'std_2',
      'name': 'Priya Singh',
      'rollNo': 'BCA-302',
      'department': 'Computer Science',
      'course': 'Bachelor of Computer Applications',
      'semester': 'Semester 3',
      'status': 'Active',
      'attendance': 96,
      'advisor': 'Prof. Rajesh Gupta',
      'email': 'priya.singh@example.com',
      'phone': '+91 98765 43212',
      'enrolledClasses': ['Database Systems (BCA-301)', 'Data Structures (BCA-302)', 'Web Tech (CS-305)'],
    },
    {
      'id': 'std_3',
      'name': 'Amit Kumar',
      'rollNo': 'BCA-303',
      'department': 'Computer Science',
      'course': 'Bachelor of Computer Applications',
      'semester': 'Semester 3',
      'status': 'Active',
      'attendance': 89,
      'advisor': 'Dr. Amit Sharma',
      'email': 'amit.kumar@example.com',
      'phone': '+91 98765 43214',
      'enrolledClasses': ['Database Systems (BCA-301)', 'Operating Systems (BCA-303)'],
    },
    {
      'id': 'std_4',
      'name': 'Neha Patel',
      'rollNo': 'MCA-101',
      'department': 'Computer Science',
      'course': 'Master of Computer Applications',
      'semester': 'Semester 1',
      'status': 'Active',
      'attendance': 94,
      'advisor': 'Dr. Amit Sharma',
      'email': 'neha.patel@example.com',
      'phone': '+91 98765 43216',
      'enrolledClasses': ['Advanced Software Eng (MCA-101)', 'Cloud Architecture (MCA-104)'],
    },
    {
      'id': 'std_5',
      'name': 'Sahil Verma',
      'rollNo': 'MATH-201',
      'department': 'Mathematics',
      'course': 'B.Sc Mathematics',
      'semester': 'Semester 2',
      'status': 'Active',
      'attendance': 88,
      'advisor': 'Prof. Sunita Rao',
      'email': 'sahil.verma@example.com',
      'phone': '+91 98765 43218',
      'enrolledClasses': ['Discrete Math (MATH-201)', 'Linear Algebra (MATH-302)'],
    },
  ];

  final List<Map<String, dynamic>> _instructorsData = [
    {
      'id': 'ins_1',
      'name': 'Dr. Amit Sharma',
      'instructorId': 'INS-001',
      'department': 'Computer Science',
      'designation': 'Professor & HOD',
      'email': 'amit.sharma@institute.com',
      'phone': '+91 98765 43210',
      'status': 'Active',
      'classesCount': 4,
      'weeklyHours': 18,
      'assignedClasses': ['BCA-301', 'BCA-302', 'MCA-101', 'MCA-102'],
    },
    {
      'id': 'ins_2',
      'name': 'Prof. Sunita Rao',
      'instructorId': 'INS-002',
      'department': 'Mathematics',
      'designation': 'Associate Professor',
      'email': 'sunita.rao@institute.com',
      'phone': '+91 98765 43218',
      'status': 'Active',
      'classesCount': 3,
      'weeklyHours': 16,
      'assignedClasses': ['MATH-201', 'MATH-302', 'MCA-203'],
    },
    {
      'id': 'ins_3',
      'name': 'Prof. Rajesh Gupta',
      'instructorId': 'INS-003',
      'department': 'Computer Science',
      'designation': 'Associate Professor',
      'email': 'rajesh.gupta@institute.com',
      'phone': '+91 98765 43222',
      'status': 'Active',
      'classesCount': 4,
      'weeklyHours': 20,
      'assignedClasses': ['CS-204', 'CS-305', 'MCA-104', 'BCA-102'],
    },
    {
      'id': 'ins_4',
      'name': 'Dr. Vikram Malhotra',
      'instructorId': 'INS-004',
      'department': 'Computer Science',
      'designation': 'Assistant Professor',
      'email': 'vikram.malhotra@institute.com',
      'phone': '+91 98765 33445',
      'status': 'On Leave',
      'classesCount': 2,
      'weeklyHours': 14,
      'assignedClasses': ['CS-401', 'CS-403'],
    },
  ];

  final List<Map<String, dynamic>> _classesData = [
    {
      'id': 'cls_1',
      'name': 'Database Management Systems',
      'code': 'BCA-301',
      'department': 'Computer Science',
      'semester': 'Semester 3',
      'coordinator': 'Dr. Amit Sharma',
      'capacity': 60,
      'enrolled': 54,
      'room': 'Hall 101',
      'status': 'Active',
    },
    {
      'id': 'cls_2',
      'name': 'Data Structures & Algorithms',
      'code': 'BCA-302',
      'department': 'Computer Science',
      'semester': 'Semester 3',
      'coordinator': 'Prof. Rajesh Gupta',
      'capacity': 60,
      'enrolled': 58,
      'room': 'Hall 202',
      'status': 'Active',
    },
    {
      'id': 'cls_3',
      'name': 'Discrete Mathematics',
      'code': 'MATH-201',
      'department': 'Mathematics',
      'semester': 'Semester 2',
      'coordinator': 'Prof. Sunita Rao',
      'capacity': 65,
      'enrolled': 62,
      'room': 'Hall 103',
      'status': 'Active',
    },
  ];

  void _showRecordDetailDialog(Map<String, dynamic> item, String type) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: type == 'Student'
                  ? AppColors.studentPrimary
                  : (type == 'Instructor' ? AppColors.teacherPrimary : AppColors.primary),
              child: Icon(
                type == 'Student' ? Icons.school : (type == 'Instructor' ? Icons.badge : Icons.class_outlined),
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                  Text(
                    type == 'Student'
                        ? 'Roll No: ${item['rollNo']} • ${item['department']}'
                        : (type == 'Instructor' ? '${item['instructorId']} • ${item['designation']}' : '${item['code']} • ${item['department']}'),
                    style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.bgPage,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      _buildDetailRow('Entity Type', type),
                      _buildDetailRow('Department', item['department'] ?? 'Computer Science'),
                      _buildDetailRow('Status', item['status'] ?? 'Active'),
                      if (type == 'Student') ...[
                        _buildDetailRow('Course', item['course'] ?? ''),
                        _buildDetailRow('Semester', item['semester'] ?? ''),
                        _buildDetailRow('Attendance Rate', '${item['attendance']}%'),
                        _buildDetailRow('Faculty Advisor', item['advisor'] ?? 'Dr. Amit Sharma'),
                      ] else if (type == 'Instructor') ...[
                        _buildDetailRow('Designation', item['designation'] ?? ''),
                        _buildDetailRow('Weekly Hours', '${item['weeklyHours']} hrs/wk'),
                        _buildDetailRow('Classes Assigned', '${item['classesCount']} Batches'),
                      ] else ...[
                        _buildDetailRow('Coordinator', item['coordinator'] ?? ''),
                        _buildDetailRow('Capacity & Enrolled', '${item['enrolled']} / ${item['capacity']} students'),
                        _buildDetailRow('Room Allocation', item['room'] ?? ''),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (item['enrolledClasses'] != null || item['assignedClasses'] != null) ...[
                  const Text('Associated Relational Batches:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ((item['enrolledClasses'] ?? item['assignedClasses']) as List)
                        .map((c) => Chip(
                              backgroundColor: AppColors.primaryLight,
                              label: Text(c.toString(), style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600)),
                            ))
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.adminPrimary),
            child: const Text('Close Record'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.w600)),
          Text(val, style: const TextStyle(fontSize: 12, color: AppColors.textMain, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  void _showBulkUpdateDialog() {
    String targetDept = 'Computer Science';
    String action = 'Mark Attendance Verified';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Bulk Update Records', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
          content: SizedBox(
            width: 450,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: targetDept,
                  decoration: const InputDecoration(labelText: 'Target Department'),
                  items: const [
                    DropdownMenuItem(value: 'Computer Science', child: Text('Computer Science')),
                    DropdownMenuItem(value: 'Mathematics', child: Text('Mathematics')),
                    DropdownMenuItem(value: 'Physics', child: Text('Physics')),
                  ],
                  onChanged: (v) => setDialogState(() => targetDept = v ?? 'Computer Science'),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  value: action,
                  decoration: const InputDecoration(labelText: 'Bulk Action'),
                  items: const [
                    DropdownMenuItem(value: 'Mark Attendance Verified', child: Text('Mark Attendance Verified')),
                    DropdownMenuItem(value: 'Promote to Next Semester', child: Text('Promote to Next Semester')),
                    DropdownMenuItem(value: 'Sync Relational Integrity', child: Text('Sync Relational Integrity')),
                  ],
                  onChanged: (v) => setDialogState(() => action = v ?? 'Mark Attendance Verified'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Bulk action "$action" applied to $targetDept!'),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.adminPrimary),
              child: const Text('Execute Bulk Update'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 960;

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
                    'Cross-Module Global Explorer',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textMain),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Unified live cross-reference between Student Admissions, Faculty Allocations, Classrooms, and Examination Records.',
                    style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Global dataset exported to CSV successfully!')),
                    );
                  },
                  icon: const Icon(Icons.download, size: 16),
                  label: const Text('Export Dataset'),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: _showBulkUpdateDialog,
                  icon: const Icon(Icons.edit_note, size: 16),
                  label: const Text('Bulk Update'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.adminPrimary),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Relational Integrity Health Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFEEF2FF),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFC7D2FE)),
          ),
          child: Row(
            children: [
              const Icon(Icons.verified, color: AppColors.adminPrimary, size: 20),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Unified Schema Integrity: 100% Passed • PostgreSQL 16 standard relational tables live synchronized.',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.adminPrimary),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.successBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('Live Synced', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w700, fontSize: 11)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Two Column Layout: Main Explorer (Left) & Quick Access Card (Right)
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Column: Table & Segmented Tabs
            Expanded(
              flex: 8,
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
                    // Segmented Tabs
                    Row(
                      children: [
                        _buildTabButton('Students', Icons.school, _studentsData.length * 250),
                        const SizedBox(width: 8),
                        _buildTabButton('Instructors', Icons.badge, _instructorsData.length * 46),
                        const SizedBox(width: 8),
                        _buildTabButton('Classes', Icons.class_outlined, _classesData.length * 6),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Search & Filter Toolbar
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            onChanged: (v) => setState(() => _searchQuery = v),
                            decoration: const InputDecoration(
                              hintText: 'Search name, roll no, employee ID, or course code...',
                              prefixIcon: Icon(Icons.search, size: 20),
                              contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        DropdownButton<String>(
                          value: _selectedDept,
                          underline: const SizedBox(),
                          items: const [
                            DropdownMenuItem(value: 'All', child: Text('All Departments')),
                            DropdownMenuItem(value: 'Computer Science', child: Text('Computer Science')),
                            DropdownMenuItem(value: 'Mathematics', child: Text('Mathematics')),
                            DropdownMenuItem(value: 'Physics', child: Text('Physics')),
                          ],
                          onChanged: (v) => setState(() => _selectedDept = v ?? 'All'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Data List based on active tab
                    if (_activeTab == 'Students') ...[
                      _buildStudentsList(),
                    ] else if (_activeTab == 'Instructors') ...[
                      _buildInstructorsList(),
                    ] else ...[
                      _buildClassesList(),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(width: 20),

            // Right Column: Quick Access & Actions
            if (isDesktop)
              SizedBox(
                width: 280,
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
                      const Text('Quick Access', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                      const SizedBox(height: 16),
                      _buildSidebarActionBtn(
                        icon: Icons.people_outline,
                        label: 'Student Directory',
                        onTap: () {
                          if (widget.onNavigate != null) widget.onNavigate!('student-records');
                        },
                      ),
                      const SizedBox(height: 10),
                      _buildSidebarActionBtn(
                        icon: Icons.badge_outlined,
                        label: 'Faculty Directory',
                        onTap: () {
                          if (widget.onNavigate != null) widget.onNavigate!('instructor-records');
                        },
                      ),
                      const SizedBox(height: 10),
                      _buildSidebarActionBtn(
                        icon: Icons.timelapse_outlined,
                        label: 'Faculty Workload',
                        onTap: () {
                          if (widget.onNavigate != null) widget.onNavigate!('instructor-tracking');
                        },
                      ),
                      const SizedBox(height: 10),
                      _buildSidebarActionBtn(
                        icon: Icons.class_outlined,
                        label: 'Class & Batches',
                        onTap: () {
                          if (widget.onNavigate != null) widget.onNavigate!('class-management');
                        },
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.bgPage,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          children: const [
                            Icon(Icons.dataset_outlined, size: 36, color: AppColors.adminPrimary),
                            SizedBox(height: 8),
                            Text(
                              'Global Cross Reference',
                              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Inspect any record to see linked faculty, courses, attendance, and exam papers in one place.',
                              style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildTabButton(String title, IconData icon, int count) {
    final isSelected = _activeTab == title;
    return InkWell(
      onTap: () => setState(() => _activeTab = title),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.adminPrimary : AppColors.bgSurface,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isSelected ? Colors.white : AppColors.textMuted),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: isSelected ? Colors.white : AppColors.textMain,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white.withValues(alpha: 0.25) : AppColors.border,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : AppColors.textMuted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentsList() {
    final filtered = _studentsData.where((s) {
      if (_selectedDept != 'All' && s['department'] != _selectedDept) return false;
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final match = (s['name'] as String).toLowerCase().contains(q) ||
            (s['rollNo'] as String).toLowerCase().contains(q) ||
            (s['department'] as String).toLowerCase().contains(q);
        if (!match) return false;
      }
      return true;
    }).toList();

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filtered.length,
      separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.borderLight),
      itemBuilder: (context, index) {
        final s = filtered[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.studentPrimary.withValues(alpha: 0.15),
                child: Text(s['name'][0], style: const TextStyle(color: AppColors.studentPrimary, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 14),
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s['name'], style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                    const SizedBox(height: 2),
                    Text('${s['rollNo']} • ${s['department']} • ${s['semester']}', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: AppColors.bgSurface, borderRadius: BorderRadius.circular(6)),
                child: Text('${s['attendance']}% Att.', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
              ),
              const SizedBox(width: 14),
              StatusBadge(label: s['status'], status: s['status']),
              const SizedBox(width: 10),
              IconButton(
                icon: const Icon(Icons.visibility_outlined, size: 18, color: AppColors.primary),
                tooltip: 'Inspect Cross-Module Details',
                onPressed: () => _showRecordDetailDialog(s, 'Student'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInstructorsList() {
    final filtered = _instructorsData.where((i) {
      if (_selectedDept != 'All' && i['department'] != _selectedDept) return false;
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final match = (i['name'] as String).toLowerCase().contains(q) ||
            (i['instructorId'] as String).toLowerCase().contains(q) ||
            (i['department'] as String).toLowerCase().contains(q);
        if (!match) return false;
      }
      return true;
    }).toList();

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filtered.length,
      separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.borderLight),
      itemBuilder: (context, index) {
        final i = filtered[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.teacherPrimary.withValues(alpha: 0.15),
                child: Text(i['name'][0], style: const TextStyle(color: AppColors.teacherPrimary, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 14),
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(i['name'], style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                    const SizedBox(height: 2),
                    Text('${i['instructorId']} • ${i['designation']} • ${i['department']}', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: AppColors.bgSurface, borderRadius: BorderRadius.circular(6)),
                child: Text('${i['weeklyHours']} hrs/wk', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.teacherPrimary)),
              ),
              const SizedBox(width: 14),
              StatusBadge(label: i['status'], status: i['status'] == 'Active' ? 'active' : 'warning'),
              const SizedBox(width: 10),
              IconButton(
                icon: const Icon(Icons.visibility_outlined, size: 18, color: AppColors.primary),
                tooltip: 'Inspect Cross-Module Details',
                onPressed: () => _showRecordDetailDialog(i, 'Instructor'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildClassesList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _classesData.length,
      separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.borderLight),
      itemBuilder: (context, index) {
        final c = _classesData[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                child: const Icon(Icons.class_outlined, color: AppColors.primary, size: 18),
              ),
              const SizedBox(width: 14),
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(c['name'], style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                    const SizedBox(height: 2),
                    Text('${c['code']} • ${c['department']} • Coordinator: ${c['coordinator']}', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: AppColors.bgSurface, borderRadius: BorderRadius.circular(6)),
                child: Text('${c['enrolled']}/${c['capacity']} Enrolled', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
              ),
              const SizedBox(width: 14),
              StatusBadge(label: c['status'], status: 'active'),
              const SizedBox(width: 10),
              IconButton(
                icon: const Icon(Icons.visibility_outlined, size: 18, color: AppColors.primary),
                tooltip: 'Inspect Cross-Module Details',
                onPressed: () => _showRecordDetailDialog(c, 'Class'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSidebarActionBtn({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.bgPage,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(width: 10),
            Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
            const Icon(Icons.chevron_right, size: 16, color: AppColors.textLight),
          ],
        ),
      ),
    );
  }
}
