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

class TeacherPortalScreen extends StatefulWidget {
  final String initialTab;
  const TeacherPortalScreen({super.key, this.initialTab = 'dashboard'});

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
      {'id': 'classes', 'title': 'My Classes', 'icon': Icons.class_outlined},
      {'id': 'students', 'title': 'Student Records', 'icon': Icons.people_outline},
      {'id': 'add-student', 'title': 'Add New Student', 'icon': Icons.person_add_outlined},
      {'id': 'courses', 'title': 'Courses & Curriculum', 'icon': Icons.menu_book_outlined},
      {'id': 'add-course', 'title': 'Add Course', 'icon': Icons.post_add_outlined},
      {'id': 'lectures', 'title': 'Lecture Schedules', 'icon': Icons.event_note_outlined},
      {'id': 'update-lecture', 'title': 'Update Lecture', 'icon': Icons.edit_calendar_outlined},
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
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.teacherPrimary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.cast_for_education, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Instructor Portal', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.textMain)),
                    Text('Faculty Desk', style: TextStyle(fontSize: 11, color: AppColors.textLight)),
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
        return 'Assigned Classes & Roster';
      case 'students':
        return 'Student Directory & Records';
      case 'add-student':
        return 'Enroll New Student';
      case 'student-detail':
        return 'Student Profile Details';
      case 'courses':
        return 'Assigned Courses & Curriculum';
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
        return _buildClassesScreen();
      case 'students':
        return _buildStudentsScreen();
      case 'add-student':
        return _buildAddStudentScreen();
      case 'student-detail':
        return _buildStudentDetailScreen();
      case 'courses':
        return _buildCoursesScreen();
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
    final classes = [
      {'name': 'BCA - Semester 3 (Section A)', 'students': 48, 'room': 'Hall 302', 'sub': 'Database Systems', 'prog': 0.72},
      {'name': 'BCA - Semester 3 (Section B)', 'students': 52, 'room': 'Hall 105', 'sub': 'Data Structures', 'prog': 0.65},
      {'name': 'MCA - Semester 1', 'students': 42, 'room': 'Hall 201', 'sub': 'Advanced Web Tech', 'prog': 0.80},
      {'name': 'B.Tech CS - Semester 5', 'students': 38, 'room': 'Seminar Hall', 'sub': 'Cloud Architecture', 'prog': 0.50},
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Assigned Class Batches', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          const Text('Manage classroom rosters, attendance logs, and student performance.', style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
          const SizedBox(height: 20),
          ...classes.map((c) {
            final prog = c['prog'] as double;
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
                        Text(c['name'] as String, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                        const SizedBox(height: 3),
                        Text('Subject: ${c['sub']} • ${c['room']} • ${c['students']} Students', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                        const SizedBox(height: 8),
                        Text('Syllabus Progress: ${(prog * 100).toInt()}%', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.teacherPrimary)),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () => setState(() => _activeScreen = 'students'),
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.teacherPrimary),
                      child: const Text('View Students'),
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
