import 'package:material_ui/material_ui.dart';
import '../../../constants/app_colors.dart';
import '../../../models/class_batch_model.dart';
import '../../../widgets/metric_card.dart';

class ClassBatchManagementScreen extends StatefulWidget {
  final Function(String screenName, {String? param})? onNavigate;

  const ClassBatchManagementScreen({super.key, this.onNavigate});

  @override
  State<ClassBatchManagementScreen> createState() => _ClassBatchManagementScreenState();
}

class _ClassBatchManagementScreenState extends State<ClassBatchManagementScreen> {
  String _searchQuery = '';
  String _selectedDept = 'All';
  String _selectedSemester = 'All';

  late List<ClassBatchModel> _classes;

  @override
  void initState() {
    super.initState();
    _initClasses();
  }

  void _initClasses() {
    _classes = [
      ClassBatchModel(
        id: 'cls_1',
        name: 'Database Management Systems',
        code: 'BCA-301',
        department: 'Computer Science',
        semester: 'Semester 3',
        section: 'Section A',
        capacity: 60,
        enrolled: 54,
        instructor: 'Dr. Amit Sharma',
        room: 'Hall 101',
        status: 'Active',
      ),
      ClassBatchModel(
        id: 'cls_2',
        name: 'Data Structures & Algorithms',
        code: 'BCA-302',
        department: 'Computer Science',
        semester: 'Semester 3',
        section: 'Section B',
        capacity: 60,
        enrolled: 58,
        instructor: 'Prof. Rajesh Gupta',
        room: 'Hall 202',
        status: 'Active',
      ),
      ClassBatchModel(
        id: 'cls_3',
        name: 'Operating Systems Architecture',
        code: 'BCA-303',
        department: 'Computer Science',
        semester: 'Semester 3',
        section: 'Section A',
        capacity: 60,
        enrolled: 52,
        instructor: 'Prof. Sunita Rao',
        room: 'Hall 105',
        status: 'Active',
      ),
      ClassBatchModel(
        id: 'cls_4',
        name: 'Advanced Software Engineering',
        code: 'MCA-101',
        department: 'Computer Science',
        semester: 'Semester 1',
        section: 'Section A',
        capacity: 50,
        enrolled: 44,
        instructor: 'Dr. Amit Sharma',
        room: 'Hall 302',
        status: 'Active',
      ),
      ClassBatchModel(
        id: 'cls_5',
        name: 'Discrete Mathematics & Logic',
        code: 'MATH-201',
        department: 'Mathematics',
        semester: 'Semester 2',
        section: 'Section A',
        capacity: 65,
        enrolled: 62,
        instructor: 'Prof. Sunita Rao',
        room: 'Hall 103',
        status: 'Active',
      ),
      ClassBatchModel(
        id: 'cls_6',
        name: 'Artificial Intelligence & Neural Nets',
        code: 'BCA-305',
        department: 'Computer Science',
        semester: 'Semester 5',
        section: 'Lab Batch 1',
        capacity: 45,
        enrolled: 41,
        instructor: 'Dr. Vikram Malhotra',
        room: 'Computer Lab 1',
        status: 'Active',
      ),
      ClassBatchModel(
        id: 'cls_7',
        name: 'Quantum Mechanics & Modern Physics',
        code: 'PHY-101',
        department: 'Physics',
        semester: 'Semester 1',
        section: 'Section A',
        capacity: 55,
        enrolled: 48,
        instructor: 'Dr. Neha Kapoor',
        room: 'Hall 201',
        status: 'Active',
      ),
      ClassBatchModel(
        id: 'cls_8',
        name: 'Financial Accounting & Taxation',
        code: 'COM-101',
        department: 'Commerce',
        semester: 'Semester 1',
        section: 'Section A',
        capacity: 70,
        enrolled: 65,
        instructor: 'Prof. Ananya Sen',
        room: 'Hall 305',
        status: 'Active',
      ),
    ];
  }

  List<ClassBatchModel> get _filteredClasses {
    return _classes.where((cls) {
      if (_selectedDept != 'All' && cls.department != _selectedDept) {
        return false;
      }
      if (_selectedSemester != 'All' && cls.semester != _selectedSemester) {
        return false;
      }
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final match = cls.name.toLowerCase().contains(q) ||
            cls.code.toLowerCase().contains(q) ||
            cls.department.toLowerCase().contains(q) ||
            cls.instructor.toLowerCase().contains(q) ||
            cls.room.toLowerCase().contains(q) ||
            cls.section.toLowerCase().contains(q);
        if (!match) return false;
      }
      return true;
    }).toList();
  }

  void _showAddOrEditClassDialog([ClassBatchModel? existing]) {
    final isEdit = existing != null;
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final codeCtrl = TextEditingController(text: existing?.code ?? '');
    String dept = existing?.department ?? 'Computer Science';
    String sem = existing?.semester ?? 'Semester 3';
    String sec = existing?.section ?? 'Section A';
    final capCtrl = TextEditingController(text: existing?.capacity.toString() ?? '60');
    final enrolledCtrl = TextEditingController(text: existing?.enrolled.toString() ?? '45');
    final instCtrl = TextEditingController(text: existing?.instructor ?? 'Dr. Amit Sharma');
    final roomCtrl = TextEditingController(text: existing?.room ?? 'Hall 101');
    String status = existing?.status ?? 'Active';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isEdit ? 'Edit Class / Batch' : 'Add New Class & Batch',
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
              ),
              if (!isEdit)
                TextButton.icon(
                  onPressed: () {
                    setDialogState(() {
                      nameCtrl.text = 'Cloud Computing & DevOps';
                      codeCtrl.text = 'CS-${300 + _classes.length + 1}';
                      dept = 'Computer Science';
                      sem = 'Semester 4';
                      sec = 'Section A';
                      capCtrl.text = '60';
                      enrolledCtrl.text = '48';
                      instCtrl.text = 'Prof. Rajesh Gupta';
                      roomCtrl.text = 'Hall 204';
                    });
                  },
                  icon: const Icon(Icons.auto_awesome, size: 14),
                  label: const Text('Demo Fill', style: TextStyle(fontSize: 12)),
                ),
            ],
          ),
          content: SizedBox(
            width: 550,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: 'Class / Subject Name *', hintText: 'e.g. Artificial Intelligence'),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: codeCtrl,
                          decoration: const InputDecoration(labelText: 'Course / Class Code *', hintText: 'e.g. BCA-305'),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: dept,
                          decoration: const InputDecoration(labelText: 'Department *'),
                          items: const [
                            DropdownMenuItem(value: 'Computer Science', child: Text('Computer Science')),
                            DropdownMenuItem(value: 'Mathematics', child: Text('Mathematics')),
                            DropdownMenuItem(value: 'Physics', child: Text('Physics')),
                            DropdownMenuItem(value: 'Commerce', child: Text('Commerce')),
                            DropdownMenuItem(value: 'English', child: Text('English')),
                          ],
                          onChanged: (v) => setDialogState(() => dept = v ?? 'Computer Science'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: sem,
                          decoration: const InputDecoration(labelText: 'Semester *'),
                          items: const [
                            DropdownMenuItem(value: 'Semester 1', child: Text('Semester 1')),
                            DropdownMenuItem(value: 'Semester 2', child: Text('Semester 2')),
                            DropdownMenuItem(value: 'Semester 3', child: Text('Semester 3')),
                            DropdownMenuItem(value: 'Semester 4', child: Text('Semester 4')),
                            DropdownMenuItem(value: 'Semester 5', child: Text('Semester 5')),
                            DropdownMenuItem(value: 'Semester 6', child: Text('Semester 6')),
                          ],
                          onChanged: (v) => setDialogState(() => sem = v ?? 'Semester 3'),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: sec,
                          decoration: const InputDecoration(labelText: 'Section / Batch *'),
                          items: const [
                            DropdownMenuItem(value: 'Section A', child: Text('Section A')),
                            DropdownMenuItem(value: 'Section B', child: Text('Section B')),
                            DropdownMenuItem(value: 'Lab Batch 1', child: Text('Lab Batch 1')),
                            DropdownMenuItem(value: 'Lab Batch 2', child: Text('Lab Batch 2')),
                          ],
                          onChanged: (v) => setDialogState(() => sec = v ?? 'Section A'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: capCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Max Capacity *', hintText: '60'),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: TextField(
                          controller: enrolledCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Enrolled Count', hintText: '45'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: instCtrl,
                          decoration: const InputDecoration(labelText: 'Assigned Coordinator / Faculty *', hintText: 'Dr. Amit Sharma'),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: TextField(
                          controller: roomCtrl,
                          decoration: const InputDecoration(labelText: 'Classroom / Hall *', hintText: 'Hall 101'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.trim().isEmpty || codeCtrl.text.trim().isEmpty) {
                  return;
                }
                final cap = int.tryParse(capCtrl.text.trim()) ?? 60;
                final enr = int.tryParse(enrolledCtrl.text.trim()) ?? 0;

                setState(() {
                  if (isEdit) {
                    final idx = _classes.indexWhere((c) => c.id == existing.id);
                    if (idx != -1) {
                      _classes[idx] = existing.copyWith(
                        name: nameCtrl.text.trim(),
                        code: codeCtrl.text.trim(),
                        department: dept,
                        semester: sem,
                        section: sec,
                        capacity: cap,
                        enrolled: enr,
                        instructor: instCtrl.text.trim(),
                        room: roomCtrl.text.trim(),
                        status: status,
                      );
                    }
                  } else {
                    _classes.insert(
                      0,
                      ClassBatchModel(
                        id: 'cls_${DateTime.now().millisecondsSinceEpoch}',
                        name: nameCtrl.text.trim(),
                        code: codeCtrl.text.trim(),
                        department: dept,
                        semester: sem,
                        section: sec,
                        capacity: cap,
                        enrolled: enr,
                        instructor: instCtrl.text.trim(),
                        room: roomCtrl.text.trim(),
                        status: 'Active',
                      ),
                    );
                  }
                });

                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(isEdit ? 'Class updated successfully!' : 'New Class & Batch created!'),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.adminPrimary),
              child: Text(isEdit ? 'Save Changes' : 'Create Class'),
            ),
          ],
        ),
      ),
    );
  }

  void _handleDeleteClass(ClassBatchModel cls) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Class & Batch?'),
        content: Text('Are you sure you want to remove "${cls.name} (${cls.code})"? This will dissociate student section enrollments.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        _classes.removeWhere((c) => c.id == cls.id);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Class ${cls.code} removed from system.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    final totalEnrolled = _classes.fold<int>(0, (sum, c) => sum + c.enrolled);
    final totalCap = _classes.fold<int>(0, (sum, c) => sum + c.capacity);
    final avgUtil = totalCap > 0 ? (totalEnrolled / totalCap * 100) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Class & Batch Management',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textMain),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'View and organize academic courses, section batch rosters, student capacity, and room allocations.',
                    style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                if (!isMobile)
                  OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Class & Batch roster exported to CSV.')),
                      );
                    },
                    icon: const Icon(Icons.file_download_outlined, size: 16),
                    label: const Text('Export Roster'),
                  ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: () => _showAddOrEditClassDialog(),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add Class / Batch'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.adminPrimary),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),

        // 4 Metric Cards
        Row(
          children: [
            Expanded(
              child: MetricCard(
                title: 'Total Active Classes',
                value: '${_classes.length}',
                icon: Icons.class_outlined,
                color: AppColors.primary,
                subtitle: 'Active course sections',
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: MetricCard(
                title: 'Total Enrolled',
                value: '$totalEnrolled',
                icon: Icons.groups_outlined,
                color: AppColors.studentPrimary,
                subtitle: 'Across all sections',
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: MetricCard(
                title: 'Active Classrooms',
                value: '24',
                icon: Icons.meeting_room_outlined,
                color: AppColors.teacherPrimary,
                subtitle: 'Halls & labs utilized',
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: MetricCard(
                title: 'Avg Utilization',
                value: '${avgUtil.toStringAsFixed(1)}%',
                icon: Icons.pie_chart_outline,
                color: AppColors.accentGreen,
                subtitle: 'Optimal occupancy rate',
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Filter & Search Toolbar
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
              SizedBox(
                width: 300,
                child: TextField(
                  onChanged: (v) => setState(() => _searchQuery = v),
                  decoration: const InputDecoration(
                    hintText: 'Search by class name, code, dept...',
                    prefixIcon: Icon(Icons.search, size: 20),
                    contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                ),
              ),
              Wrap(
                spacing: 12,
                runSpacing: 10,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  DropdownButton<String>(
                    value: _selectedDept,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: 'All', child: Text('All Departments')),
                      DropdownMenuItem(value: 'Computer Science', child: Text('Computer Science')),
                      DropdownMenuItem(value: 'Mathematics', child: Text('Mathematics')),
                      DropdownMenuItem(value: 'Physics', child: Text('Physics')),
                      DropdownMenuItem(value: 'Commerce', child: Text('Commerce')),
                    ],
                    onChanged: (v) => setState(() => _selectedDept = v ?? 'All'),
                  ),
                  DropdownButton<String>(
                    value: _selectedSemester,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: 'All', child: Text('All Semesters')),
                      DropdownMenuItem(value: 'Semester 1', child: Text('Semester 1')),
                      DropdownMenuItem(value: 'Semester 2', child: Text('Semester 2')),
                      DropdownMenuItem(value: 'Semester 3', child: Text('Semester 3')),
                      DropdownMenuItem(value: 'Semester 4', child: Text('Semester 4')),
                      DropdownMenuItem(value: 'Semester 5', child: Text('Semester 5')),
                      DropdownMenuItem(value: 'Semester 6', child: Text('Semester 6')),
                    ],
                    onChanged: (v) => setState(() => _selectedSemester = v ?? 'All'),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Interactive Classes Table Container
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
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Classes & Batch Allocations (${_filteredClasses.length})',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                    ),
                    Text(
                      'Showing 1-${_filteredClasses.length} of ${_classes.length}',
                      style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppColors.border),

              if (_filteredClasses.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(
                    child: Text('No classes found matching search filters.', style: TextStyle(color: AppColors.textMuted)),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _filteredClasses.length,
                  separatorBuilder: (_, _) => const Divider(height: 1, color: AppColors.borderLight),
                  itemBuilder: (context, index) {
                    final cls = _filteredClasses[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      child: Row(
                        children: [
                          // Index
                          Container(
                            width: 28,
                            alignment: Alignment.center,
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(fontSize: 12, color: AppColors.textLight, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Class Name & Department
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  cls.name,
                                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textMain),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${cls.department} • ${cls.semester}',
                                  style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                                ),
                              ],
                            ),
                          ),

                          // Code & Section Pill
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.bgSurface,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Text(
                              cls.code,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              cls.section,
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary),
                            ),
                          ),
                          const SizedBox(width: 16),

                          // Capacity / Enrolled with progress bar
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${cls.enrolled}/${cls.capacity} students',
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMain),
                                    ),
                                    Text(
                                      '${(cls.utilizationRate * 100).toInt()}%',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: cls.utilizationRate >= 0.9 ? AppColors.warning : AppColors.success,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(3),
                                  child: LinearProgressIndicator(
                                    value: cls.utilizationRate,
                                    minHeight: 5,
                                    backgroundColor: AppColors.bgSurface,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      cls.utilizationRate >= 0.9 ? AppColors.warning : AppColors.accentGreen,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),

                          // Instructor & Room
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  cls.instructor,
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textMain),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    const Icon(Icons.room, size: 12, color: AppColors.textLight),
                                    const SizedBox(width: 3),
                                    Text(cls.room, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Action Buttons
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.schedule, size: 18, color: AppColors.primary),
                                tooltip: 'View Lecture Schedule',
                                onPressed: () {
                                  if (widget.onNavigate != null) {
                                    widget.onNavigate!('lecture-schedule', param: cls.code);
                                  }
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.textMuted),
                                tooltip: 'Edit Class',
                                onPressed: () => _showAddOrEditClassDialog(cls),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                                tooltip: 'Delete Class',
                                onPressed: () => _handleDeleteClass(cls),
                              ),
                            ],
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
}
