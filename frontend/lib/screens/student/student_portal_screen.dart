import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../models/user_model.dart';
import '../../providers/navigation_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/metric_card.dart';

class StudentPortalScreen extends StatefulWidget {
  final String initialTab;
  const StudentPortalScreen({super.key, this.initialTab = 'dashboard'});

  @override
  State<StudentPortalScreen> createState() => _StudentPortalScreenState();
}

class _StudentPortalScreenState extends State<StudentPortalScreen> {
  late String _activeTab;
  String _selectedDay = 'Mon';

  // Live Exam States
  int _currentQuestion = 1;
  final Map<int, String> _selectedAnswers = {
    1: 'B',
    2: 'A',
    3: 'C',
    4: 'D',
  };
  final Set<int> _flaggedQuestions = {3};
  bool _instructionsAccepted = false;
  int _examTimeSeconds = 3600; // 60 mins
  Timer? _examTimer;

  // Modals & Notifications
  bool _showNotifications = false;

  @override
  void initState() {
    super.initState();
    _activeTab = widget.initialTab.isNotEmpty ? widget.initialTab : 'dashboard';
  }

  @override
  void didUpdateWidget(StudentPortalScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialTab.isNotEmpty && widget.initialTab != _activeTab) {
      setState(() => _activeTab = widget.initialTab);
    }
  }

  void _startExamTimer() {
    _examTimer?.cancel();
    _examTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_examTimeSeconds > 0) {
        if (mounted) setState(() => _examTimeSeconds--);
      } else {
        timer.cancel();
        if (mounted) _submitExam();
      }
    });
  }

  void _submitExam() {
    _examTimer?.cancel();
    setState(() => _activeTab = 'exam-submitted');
  }

  @override
  void dispose() {
    _examTimer?.cancel();
    super.dispose();
  }

  String _formatTime(int totalSeconds) {
    final m = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
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
                        child: _buildTabContent(user, nav),
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
      {'id': 'profile', 'title': 'My Profile', 'icon': Icons.person_outline},
      {'id': 'attendance', 'title': 'Attendance', 'icon': Icons.fact_check_outlined},
      {'id': 'grades', 'title': 'Grades & Results', 'icon': Icons.emoji_events_outlined},
      {'id': 'schedule', 'title': 'Class Schedule', 'icon': Icons.calendar_today_outlined},
      {'id': 'materials', 'title': 'Study Materials', 'icon': Icons.menu_book_outlined},
      {'id': 'timetable', 'title': 'Weekly Timetable', 'icon': Icons.grid_view_outlined},
      {'id': 'parents', 'title': 'Parent Portal', 'icon': Icons.family_restroom_outlined},
      {'id': 'exams', 'title': 'Online Exams', 'icon': Icons.assignment_outlined},
    ];

    return Container(
      width: 260,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        children: [
          // Brand Header
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
                    Text('Student Academic Desk', style: TextStyle(fontSize: 11, color: AppColors.textLight)),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),

          // Student Mini Card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF3E8FF),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE9D5FF)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.studentPrimary,
                  child: Text(
                    user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : 'S',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.name ?? 'Rahul Sharma',
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textMain),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Roll: ${user?.rollNumber ?? "1023"}',
                        style: const TextStyle(fontSize: 11, color: AppColors.studentPrimary, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Nav Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: menuItems.map((item) {
                final id = item['id'] as String;
                final isSelected = _activeTab == id || (_activeTab.startsWith('exam-') && id == 'exams');
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: ListTile(
                    dense: true,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    tileColor: isSelected ? const Color(0xFFF3E8FF) : Colors.transparent,
                    leading: Icon(
                      item['icon'] as IconData,
                      size: 20,
                      color: isSelected ? AppColors.studentPrimary : AppColors.textMuted,
                    ),
                    title: Text(
                      item['title'] as String,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? AppColors.studentPrimary : AppColors.textMain,
                      ),
                    ),
                    onTap: () {
                      setState(() => _activeTab = id);
                      nav.setPortalTab(id);
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          // Bottom Gateway Return
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
                _getTabTitle(_activeTab),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textMain),
              ),
            ],
          ),
          Row(
            children: [
              // Notification Bell
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined, size: 22, color: AppColors.textMuted),
                    onPressed: () => setState(() => _showNotifications = !_showNotifications),
                  ),
                  Positioned(
                    right: 10,
                    top: 10,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.error),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              // User Chip
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
                  nav.navigateTo('student-login');
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getTabTitle(String tab) {
    switch (tab) {
      case 'dashboard':
        return 'Student Dashboard';
      case 'profile':
        return 'Student Profile & ID';
      case 'attendance':
        return 'Attendance Tracker';
      case 'grades':
        return 'Academic Results & Marksheet';
      case 'schedule':
        return 'Class Timetable';
      case 'materials':
        return 'Course Materials & Lectures';
      case 'timetable':
        return 'Weekly Schedule Grid';
      case 'parents':
        return 'Parent & Guardian Portal';
      case 'exams':
        return 'Online Examination Hall';
      case 'exam-instructions':
        return 'Examination Rules & Instructions';
      case 'exam-live':
        return 'Live Assessment in Progress';
      case 'exam-submitted':
        return 'Examination Submitted';
      case 'exam-results':
        return 'Assessment Results & Scorecard';
      default:
        return 'Student Portal';
    }
  }

  Widget _buildTabContent(UserModel? user, NavigationProvider nav) {
    switch (_activeTab) {
      case 'dashboard':
        return _buildDashboardTab(user);
      case 'profile':
        return _buildProfileTab(user);
      case 'attendance':
        return _buildAttendanceTab();
      case 'grades':
        return _buildGradesTab();
      case 'schedule':
        return _buildScheduleTab();
      case 'materials':
        return _buildMaterialsTab();
      case 'timetable':
        return _buildTimetableTab();
      case 'parents':
        return _buildParentsTab(user);
      case 'exams':
        return _buildExamsTab();
      case 'exam-instructions':
        return _buildExamInstructionsTab();
      case 'exam-live':
        return _buildExamLiveTab();
      case 'exam-submitted':
        return _buildExamSubmittedTab();
      case 'exam-results':
        return _buildExamResultsTab();
      default:
        return _buildDashboardTab(user);
    }
  }

  // 1. Dashboard Tab
  Widget _buildDashboardTab(UserModel? user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Welcome Banner
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF581C87), Color(0xFF7C3AED)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Welcome Back!', style: TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 4),
                  Text(
                    user?.name ?? 'Rahul Sharma',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Class: ${user?.className ?? "BCA - Sem 3"} • Roll No: ${user?.rollNumber ?? "1023"}',
                    style: const TextStyle(fontSize: 13, color: Colors.white70),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  children: [
                    Text('TERM STATUS', style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w700)),
                    Text('Semester 3', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // 4 KPI Cards
        Row(
          children: [
            Expanded(
              child: MetricCard(
                title: 'Attendance',
                value: '92.4%',
                icon: Icons.check_circle_outline,
                color: AppColors.accentGreen,
                subtitle: 'Above 75% requirement',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: MetricCard(
                title: 'Current CGPA',
                value: '3.82 / 4.0',
                icon: Icons.emoji_events_outlined,
                color: AppColors.accentOrange,
                subtitle: 'Top 5% of class',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: MetricCard(
                title: 'Enrolled Courses',
                value: '6 Subjects',
                icon: Icons.menu_book,
                color: AppColors.studentPrimary,
                subtitle: '22 Total Credits',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: MetricCard(
                title: 'Upcoming Exams',
                value: '2 Tests',
                icon: Icons.assignment_outlined,
                color: AppColors.primary,
                subtitle: 'Next: DBMS Mid-Term',
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),

        // Today's Lectures + Quick Links
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Lectures
            Expanded(
              flex: 7,
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
                    const Text("Today's Lectures", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 16),
                    _buildLectureItem('10:00 AM - 11:30 AM', 'Database Systems (CS-301)', 'Hall 302 • Dr. Amit Sharma', 'Scheduled'),
                    const Divider(color: AppColors.border),
                    _buildLectureItem('11:45 AM - 01:15 PM', 'Data Structures & Algorithms', 'Lab 2 • Prof. Rajesh Gupta', 'In Progress'),
                    const Divider(color: AppColors.border),
                    _buildLectureItem('02:00 PM - 03:30 PM', 'Computer Networks (CS-303)', 'Hall 105 • Prof. Sunita Rao', 'Upcoming'),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 20),

            // Quick Actions
            Expanded(
              flex: 5,
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
                    const Text('Quick Access', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 16),
                    _buildQuickAction('Take Online Exam', Icons.quiz_outlined, () => setState(() => _activeTab = 'exams')),
                    const SizedBox(height: 10),
                    _buildQuickAction('View Grade Card', Icons.grade_outlined, () => setState(() => _activeTab = 'grades')),
                    const SizedBox(height: 10),
                    _buildQuickAction('Download Study Notes', Icons.download_outlined, () => setState(() => _activeTab = 'materials')),
                    const SizedBox(height: 10),
                    _buildQuickAction('Parent Meeting Request', Icons.connect_without_contact, () => setState(() => _activeTab = 'parents')),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLectureItem(String time, String title, String subtitle, String status) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: AppColors.studentPrimary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.access_time, color: AppColors.studentPrimary, size: 18),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textMain)),
                  const SizedBox(height: 2),
                  Text('$time • $subtitle', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                ],
              ),
            ],
          ),
          StatusBadge(label: status, status: status),
        ],
      ),
    );
  }

  Widget _buildQuickAction(String title, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.bgPage,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.studentPrimary),
            const SizedBox(width: 12),
            Expanded(child: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
            const Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.textLight),
          ],
        ),
      ),
    );
  }

  // 2. Profile Tab
  Widget _buildProfileTab(UserModel? user) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: AppColors.studentPrimary,
                child: Text(
                  user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : 'R',
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Colors.white),
                ),
              ),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user?.name ?? 'Rahul Sharma', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text('Roll Number: ${user?.rollNumber ?? "1023"} • ${user?.className ?? "BCA - Sem 3"}', style: const TextStyle(color: AppColors.textMuted)),
                  const SizedBox(height: 6),
                  const StatusBadge(label: 'Enrolled & Verified', status: 'active'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 28),
          const Divider(color: AppColors.border),
          const SizedBox(height: 20),
          const Text('Academic Information', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 14),
          _buildInfoRow('Registered Email', user?.email ?? 'rahul@institute.com'),
          _buildInfoRow('Course / Degree', user?.course ?? 'Bachelor of Computer Applications'),
          _buildInfoRow('Current Semester', user?.semester ?? 'Semester 3'),
          _buildInfoRow('Institute Name', user?.instituteName ?? 'Apex Institute of Technology'),
          _buildInfoRow('Institute Code', user?.instituteCode ?? 'INST-2025'),
          const SizedBox(height: 24),
          const Text('Parent / Guardian Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 14),
          _buildInfoRow('Father Name', user?.fatherName ?? 'Rakesh Sharma'),
          _buildInfoRow('Father Phone', user?.fatherPhone ?? '+91 98765 43210'),
          _buildInfoRow('Mother Name', user?.motherName ?? 'Pooja Sharma'),
          _buildInfoRow('Residential Address', user?.address ?? '123, Green Park, Delhi - 110016'),
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

  // 3. Attendance Tab
  Widget _buildAttendanceTab() {
    final subjects = [
      {'name': 'Database Systems', 'held': 40, 'attended': 38, 'rate': 95.0},
      {'name': 'Data Structures & Algorithms', 'held': 44, 'attended': 40, 'rate': 90.9},
      {'name': 'Operating Systems', 'held': 36, 'attended': 32, 'rate': 88.8},
      {'name': 'Web Technologies', 'held': 35, 'attended': 33, 'rate': 94.2},
      {'name': 'Applied Mathematics', 'held': 38, 'attended': 34, 'rate': 89.4},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              flex: 4,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Cumulative Attendance', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
                    const SizedBox(height: 10),
                    const Text('92.4%', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: AppColors.accentGreen)),
                    const SizedBox(height: 8),
                    const Text('Status: Eligible for final examinations (Threshold: 75%)', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 8,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Attendance Rules', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
                    SizedBox(height: 8),
                    Text('• Minimum 75% attendance mandatory in each course to sit for semester exams.', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                    SizedBox(height: 4),
                    Text('• Medical leaves must be approved by class coordinator within 3 working days.', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Course Attendance Breakdown', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              const SizedBox(height: 16),
              ...subjects.map((s) {
                final rate = s['rate'] as double;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(s['name'] as String, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                          Text('${s['attended']} / ${s['held']} (${rate.toStringAsFixed(1)}%)', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      LinearProgressIndicator(
                        value: rate / 100,
                        backgroundColor: AppColors.bgPage,
                        valueColor: AlwaysStoppedAnimation<Color>(rate >= 75 ? AppColors.accentGreen : AppColors.error),
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  // 4. Grades Tab
  Widget _buildGradesTab() {
    final grades = [
      {'code': 'CS-301', 'title': 'Database Management Systems', 'credits': 4, 'grade': 'A+', 'score': 92},
      {'code': 'CS-302', 'title': 'Data Structures & Algorithms', 'credits': 4, 'grade': 'A', 'score': 88},
      {'code': 'CS-303', 'title': 'Operating Systems', 'credits': 4, 'grade': 'B+', 'score': 79},
      {'code': 'CS-304', 'title': 'Web Technologies & Frameworks', 'credits': 3, 'grade': 'A+', 'score': 95},
      {'code': 'MA-301', 'title': 'Applied Numerical Mathematics', 'credits': 4, 'grade': 'A', 'score': 85},
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Semester Grade Report', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                  Text('Semester 2 Result Card • Official Transcript', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Grade report downloaded as PDF!')));
                },
                icon: const Icon(Icons.download, size: 16),
                label: const Text('Download PDF'),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.studentPrimary),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(color: AppColors.border),
          ...grades.map((g) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(g['title'] as String, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                      Text('${g['code']} • Credits: ${g['credits']}', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                    ],
                  ),
                  Row(
                    children: [
                      Text('${g['score']}%', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.studentPrimary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          g['grade'] as String,
                          style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.studentPrimary, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // 5. Schedule Tab
  Widget _buildScheduleTab() {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
    final scheduleMap = {
      'Mon': [
        {'time': '09:00 - 10:30', 'course': 'Database Systems', 'room': 'Hall 302', 'faculty': 'Dr. Amit Sharma'},
        {'time': '11:00 - 12:30', 'course': 'Data Structures Lab', 'room': 'Lab 1', 'faculty': 'Prof. Rajesh Gupta'},
      ],
      'Tue': [
        {'time': '10:00 - 11:30', 'course': 'Operating Systems', 'room': 'Hall 105', 'faculty': 'Prof. Sunita Rao'},
        {'time': '01:00 - 02:30', 'course': 'Web Technologies', 'room': 'Lab 3', 'faculty': 'Dr. Amit Sharma'},
      ],
      'Wed': [
        {'time': '09:00 - 10:30', 'course': 'Applied Mathematics', 'room': 'Hall 201', 'faculty': 'Dr. Ramanujan'},
        {'time': '11:00 - 12:30', 'course': 'Database Lab', 'room': 'Lab 2', 'faculty': 'Dr. Amit Sharma'},
      ],
      'Thu': [
        {'time': '10:00 - 11:30', 'course': 'Data Structures & Algorithms', 'room': 'Hall 302', 'faculty': 'Prof. Rajesh Gupta'},
      ],
      'Fri': [
        {'time': '09:00 - 10:30', 'course': 'Web Development Workshop', 'room': 'Seminar Hall', 'faculty': 'Guest Faculty'},
      ],
    };

    final currentList = scheduleMap[_selectedDay] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: days.map((d) {
            final isSel = _selectedDay == d;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ElevatedButton(
                onPressed: () => setState(() => _selectedDay = d),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSel ? AppColors.studentPrimary : Colors.white,
                  foregroundColor: isSel ? Colors.white : AppColors.textMain,
                  elevation: 0,
                  side: BorderSide(color: isSel ? AppColors.studentPrimary : AppColors.border),
                ),
                child: Text(d),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("$_selectedDay's Timetable", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              const SizedBox(height: 16),
              ...currentList.map((c) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
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
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(c['course']!, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                              const SizedBox(height: 4),
                              Text('${c['room']} • Faculty: ${c['faculty']}', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                            child: Text(c['time']!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.studentPrimary)),
                          ),
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

  // 6. Materials Tab
  Widget _buildMaterialsTab() {
    final materials = [
      {'title': 'Relational Schema & 3NF Normalization.pdf', 'course': 'Database Systems', 'size': '4.2 MB', 'date': 'May 02, 2025'},
      {'title': 'Balanced BST & Graph Algorithms.pdf', 'course': 'Algorithms', 'size': '6.8 MB', 'date': 'Apr 28, 2025'},
      {'title': 'Virtual Memory & Page Replacement.pdf', 'course': 'Operating Systems', 'size': '3.1 MB', 'date': 'Apr 24, 2025'},
      {'title': 'REST API Architecture & JSON Schemas.pdf', 'course': 'Web Technologies', 'size': '2.5 MB', 'date': 'Apr 20, 2025'},
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Lecture Materials & Resources', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          const Text('Download notes, slides and reference materials uploaded by instructors.', style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
          const SizedBox(height: 20),
          ...materials.map((m) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
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
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                          child: const Icon(Icons.picture_as_pdf, color: AppColors.error, size: 20),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(m['title']!, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                            const SizedBox(height: 2),
                            Text('${m['course']} • ${m['size']} • Uploaded: ${m['date']}', style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.download, color: AppColors.studentPrimary),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Downloading ${m["title"]}...')));
                      },
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

  // 7. Timetable Tab
  Widget _buildTimetableTab() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Weekly Academic Timetable Matrix', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          SizedBox(height: 8),
          Text('Complete 5-day class matrix for BCA Semester 3 (Section A)', style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
          SizedBox(height: 24),
          // Simple visual timetable grid
          Text('• Monday: 09:00 DBMS (H-302) | 11:00 DSA Lab (L-1) | 02:00 Web Tech (H-102)'),
          SizedBox(height: 10),
          Text('• Tuesday: 10:00 OS (H-105) | 01:00 Web Tech Lab (L-3) | 03:00 Maths (H-201)'),
          SizedBox(height: 10),
          Text('• Wednesday: 09:00 Maths (H-201) | 11:00 DBMS Lab (L-2) | 02:00 DSA (H-302)'),
          SizedBox(height: 10),
          Text('• Thursday: 10:00 DSA (H-302) | 01:00 OS Lab (L-1) | 03:00 DBMS (H-302)'),
          SizedBox(height: 10),
          Text('• Friday: 09:00 Workshop (Seminar Hall) | 02:00 Faculty Mentoring'),
        ],
      ),
    );
  }

  // 8. Parents Tab
  Widget _buildParentsTab(UserModel? user) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Parent & Guardian Portal', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          const Text('Registered contact information and Parent-Teacher Meeting (PTM) records.', style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
          const SizedBox(height: 24),
          _buildInfoRow('Father Name', user?.fatherName ?? 'Rakesh Sharma'),
          _buildInfoRow('Father Phone', user?.fatherPhone ?? '+91 98765 43210'),
          _buildInfoRow('Father Email', user?.fatherEmail ?? 'rakesh@example.com'),
          _buildInfoRow('Mother Name', user?.motherName ?? 'Pooja Sharma'),
          _buildInfoRow('Mother Phone', user?.motherPhone ?? '+91 98765 43211'),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('PTM meeting scheduled for next Friday 04:00 PM.')));
            },
            icon: const Icon(Icons.event, size: 16),
            label: const Text('Schedule PTM Meeting'),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.studentPrimary),
          ),
        ],
      ),
    );
  }

  // 9. Exams Tab
  Widget _buildExamsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Upcoming Examinations', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              const Text('Review instructions and enter the online testing environment.', style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
              const SizedBox(height: 20),
              _buildExamCard(
                title: 'DBMS Mid-Term Examination (CS-301)',
                date: 'May 10, 2025 • 10:00 AM',
                duration: '60 Minutes • 50 Marks',
                status: 'Ready to Start',
                onEnter: () => setState(() => _activeTab = 'exam-instructions'),
              ),
              const SizedBox(height: 12),
              _buildExamCard(
                title: 'Data Structures Practical Assessment',
                date: 'May 16, 2025 • 02:00 PM',
                duration: '90 Minutes • 100 Marks',
                status: 'Upcoming',
                onEnter: null,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExamCard({
    required String title,
    required String date,
    required String duration,
    required String status,
    required VoidCallback? onEnter,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
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
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: AppColors.studentPrimary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.assignment, color: AppColors.studentPrimary, size: 24),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                  const SizedBox(height: 3),
                  Text('$date • $duration', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                ],
              ),
            ],
          ),
          if (onEnter != null)
            ElevatedButton(
              onPressed: onEnter,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.studentPrimary),
              child: const Text('Start Exam'),
            )
          else
            const StatusBadge(label: 'Upcoming', status: 'pending'),
        ],
      ),
    );
  }

  // 10. Exam Instructions Tab
  Widget _buildExamInstructionsTab() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Online Examination Rules & Instructions', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          const Text('DBMS Mid-Term Examination (CS-301) • Academic Session 2025–2026', style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
          const SizedBox(height: 20),
          const Divider(color: AppColors.border),
          const SizedBox(height: 16),
          const Text('1. Examination Duration: 60 minutes. The countdown starts immediately once you click Start Exam.'),
          const SizedBox(height: 8),
          const Text('2. Total Questions: 20 multiple choice questions. Each question carries 2.5 marks.'),
          const SizedBox(height: 8),
          const Text('3. Navigating away from the exam tab will trigger automatic warning and proctor review.'),
          const SizedBox(height: 8),
          const Text('4. Click "Submit Exam" once you have attempted all required questions.'),
          const SizedBox(height: 24),
          Row(
            children: [
              Checkbox(
                value: _instructionsAccepted,
                onChanged: (v) => setState(() => _instructionsAccepted = v ?? false),
              ),
              const Expanded(
                child: Text('I have read and agree to comply with all online examination guidelines and honor code.'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _instructionsAccepted
                ? () {
                    _startExamTimer();
                    setState(() => _activeTab = 'exam-live');
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.studentPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
            ),
            child: const Text('Agree & Launch Examination Hall'),
          ),
        ],
      ),
    );
  }

  // 11. Exam Live Tab
  Widget _buildExamLiveTab() {
    final questions = [
      {
        'id': 1,
        'q': 'Which normal form is based on the concept of full functional dependency?',
        'options': {'A': 'First Normal Form (1NF)', 'B': 'Second Normal Form (2NF)', 'C': 'Third Normal Form (3NF)', 'D': 'Boyce-Codd Normal Form (BCNF)'},
      },
      {
        'id': 2,
        'q': 'In SQL, which command is used to remove an index from a database?',
        'options': {'A': 'DROP INDEX', 'B': 'REMOVE INDEX', 'C': 'DELETE INDEX', 'D': 'ALTER TABLE DROP'},
      },
      {
        'id': 3,
        'q': 'What does ACID stand for in the context of database transactions?',
        'options': {'A': 'Accuracy, Consistency, Integrity, Durability', 'B': 'Atomicity, Compatibility, Isolation, Durability', 'C': 'Atomicity, Consistency, Isolation, Durability', 'D': 'Access, Control, Isolation, Distribution'},
      },
      {
        'id': 4,
        'q': 'Which of the following is NOT an aggregate function in SQL?',
        'options': {'A': 'AVG()', 'B': 'COUNT()', 'C': 'SUM()', 'D': 'SELECT()'},
      },
    ];

    final currentQ = questions[(_currentQuestion - 1).clamp(0, questions.length - 1)];

    return Column(
      children: [
        // Live Exam Header Banner
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('DBMS Mid-Term Examination', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
                  Text('Live Proctored Session', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.errorBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.timer, color: AppColors.error, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      _formatTime(_examTimeSeconds),
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.error),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question area
            Expanded(
              flex: 8,
              child: Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Question $_currentQuestion of ${questions.length}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.studentPrimary)),
                        OutlinedButton.icon(
                          onPressed: () {
                            setState(() {
                              if (_flaggedQuestions.contains(_currentQuestion)) {
                                _flaggedQuestions.remove(_currentQuestion);
                              } else {
                                _flaggedQuestions.add(_currentQuestion);
                              }
                            });
                          },
                          icon: Icon(
                            _flaggedQuestions.contains(_currentQuestion) ? Icons.flag : Icons.outlined_flag,
                            size: 16,
                            color: _flaggedQuestions.contains(_currentQuestion) ? AppColors.accentOrange : AppColors.textMuted,
                          ),
                          label: Text(_flaggedQuestions.contains(_currentQuestion) ? 'Flagged' : 'Flag for Review'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(currentQ['q'] as String, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, height: 1.4)),
                    const SizedBox(height: 24),
                    ...(currentQ['options'] as Map<String, String>).entries.map((opt) {
                      final isSelected = _selectedAnswers[_currentQuestion] == opt.key;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          onTap: () => setState(() => _selectedAnswers[_currentQuestion] = opt.key),
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFFF3E8FF) : AppColors.bgPage,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: isSelected ? AppColors.studentPrimary : AppColors.border, width: isSelected ? 1.5 : 1),
                            ),
                            child: Row(
                              children: [
                                Text('${opt.key}. ', style: TextStyle(fontWeight: FontWeight.w800, color: isSelected ? AppColors.studentPrimary : AppColors.textMain)),
                                Expanded(child: Text(opt.value, style: TextStyle(fontSize: 14, color: isSelected ? AppColors.studentPrimary : AppColors.textMain))),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        OutlinedButton(
                          onPressed: _currentQuestion > 1 ? () => setState(() => _currentQuestion--) : null,
                          child: const Text('Previous'),
                        ),
                        if (_currentQuestion < questions.length)
                          ElevatedButton(
                            onPressed: () => setState(() => _currentQuestion++),
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.studentPrimary),
                            child: const Text('Next Question'),
                          )
                        else
                          ElevatedButton(
                            onPressed: _submitExam,
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
                            child: const Text('Submit Final Exam'),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Palette
            Expanded(
              flex: 4,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Question Navigator', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: List.generate(questions.length, (idx) {
                        final qNum = idx + 1;
                        final isAnswered = _selectedAnswers.containsKey(qNum);
                        final isFlagged = _flaggedQuestions.contains(qNum);
                        final isCur = _currentQuestion == qNum;

                        Color bg = AppColors.bgPage;
                        if (isCur) {
                          bg = AppColors.studentPrimary;
                        } else if (isFlagged) {
                          bg = AppColors.warningBg;
                        } else if (isAnswered) {
                          bg = AppColors.successBg;
                        }

                        return InkWell(
                          onTap: () => setState(() => _currentQuestion = qNum),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: bg,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: isCur ? AppColors.studentPrimary : AppColors.border),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '$qNum',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                color: isCur ? Colors.white : AppColors.textMain,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _submitExam,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        minimumSize: const Size.fromHeight(40),
                      ),
                      child: const Text('Submit Exam'),
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

  // 12. Exam Submitted Tab
  Widget _buildExamSubmittedTab() {
    return Container(
      padding: const EdgeInsets.all(36),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.border)),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.successBg, shape: BoxShape.circle),
            child: const Icon(Icons.check_circle, color: AppColors.success, size: 54),
          ),
          const SizedBox(height: 20),
          const Text('Exam Successfully Submitted!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.textMain)),
          const SizedBox(height: 8),
          const Text(
            'Your answers for DBMS Mid-Term Examination have been recorded into the database.',
            style: TextStyle(fontSize: 14, color: AppColors.textMuted),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => setState(() => _activeTab = 'exam-results'),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.studentPrimary),
                child: const Text('View Exam Results'),
              ),
              const SizedBox(width: 14),
              OutlinedButton(
                onPressed: () => setState(() => _activeTab = 'dashboard'),
                child: const Text('Return to Dashboard'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 13. Exam Results Tab
  Widget _buildExamResultsTab() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Examination Scorecard', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                  Text('DBMS Mid-Term Examination (CS-301) Result', style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(color: AppColors.successBg, borderRadius: BorderRadius.circular(12)),
                child: const Text('PASSED (GRADE: A)', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.success)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(color: AppColors.border),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _buildResultStat('Score', '46 / 50', AppColors.studentPrimary)),
              Expanded(child: _buildResultStat('Percentage', '92.0%', AppColors.accentGreen)),
              Expanded(child: _buildResultStat('Accuracy', '95.0%', AppColors.accentOrange)),
              Expanded(child: _buildResultStat('Attempted', '4 / 4', AppColors.primary)),
            ],
          ),
          const SizedBox(height: 28),
          ElevatedButton(
            onPressed: () => setState(() => _activeTab = 'dashboard'),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.studentPrimary),
            child: const Text('Return to Student Dashboard'),
          ),
        ],
      ),
    );
  }

  Widget _buildResultStat(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: AppColors.bgPage,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: color)),
        ],
      ),
    );
  }
}
