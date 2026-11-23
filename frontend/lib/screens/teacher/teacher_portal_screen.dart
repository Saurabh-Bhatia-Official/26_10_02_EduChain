import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../models/user_model.dart';
import '../../models/student_model.dart';
import '../../models/course_model.dart';
import '../../models/lecture_model.dart';
import '../../providers/navigation_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/student_provider.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/metric_card.dart';
import '../portal_modules_screen.dart';
import '../../widgets/portal_notification_bell.dart';
import '../../widgets/portal_announcement_preview.dart';
import '../classroom/classroom_hub_screen.dart';
import '../classroom/assignment_view_screen.dart';
import '../../services/api_service.dart';

class TeacherPortalScreen extends StatefulWidget {
  final String initialTab;
  final String? initialTargetId;
  const TeacherPortalScreen({super.key, this.initialTab = 'dashboard', this.initialTargetId});

  @override
  State<TeacherPortalScreen> createState() => _TeacherPortalScreenState();
}

class _TeacherPortalScreenState extends State<TeacherPortalScreen> {
  late String _activeScreen;
  StudentModel? _selectedStudent;
  CourseModel? _selectedCourse;

  // Form Controllers for Add Student
  final _studentNameController = TextEditingController();
  final _studentEmailController = TextEditingController();
  final _studentRollController = TextEditingController();
  final _studentClassController = TextEditingController(text: 'BCA - Sem 3');
  final _studentPhoneController = TextEditingController();

  // Form Controllers for Add Course
  final _courseCodeController = TextEditingController();
  final _courseNameController = TextEditingController();
  final _courseDeptController = TextEditingController(text: 'Computer Science');
  final _courseCreditsController = TextEditingController(text: '4');

  // Form Controllers for Update Lecture
  final _lectureTopicController = TextEditingController(text: 'Relational Database Schema & 3NF Normalization');
  final _lectureRoomController = TextEditingController(text: 'Hall 302');
  final _lectureTimeController = TextEditingController(text: '10:00 AM - 11:30 AM');

  // Courses List
  final List<CourseModel> _courses = [
    CourseModel(id: '1', code: 'CS-301', name: 'Database Management Systems', department: 'Computer Science', credits: 4, semester: 'Semester 3', studentsEnrolled: 48, progress: 0.72),
    CourseModel(id: '2', code: 'CS-302', name: 'Data Structures & Algorithms', department: 'Computer Science', credits: 4, semester: 'Semester 3', studentsEnrolled: 52, progress: 0.65),
    CourseModel(id: '3', code: 'CS-401', name: 'Advanced Web Engineering', department: 'Computer Science', credits: 3, semester: 'Semester 4', studentsEnrolled: 42, progress: 0.80),
    CourseModel(id: '4', code: 'CS-502', name: 'Cloud Distributed Computing', department: 'Computer Science', credits: 4, semester: 'Semester 5', studentsEnrolled: 38, progress: 0.50),
  ];

  // Lectures List
  final List<LectureModel> _lectures = [
    LectureModel(id: '1', title: 'Database Systems (CS-301)', courseCode: 'CS-301', courseName: 'Database Management Systems', date: 'May 06, 2025', time: '10:00 AM - 11:30 AM', room: 'Hall 302', status: 'Scheduled', topic: 'Relational Schema & 3NF Normalization'),
    LectureModel(id: '2', title: 'Algorithms Lab (CS-302)', courseCode: 'CS-302', courseName: 'Data Structures', date: 'May 06, 2025', time: '01:00 PM - 03:00 PM', room: 'Computer Lab 2', status: 'Scheduled', topic: 'Graph Traversal BFS & DFS Algorithms'),
    LectureModel(id: '3', title: 'Web Frameworks (CS-401)', courseCode: 'CS-401', courseName: 'Web Engineering', date: 'May 07, 2025', time: '11:00 AM - 12:30 PM', room: 'Hall 105', status: 'Scheduled', topic: 'State Management & API Integration'),
  ];

  @override
  void initState() {
    super.initState();
    _activeScreen = widget.initialTab.isNotEmpty ? widget.initialTab : 'dashboard';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<StudentProvider>(context, listen: false).fetchStudents();
      _fetchTeacherExams();
      _fetchTeacherAssignments();
    });
  }

  @override
  void didUpdateWidget(TeacherPortalScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialTab.isNotEmpty && widget.initialTab != _activeScreen) {
      setState(() => _activeScreen = widget.initialTab);
    }
  }

  @override
  void dispose() {
    _studentNameController.dispose();
    _studentEmailController.dispose();
    _studentRollController.dispose();
    _studentClassController.dispose();
    _studentPhoneController.dispose();
    _courseCodeController.dispose();
    _courseNameController.dispose();
    _courseDeptController.dispose();
    _courseCreditsController.dispose();
    _lectureTopicController.dispose();
    _lectureRoomController.dispose();
    _lectureTimeController.dispose();
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
                if (_isClassroomHubTab(_activeScreen))
                  Expanded(
                    child: _buildClassroomHubWidget(_activeScreen),
                  )
                else
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

  bool _isClassroomHubTab(String screen) {
    return screen == 'classes' ||
        screen == 'my-classrooms' ||
        screen == 'assignments' ||
        screen == 'meet';
  }

  Widget _buildClassroomHubWidget(String screen) {
    int initialIdx = 0;
    if (screen == 'assignments') {
      initialIdx = 1;
    } else if (screen == 'meet') {
      initialIdx = 2;
    }
    return ClassroomHubScreen(
      key: ValueKey('teacher-classroom-$screen'),
      userRole: 'teacher',
      initialIndex: initialIdx,
    );
  }

  Widget _buildSidebar(UserModel? user, NavigationProvider nav) {
    final menuItems = [
      {'id': 'dashboard', 'title': 'Dashboard', 'icon': Icons.dashboard_outlined},
      {'id': 'classes', 'title': 'My Classrooms', 'icon': Icons.school_outlined},
      {'id': 'assignments', 'title': 'Assignments', 'icon': Icons.assignment_turned_in_outlined},
      {'id': 'assignment-eval', 'title': 'Assignment Evaluation', 'icon': Icons.rate_review_outlined},
      {'id': 'exams', 'title': 'Examinations', 'icon': Icons.assignment_outlined},
      {'id': 'question-mgmt', 'title': 'Question Management', 'icon': Icons.quiz_outlined},
      {'id': 'exam-eval', 'title': 'Exam Evaluation', 'icon': Icons.fact_check_outlined},
      {'id': 'results', 'title': 'Results', 'icon': Icons.emoji_events_outlined},
      {'id': 'meet', 'title': 'Google Meet', 'icon': Icons.video_call_outlined},
      {'id': 'announcements', 'title': 'Announcements', 'icon': Icons.campaign_outlined},
      {'id': 'study-materials', 'title': 'Study Materials', 'icon': Icons.menu_book_outlined},
      {'id': 'students', 'title': 'Student Records', 'icon': Icons.people_outline},
      {'id': 'lectures', 'title': 'Lecture Schedules', 'icon': Icons.event_note_outlined},
      {'id': 'leaves', 'title': 'Leave Requests', 'icon': Icons.event_available_outlined},
      {'id': 'profile', 'title': 'Faculty Profile', 'icon': Icons.badge_outlined},
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
                    Text('EduChain', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF00337F))),
                    Text('Faculty & Teacher Desk', style: TextStyle(fontSize: 11, color: AppColors.textLight)),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),

          // Mini Profile
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFE0F2FE),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFBAE6FD)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.teacherPrimary,
                  child: Text(
                    user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : 'T',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.name ?? 'Dr. Amit Sharma',
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textMain),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        user?.department ?? 'Computer Science',
                        style: const TextStyle(fontSize: 11, color: AppColors.teacherPrimary, fontWeight: FontWeight.w600),
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
                  padding: const EdgeInsets.only(bottom: 4),
                  child: ListTile(
                    dense: true,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    tileColor: isSelected ? const Color(0xFFE0F2FE) : Colors.transparent,
                    leading: Icon(
                      item['icon'] as IconData,
                      size: 20,
                      color: isSelected ? AppColors.teacherPrimary : AppColors.textMuted,
                    ),
                    title: Text(
                      item['title'] as String,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? AppColors.teacherPrimary : AppColors.textMain,
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

          // Role gateway
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
              const PortalNotificationBell(role: 'teacher'),
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
                  nav.navigateTo('teacher-login');
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
        return 'Instructor Dashboard';
      case 'classes':
      case 'my-classrooms':
        return 'My Classrooms (Google Classroom)';
      case 'assignments':
        return 'Assignments Stream & Review';
      case 'assignment-eval':
        return 'Assignment Submissions & Evaluation';
      case 'exams':
        return 'Online Examinations';
      case 'question-mgmt':
        return 'Question Management & Question Bank';
      case 'exam-eval':
        return 'Student Exam Evaluation & Grading';
      case 'results':
        return 'Academic Results & Scorecard Publication';
      case 'meet':
        return 'Google Meet Live Classes';
      case 'study-materials':
      case 'courses':
        return 'Study Materials & Curriculum';
      case 'students':
        return 'Student Directory & Records';
      case 'add-student':
        return 'Enroll New Student';
      case 'student-detail':
        return 'Student Profile Details';
      case 'add-course':
        return 'Add Academic Course';
      case 'remove-course':
        return 'Course Management & Archiving';
      case 'course-details':
        return 'Course Syllabus Breakdown';
      case 'lectures':
        return 'Lecture Schedule Manager';
      case 'update-lecture':
        return 'Reschedule / Update Lecture';
      case 'announcements':
        return 'Announcements';
      case 'leaves':
        return 'Student Leave Requests & My Leave';
      case 'profile':
        return 'Faculty Member Profile';
      default:
        return 'Instructor Portal';
    }
  }

  Widget _buildScreenContent(UserModel? user, NavigationProvider nav) {
    switch (_activeScreen) {
      case 'dashboard':
        return _buildDashboardScreen();
      case 'classes':
      case 'my-classrooms':
        return _buildClassesScreen();
      case 'assignment-eval':
        return _buildAssignmentEvaluationScreen();
      case 'exams':
        return _buildTeacherExamsScreen();
      case 'question-mgmt':
        return _buildQuestionManagementScreen();
      case 'exam-eval':
        return _buildExamEvaluationScreen();
      case 'results':
        return _buildResultsScreen();
      case 'study-materials':
      case 'courses':
        return _buildCoursesScreen();
      case 'students':
        return _buildStudentsScreen();
      case 'add-student':
        return _buildAddStudentScreen();
      case 'student-detail':
        return _buildStudentDetailScreen();
      case 'add-course':
        return _buildAddCourseScreen();
      case 'remove-course':
        return _buildRemoveCourseScreen();
      case 'course-details':
        return _buildCourseDetailsScreen();
      case 'lectures':
        return _buildLecturesScreen();
      case 'update-lecture':
        return _buildUpdateLectureScreen();
      case 'announcements':
      case 'leaves':
        return PortalModulesScreen(
          key: ValueKey('$_activeScreen-${widget.initialTargetId ?? ''}'),
          role: 'teacher',
          module: _activeScreen,
          user: user,
          targetId: widget.initialTargetId,
        );
      case 'profile':
        return _buildProfileScreen(user);
      default:
        return _buildDashboardScreen();
    }
  }

  // 1. Dashboard
  Widget _buildDashboardScreen() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PortalAnnouncementPreview(role: 'teacher'),
        Row(
          children: [
            Expanded(child: MetricCard(title: 'Assigned Courses', value: '4 Courses', icon: Icons.menu_book, color: AppColors.teacherPrimary)),
            const SizedBox(width: 16),
            Expanded(child: MetricCard(title: 'Enrolled Students', value: '180 Total', icon: Icons.people, color: AppColors.studentPrimary)),
            const SizedBox(width: 16),
            Expanded(child: MetricCard(title: 'Upcoming Lectures', value: '3 Today', icon: Icons.event_note, color: AppColors.primary)),
            const SizedBox(width: 16),
            Expanded(child: MetricCard(title: 'Average Class Rating', value: '4.8 / 5.0', icon: Icons.star, color: AppColors.accentOrange)),
          ],
        ),
        const SizedBox(height: 28),

        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Today's Lecture Agenda", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                  ElevatedButton.icon(
                    onPressed: () => setState(() => _activeScreen = 'update-lecture'),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Update Schedule'),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.teacherPrimary),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ..._lectures.map((l) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: AppColors.bgPage, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(l.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                              const SizedBox(height: 2),
                              Text('${l.time} • ${l.room} • Topic: ${l.topic}', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                            ],
                          ),
                          StatusBadge(label: l.status, status: 'scheduled'),
                        ],
                      ),
                    ),
                  )),
            ],
          ),
        ),
      ],
    );
  }

  // 2. Classes
  Widget _buildClassesScreen() {
    return const ClassroomHubScreen(userRole: 'teacher');
  }

  // 2B. Examinations Management & Evaluations (Teacher Portal)
  List<Map<String, dynamic>> _teacherExams = [];
  bool _loadingTeacherExams = false;
  String? _teacherExamError;

  List<Map<String, dynamic>> _teacherAssignments = [];
  bool _loadingTeacherAssignments = false;

  Future<void> _fetchTeacherAssignments() async {
    setState(() => _loadingTeacherAssignments = true);
    try {
      final classrooms = await ApiService().getClassrooms();
      final List<Map<String, dynamic>> list = [];
      for (final c in classrooms) {
        final cId = c['id']?.toString() ?? '';
        if (cId.isNotEmpty) {
          final asgns = await ApiService().getClassroomAssignments(cId);
          for (final a in asgns) {
            list.add({
              ...a,
              'classroomId': cId,
              'classroomName': c['name'] ?? 'Classroom',
              'classroomSection': c['section'] ?? '',
            });
          }
        }
      }
      if (mounted) {
        setState(() {
          _teacherAssignments = list;
          _loadingTeacherAssignments = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingTeacherAssignments = false);
    }
  }

  Future<void> _fetchTeacherExams() async {
    setState(() {
      _loadingTeacherExams = true;
      _teacherExamError = null;
    });
    try {
      final exams = await ApiService().getExams();
      if (mounted) {
        setState(() {
          _teacherExams = exams;
          _loadingTeacherExams = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadingTeacherExams = false;
          _teacherExamError = e.toString().replaceFirst('Exception: ', '');
        });
      }
    }
  }

  void _showCreateExamDialog() {
    final titleController = TextEditingController();
    final courseCodeController = TextEditingController(text: 'CS-302');
    final courseNameController = TextEditingController(text: 'Data Structures & Algorithms');
    final classNameController = TextEditingController(text: 'CSE 2026');
    final sectionController = TextEditingController(text: 'Batch A');
    final durationController = TextEditingController(text: '60');
    final totalMarksController = TextEditingController(text: '100');

    // Questions builder
    final List<Map<String, dynamic>> questions = [
      {
        'id': '1',
        'question': 'Which data structure follows the Last-In-First-Out (LIFO) principle?',
        'options': ['Queue', 'Stack', 'Linked List', 'Binary Tree'],
        'correctAnswer': 'Stack',
        'marks': 25,
      },
      {
        'id': '2',
        'question': 'What is the average time complexity of searching in a Balanced Binary Search Tree (AVL Tree)?',
        'options': ['O(1)', 'O(n)', 'O(log n)', 'O(n log n)'],
        'correctAnswer': 'O(log n)',
        'marks': 25,
      },
      {
        'id': '3',
        'question': 'Which algorithm is used to find the shortest path in a weighted graph without negative cycles?',
        'options': ['Dijkstra Algorithm', 'Prim Algorithm', 'Kruskal Algorithm', 'Floyd-Warshall'],
        'correctAnswer': 'Dijkstra Algorithm',
        'marks': 25,
      },
      {
        'id': '4',
        'question': 'In a max heap, where is the largest element always located?',
        'options': ['At the deepest leaf', 'At the root node', 'In the left subtree', 'At any position'],
        'correctAnswer': 'At the root node',
        'marks': 25,
      },
    ];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.assignment_add, color: AppColors.teacherPrimary),
              SizedBox(width: 10),
              Text('Create Online Examination', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
          content: SizedBox(
            width: 520,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'Exam Title', hintText: 'e.g. Midterm Assessment: Data Structures'),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: courseCodeController,
                          decoration: const InputDecoration(labelText: 'Course Code', hintText: 'CS-302'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: classNameController,
                          decoration: const InputDecoration(labelText: 'Class / Program', hintText: 'BCA / B.Tech'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: durationController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Duration (Minutes)', hintText: '60'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: totalMarksController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Total Marks', hintText: '100'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Assessment Questions (${questions.length})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      Text('${questions.fold<int>(0, (sum, q) => sum + (q['marks'] as int? ?? 0))} Marks Total', style: const TextStyle(fontSize: 12, color: AppColors.teacherPrimary, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    constraints: const BoxConstraints(maxHeight: 180),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: questions.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (ctx, i) {
                        final q = questions[i];
                        return ListTile(
                          dense: true,
                          leading: CircleAvatar(
                            radius: 12,
                            backgroundColor: AppColors.teacherPrimary,
                            child: Text('${i + 1}', style: const TextStyle(color: Colors.white, fontSize: 11)),
                          ),
                          title: Text(q['question'] as String, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                          subtitle: Text('Ans: ${q['correctAnswer']} • ${q['marks']} pts', style: const TextStyle(fontSize: 11, color: Colors.green)),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.teacherPrimary,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                final title = titleController.text.trim();
                if (title.isEmpty) return;
                Navigator.pop(ctx);
                try {
                  await ApiService().createExam({
                    'title': title,
                    'courseCode': courseCodeController.text.trim(),
                    'courseName': courseNameController.text.trim(),
                    'className': classNameController.text.trim(),
                    'sectionName': sectionController.text.trim(),
                    'durationMinutes': int.tryParse(durationController.text.trim()) ?? 60,
                    'totalMarks': int.tryParse(totalMarksController.text.trim()) ?? 100,
                    'questions': questions,
                    'status': 'Published',
                    'resultsReleased': false,
                  });
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Examination published successfully!'), backgroundColor: Colors.green),
                  );
                  _fetchTeacherExams();
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString().replaceFirst('Exception: ', '')), backgroundColor: Colors.red),
                  );
                }
              },
              child: const Text('Publish Exam'),
            ),
          ],
        ),
      ),
    );
  }

  void _showExamAttemptsDialog(Map<String, dynamic> exam) async {
    final examId = exam['id'].toString();
    showDialog(
      context: context,
      builder: (ctx) => FutureBuilder<List<Map<String, dynamic>>>(
        future: ApiService().getExamAttempts(examId),
        builder: (ctx, snapshot) {
          final attempts = snapshot.data ?? [];
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                const Icon(Icons.people_alt_outlined, color: AppColors.teacherPrimary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Student Attempts: ${exam['title'] ?? 'Exam'}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            content: SizedBox(
              width: 580,
              height: 380,
              child: snapshot.connectionState == ConnectionState.waiting
                  ? const Center(child: CircularProgressIndicator())
                  : attempts.isEmpty
                      ? const Center(
                          child: Text(
                            'No student attempts recorded for this exam yet.',
                            style: TextStyle(color: AppColors.textMuted),
                          ),
                        )
                      : ListView.separated(
                          itemCount: attempts.length,
                          separatorBuilder: (_, _) => const Divider(height: 1),
                          itemBuilder: (ctx, i) {
                            final att = attempts[i];
                            final status = att['status']?.toString() ?? 'IN_PROGRESS';
                            final score = att['obtainedMarks'];
                            final total = att['totalMarks'] ?? exam['totalMarks'] ?? 100;
                            final isSubmitted = status == 'SUBMITTED';

                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: isSubmitted ? Colors.green.shade100 : Colors.amber.shade100,
                                child: Icon(
                                  isSubmitted ? Icons.check : Icons.hourglass_top,
                                  color: isSubmitted ? Colors.green.shade800 : Colors.amber.shade800,
                                  size: 18,
                                ),
                              ),
                              title: Text(att['studentName'] ?? 'Student', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              subtitle: Text(
                                'Roll: ${att['rollNumber'] ?? "-"} • ${att['email'] ?? ""}\nSubmitted: ${att['submittedAt']?.toString().split("T").first ?? "In Progress"}',
                                style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                              ),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isSubmitted ? Colors.purple.shade50 : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: isSubmitted ? Colors.purple.shade200 : Colors.grey.shade300),
                                ),
                                child: Text(
                                  isSubmitted ? '$score / $total pts' : 'In Progress',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: isSubmitted ? Colors.purple.shade900 : AppColors.textMuted,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
            ],
          );
        },
      ),
    );
  }

  void _toggleReleaseResults(Map<String, dynamic> exam) async {
    final examId = exam['id'].toString();
    final currentStatus = exam['resultsReleased'] == true;
    final newStatus = !currentStatus;

    try {
      final res = await ApiService().releaseExamResults(examId, newStatus);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res['message'] ?? (newStatus ? 'Results released to students!' : 'Results hidden from students.')),
          backgroundColor: newStatus ? Colors.green : Colors.orange,
        ),
      );
      _fetchTeacherExams();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', '')), backgroundColor: Colors.red),
      );
    }
  }

  void _deleteExam(Map<String, dynamic> exam) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Examination?'),
        content: Text('Are you sure you want to delete "${exam['title']}"? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await ApiService().deleteExam(exam['id'].toString());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Examination deleted.'), backgroundColor: Colors.red),
      );
      _fetchTeacherExams();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', '')), backgroundColor: Colors.red),
      );
    }
  }

  Widget _buildTeacherExamsScreen() {
    if (_teacherExams.isEmpty && !_loadingTeacherExams && _teacherExamError == null) {
      _fetchTeacherExams();
    }

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
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Examinations & Evaluation Desk', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textMain)),
                  SizedBox(height: 4),
                  Text('Create exams, manage objective/subjective assessments, and evaluate student attempts.', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.refresh, color: AppColors.teacherPrimary),
                    tooltip: 'Refresh Exams',
                    onPressed: _fetchTeacherExams,
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Create Examination'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.teacherPrimary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: _showCreateExamDialog,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (_loadingTeacherExams)
            const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()))
          else if (_teacherExamError != null)
            Center(
              child: Column(
                children: [
                  Text(_teacherExamError!, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 12),
                  ElevatedButton(onPressed: _fetchTeacherExams, child: const Text('Retry')),
                ],
              ),
            )
          else if (_teacherExams.isEmpty)
            Container(
              padding: const EdgeInsets.all(48),
              alignment: Alignment.center,
              child: Column(
                children: [
                  const Icon(Icons.assignment_outlined, size: 54, color: AppColors.textMuted),
                  const SizedBox(height: 12),
                  const Text('No examinations scheduled yet.', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textMuted)),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Create Your First Exam'),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.teacherPrimary, foregroundColor: Colors.white),
                    onPressed: _showCreateExamDialog,
                  ),
                ],
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _teacherExams.length,
              itemBuilder: (ctx, idx) {
                final exam = _teacherExams[idx];
                final resultsReleased = exam['resultsReleased'] == true;
                final duration = exam['durationMinutes'] ?? 60;
                final totalMarks = exam['totalMarks'] ?? 100;

                return Card(
                  margin: const EdgeInsets.only(bottom: 14),
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: AppColors.border),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE0F2FE),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.quiz_outlined, color: AppColors.teacherPrimary, size: 24),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(exam['title'] ?? 'Examination', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textMain)),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${exam['courseCode'] ?? "CS-301"} • ${exam['courseName'] ?? ""} • Class: ${exam['className'] ?? ""}',
                                    style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: resultsReleased ? Colors.green.shade50 : Colors.orange.shade50,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: resultsReleased ? Colors.green.shade300 : Colors.orange.shade300),
                              ),
                              child: Text(
                                resultsReleased ? 'Results Released' : 'Results Pending',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: resultsReleased ? Colors.green.shade800 : Colors.orange.shade900,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Text('Duration: $duration mins', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                            const SizedBox(width: 16),
                            Text('Total Marks: $totalMarks pts', style: const TextStyle(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.bold)),
                            const Spacer(),
                            OutlinedButton.icon(
                              icon: const Icon(Icons.visibility_outlined, size: 16),
                              label: const Text('Submissions & Evaluation'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.teacherPrimary,
                                side: const BorderSide(color: AppColors.teacherPrimary),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                              ),
                              onPressed: () => _showExamAttemptsDialog(exam),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              icon: Icon(resultsReleased ? Icons.lock : Icons.lock_open, size: 16),
                              label: Text(resultsReleased ? 'Lock Results' : 'Release Results'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: resultsReleased ? Colors.orange.shade700 : Colors.green.shade700,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                              ),
                              onPressed: () => _toggleReleaseResults(exam),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                              tooltip: 'Delete Examination',
                              onPressed: () => _deleteExam(exam),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  // 2C. Assignment Evaluation Screen
  Widget _buildAssignmentEvaluationScreen() {
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
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Assignment Evaluation & Grading Desk', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textMain)),
                  SizedBox(height: 4),
                  Text('Review student submissions, evaluate attachments, assign marks and return feedback.', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.refresh, color: AppColors.teacherPrimary),
                tooltip: 'Refresh Assignments',
                onPressed: _fetchTeacherAssignments,
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (_loadingTeacherAssignments)
            const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()))
          else if (_teacherAssignments.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  children: [
                    const Icon(Icons.assignment_turned_in_outlined, size: 54, color: AppColors.textMuted),
                    const SizedBox(height: 12),
                    const Text('No assignments found to evaluate.', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textMuted)),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.school_outlined),
                      label: const Text('Open Classrooms Hub'),
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.teacherPrimary, foregroundColor: Colors.white),
                      onPressed: () => setState(() => _activeScreen = 'classes'),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _teacherAssignments.length,
              itemBuilder: (ctx, idx) {
                final a = _teacherAssignments[idx];
                final dueDate = a['dueDate']?.toString() ?? 'No deadline';
                final points = a['points'] ?? 100;
                final classroomName = a['classroomName'] ?? 'Classroom';

                return Card(
                  margin: const EdgeInsets.only(bottom: 14),
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: AppColors.border),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0FDF4),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.rate_review_outlined, color: Colors.green, size: 24),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(a['title'] ?? 'Assignment', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textMain)),
                              const SizedBox(height: 4),
                              Text(
                                '$classroomName • Due: $dueDate • Total: $points pts',
                                style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.grading, size: 16),
                          label: const Text('Evaluate Submissions'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.teacherPrimary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () {
                            final cId = a['classroomId']?.toString() ?? '';
                            final aId = a['id']?.toString() ?? '';
                            if (cId.isNotEmpty && aId.isNotEmpty) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AssignmentViewScreen(
                                    assignmentId: aId,
                                    classroomId: cId,
                                    userRole: 'teacher',
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  // 2D. Question Management Screen
  Widget _buildQuestionManagementScreen() {
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
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Question Management & Question Bank', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textMain)),
                  SizedBox(height: 4),
                  Text('Review exam question sets, answer options, correct choices, and scoring weights.', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                ],
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.add, size: 18),
                label: const Text('New Assessment with Questions'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.teacherPrimary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: _showCreateExamDialog,
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (_loadingTeacherExams)
            const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()))
          else if (_teacherExams.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  children: [
                    const Icon(Icons.quiz_outlined, size: 54, color: AppColors.textMuted),
                    const SizedBox(height: 12),
                    const Text('No questions created yet. Schedule an assessment to build questions.', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textMuted)),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('Create Exam & Questions'),
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.teacherPrimary, foregroundColor: Colors.white),
                      onPressed: _showCreateExamDialog,
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _teacherExams.length,
              itemBuilder: (ctx, idx) {
                final exam = _teacherExams[idx];
                final qs = exam['questions'] as List? ?? [];

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: AppColors.border),
                  ),
                  child: ExpansionTile(
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3E8FF),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.quiz_outlined, color: Colors.purple, size: 22),
                    ),
                    title: Text(exam['title'] ?? 'Assessment', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    subtitle: Text('${exam['courseCode'] ?? "CS"} • ${qs.length} Questions • Total ${exam['totalMarks'] ?? 100} Marks', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Column(
                          children: qs.asMap().entries.map((entry) {
                            final qIdx = entry.key + 1;
                            final q = entry.value as Map<String, dynamic>;
                            final opts = (q['options'] as List?) ?? [];
                            final correct = q['correctAnswer']?.toString() ?? '';

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text('Q$qIdx: ', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                                      Expanded(
                                        child: Text(q['question']?.toString() ?? '', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(4)),
                                        child: Text('${q['marks'] ?? 25} pts', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blue.shade800)),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 6,
                                    children: opts.map((opt) {
                                      final isCorrect = opt.toString() == correct;
                                      return Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: isCorrect ? Colors.green.shade50 : Colors.white,
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(color: isCorrect ? Colors.green : AppColors.border),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            if (isCorrect) const Icon(Icons.check_circle, size: 14, color: Colors.green),
                                            if (isCorrect) const SizedBox(width: 4),
                                            Text(
                                              opt.toString(),
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: isCorrect ? FontWeight.bold : FontWeight.normal,
                                                color: isCorrect ? Colors.green.shade900 : AppColors.textMain,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  // 2E. Exam Evaluation Screen
  Widget _buildExamEvaluationScreen() {
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
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Exam Evaluation & Student Attempts', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textMain)),
                  SizedBox(height: 4),
                  Text('Review student submissions, inspect chosen responses, and verify automated marks.', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.refresh, color: AppColors.teacherPrimary),
                tooltip: 'Refresh',
                onPressed: _fetchTeacherExams,
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (_loadingTeacherExams)
            const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()))
          else if (_teacherExams.isEmpty)
            const Center(child: Padding(padding: EdgeInsets.all(40), child: Text('No exams scheduled yet.')))
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _teacherExams.length,
              itemBuilder: (ctx, idx) {
                final exam = _teacherExams[idx];
                final resultsReleased = exam['resultsReleased'] == true;

                return Card(
                  margin: const EdgeInsets.only(bottom: 14),
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: AppColors.border),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.fact_check_outlined, color: Colors.orange, size: 24),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(exam['title'] ?? 'Examination', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textMain)),
                              const SizedBox(height: 4),
                              Text(
                                '${exam['courseCode'] ?? "CS"} • ${exam['courseName'] ?? ""} • Max Marks: ${exam['totalMarks'] ?? 100}',
                                style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                              ),
                            ],
                          ),
                        ),
                        OutlinedButton.icon(
                          icon: const Icon(Icons.people_outline, size: 16),
                          label: const Text('Inspect Attempts'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.teacherPrimary,
                            side: const BorderSide(color: AppColors.teacherPrimary),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () => _showExamAttemptsDialog(exam),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          icon: Icon(resultsReleased ? Icons.lock : Icons.lock_open, size: 16),
                          label: Text(resultsReleased ? 'Lock' : 'Release'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: resultsReleased ? Colors.orange.shade700 : Colors.green.shade700,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () => _toggleReleaseResults(exam),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  // 2F. Results Screen
  Widget _buildResultsScreen() {
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
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Examination Results & Publication', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textMain)),
                  SizedBox(height: 4),
                  Text('Control scorecard release to students and view consolidated academic grading.', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.refresh, color: AppColors.teacherPrimary),
                tooltip: 'Refresh',
                onPressed: _fetchTeacherExams,
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (_loadingTeacherExams)
            const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()))
          else if (_teacherExams.isEmpty)
            const Center(child: Padding(padding: EdgeInsets.all(40), child: Text('No exams recorded.')))
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _teacherExams.length,
              itemBuilder: (ctx, idx) {
                final exam = _teacherExams[idx];
                final resultsReleased = exam['resultsReleased'] == true;

                return Card(
                  margin: const EdgeInsets.only(bottom: 14),
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: AppColors.border),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: resultsReleased ? Colors.green.shade50 : Colors.amber.shade50,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            resultsReleased ? Icons.emoji_events : Icons.lock_clock,
                            color: resultsReleased ? Colors.green : Colors.amber.shade800,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(exam['title'] ?? 'Examination', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textMain)),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                                    '${exam['courseCode'] ?? "CS"} • Total: ${exam['totalMarks'] ?? 100} Marks  •  ',
                                    style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: resultsReleased ? Colors.green.shade50 : Colors.amber.shade50,
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(color: resultsReleased ? Colors.green : Colors.amber),
                                    ),
                                    child: Text(
                                      resultsReleased ? 'RESULTS RELEASED' : 'WITHHELD / DRAFT',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: resultsReleased ? Colors.green.shade800 : Colors.amber.shade900,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton.icon(
                          icon: Icon(resultsReleased ? Icons.lock : Icons.lock_open, size: 16),
                          label: Text(resultsReleased ? 'Lock Scorecards' : 'Release Scorecards'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: resultsReleased ? Colors.orange.shade700 : Colors.green.shade700,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () => _toggleReleaseResults(exam),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  // 3. Students (Live CRUD from Backend)
  Widget _buildStudentsScreen() {
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
                  const Text('Student Directory', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                  Text('${studentProv.students.length} students retrieved from backend database.', style: const TextStyle(fontSize: 13, color: AppColors.textMuted)),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => setState(() => _activeScreen = 'add-student'),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Student'),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.teacherPrimary),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Search Bar
          TextField(
            onChanged: (v) => studentProv.fetchStudents(v),
            decoration: const InputDecoration(
              hintText: 'Search by student name, roll number, or email...',
              prefixIcon: Icon(Icons.search, size: 20),
            ),
          ),
          const SizedBox(height: 20),

          if (studentProv.isLoading)
            const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()))
          else if (studentProv.students.isEmpty)
            const Center(child: Padding(padding: EdgeInsets.all(32), child: Text('No students found.')))
          else
            ...studentProv.students.map((s) {
              return Padding(
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
                            backgroundColor: AppColors.teacherPrimary.withValues(alpha: 0.2),
                            child: Text(s.name.isNotEmpty ? s.name[0].toUpperCase() : 'S', style: const TextStyle(color: AppColors.teacherPrimary, fontWeight: FontWeight.w700)),
                          ),
                          const SizedBox(width: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(s.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                              const SizedBox(height: 2),
                              Text('Roll: ${s.rollNumber} • ${s.className} • ${s.email}', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.visibility, size: 18, color: AppColors.primary),
                            tooltip: 'View Details',
                            onPressed: () {
                              setState(() {
                                _selectedStudent = s;
                                _activeScreen = 'student-detail';
                              });
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                            tooltip: 'Delete Student',
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Delete Student?'),
                                  content: Text('Are you sure you want to remove ${s.name}?'),
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
                                await studentProv.deleteStudent(s.id);
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Student deleted successfully')));
                                }
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  // 4. Add Student Form
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
              const Text('Enroll New Student', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              TextButton(
                onPressed: () {
                  _studentNameController.text = 'Aakash Verma';
                  _studentEmailController.text = 'aakash.verma@example.com';
                  _studentRollController.text = 'BCA-${DateTime.now().millisecondsSinceEpoch % 1000}';
                  _studentClassController.text = 'BCA - Sem 3';
                  _studentPhoneController.text = '+91 98765 22334';
                },
                child: const Text('Demo Fill'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _studentNameController,
            decoration: const InputDecoration(labelText: 'Student Full Name', hintText: 'e.g. Aakash Verma'),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _studentEmailController,
                  decoration: const InputDecoration(labelText: 'Email Address', hintText: 'student@example.com'),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: TextFormField(
                  controller: _studentRollController,
                  decoration: const InputDecoration(labelText: 'Roll Number', hintText: 'BCA-305'),
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
                  decoration: const InputDecoration(labelText: 'Class / Course', hintText: 'BCA - Sem 3'),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: TextFormField(
                  controller: _studentPhoneController,
                  decoration: const InputDecoration(labelText: 'Phone Number', hintText: '+91 98765 00000'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
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
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Student enrolled into database!'), backgroundColor: AppColors.success));
                    setState(() => _activeScreen = 'students');
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.teacherPrimary),
                child: const Text('Save Student Record'),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: () => setState(() => _activeScreen = 'students'),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 5. Student Detail
  Widget _buildStudentDetailScreen() {
    final s = _selectedStudent;
    if (s == null) {
      return const Center(child: Text('No student selected'));
    }

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.teacherPrimary,
                    child: Text(s.name.isNotEmpty ? s.name[0].toUpperCase() : 'S', style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                      Text('Roll No: ${s.rollNumber} • ${s.className}', style: const TextStyle(color: AppColors.textMuted)),
                    ],
                  ),
                ],
              ),
              OutlinedButton(
                onPressed: () => setState(() => _activeScreen = 'students'),
                child: const Text('Back to Students'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(color: AppColors.border),
          const SizedBox(height: 16),
          _buildInfoRow('Email Address', s.email),
          _buildInfoRow('Phone', s.phone ?? 'N/A'),
          _buildInfoRow('Course / Degree', s.course),
          _buildInfoRow('Status', s.status ?? 'Active'),
          _buildInfoRow('Father Name', s.fatherName ?? 'Guardian'),
          _buildInfoRow('Father Contact', s.fatherPhone ?? 'N/A'),
          _buildInfoRow('Address', s.address ?? 'Campus Residential'),
        ],
      ),
    );
  }

  // 6. Courses
  Widget _buildCoursesScreen() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Assigned Curriculum & Courses', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              ElevatedButton.icon(
                onPressed: () => setState(() => _activeScreen = 'add-course'),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Course'),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.teacherPrimary),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ..._courses.map((c) {
            return Padding(
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
                        Text('${c.code}: ${c.name}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                        const SizedBox(height: 3),
                        Text('${c.department} • ${c.semester} • ${c.credits} Credits • ${c.studentsEnrolled} Students', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                        const SizedBox(height: 8),
                        Text('Syllabus Completion: ${(c.progress * 100).toInt()}%', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.teacherPrimary)),
                      ],
                    ),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _selectedCourse = c;
                              _activeScreen = 'course-details';
                            });
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.teacherPrimary),
                          child: const Text('Syllabus Breakdown'),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: AppColors.error),
                          onPressed: () {
                            setState(() => _courses.removeWhere((item) => item.id == c.id));
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Course removed')));
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // 7. Add Course
  Widget _buildAddCourseScreen() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Create New Academic Course', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: TextFormField(controller: _courseCodeController, decoration: const InputDecoration(labelText: 'Course Code', hintText: 'CS-405'))),
              const SizedBox(width: 14),
              Expanded(child: TextFormField(controller: _courseNameController, decoration: const InputDecoration(labelText: 'Course Name', hintText: 'Network Security'))),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: TextFormField(controller: _courseDeptController, decoration: const InputDecoration(labelText: 'Department', hintText: 'Computer Science'))),
              const SizedBox(width: 14),
              Expanded(child: TextFormField(controller: _courseCreditsController, decoration: const InputDecoration(labelText: 'Credits', hintText: '4'))),
            ],
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              if (_courseCodeController.text.isEmpty || _courseNameController.text.isEmpty) return;
              setState(() {
                _courses.add(CourseModel(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  code: _courseCodeController.text.trim(),
                  name: _courseNameController.text.trim(),
                  department: _courseDeptController.text.trim(),
                  credits: int.tryParse(_courseCreditsController.text) ?? 4,
                  semester: 'Semester 3',
                  studentsEnrolled: 0,
                  progress: 0.0,
                ));
                _activeScreen = 'courses';
              });
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Course added successfully!'), backgroundColor: AppColors.success));
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.teacherPrimary),
            child: const Text('Add Course to Curriculum'),
          ),
        ],
      ),
    );
  }

  // 8. Remove Course Screen
  Widget _buildRemoveCourseScreen() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Remove / Archive Courses', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          const Text('Select a course to archive or remove from the active semester.', style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
          const SizedBox(height: 20),
          ..._courses.map((c) => ListTile(
                title: Text('${c.code}: ${c.name}'),
                subtitle: Text('${c.department} • ${c.studentsEnrolled} Students'),
                trailing: ElevatedButton(
                  onPressed: () {
                    setState(() => _courses.removeWhere((item) => item.id == c.id));
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Course archived')));
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                  child: const Text('Archive'),
                ),
              )),
        ],
      ),
    );
  }

  // 9. Course Details
  Widget _buildCourseDetailsScreen() {
    final c = _selectedCourse ?? _courses.first;
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${c.code}: ${c.name}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              OutlinedButton(onPressed: () => setState(() => _activeScreen = 'courses'), child: const Text('Back to Courses')),
            ],
          ),
          const SizedBox(height: 8),
          Text('Instructor: ${c.instructor} • Credits: ${c.credits} • ${c.semester}', style: const TextStyle(color: AppColors.textMuted)),
          const SizedBox(height: 24),
          const Divider(color: AppColors.border),
          const SizedBox(height: 16),
          const Text('Syllabus Modules:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          const Text('• Unit 1: Relational Data Models, ER Diagrams, Relational Algebra'),
          const SizedBox(height: 6),
          const Text('• Unit 2: SQL DDL, DML, Subqueries, Joins, Triggers and Stored Procedures'),
          const SizedBox(height: 6),
          const Text('• Unit 3: Normalization 1NF, 2NF, 3NF, BCNF and Functional Dependencies'),
          const SizedBox(height: 6),
          const Text('• Unit 4: Transaction Processing, ACID Properties, Concurrency Control'),
        ],
      ),
    );
  }

  // 10. Lectures
  Widget _buildLecturesScreen() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Lecture Schedule Management', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              ElevatedButton.icon(
                onPressed: () => setState(() => _activeScreen = 'update-lecture'),
                icon: const Icon(Icons.edit, size: 16),
                label: const Text('Update Lecture'),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.teacherPrimary),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ..._lectures.map((l) => Padding(
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
                          Text(l.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                          const SizedBox(height: 4),
                          Text('${l.date} • ${l.time} • ${l.room}', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                          const SizedBox(height: 4),
                          Text('Topic: ${l.topic}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.teacherPrimary)),
                        ],
                      ),
                      StatusBadge(label: l.status, status: 'scheduled'),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }

  // 11. Update Lecture
  Widget _buildUpdateLectureScreen() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Update Lecture Schedule', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 20),
          TextFormField(controller: _lectureTopicController, decoration: const InputDecoration(labelText: 'Topic Title')),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: TextFormField(controller: _lectureTimeController, decoration: const InputDecoration(labelText: 'Time Slot'))),
              const SizedBox(width: 14),
              Expanded(child: TextFormField(controller: _lectureRoomController, decoration: const InputDecoration(labelText: 'Assigned Classroom'))),
            ],
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _lectures.first = LectureModel(
                  id: '1',
                  title: 'Database Systems (CS-301)',
                  courseCode: 'CS-301',
                  courseName: 'Database Management Systems',
                  date: 'May 06, 2025',
                  time: _lectureTimeController.text,
                  room: _lectureRoomController.text,
                  status: 'Scheduled',
                  topic: _lectureTopicController.text,
                );
                _activeScreen = 'lectures';
              });
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lecture schedule updated!'), backgroundColor: AppColors.success));
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.teacherPrimary),
            child: const Text('Save Changes to Schedule'),
          ),
        ],
      ),
    );
  }

  // 12. Profile
  Widget _buildProfileScreen(UserModel? user) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: AppColors.teacherPrimary,
                child: Text(
                  user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : 'T',
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Colors.white),
                ),
              ),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user?.name ?? 'Dr. Amit Sharma', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                  Text('${user?.designation ?? "Assistant Professor"} • ${user?.department ?? "Computer Science"}', style: const TextStyle(color: AppColors.textMuted)),
                  const SizedBox(height: 6),
                  const StatusBadge(label: 'Verified Faculty', status: 'active'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(color: AppColors.border),
          const SizedBox(height: 16),
          _buildInfoRow('Employee / Faculty ID', user?.instructorId ?? 'INS-001'),
          _buildInfoRow('Official Email', user?.email ?? 'amit.sharma@institute.com'),
          _buildInfoRow('Contact Phone', user?.phone ?? '+91 98765 43210'),
          _buildInfoRow('Qualification', user?.qualification ?? 'Ph.D - Computer Science'),
          _buildInfoRow('Teaching Experience', user?.experience ?? '5 Years'),
          _buildInfoRow('Campus Affiliation', user?.instituteName ?? 'Apex Institute of Technology'),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Faculty profile saved successfully!'), backgroundColor: AppColors.success));
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.teacherPrimary),
            child: const Text('Update Profile Details'),
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
