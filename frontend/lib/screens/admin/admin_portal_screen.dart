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
import '../portal_modules_screen.dart';
import '../../widgets/portal_notification_bell.dart';
import '../../widgets/portal_announcement_preview.dart';

class AdminPortalScreen extends StatefulWidget {
  final String initialTab;
  final String? initialTargetId;
  const AdminPortalScreen({
    super.key,
    this.initialTab = 'dashboard',
    this.initialTargetId,
  });

  @override
  State<AdminPortalScreen> createState() => _AdminPortalScreenState();
}

class _AdminPortalScreenState extends State<AdminPortalScreen> {
  late String _activeScreen;
  AdminDashboardStatsModel? _dashboardStats;
  StudentModel? _selectedStudent;
  String _explorerSearchQuery = '';
  String _explorerTypeFilter = 'All records';

  // Form Controllers for Student
  final _studentNameController = TextEditingController();
  final _studentEmailController = TextEditingController();
  final _studentRollController = TextEditingController();
  final _studentClassController = TextEditingController(text: 'BCA - Sem 3');
  final _studentPhoneController = TextEditingController();
  final _studentPasswordController = TextEditingController();

  // Form Controllers for Instructor
  final _instructorNameController = TextEditingController();
  final _instructorEmailController = TextEditingController();
  final _instructorIdController = TextEditingController();
  final _instructorDeptController = TextEditingController(
    text: 'Computer Science',
  );
  final _instructorDesignationController = TextEditingController(
    text: 'Assistant Professor',
  );
  final _instructorPhoneController = TextEditingController();
  final _instructorPasswordController = TextEditingController();

  // Form Controllers for Exam
  final _examTitleController = TextEditingController();
  final _examDateController = TextEditingController(text: 'May 15, 2025');
  final _examRoomController = TextEditingController(text: 'Hall 101');
  final _examDurationController = TextEditingController(text: '180');

  final List<Map<String, dynamic>> _examTimetable = [
    {
      'title': 'Database Management Systems',
      'code': 'CS-301',
      'date': 'May 10, 2025',
      'time': '09:00 AM - 12:00 PM',
      'room': 'Hall 101',
      'invigilator': 'Dr. Amit Sharma',
    },
    {
      'title': 'Data Structures & Algorithms',
      'code': 'CS-302',
      'date': 'May 13, 2025',
      'time': '09:00 AM - 12:00 PM',
      'room': 'Hall 202',
      'invigilator': 'Prof. Rajesh Gupta',
    },
    {
      'title': 'Operating Systems Architecture',
      'code': 'CS-303',
      'date': 'May 16, 2025',
      'time': '09:00 AM - 12:00 PM',
      'room': 'Hall 105',
      'invigilator': 'Prof. Sunita Rao',
    },
  ];

  List<Map<String, dynamic>> _onlineExamsAdmin = [];
  bool _loadingOnlineExams = false;

  Future<void> _loadOnlineExamsAdmin() async {
    setState(() => _loadingOnlineExams = true);
    try {
      final exams = await ApiService().getExams();
      if (mounted) {
        setState(() {
          _onlineExamsAdmin = exams;
          _loadingOnlineExams = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingOnlineExams = false);
    }
  }

  Future<void> _toggleReleaseResults(
    String examId,
    bool currentReleased,
  ) async {
    try {
      await ApiService().releaseExamResults(examId, !currentReleased);
      await _loadOnlineExamsAdmin();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              !currentReleased
                  ? 'Exam results released! Students can now view their scorecards.'
                  : 'Exam results withheld from students.',
            ),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _activeScreen = widget.initialTab.isNotEmpty
        ? widget.initialTab
        : 'dashboard';
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
    final instructorProv = Provider.of<InstructorProvider>(
      context,
      listen: false,
    );

    await Future.wait([
      studentProv.fetchStudents(),
      instructorProv.fetchInstructors(),
      _loadOnlineExamsAdmin(),
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
    _studentPasswordController.dispose();
    _instructorNameController.dispose();
    _instructorEmailController.dispose();
    _instructorIdController.dispose();
    _instructorDeptController.dispose();
    _instructorDesignationController.dispose();
    _instructorPhoneController.dispose();
    _instructorPasswordController.dispose();
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
      {
        'id': 'dashboard',
        'title': 'Dashboard',
        'icon': Icons.dashboard_outlined,
      },
      {
        'id': 'student-records',
        'title': 'Student Records',
        'icon': Icons.people_outline,
      },
      {
        'id': 'add-student',
        'title': 'Add Student',
        'icon': Icons.person_add_outlined,
      },
      {
        'id': 'instructor-records',
        'title': 'Instructors',
        'icon': Icons.badge_outlined,
      },
      {
        'id': 'instructor-tracking',
        'title': 'Faculty Workload',
        'icon': Icons.timelapse_outlined,
      },
      {
        'id': 'add-instructor',
        'title': 'Add Instructor',
        'icon': Icons.person_add_alt_1_outlined,
      },
      {
        'id': 'academic-planning',
        'title': 'Academic Planning',
        'icon': Icons.calendar_month_outlined,
      },
      {
        'id': 'lecture-schedule',
        'title': 'Lecture Schedule',
        'icon': Icons.schedule_outlined,
      },
      {
        'id': 'exam-timetable',
        'title': 'Exam Timetable',
        'icon': Icons.assignment_outlined,
      },
      {
        'id': 'create-exam',
        'title': 'Schedule Exam',
        'icon': Icons.post_add_outlined,
      },
      {
        'id': 'announcements',
        'title': 'Announcements',
        'icon': Icons.campaign_outlined,
      },
      {
        'id': 'leaves',
        'title': 'Leave Management',
        'icon': Icons.event_available_outlined,
      },
      {
        'id': 'cross-module',
        'title': 'Global Explorer',
        'icon': Icons.dataset_outlined,
      },
      {
        'id': 'reports',
        'title': 'Analytics & Reports',
        'icon': Icons.analytics_outlined,
      },
      {
        'id': 'settings',
        'title': 'Settings & System',
        'icon': Icons.settings_outlined,
      },
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
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    'assets/images/educhain_icon.png',
                    width: 36,
                    height: 36,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'EduChain',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: Color(0xFF00337F),
                      ),
                    ),
                    Text(
                      'Admin Control Center',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textLight,
                      ),
                    ),
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
                    user?.name.isNotEmpty == true
                        ? user!.name[0].toUpperCase()
                        : 'A',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.name ?? 'Amit Kumar',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: AppColors.textMain,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Text(
                        'System Administrator',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.adminPrimary,
                          fontWeight: FontWeight.w600,
                        ),
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    tileColor: isSelected
                        ? const Color(0xFFEEF2FF)
                        : Colors.transparent,
                    leading: Icon(
                      item['icon'] as IconData,
                      size: 19,
                      color: isSelected
                          ? AppColors.adminPrimary
                          : AppColors.textMuted,
                    ),
                    title: Text(
                      item['title'] as String,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: isSelected
                            ? AppColors.adminPrimary
                            : AppColors.textMain,
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

  Widget _buildTopBar(
    UserModel? user,
    NavigationProvider nav,
    AuthProvider auth,
    bool isDesktop,
  ) {
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
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textMain,
                ),
              ),
            ],
          ),
          Row(
            children: [
              const PortalNotificationBell(role: 'admin'),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(
                  Icons.refresh,
                  size: 20,
                  color: AppColors.textMuted,
                ),
                tooltip: 'Refresh Data',
                onPressed: _loadDashboardData,
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.bgPage,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.account_balance,
                      size: 14,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      user?.instituteCode ?? 'INST-2025',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textMain,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                icon: const Icon(
                  Icons.logout,
                  size: 20,
                  color: AppColors.error,
                ),
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
      case 'academic-planning':
        return 'Academic Planning & Semesters';
      case 'lecture-schedule':
        return 'Institute-wide Lecture Schedule';
      case 'exam-timetable':
        return 'Master Examination Timetable';
      case 'create-exam':
        return 'Schedule New Assessment';
      case 'announcements':
        return 'Announcement Management';
      case 'leaves':
        return 'Leave Management';
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
      case 'academic-planning':
        return _buildAcademicPlanningScreen();
      case 'lecture-schedule':
        return _buildLectureScheduleScreen();
      case 'exam-timetable':
        return _buildExamTimetableScreen();
      case 'create-exam':
        return _buildCreateExamScreen();
      case 'announcements':
      case 'leaves':
        return PortalModulesScreen(
          key: ValueKey('$_activeScreen-${widget.initialTargetId ?? ''}'),
          role: 'admin',
          module: _activeScreen,
          user: user,
          targetId: widget.initialTargetId,
        );
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

    final totalStudents =
        _dashboardStats?.totalStudents ?? studentProv.students.length;
    final totalInstructors =
        _dashboardStats?.totalInstructors ?? instructorProv.instructors.length;
    final activeClasses = _dashboardStats?.activeClasses ?? 18;
    final attendanceRate = _dashboardStats?.attendanceRate ?? 92.4;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PortalAnnouncementPreview(role: 'admin'),
        Row(
          children: [
            Expanded(
              child: MetricCard(
                title: 'Total Students',
                value: '$totalStudents',
                icon: Icons.school,
                color: AppColors.studentPrimary,
                subtitle: 'Live registered count',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: MetricCard(
                title: 'Faculty Instructors',
                value: '$totalInstructors',
                icon: Icons.people,
                color: AppColors.teacherPrimary,
                subtitle: 'Active teaching staff',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: MetricCard(
                title: 'Active Batches',
                value: '$activeClasses',
                icon: Icons.class_outlined,
                color: AppColors.primary,
                subtitle: 'Across 8 departments',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: MetricCard(
                title: 'Attendance Rate',
                value: '${attendanceRate.toStringAsFixed(1)}%',
                icon: Icons.fact_check,
                color: AppColors.accentGreen,
                subtitle: 'Campus-wide compliance',
              ),
            ),
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
                      children: [
                        const Text(
                          'Recent Students',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        TextButton(
                          onPressed: () =>
                              setState(() => _activeScreen = 'student-records'),
                          child: const Text('View All'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (studentProv.students.isEmpty)
                      const Text(
                        'No student records yet.',
                        style: TextStyle(color: AppColors.textMuted),
                      )
                    else
                      ...studentProv.students
                          .take(5)
                          .map(
                            (s) => ListTile(
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              leading: CircleAvatar(
                                backgroundColor: AppColors.studentPrimary
                                    .withValues(alpha: 0.15),
                                child: Text(
                                  s.name.isNotEmpty
                                      ? s.name[0].toUpperCase()
                                      : 'S',
                                  style: const TextStyle(
                                    color: AppColors.studentPrimary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              title: Text(
                                s.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                              subtitle: Text(
                                'Roll: ${s.rollNumber} • ${s.className}',
                                style: const TextStyle(fontSize: 11),
                              ),
                              trailing: StatusBadge(
                                label: s.status ?? 'Active',
                                status: s.status ?? 'active',
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 20),

            // Recent Instructors
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(22),
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
                      children: [
                        const Text(
                          'Faculty Directory',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        TextButton(
                          onPressed: () => setState(
                            () => _activeScreen = 'instructor-records',
                          ),
                          child: const Text('View All'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (instructorProv.instructors.isEmpty)
                      const Text(
                        'No faculty records yet.',
                        style: TextStyle(color: AppColors.textMuted),
                      )
                    else
                      ...instructorProv.instructors
                          .take(5)
                          .map(
                            (i) => ListTile(
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              leading: CircleAvatar(
                                backgroundColor: AppColors.teacherPrimary
                                    .withValues(alpha: 0.15),
                                child: Text(
                                  i.name.isNotEmpty
                                      ? i.name[0].toUpperCase()
                                      : 'T',
                                  style: const TextStyle(
                                    color: AppColors.teacherPrimary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              title: Text(
                                i.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                              subtitle: Text(
                                '${i.instructorId} • ${i.department}',
                                style: const TextStyle(fontSize: 11),
                              ),
                              trailing: StatusBadge(
                                label: i.status ?? 'Active',
                                status: i.status ?? 'active',
                              ),
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

  // 2. Student Records
  Widget _buildStudentRecordsScreen() {
    final studentProv = Provider.of<StudentProvider>(context);

    return Container(
      padding: const EdgeInsets.all(24),
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
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Student Directory (Admin Control)',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  Text(
                    '${studentProv.students.length} students synchronized with PostgreSQL database.',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => setState(() => _activeScreen = 'add-student'),
                icon: const Icon(Icons.person_add, size: 16),
                label: const Text('Enroll New Student'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.adminPrimary,
                ),
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
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              ),
            )
          else
            ...studentProv.students.map(
              (s) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.bgPage,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: AppColors.studentPrimary
                                .withValues(alpha: 0.15),
                            child: Text(
                              s.name.isNotEmpty ? s.name[0].toUpperCase() : 'S',
                              style: const TextStyle(
                                color: AppColors.studentPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                s.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                'Roll: ${s.rollNumber} • ${s.className} • ${s.email}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.visibility,
                              size: 18,
                              color: AppColors.primary,
                            ),
                            onPressed: () {
                              setState(() {
                                _selectedStudent = s;
                                _activeScreen = 'student-detail';
                              });
                            },
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              size: 18,
                              color: AppColors.error,
                            ),
                            onPressed: () async {
                              final ok = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Delete Student?'),
                                  content: Text(
                                    'Remove ${s.name} from database?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(ctx, false),
                                      child: const Text('Cancel'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () => Navigator.pop(ctx, true),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.error,
                                      ),
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                ),
                              );
                              if (ok == true) {
                                await studentProv.deleteStudent(s.id);
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Student deleted from database',
                                      ),
                                    ),
                                  );
                                }
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // 3. Add Student Form
  Widget _buildAddStudentScreen() {
    final studentProv = Provider.of<StudentProvider>(context);

    return Container(
      padding: const EdgeInsets.all(28),
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
            children: [
              const Text(
                'Add Student to Database',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _studentNameController,
            decoration: const InputDecoration(
              labelText: 'Student Full Name',
              hintText: 'Rohit Singhania',
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _studentEmailController,
                  decoration: const InputDecoration(labelText: 'Email Address'),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: TextFormField(
                  controller: _studentRollController,
                  decoration: const InputDecoration(labelText: 'Roll Number'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _studentClassController,
                  decoration: const InputDecoration(
                    labelText: 'Course / Class',
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: TextFormField(
                  controller: _studentPhoneController,
                  decoration: const InputDecoration(labelText: 'Phone Number'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _studentPasswordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Initial Password (at least 8 characters)',
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () async {
              if (_studentNameController.text.trim().isEmpty ||
                  !_studentEmailController.text.trim().contains('@') ||
                  _studentRollController.text.trim().isEmpty ||
                  _studentClassController.text.trim().isEmpty ||
                  _studentPasswordController.text.length < 8) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Enter student name, valid email, roll number, class, and a password of at least 8 characters.',
                    ),
                  ),
                );
                return;
              }
              final newStd = StudentModel(
                id: '',
                name: _studentNameController.text.trim(),
                email: _studentEmailController.text.trim(),
                rollNumber: _studentRollController.text.trim(),
                className: _studentClassController.text.trim(),
                course: _studentClassController.text.trim(),
                phone: _studentPhoneController.text.trim(),
                initialPassword: _studentPasswordController.text,
              );
              final ok = await studentProv.addStudent(newStd);
              if (ok && mounted) {
                _studentNameController.clear();
                _studentEmailController.clear();
                _studentRollController.clear();
                _studentClassController.text = 'BCA - Sem 3';
                _studentPhoneController.clear();
                _studentPasswordController.clear();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Student registered into backend database!'),
                    backgroundColor: AppColors.success,
                  ),
                );
                setState(() => _activeScreen = 'student-records');
              } else if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      studentProv.errorMessage ?? 'Could not create student.',
                    ),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.adminPrimary,
            ),
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
            children: [
              Text(
                'Student Profile: ${s.name}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              OutlinedButton(
                onPressed: () =>
                    setState(() => _activeScreen = 'student-records'),
                child: const Text('Back to Records'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(color: AppColors.border),
          const SizedBox(height: 16),
          _buildInfoRow('Roll Number', s.rollNumber),
          _buildInfoRow('Email Address', s.email),
          _buildInfoRow(
            'Course & Semester',
            '${s.course} (${s.semester ?? "Sem 1"})',
          ),
          _buildInfoRow('Phone', s.phone ?? 'N/A'),
          _buildInfoRow('Father / Guardian', s.fatherName ?? 'Guardian'),
          _buildInfoRow(
            'Campus Affiliation',
            s.instituteName ?? 'Apex Institute of Technology',
          ),
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
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Faculty Directory (Admin Control)',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  Text(
                    '${instructorProv.instructors.length} faculty members retrieved from backend database.',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () =>
                    setState(() => _activeScreen = 'add-instructor'),
                icon: const Icon(Icons.person_add_alt_1, size: 16),
                label: const Text('Add Instructor'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.adminPrimary,
                ),
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
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              ),
            )
          else
            ...instructorProv.instructors.map(
              (i) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.bgPage,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: AppColors.teacherPrimary
                                .withValues(alpha: 0.15),
                            child: Text(
                              i.name.isNotEmpty ? i.name[0].toUpperCase() : 'T',
                              style: const TextStyle(
                                color: AppColors.teacherPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                i.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                '${i.instructorId} • ${i.designation} • ${i.department} • ${i.email}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (i.status?.toLowerCase() != 'active')
                            TextButton.icon(
                              onPressed: () async {
                                final approved = InstructorModel(
                                  id: i.id,
                                  name: i.name,
                                  email: i.email,
                                  instructorId: i.instructorId,
                                  department: i.department,
                                  designation: i.designation,
                                  phone: i.phone,
                                  qualification: i.qualification,
                                  experience: i.experience,
                                  about: i.about,
                                  status: 'Active',
                                  instituteCode: i.instituteCode,
                                  instituteName: i.instituteName,
                                );
                                final success = await instructorProv
                                    .updateInstructor(i.id, approved);
                                if (success && mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('${i.name} is now active.'),
                                    ),
                                  );
                                }
                              },
                              icon: const Icon(
                                Icons.check_circle_outline,
                                size: 16,
                              ),
                              label: const Text('Approve'),
                            ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              size: 18,
                              color: AppColors.error,
                            ),
                            tooltip: 'Delete instructor',
                            onPressed: () async {
                              final ok = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Delete Instructor?'),
                                  content: Text(
                                    'Remove ${i.name} from database?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(ctx, false),
                                      child: const Text('Cancel'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () => Navigator.pop(ctx, true),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.error,
                                      ),
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                ),
                              );
                              if (ok == true) {
                                await instructorProv.deleteInstructor(i.id);
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Instructor removed from database',
                                      ),
                                    ),
                                  );
                                }
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // 6. Instructor Tracking
  Widget _buildInstructorTrackingScreen() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildAdminPageHeader(
          eyebrow: 'FACULTY MANAGEMENT',
          title: 'Faculty workload',
          subtitle:
              'Review teaching hours, course assignments, and faculty feedback.',
          icon: Icons.groups_2_outlined,
          tag: 'WEEKLY OVERVIEW',
        ),
        const SizedBox(height: 16),
        _buildAdminMetrics([
          const _AdminMetric(
            'Faculty tracked',
            '03',
            'Across active departments',
            Icons.people_alt_outlined,
            AppColors.adminPrimary,
          ),
          const _AdminMetric(
            'Teaching hours',
            '54',
            'Hours scheduled per week',
            Icons.schedule_outlined,
            AppColors.primary,
          ),
          const _AdminMetric(
            'Course assignments',
            '11',
            'Across all faculty',
            Icons.menu_book_outlined,
            AppColors.accentTeal,
          ),
          const _AdminMetric(
            'Average rating',
            '4.8',
            'Student evaluation score',
            Icons.star_outline_rounded,
            AppColors.accentOrange,
          ),
        ]),
        const SizedBox(height: 16),
        _buildAdminPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAdminPanelHeading(
                'Faculty snapshots',
                'Workload and performance at a glance',
                trailing: _buildAdminStatusPill(
                  '3 faculty',
                  AppColors.adminPrimary,
                ),
              ),
              const SizedBox(height: 16),
              _buildFacultyWorkloadRow(
                name: 'Dr. Amit Sharma',
                department: 'Computer Science',
                hours: 18,
                courses: 4,
                rating: '4.8',
                color: AppColors.adminPrimary,
              ),
              const SizedBox(height: 12),
              _buildFacultyWorkloadRow(
                name: 'Prof. Sunita Rao',
                department: 'Information Technology',
                hours: 16,
                courses: 3,
                rating: '4.9',
                color: AppColors.accentTeal,
              ),
              const SizedBox(height: 12),
              _buildFacultyWorkloadRow(
                name: 'Prof. Rajesh Gupta',
                department: 'Mathematics',
                hours: 20,
                courses: 4,
                rating: '4.7',
                color: AppColors.accentPurple,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 7. Add Instructor Form
  Widget _buildAddInstructorScreen() {
    final instructorProv = Provider.of<InstructorProvider>(context);

    return Container(
      padding: const EdgeInsets.all(28),
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
            children: [
              const Text(
                'Add Faculty Member to Database',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _instructorNameController,
            decoration: const InputDecoration(labelText: 'Faculty Full Name'),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _instructorEmailController,
                  decoration: const InputDecoration(
                    labelText: 'Official Email',
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: TextFormField(
                  controller: _instructorIdController,
                  decoration: const InputDecoration(labelText: 'Instructor ID'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _instructorDeptController,
                  decoration: const InputDecoration(labelText: 'Department'),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: TextFormField(
                  controller: _instructorDesignationController,
                  decoration: const InputDecoration(labelText: 'Designation'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _instructorPhoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(labelText: 'Phone Number'),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _instructorPasswordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Initial Password (at least 8 characters)',
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () async {
              if (_instructorNameController.text.trim().isEmpty ||
                  !_instructorEmailController.text.trim().contains('@') ||
                  _instructorPasswordController.text.length < 8) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Enter faculty name, valid email, and a password of at least 8 characters.',
                    ),
                  ),
                );
                return;
              }
              final newIns = InstructorModel(
                id: '',
                name: _instructorNameController.text.trim(),
                email: _instructorEmailController.text.trim(),
                instructorId: _instructorIdController.text.trim(),
                department: _instructorDeptController.text.trim(),
                designation: _instructorDesignationController.text.trim(),
                phone: _instructorPhoneController.text.trim(),
                initialPassword: _instructorPasswordController.text,
              );
              final ok = await instructorProv.addInstructor(newIns);
              if (ok && mounted) {
                _instructorNameController.clear();
                _instructorEmailController.clear();
                _instructorIdController.clear();
                _instructorDeptController.text = 'Computer Science';
                _instructorDesignationController.text = 'Assistant Professor';
                _instructorPhoneController.clear();
                _instructorPasswordController.clear();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Faculty member saved to database!'),
                    backgroundColor: AppColors.success,
                  ),
                );
                setState(() => _activeScreen = 'instructor-records');
              } else if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      instructorProv.errorMessage ??
                          'Could not create faculty account.',
                    ),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.adminPrimary,
            ),
            child: const Text('Save Instructor to Database'),
          ),
        ],
      ),
    );
  }

  // 8. Academic Planning
  Widget _buildAcademicPlanningScreen() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildAdminPageHeader(
          eyebrow: 'ACADEMIC OPERATIONS',
          title: 'Academic planning',
          subtitle:
              'Coordinate semester dates, assessments, and key academic milestones.',
          icon: Icons.calendar_month_outlined,
          tag: '2025–2026',
        ),
        const SizedBox(height: 16),
        _buildAdminMetrics([
          const _AdminMetric(
            'Key milestones',
            '04',
            'In this semester plan',
            Icons.flag_outlined,
            AppColors.adminPrimary,
          ),
          const _AdminMetric(
            'Assessment windows',
            '02',
            'Mid-term and final exams',
            Icons.fact_check_outlined,
            AppColors.accentOrange,
          ),
          const _AdminMetric(
            'Semester begins',
            'Jan 15',
            'First planned milestone',
            Icons.play_circle_outline,
            AppColors.accentTeal,
          ),
          const _AdminMetric(
            'Grade publication',
            'Jul 15',
            'Academic grade cards',
            Icons.school_outlined,
            AppColors.accentPurple,
          ),
        ]),
        const SizedBox(height: 16),
        _buildAdminPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAdminPanelHeading(
                'Semester timeline',
                'Academic year 2025–2026',
                trailing: _buildAdminStatusPill(
                  '4 milestones',
                  AppColors.adminPrimary,
                ),
              ),
              const SizedBox(height: 20),
              _buildAcademicMilestone(
                date: 'JAN 15, 2025',
                title: 'Semester begins',
                subtitle: 'Classes commence for the new semester.',
                icon: Icons.play_arrow_rounded,
                color: AppColors.adminPrimary,
                isLast: false,
              ),
              _buildAcademicMilestone(
                date: 'MAY 05 – MAY 16, 2025',
                title: 'Mid-term examination window',
                subtitle: 'Assessment period across academic programs.',
                icon: Icons.edit_note_rounded,
                color: AppColors.accentOrange,
                isLast: false,
              ),
              _buildAcademicMilestone(
                date: 'JUN 20 – JUL 05, 2025',
                title: 'Final semester examination window',
                subtitle: 'End-of-semester examinations and evaluations.',
                icon: Icons.assignment_turned_in_outlined,
                color: AppColors.accentTeal,
                isLast: false,
              ),
              _buildAcademicMilestone(
                date: 'JUL 15, 2025',
                title: 'Grade cards published',
                subtitle: 'Academic results become available to students.',
                icon: Icons.workspace_premium_outlined,
                color: AppColors.accentPurple,
                isLast: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 9. Lecture Schedule
  Widget _buildLectureScheduleScreen() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildAdminPageHeader(
          eyebrow: 'CAMPUS OPERATIONS',
          title: 'Lecture schedule',
          subtitle:
              'A clear view of scheduled lectures, labs, and learning spaces.',
          icon: Icons.calendar_view_week_outlined,
          tag: 'MASTER TIMETABLE',
        ),
        const SizedBox(height: 16),
        _buildAdminMetrics([
          const _AdminMetric(
            'Sessions today',
            '04',
            'Lectures and lab sessions',
            Icons.event_note_outlined,
            AppColors.adminPrimary,
          ),
          const _AdminMetric(
            'Lecture halls',
            '02',
            'Rooms in the schedule',
            Icons.meeting_room_outlined,
            AppColors.primary,
          ),
          const _AdminMetric(
            'Laboratories',
            '02',
            'Practical sessions',
            Icons.science_outlined,
            AppColors.accentTeal,
          ),
          const _AdminMetric(
            'First session',
            '09:00',
            'Morning start time',
            Icons.access_time_rounded,
            AppColors.accentOrange,
          ),
        ]),
        const SizedBox(height: 16),
        _buildAdminPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAdminPanelHeading(
                'Institute master timetable',
                'All lecture halls and laboratory sessions',
                trailing: _buildAdminStatusPill(
                  '4 sessions',
                  AppColors.adminPrimary,
                ),
              ),
              const SizedBox(height: 16),
              _buildLectureSession(
                time: '09:00 AM',
                title: 'Advanced Software Engineering',
                cohort: 'MCA · Semester 1',
                room: 'Hall 101',
                isLab: false,
              ),
              const SizedBox(height: 12),
              _buildLectureSession(
                time: '10:00 AM',
                title: 'Database Systems',
                cohort: 'BCA · Semester 3',
                room: 'Hall 302',
                isLab: false,
              ),
              const SizedBox(height: 12),
              _buildLectureSession(
                time: '11:00 AM',
                title: 'Data Structures Lab Session',
                cohort: 'Practical session',
                room: 'Computer Lab 1',
                isLab: true,
              ),
              const SizedBox(height: 12),
              _buildLectureSession(
                time: '01:00 PM',
                title: 'Database Normalization Practicals',
                cohort: 'Practical session',
                room: 'Computer Lab 2',
                isLab: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 11. Exam Timetable
  Widget _buildExamTimetableScreen() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Live Online Examination Management & Results Release
        Container(
          padding: const EdgeInsets.all(24),
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
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Online Examinations & Results Release',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Control student assessment status and release results for official viewing.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.refresh,
                      color: AppColors.adminPrimary,
                    ),
                    tooltip: 'Refresh Online Exams',
                    onPressed: _loadOnlineExamsAdmin,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (_loadingOnlineExams)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (_onlineExamsAdmin.isEmpty)
                const Text(
                  'No online examinations currently found.',
                  style: TextStyle(color: AppColors.textMuted),
                )
              else
                ..._onlineExamsAdmin.map((exam) {
                  final id = exam['id'].toString();
                  final title = exam['title']?.toString() ?? 'Examination';
                  final code = exam['code']?.toString() ?? '';
                  final subject = exam['subject']?.toString() ?? '';
                  final resultsReleased = exam['resultsReleased'] == true;

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.bgPage,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      '$title ${code.isNotEmpty ? "($code)" : ""}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: resultsReleased
                                            ? AppColors.successBg
                                            : Colors.amber.shade100,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        resultsReleased
                                            ? 'Results Released'
                                            : 'Results Withheld',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: resultsReleased
                                              ? AppColors.success
                                              : Colors.amber.shade900,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Subject: $subject • Duration: ${exam["durationMinutes"]} Mins • Total Marks: ${exam["totalMarks"]}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () =>
                                _toggleReleaseResults(id, resultsReleased),
                            icon: Icon(
                              resultsReleased
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              size: 16,
                            ),
                            label: Text(
                              resultsReleased
                                  ? 'Withhold Results'
                                  : 'Release Results to Students',
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: resultsReleased
                                  ? Colors.grey.shade700
                                  : AppColors.adminPrimary,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Traditional Master Timetable
        Container(
          padding: const EdgeInsets.all(24),
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
                children: [
                  const Text(
                    'Master Examination Timetable',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  ElevatedButton.icon(
                    onPressed: () =>
                        setState(() => _activeScreen = 'create-exam'),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Schedule Exam'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.adminPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ..._examTimetable.map(
                (e) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.bgPage,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${e['code']}: ${e['title']}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '${e['date']} • ${e['time']} • ${e['room']}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'Invigilator: ${e['invigilator']}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.adminPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 12. Create Exam
  Widget _buildCreateExamScreen() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Schedule Examination Assessment',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _examTitleController,
            decoration: const InputDecoration(
              labelText: 'Exam Subject Title',
              hintText: 'Computer Networks',
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _examDateController,
                  decoration: const InputDecoration(labelText: 'Date'),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: TextFormField(
                  controller: _examRoomController,
                  decoration: const InputDecoration(
                    labelText: 'Exam Hall / Room',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _examDurationController,
            decoration: const InputDecoration(
              labelText: 'Duration in Minutes',
              hintText: '180',
            ),
          ),
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
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Exam added to timetable!'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.adminPrimary,
            ),
            child: const Text('Add Exam to Timetable'),
          ),
        ],
      ),
    );
  }

  // 13. Cross Module
  Widget _buildCrossModuleScreen() {
    final studentProv = Provider.of<StudentProvider>(context);
    final instructorProv = Provider.of<InstructorProvider>(context);
    final query = _explorerSearchQuery.trim().toLowerCase();
    final students = studentProv.students.where((student) {
      if (_explorerTypeFilter == 'Faculty') return false;
      return query.isEmpty ||
          student.name.toLowerCase().contains(query) ||
          student.email.toLowerCase().contains(query) ||
          student.rollNumber.toLowerCase().contains(query) ||
          student.className.toLowerCase().contains(query) ||
          student.course.toLowerCase().contains(query) ||
          (student.department?.toLowerCase().contains(query) ?? false);
    }).toList();
    final instructors = instructorProv.instructors.where((instructor) {
      if (_explorerTypeFilter == 'Students') return false;
      return query.isEmpty ||
          instructor.name.toLowerCase().contains(query) ||
          instructor.email.toLowerCase().contains(query) ||
          instructor.instructorId.toLowerCase().contains(query) ||
          instructor.department.toLowerCase().contains(query) ||
          instructor.designation.toLowerCase().contains(query);
    }).toList();
    final visibleRecords = students.length + instructors.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildAdminPageHeader(
          eyebrow: 'DATA & INSIGHTS',
          title: 'Global explorer',
          subtitle:
              'Search student and faculty records from one unified workspace.',
          icon: Icons.travel_explore_outlined,
          tag: 'RECORDS',
        ),
        const SizedBox(height: 16),
        _buildAdminMetrics([
          _AdminMetric(
            'Total records',
            '${studentProv.students.length + instructorProv.instructors.length}',
            'Students and faculty',
            Icons.dataset_outlined,
            AppColors.adminPrimary,
          ),
          _AdminMetric(
            'Students',
            '${studentProv.students.length}',
            'Enrolled records',
            Icons.school_outlined,
            AppColors.studentPrimary,
          ),
          _AdminMetric(
            'Faculty',
            '${instructorProv.instructors.length}',
            'Instructor records',
            Icons.badge_outlined,
            AppColors.teacherPrimary,
          ),
          const _AdminMetric(
            'Data integrity',
            '100%',
            'Relational checks passed',
            Icons.verified_outlined,
            AppColors.accentTeal,
          ),
        ]),
        const SizedBox(height: 16),
        _buildAdminPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAdminPanelHeading(
                'Unified records',
                'Search by name, email, ID, department, or class',
                trailing: _buildAdminStatusPill(
                  '$visibleRecords results',
                  AppColors.adminPrimary,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                onChanged: (value) =>
                    setState(() => _explorerSearchQuery = value),
                decoration: InputDecoration(
                  hintText: 'Search records...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _explorerSearchQuery.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Clear search',
                          onPressed: () =>
                              setState(() => _explorerSearchQuery = ''),
                          icon: const Icon(Icons.close_rounded),
                        ),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildExplorerFilterChip(
                    'All records',
                    studentProv.students.length +
                        instructorProv.instructors.length,
                  ),
                  _buildExplorerFilterChip(
                    'Students',
                    studentProv.students.length,
                  ),
                  _buildExplorerFilterChip(
                    'Faculty',
                    instructorProv.instructors.length,
                  ),
                ],
              ),
              const SizedBox(height: 18),
              if (visibleRecords == 0)
                _buildExplorerEmptyState()
              else
                LayoutBuilder(
                  builder: (context, constraints) {
                    final columns = constraints.maxWidth >= 760 ? 2 : 1;
                    final cardWidth =
                        (constraints.maxWidth - (columns - 1) * 12) / columns;
                    return Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        ...students.map(
                          (student) => SizedBox(
                            width: cardWidth,
                            child: _buildExplorerRecordCard(
                              kind: 'STUDENT',
                              name: student.name,
                              email: student.email,
                              identifier: student.rollNumber.isEmpty
                                  ? student.id
                                  : student.rollNumber,
                              detail:
                                  '${student.className} · ${student.course}',
                              status: student.status ?? 'Active',
                              color: AppColors.studentPrimary,
                              icon: Icons.school_outlined,
                            ),
                          ),
                        ),
                        ...instructors.map(
                          (instructor) => SizedBox(
                            width: cardWidth,
                            child: _buildExplorerRecordCard(
                              kind: 'FACULTY',
                              name: instructor.name,
                              email: instructor.email,
                              identifier: instructor.instructorId.isEmpty
                                  ? instructor.id
                                  : instructor.instructorId,
                              detail:
                                  '${instructor.department} · ${instructor.designation}',
                              status: instructor.status ?? 'Active',
                              color: AppColors.teacherPrimary,
                              icon: Icons.badge_outlined,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildAdminPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAdminPanelHeading(
                'Platform connections',
                'Connected services supporting the institute workspace',
              ),
              const SizedBox(height: 14),
              LayoutBuilder(
                builder: (context, constraints) {
                  final columns = constraints.maxWidth >= 760 ? 3 : 1;
                  final itemWidth =
                      (constraints.maxWidth - (columns - 1) * 12) / columns;
                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      SizedBox(
                        width: itemWidth,
                        child: _buildExplorerSystemCard(
                          icon: Icons.account_tree_outlined,
                          title: 'Relational integrity',
                          subtitle: '100% checks passed',
                          color: AppColors.accentTeal,
                        ),
                      ),
                      SizedBox(
                        width: itemWidth,
                        child: _buildExplorerSystemCard(
                          icon: Icons.storage_outlined,
                          title: 'Database schema',
                          subtitle: 'PostgreSQL 16',
                          color: AppColors.adminPrimary,
                        ),
                      ),
                      SizedBox(
                        width: itemWidth,
                        child: _buildExplorerSystemCard(
                          icon: Icons.cloud_done_outlined,
                          title: 'File storage',
                          subtitle: 'Cloudinary integrated',
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAdminPageHeader({
    required String eyebrow,
    required String title,
    required String subtitle,
    required IconData icon,
    required String tag,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final iconTile = Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.adminPrimary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: AppColors.adminPrimary, size: 25),
          );
          final titleBlock = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                eyebrow,
                style: const TextStyle(
                  color: AppColors.adminPrimary,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          );
          final status = _buildAdminStatusPill(tag, AppColors.adminPrimary);

          if (constraints.maxWidth < 560) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    iconTile,
                    const SizedBox(width: 12),
                    Expanded(child: titleBlock),
                  ],
                ),
                const SizedBox(height: 12),
                status,
              ],
            );
          }

          return Row(
            children: [
              iconTile,
              const SizedBox(width: 16),
              Expanded(child: titleBlock),
              const SizedBox(width: 12),
              status,
            ],
          );
        },
      ),
    );
  }

  Widget _buildAdminMetrics(List<_AdminMetric> metrics) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 960
            ? 4
            : constraints.maxWidth >= 560
            ? 2
            : 1;
        final cardWidth = (constraints.maxWidth - (columns - 1) * 12) / columns;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: metrics
              .map(
                (metric) => SizedBox(
                  width: cardWidth,
                  child: _buildAdminMetricCard(metric),
                ),
              )
              .toList(),
        );
      },
    );
  }

  Widget _buildAdminMetricCard(_AdminMetric metric) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  metric.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: metric.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(metric.icon, size: 17, color: metric.color),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            metric.value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            metric.caption,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, color: AppColors.textLight),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminPanel({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }

  Widget _buildAdminPanelHeading(
    String title,
    String subtitle, {
    Widget? trailing,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
        if (trailing != null) ...[const SizedBox(width: 8), trailing],
      ],
    );
  }

  Widget _buildAdminStatusPill(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.16)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }

  Widget _buildFacultyWorkloadRow({
    required String name,
    required String department,
    required int hours,
    required int courses,
    required String rating,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgPage,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 21,
                backgroundColor: color.withValues(alpha: 0.12),
                child: Text(
                  name.characters.first,
                  style: TextStyle(color: color, fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      department,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              _buildAdminStatusPill('$rating rating', AppColors.accentOrange),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildWorkloadDetail(
                Icons.schedule_outlined,
                '$hours hrs / week',
                color,
              ),
              _buildWorkloadDetail(
                Icons.menu_book_outlined,
                '$courses courses',
                AppColors.adminPrimary,
              ),
              _buildWorkloadDetail(
                Icons.auto_awesome_outlined,
                'Performance',
                AppColors.accentTeal,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWorkloadDetail(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textMain,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAcademicMilestone({
    required String date,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isLast,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 42,
            child: Column(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(icon, size: 18, color: color),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      color: AppColors.border,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              margin: EdgeInsets.only(bottom: isLast ? 0 : 14),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.bgPage,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    date,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLectureSession({
    required String time,
    required String title,
    required String cohort,
    required String room,
    required bool isLab,
  }) {
    final color = isLab ? AppColors.accentTeal : AppColors.adminPrimary;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgPage,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 76,
                padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  time,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textMain,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              _buildAdminStatusPill(isLab ? 'LAB' : 'LECTURE', color),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 3,
                height: 42,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      cohort,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(left: 15),
            child: Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 15,
                  color: AppColors.textMuted,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    room,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExplorerFilterChip(String label, int count) {
    final selected = _explorerTypeFilter == label;
    return ChoiceChip(
      selected: selected,
      onSelected: (_) => setState(() => _explorerTypeFilter = label),
      label: Text('$label  $count'),
      avatar: selected ? const Icon(Icons.check_rounded, size: 15) : null,
      labelStyle: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: selected ? AppColors.adminPrimary : AppColors.textMuted,
      ),
      selectedColor: AppColors.adminPrimary.withValues(alpha: 0.1),
      backgroundColor: Colors.white,
      side: BorderSide(
        color: selected
            ? AppColors.adminPrimary.withValues(alpha: 0.3)
            : AppColors.border,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      showCheckmark: false,
    );
  }

  Widget _buildExplorerRecordCard({
    required String kind,
    required String name,
    required String email,
    required String identifier,
    required String detail,
    required String status,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgPage,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, size: 19, color: color),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              _buildAdminStatusPill(kind, color),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            email,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
          const SizedBox(height: 5),
          Text(
            detail,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.tag_rounded,
                size: 14,
                color: AppColors.textLight,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  identifier.isEmpty ? 'No ID available' : identifier,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _buildAdminStatusPill(
                status,
                status.toLowerCase() == 'active'
                    ? AppColors.accentTeal
                    : AppColors.textMuted,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExplorerEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 34, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.bgPage,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: const Column(
        children: [
          Icon(Icons.search_off_rounded, size: 30, color: AppColors.textLight),
          SizedBox(height: 10),
          Text(
            'No matching records',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
          ),
          SizedBox(height: 4),
          Text(
            'Try another search term or record type.',
            style: TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildExplorerSystemCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgPage,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 14. Reports
  Widget _buildReportsScreen() {
    return Container(
      padding: const EdgeInsets.all(24),
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
            children: [
              const Text(
                'Institute Analytics & Compliance Reports',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Comprehensive report exported as CSV!'),
                    ),
                  );
                },
                icon: const Icon(Icons.file_download, size: 16),
                label: const Text('Export CSV Report'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.adminPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            '• Attendance Compliance: 92.4% campus average (98.2% minimum standard met)',
          ),
          const SizedBox(height: 8),
          const Text(
            '• Semester Pass Rate: 94.6% students passed in regular examination session',
          ),
          const SizedBox(height: 8),
          const Text(
            '• Faculty-to-Student Ratio: 1:21 (Compliant with UGC guidelines)',
          ),
        ],
      ),
    );
  }

  // 15. Settings
  Widget _buildSettingsScreen(UserModel? user) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'System Administration Settings',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 20),
          _buildInfoRow('Campus Code', user?.instituteCode ?? 'INST-2025'),
          _buildInfoRow(
            'Institute Name',
            user?.instituteName ?? 'Apex Institute of Technology',
          ),
          _buildInfoRow(
            'Admin Account',
            user?.email ?? 'amit.kumar@institute.com',
          ),
          _buildInfoRow(
            'Database Engine',
            'PostgreSQL 16 (Spring Boot JPA Hibernate)',
          ),
          _buildInfoRow(
            'Storage Integration',
            'Cloudinary Media Cloud & S3 Bucket',
          ),
          _buildInfoRow('Session Validity', '24 Hours (JWT Signing Active)'),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('System configuration verified & healthy!'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.adminPrimary,
            ),
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
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.textMain,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminMetric {
  final String label;
  final String value;
  final String caption;
  final IconData icon;
  final Color color;

  const _AdminMetric(
    this.label,
    this.value,
    this.caption,
    this.icon,
    this.color,
  );
}
