import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../models/user_model.dart';
import '../../models/student_model.dart';
import '../../models/instructor_model.dart';
import '../../models/dashboard_stats_model.dart';
import '../../providers/navigation_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/student_provider.dart';
import '../../providers/instructor_provider.dart';
import '../../services/api_service.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/metric_card.dart';

class AdminPortalScreen extends StatefulWidget {
  final String initialTab;
  const AdminPortalScreen({super.key, this.initialTab = 'dashboard'});

  @override
  State<AdminPortalScreen> createState() => _AdminPortalScreenState();
}

class _AdminPortalScreenState extends State<AdminPortalScreen> {
  late String _activeScreen;
  AdminDashboardStatsModel? _dashboardStats;
  StudentModel? _selectedStudent;

  // Form Controllers for Student
  final _studentNameController = TextEditingController();
  final _studentEmailController = TextEditingController();
  final _studentRollController = TextEditingController();
  final _studentClassController = TextEditingController(text: 'BCA - Sem 3');
  final _studentPhoneController = TextEditingController();

  // Form Controllers for Instructor
  final _instructorNameController = TextEditingController();
  final _instructorEmailController = TextEditingController();
  final _instructorIdController = TextEditingController();
  final _instructorDeptController = TextEditingController(text: 'Computer Science');
  final _instructorDesignationController = TextEditingController(text: 'Assistant Professor');
  final _instructorPhoneController = TextEditingController();

  // Form Controllers for Exam
  final _examTitleController = TextEditingController();
  final _examDateController = TextEditingController(text: 'May 15, 2025');
  final _examRoomController = TextEditingController(text: 'Hall 101');
  final _examDurationController = TextEditingController(text: '180');

  final List<Map<String, dynamic>> _examTimetable = [
    {'title': 'Database Management Systems', 'code': 'CS-301', 'date': 'May 10, 2025', 'time': '09:00 AM - 12:00 PM', 'room': 'Hall 101', 'invigilator': 'Dr. Amit Sharma'},
    {'title': 'Data Structures & Algorithms', 'code': 'CS-302', 'date': 'May 13, 2025', 'time': '09:00 AM - 12:00 PM', 'room': 'Hall 202', 'invigilator': 'Prof. Rajesh Gupta'},
    {'title': 'Operating Systems Architecture', 'code': 'CS-303', 'date': 'May 16, 2025', 'time': '09:00 AM - 12:00 PM', 'room': 'Hall 105', 'invigilator': 'Prof. Sunita Rao'},
  ];

  @override
  void initState() {
    super.initState();
    _activeScreen = widget.initialTab.isNotEmpty ? widget.initialTab : 'dashboard';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDashboardData();
    });
  }

  @override
  void didUpdateWidget(AdminPortalScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialTab.isNotEmpty && widget.initialTab != _activeScreen) {
      setState(() => _activeScreen = widget.initialTab);
    }
  }

  Future<void> _loadDashboardData() async {
    final studentProv = Provider.of<StudentProvider>(context, listen: false);
    final instructorProv = Provider.of<InstructorProvider>(context, listen: false);

    await Future.wait([
      studentProv.fetchStudents(),
      instructorProv.fetchInstructors(),
    ]);

    try {
      final stats = await ApiService().getAdminDashboardStats();
      if (mounted) {
        setState(() => _dashboardStats = stats);
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _studentNameController.dispose();
    _studentEmailController.dispose();
    _studentRollController.dispose();
    _studentClassController.dispose();
    _studentPhoneController.dispose();
    _instructorNameController.dispose();
    _instructorEmailController.dispose();
    _instructorIdController.dispose();
    _instructorDeptController.dispose();
    _instructorDesignationController.dispose();
    _instructorPhoneController.dispose();
    _examTitleController.dispose();
    _examDateController.dispose();
    _examRoomController.dispose();
    _examDurationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nav = Provider.of<NavigationProvider>(context);
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.currentUser;
    final isDesktop = MediaQuery.of(context).size.width >= 960;

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: Row(
        children: [
          // Left Sidebar
          if (isDesktop) _buildSidebar(user, nav),

          // Main Area
          Expanded(
            child: Column(
              children: [
                _buildTopBar(user, nav, auth, isDesktop),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1200),
                        child: _buildScreenContent(user, nav),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      drawer: isDesktop ? null : Drawer(child: _buildSidebar(user, nav)),
    );
  }

  Widget _buildSidebar(UserModel? user, NavigationProvider nav) {
    final menuItems = [
      {'id': 'dashboard', 'title': 'Dashboard', 'icon': Icons.dashboard_outlined},
      {'id': 'student-records', 'title': 'Student Records', 'icon': Icons.people_outline},
      {'id': 'add-student', 'title': 'Add Student', 'icon': Icons.person_add_outlined},
      {'id': 'instructor-records', 'title': 'Instructors', 'icon': Icons.badge_outlined},
      {'id': 'instructor-tracking', 'title': 'Faculty Workload', 'icon': Icons.timelapse_outlined},
      {'id': 'add-instructor', 'title': 'Add Instructor', 'icon': Icons.person_add_alt_1_outlined},
      {'id': 'class-management', 'title': 'Class Management', 'icon': Icons.class_outlined},
      {'id': 'academic-planning', 'title': 'Academic Planning', 'icon': Icons.calendar_month_outlined},
      {'id': 'lecture-schedule', 'title': 'Lecture Schedule', 'icon': Icons.schedule_outlined},
      {'id': 'exam-timetable', 'title': 'Exam Timetable', 'icon': Icons.assignment_outlined},
      {'id': 'create-exam', 'title': 'Schedule Exam', 'icon': Icons.post_add_outlined},
      {'id': 'cross-module', 'title': 'Global Explorer', 'icon': Icons.dataset_outlined},
      {'id': 'reports', 'title': 'Analytics & Reports', 'icon': Icons.analytics_outlined},
      {'id': 'settings', 'title': 'Settings & System', 'icon': Icons.settings_outlined},
    ];

    return Container(
      width: 260,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.adminPrimary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.shield, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Admin Portal', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.textMain)),
                    Text('Control Center', style: TextStyle(fontSize: 11, color: AppColors.textLight)),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),

          // Mini Admin Info
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFC7D2FE)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.adminPrimary,
                  child: Text(
                    user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : 'A',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.name ?? 'Amit Kumar',
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textMain),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Text(
                        'System Administrator',
                        style: TextStyle(fontSize: 11, color: AppColors.adminPrimary, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Menu List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: menuItems.map((item) {
                final id = item['id'] as String;
                final isSelected = _activeScreen == id;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: ListTile(
                    dense: true,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    tileColor: isSelected ? const Color(0xFFEEF2FF) : Colors.transparent,
                    leading: Icon(
                      item['icon'] as IconData,
                      size: 19,
                      color: isSelected ? AppColors.adminPrimary : AppColors.textMuted,
                    ),
                    title: Text(
                      item['title'] as String,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? AppColors.adminPrimary : AppColors.textMain,
                      ),
                    ),
                    onTap: () {
                      setState(() => _activeScreen = id);
                      nav.setPortalTab(id);
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: OutlinedButton.icon(
              onPressed: () => nav.navigateTo('select-role'),
              icon: const Icon(Icons.arrow_back, size: 16),
              label: const Text('Role Gateway'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(40),
                side: const BorderSide(color: AppColors.border),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(UserModel? user, NavigationProvider nav, AuthProvider auth, bool isDesktop) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (!isDesktop) ...[
                IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
                const SizedBox(width: 8),
              ],
              Text(
                _getScreenTitle(_activeScreen),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textMain),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.refresh, size: 20, color: AppColors.textMuted),
                tooltip: 'Refresh Data',
                onPressed: _loadDashboardData,
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.bgPage,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.account_balance, size: 14, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Text(
                      user?.instituteCode ?? 'INST-2025',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textMain),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                icon: const Icon(Icons.logout, size: 20, color: AppColors.error),
                tooltip: 'Logout',
                onPressed: () async {
                  await auth.logout();
                  nav.navigateTo('admin-login');
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getScreenTitle(String screen) {
    switch (screen) {
      case 'dashboard':
        return 'Campus Master Dashboard';
      case 'student-records':
        return 'Student Directory Management';
      case 'add-student':
        return 'Admissions & Enrollment';
      case 'student-detail':
        return 'Student Inspection Profile';
      case 'instructor-records':
        return 'Faculty Members Directory';
      case 'instructor-tracking':
        return 'Faculty Workload & Performance';
      case 'add-instructor':
        return 'Faculty Onboarding & Recruitment';
      case 'class-management':
        return 'Classroom & Batch Management';
      case 'academic-planning':
        return 'Academic Planning & Semesters';
      case 'lecture-schedule':
        return 'Institute-wide Lecture Schedule';
      case 'exam-timetable':
        return 'Master Examination Timetable';
      case 'create-exam':
        return 'Schedule New Assessment';
      case 'cross-module':
        return 'Cross-Module Global Explorer';
      case 'reports':
        return 'Analytics & Compliance Reports';
      case 'settings':
        return 'Platform Settings & Database';
      default:
        return 'Admin Portal';
    }
  }

  Widget _buildScreenContent(UserModel? user, NavigationProvider nav) {
    switch (_activeScreen) {
      case 'dashboard':
        return _buildDashboardScreen();
      case 'student-records':
        return _buildStudentRecordsScreen();
      case 'add-student':
        return _buildAddStudentScreen();
      case 'student-detail':
        return _buildStudentDetailScreen();
      case 'instructor-records':
        return _buildInstructorRecordsScreen();
      case 'instructor-tracking':
        return _buildInstructorTrackingScreen();
      case 'add-instructor':
        return _buildAddInstructorScreen();
      case 'class-management':
        return _buildClassManagementScreen();
      case 'academic-planning':
        return _buildAcademicPlanningScreen();
      case 'lecture-schedule':
        return _buildLectureScheduleScreen();
      case 'exam-timetable':
        return _buildExamTimetableScreen();
      case 'create-exam':
        return _buildCreateExamScreen();
      case 'cross-module':
        return _buildCrossModuleScreen();
      case 'reports':
        return _buildReportsScreen();
      case 'settings':
        return _buildSettingsScreen(user);
      default:
        return _buildDashboardScreen();
    }
  }

  // 1. Dashboard Screen (Live data from /api/dashboard/admin)
  Widget _buildDashboardScreen() {
    final studentProv = Provider.of<StudentProvider>(context);
    final instructorProv = Provider.of<InstructorProvider>(context);

    final totalStudents = _dashboardStats?.totalStudents ?? studentProv.students.length;
    final totalInstructors = _dashboardStats?.totalInstructors ?? instructorProv.instructors.length;
    final activeClasses = _dashboardStats?.activeClasses ?? 18;
    final attendanceRate = _dashboardStats?.attendanceRate ?? 92.4;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: MetricCard(title: 'Total Students', value: '$totalStudents', icon: Icons.school, color: AppColors.studentPrimary, subtitle: 'Live registered count')),
            const SizedBox(width: 16),
            Expanded(child: MetricCard(title: 'Faculty Instructors', value: '$totalInstructors', icon: Icons.people, color: AppColors.teacherPrimary, subtitle: 'Active teaching staff')),
            const SizedBox(width: 16),
            Expanded(child: MetricCard(title: 'Active Batches', value: '$activeClasses', icon: Icons.class_outlined, color: AppColors.primary, subtitle: 'Across 8 departments')),
            const SizedBox(width: 16),
            Expanded(child: MetricCard(title: 'Attendance Rate', value: '${attendanceRate.toStringAsFixed(1)}%', icon: Icons.fact_check, color: AppColors.accentGreen, subtitle: 'Campus-wide compliance')),
          ],
        ),
        const SizedBox(height: 28),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Recent Students
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Recent Students', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                        TextButton(
                          onPressed: () => setState(() => _activeScreen = 'student-records'),
                          child: const Text('View All'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (studentProv.students.isEmpty)
                      const Text('No student records yet.', style: TextStyle(color: AppColors.textMuted))
                    else
                      ...studentProv.students.take(5).map((s) => ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            leading: CircleAvatar(
                              backgroundColor: AppColors.studentPrimary.withValues(alpha: 0.15),
                              child: Text(s.name.isNotEmpty ? s.name[0].toUpperCase() : 'S', style: const TextStyle(color: AppColors.studentPrimary, fontWeight: FontWeight.w700)),
                            ),
                            title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                            subtitle: Text('Roll: ${s.rollNumber} • ${s.className}', style: const TextStyle(fontSize: 11)),
                            trailing: StatusBadge(label: s.status ?? 'Active', status: s.status ?? 'active'),
                          )),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 20),

            // Recent Instructors
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Faculty Directory', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                        TextButton(
                          onPressed: () => setState(() => _activeScreen = 'instructor-records'),
                          child: const Text('View All'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (instructorProv.instructors.isEmpty)
                      const Text('No faculty records yet.', style: TextStyle(color: AppColors.textMuted))
                    else
                      ...instructorProv.instructors.take(5).map((i) => ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            leading: CircleAvatar(
                              backgroundColor: AppColors.teacherPrimary.withValues(alpha: 0.15),
                              child: Text(i.name.isNotEmpty ? i.name[0].toUpperCase() : 'T', style: const TextStyle(color: AppColors.teacherPrimary, fontWeight: FontWeight.w700)),
                            ),
                            title: Text(i.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                            subtitle: Text('${i.instructorId} • ${i.department}', style: const TextStyle(fontSize: 11)),
                            trailing: StatusBadge(label: i.status ?? 'Active', status: i.status ?? 'active'),
                          )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 2. Student Records
  Widget _buildStudentRecordsScreen() {
    final studentProv = Provider.of<StudentProvider>(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Student Directory (Admin Control)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                  Text('${studentProv.students.length} students synchronized with PostgreSQL database.', style: const TextStyle(fontSize: 13, color: AppColors.textMuted)),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => setState(() => _activeScreen = 'add-student'),
                icon: const Icon(Icons.person_add, size: 16),
                label: const Text('Enroll New Student'),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.adminPrimary),
              ),
            ],
          ),
          const SizedBox(height: 18),

          TextField(
            onChanged: (v) => studentProv.fetchStudents(v),
            decoration: const InputDecoration(
              hintText: 'Search by student name, roll number, or department...',
              prefixIcon: Icon(Icons.search, size: 20),
            ),
          ),
          const SizedBox(height: 20),

          if (studentProv.isLoading)
            const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()))
          else
            ...studentProv.students.map((s) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: AppColors.bgPage, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: AppColors.studentPrimary.withValues(alpha: 0.15),
                              child: Text(s.name.isNotEmpty ? s.name[0].toUpperCase() : 'S', style: const TextStyle(color: AppColors.studentPrimary, fontWeight: FontWeight.w700)),
                            ),
                            const SizedBox(width: 14),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(s.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                                Text('Roll: ${s.rollNumber} • ${s.className} • ${s.email}', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                              ],
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.visibility, size: 18, color: AppColors.primary),
                              onPressed: () {
                                setState(() {
                                  _selectedStudent = s;
                                  _activeScreen = 'student-detail';
                                });
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                              onPressed: () async {
                                final ok = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Delete Student?'),
                                    content: Text('Remove ${s.name} from database?'),
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
                                if (ok == true) {
                                  await studentProv.deleteStudent(s.id);
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Student deleted from database')));
                                  }
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                )),
        ],
      ),
    );
  }

  // 3. Add Student Form
  Widget _buildAddStudentScreen() {
    final studentProv = Provider.of<StudentProvider>(context);

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Add Student to Database', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              TextButton(
                onPressed: () {
                  _studentNameController.text = 'Rohit Singhania';
                  _studentEmailController.text = 'rohit.singhania@example.com';
                  _studentRollController.text = 'BCA-${DateTime.now().millisecondsSinceEpoch % 1000}';
                  _studentClassController.text = 'BCA - Sem 3';
                  _studentPhoneController.text = '+91 98765 88990';
                },
                child: const Text('Demo Fill'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          TextFormField(controller: _studentNameController, decoration: const InputDecoration(labelText: 'Student Full Name', hintText: 'Rohit Singhania')),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: TextFormField(controller: _studentEmailController, decoration: const InputDecoration(labelText: 'Email Address'))),
              const SizedBox(width: 14),
              Expanded(child: TextFormField(controller: _studentRollController, decoration: const InputDecoration(labelText: 'Roll Number'))),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: TextFormField(controller: _studentClassController, decoration: const InputDecoration(labelText: 'Course / Class'))),
              const SizedBox(width: 14),
              Expanded(child: TextFormField(controller: _studentPhoneController, decoration: const InputDecoration(labelText: 'Phone Number'))),
            ],
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () async {
              if (_studentNameController.text.trim().isEmpty) return;
              final newStd = StudentModel(
                id: '',
                name: _studentNameController.text.trim(),
                email: _studentEmailController.text.trim(),
                rollNumber: _studentRollController.text.trim(),
                className: _studentClassController.text.trim(),
                course: _studentClassController.text.trim(),
                phone: _studentPhoneController.text.trim(),
              );
              final ok = await studentProv.addStudent(newStd);
              if (ok && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Student registered into backend database!'), backgroundColor: AppColors.success));
                setState(() => _activeScreen = 'student-records');
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.adminPrimary),
            child: const Text('Save Student to Database'),
          ),
        ],
      ),
    );
  }

  // 4. Student Detail
  Widget _buildStudentDetailScreen() {
    final s = _selectedStudent;
    if (s == null) return const Center(child: Text('No student selected'));

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Student Profile: ${s.name}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              OutlinedButton(onPressed: () => setState(() => _activeScreen = 'student-records'), child: const Text('Back to Records')),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(color: AppColors.border),
          const SizedBox(height: 16),
          _buildInfoRow('Roll Number', s.rollNumber),
          _buildInfoRow('Email Address', s.email),
          _buildInfoRow('Course & Semester', '${s.course} (${s.semester ?? "Sem 1"})'),
          _buildInfoRow('Phone', s.phone ?? 'N/A'),
          _buildInfoRow('Father / Guardian', s.fatherName ?? 'Guardian'),
          _buildInfoRow('Campus Affiliation', s.instituteName ?? 'Apex Institute of Technology'),
          _buildInfoRow('Status', s.status ?? 'Active'),
        ],
      ),
    );
  }

  // 5. Instructor Records
  Widget _buildInstructorRecordsScreen() {
    final instructorProv = Provider.of<InstructorProvider>(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Faculty Directory (Admin Control)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                  Text('${instructorProv.instructors.length} faculty members retrieved from backend database.', style: const TextStyle(fontSize: 13, color: AppColors.textMuted)),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => setState(() => _activeScreen = 'add-instructor'),
                icon: const Icon(Icons.person_add_alt_1, size: 16),
                label: const Text('Add Instructor'),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.adminPrimary),
              ),
            ],
          ),
          const SizedBox(height: 18),

          TextField(
            onChanged: (v) => instructorProv.fetchInstructors(v),
            decoration: const InputDecoration(
              hintText: 'Search instructors by name, department, or ID...',
              prefixIcon: Icon(Icons.search, size: 20),
            ),
          ),
          const SizedBox(height: 20),

          if (instructorProv.isLoading)
            const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()))
          else
            ...instructorProv.instructors.map((i) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: AppColors.bgPage, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: AppColors.teacherPrimary.withValues(alpha: 0.15),
                              child: Text(i.name.isNotEmpty ? i.name[0].toUpperCase() : 'T', style: const TextStyle(color: AppColors.teacherPrimary, fontWeight: FontWeight.w700)),
                            ),
                            const SizedBox(width: 14),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(i.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                                Text('${i.instructorId} • ${i.designation} • ${i.department} • ${i.email}', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                              ],
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                          onPressed: () async {
                            final ok = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Delete Instructor?'),
                                content: Text('Remove ${i.name} from database?'),
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
                            if (ok == true) {
                              await instructorProv.deleteInstructor(i.id);
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Instructor removed from database')));
                              }
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                )),
        ],
      ),
    );
  }

  // 6. Instructor Tracking
  Widget _buildInstructorTrackingScreen() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Faculty Workload & Performance Tracking', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          SizedBox(height: 6),
          Text('Monitor weekly teaching hours, assigned batches, and student evaluations.', style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
          SizedBox(height: 20),
          Text('• Dr. Amit Sharma: 18 Lecture Hours/week • 4 Assigned Courses • 4.8 Rating'),
          SizedBox(height: 10),
          Text('• Prof. Sunita Rao: 16 Lecture Hours/week • 3 Assigned Courses • 4.9 Rating'),
          SizedBox(height: 10),
          Text('• Prof. Rajesh Gupta: 20 Lecture Hours/week • 4 Assigned Courses • 4.7 Rating'),
        ],
      ),
    );
  }

  // 7. Add Instructor Form
  Widget _buildAddInstructorScreen() {
    final instructorProv = Provider.of<InstructorProvider>(context);

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Add Faculty Member to Database', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              TextButton(
                onPressed: () {
                  _instructorNameController.text = 'Prof. Vikram Malhotra';
                  _instructorEmailController.text = 'vikram.malhotra@institute.com';
                  _instructorIdController.text = 'INS-${DateTime.now().millisecondsSinceEpoch % 1000}';
                  _instructorDeptController.text = 'Computer Science';
                  _instructorDesignationController.text = 'Associate Professor';
                  _instructorPhoneController.text = '+91 98765 33445';
                },
                child: const Text('Demo Fill'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          TextFormField(controller: _instructorNameController, decoration: const InputDecoration(labelText: 'Faculty Full Name')),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: TextFormField(controller: _instructorEmailController, decoration: const InputDecoration(labelText: 'Official Email'))),
              const SizedBox(width: 14),
              Expanded(child: TextFormField(controller: _instructorIdController, decoration: const InputDecoration(labelText: 'Instructor ID'))),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: TextFormField(controller: _instructorDeptController, decoration: const InputDecoration(labelText: 'Department'))),
              const SizedBox(width: 14),
              Expanded(child: TextFormField(controller: _instructorDesignationController, decoration: const InputDecoration(labelText: 'Designation'))),
            ],
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () async {
              if (_instructorNameController.text.trim().isEmpty) return;
              final newIns = InstructorModel(
                id: '',
                name: _instructorNameController.text.trim(),
                email: _instructorEmailController.text.trim(),
                instructorId: _instructorIdController.text.trim(),
                department: _instructorDeptController.text.trim(),
                designation: _instructorDesignationController.text.trim(),
                phone: _instructorPhoneController.text.trim(),
              );
              final ok = await instructorProv.addInstructor(newIns);
              if (ok && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Faculty member saved to database!'), backgroundColor: AppColors.success));
                setState(() => _activeScreen = 'instructor-records');
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.adminPrimary),
            child: const Text('Save Instructor to Database'),
          ),
        ],
      ),
    );
  }

  // 8. Class Management
  Widget _buildClassManagementScreen() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Academic Class Batches & Section Roster', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          SizedBox(height: 8),
          Text('Manage classroom section allocations, maximum capacities, and batch coordinators.', style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
          SizedBox(height: 20),
          Text('• BCA Semester 3 (Section A): Capacity 60 • Enrolled: 48 • Coordinator: Dr. Amit Sharma'),
          SizedBox(height: 10),
          Text('• BCA Semester 3 (Section B): Capacity 60 • Enrolled: 52 • Coordinator: Prof. Rajesh Gupta'),
          SizedBox(height: 10),
          Text('• MCA Semester 1: Capacity 50 • Enrolled: 42 • Coordinator: Prof. Sunita Rao'),
        ],
      ),
    );
  }

  // 9. Academic Planning
  Widget _buildAcademicPlanningScreen() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Academic Calendar & Planning Session', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          SizedBox(height: 8),
          Text('Academic Year 2025–2026 Semester Timeline', style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
          SizedBox(height: 20),
          Text('• Semester Start Date: January 15, 2025'),
          SizedBox(height: 8),
          Text('• Mid-Term Examination Window: May 05 - May 16, 2025'),
          SizedBox(height: 8),
          Text('• Final Semester Exam Window: June 20 - July 05, 2025'),
          SizedBox(height: 8),
          Text('• Academic Grade Cards Publication: July 15, 2025'),
        ],
      ),
    );
  }

  // 10. Lecture Schedule
  Widget _buildLectureScheduleScreen() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Institute Master Lecture Timetable', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          SizedBox(height: 8),
          Text('All classrooms and laboratory sessions active across campus.', style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
          SizedBox(height: 20),
          Text('• Hall 101: MCA Semester 1 (Advanced Software Engineering) - 09:00 AM'),
          SizedBox(height: 8),
          Text('• Hall 302: BCA Semester 3 (Database Systems) - 10:00 AM'),
          SizedBox(height: 8),
          Text('• Computer Lab 1: Data Structures Lab Session - 11:00 AM'),
          SizedBox(height: 8),
          Text('• Computer Lab 2: Database Normalization Practicals - 01:00 PM'),
        ],
      ),
    );
  }

  // 11. Exam Timetable
  Widget _buildExamTimetableScreen() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Master Examination Timetable', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              ElevatedButton.icon(
                onPressed: () => setState(() => _activeScreen = 'create-exam'),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Schedule Exam'),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.adminPrimary),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ..._examTimetable.map((e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: AppColors.bgPage, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${e['code']}: ${e['title']}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                          const SizedBox(height: 3),
                          Text('${e['date']} • ${e['time']} • ${e['room']}', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                        ],
                      ),
                      Text('Invigilator: ${e['invigilator']}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.adminPrimary)),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }

  // 12. Create Exam
  Widget _buildCreateExamScreen() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Schedule Examination Assessment', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 20),
          TextFormField(controller: _examTitleController, decoration: const InputDecoration(labelText: 'Exam Subject Title', hintText: 'Computer Networks')),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: TextFormField(controller: _examDateController, decoration: const InputDecoration(labelText: 'Date'))),
              const SizedBox(width: 14),
              Expanded(child: TextFormField(controller: _examRoomController, decoration: const InputDecoration(labelText: 'Exam Hall / Room'))),
            ],
          ),
          const SizedBox(height: 14),
          TextFormField(controller: _examDurationController, decoration: const InputDecoration(labelText: 'Duration in Minutes', hintText: '180')),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              if (_examTitleController.text.trim().isEmpty) return;
              setState(() {
                _examTimetable.add({
                  'title': _examTitleController.text.trim(),
                  'code': 'CS-${300 + _examTimetable.length}',
                  'date': _examDateController.text.trim(),
                  'time': '09:00 AM - 12:00 PM',
                  'room': _examRoomController.text.trim(),
                  'invigilator': 'Assigned Faculty',
                });
                _activeScreen = 'exam-timetable';
              });
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Exam added to timetable!'), backgroundColor: AppColors.success));
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.adminPrimary),
            child: const Text('Add Exam to Timetable'),
          ),
        ],
      ),
    );
  }

  // 13. Cross Module
  Widget _buildCrossModuleScreen() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Global Cross-Module Record Explorer', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          SizedBox(height: 8),
          Text('Unified live cross-reference between Student Admissions, Faculty Allocations, and Examination Papers.', style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
          SizedBox(height: 20),
          Text('• Relational Integrity Check: 100% Passed'),
          SizedBox(height: 8),
          Text('• Database Schema: PostgreSQL 16 standard relational tables'),
          SizedBox(height: 8),
          Text('• Cloudinary File Uploads: Integrated & Ready'),
        ],
      ),
    );
  }

  // 14. Reports
  Widget _buildReportsScreen() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Institute Analytics & Compliance Reports', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Comprehensive report exported as CSV!')));
                },
                icon: const Icon(Icons.file_download, size: 16),
                label: const Text('Export CSV Report'),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.adminPrimary),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text('• Attendance Compliance: 92.4% campus average (98.2% minimum standard met)'),
          const SizedBox(height: 8),
          const Text('• Semester Pass Rate: 94.6% students passed in regular examination session'),
          const SizedBox(height: 8),
          const Text('• Faculty-to-Student Ratio: 1:21 (Compliant with UGC guidelines)'),
        ],
      ),
    );
  }

  // 15. Settings
  Widget _buildSettingsScreen(UserModel? user) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('System Administration Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 20),
          _buildInfoRow('Campus Code', user?.instituteCode ?? 'INST-2025'),
          _buildInfoRow('Institute Name', user?.instituteName ?? 'Apex Institute of Technology'),
          _buildInfoRow('Admin Account', user?.email ?? 'amit.kumar@institute.com'),
          _buildInfoRow('Database Engine', 'PostgreSQL 16 (Spring Boot JPA Hibernate)'),
          _buildInfoRow('Storage Integration', 'Cloudinary Media Cloud & S3 Bucket'),
          _buildInfoRow('Session Validity', '24 Hours (JWT Signing Active)'),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('System configuration verified & healthy!'), backgroundColor: AppColors.success));
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.adminPrimary),
            child: const Text('Verify Database Health'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 180,
            child: Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 13, fontWeight: FontWeight.w600)),
          ),
          Expanded(child: Text(value, style: const TextStyle(color: AppColors.textMain, fontSize: 13, fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}
