import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../models/user_model.dart';
import '../../providers/navigation_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/metric_card.dart';
import '../portal_modules_screen.dart';
import '../../widgets/portal_notification_bell.dart';
import '../../widgets/portal_announcement_preview.dart';
import '../../services/api_service.dart';
import '../classroom/classroom_hub_screen.dart';
import '../classroom/assignment_view_screen.dart';

class StudentPortalScreen extends StatefulWidget {
  final String initialTab;
  final String? initialTargetId;
  const StudentPortalScreen({
    super.key,
    this.initialTab = 'dashboard',
    this.initialTargetId,
  });

  @override
  State<StudentPortalScreen> createState() => _StudentPortalScreenState();
}

class _StudentPortalScreenState extends State<StudentPortalScreen> {
  late String _activeTab;
  String _selectedDay = 'Mon';

  // Live Exam States
  int _currentQuestion = 1;
  final Map<int, String> _selectedAnswers = {};
  final Set<int> _flaggedQuestions = {};
  bool _instructionsAccepted = false;
  int _examTimeSeconds = 3600; // 60 mins
  Timer? _examTimer;
  Timer? _meetingRefreshTimer;
  List<Map<String, dynamic>> _upcomingMeetings = [];
  bool _loadingMeetings = false;

  // Real backend exam integration state
  List<Map<String, dynamic>> _onlineExams = [];
  bool _loadingExams = false;
  Map<String, dynamic>? _selectedExam;
  Map<String, dynamic>? _examAttempt;
  List<Map<String, dynamic>> _liveQuestions = [];
  bool _submittingExam = false;
  String? _examError;

  Map<String, dynamic>? _studentSubmissionsData;
  bool _loadingSubmissions = false;
  bool _fetchingSubmissions = false;

  Future<void> _fetchSubmissionsData({bool showLoading = true}) async {
    if (_fetchingSubmissions) return;
    _fetchingSubmissions = true;
    if (showLoading) setState(() => _loadingSubmissions = true);
    try {
      final res = await ApiService().getStudentTodoList();
      if (mounted) {
        setState(() {
          _studentSubmissionsData = res;
          if (showLoading) _loadingSubmissions = false;
        });
      }
    } catch (_) {
      if (mounted && showLoading) setState(() => _loadingSubmissions = false);
    } finally {
      _fetchingSubmissions = false;
    }
  }

  @override
  void initState() {
    super.initState();
    _activeTab = widget.initialTab.isNotEmpty ? widget.initialTab : 'dashboard';
    _fetchOnlineExams();
    _fetchSubmissionsData();
    _fetchUpcomingMeetings();
    _meetingRefreshTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      _fetchUpcomingMeetings();
      _fetchSubmissionsData(showLoading: false);
    });
  }

  @override
  void didUpdateWidget(StudentPortalScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialTab.isNotEmpty && widget.initialTab != _activeTab) {
      setState(() => _activeTab = widget.initialTab);
      if (_activeTab == 'exams') {
        _fetchOnlineExams();
      } else if (_activeTab == 'my-submissions') {
        _fetchSubmissionsData();
      }
    }
  }

  Future<void> _fetchOnlineExams() async {
    setState(() {
      _loadingExams = true;
      _examError = null;
    });
    try {
      final exams = await ApiService().getExams();
      if (mounted) {
        setState(() {
          _onlineExams = exams;
          _loadingExams = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadingExams = false;
          _examError = e.toString().replaceFirst('Exception: ', '');
        });
      }
    }
  }

  Future<void> _openExamInstructions(Map<String, dynamic> exam) async {
    setState(() {
      _selectedExam = exam;
      _instructionsAccepted = false;
      _examError = null;
    });
    try {
      final details = await ApiService().getExamDetails(exam['id'].toString());
      if (mounted) {
        setState(() {
          _selectedExam = details;
          final qs = details['questions'];
          if (qs is List) {
            _liveQuestions = qs.cast<Map<String, dynamic>>();
          }
          _activeTab = 'exam-instructions';
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load exam details: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _startLiveExam() async {
    if (_selectedExam == null) return;
    final examId = _selectedExam!['id'].toString();
    try {
      final attemptRes = await ApiService().startExamAttempt(examId);
      final qs = _selectedExam!['questions'];
      if (qs is List && qs.isNotEmpty) {
        _liveQuestions = qs.cast<Map<String, dynamic>>();
      }
      final duration =
          int.tryParse(_selectedExam!['durationMinutes']?.toString() ?? '60') ??
          60;
      _examTimeSeconds = duration * 60;
      _currentQuestion = 1;
      _selectedAnswers.clear();
      _flaggedQuestions.clear();

      if (attemptRes['answers'] is Map) {
        final existing = attemptRes['answers'] as Map;
        for (var i = 0; i < _liveQuestions.length; i++) {
          final qId = _liveQuestions[i]['id']?.toString() ?? '';
          if (existing.containsKey(qId)) {
            _selectedAnswers[i + 1] = existing[qId].toString();
          }
        }
      }

      _startExamTimer();
      setState(() => _activeTab = 'exam-live');
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<void> _saveAnswerLocallyAndRemote(int qIndex, String optKey) async {
    setState(() {
      _selectedAnswers[qIndex] = optKey;
    });
    if (_selectedExam == null || qIndex - 1 >= _liveQuestions.length) return;
    final qId = _liveQuestions[qIndex - 1]['id']?.toString() ?? '';
    final examId = _selectedExam!['id'].toString();
    try {
      await ApiService().saveExamAnswer(examId, qId, optKey);
    } catch (_) {}
  }

  void _startExamTimer() {
    _examTimer?.cancel();
    _examTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_examTimeSeconds > 0) {
        if (mounted) setState(() => _examTimeSeconds--);
      } else {
        timer.cancel();
        if (mounted) _submitLiveExam();
      }
    });
  }

  Future<void> _submitLiveExam() async {
    if (_selectedExam == null || _submittingExam) return;
    setState(() => _submittingExam = true);
    _examTimer?.cancel();
    final examId = _selectedExam!['id'].toString();
    final answersPayload = <String, String>{};
    for (var i = 0; i < _liveQuestions.length; i++) {
      final qId = _liveQuestions[i]['id']?.toString() ?? '';
      if (_selectedAnswers.containsKey(i + 1)) {
        answersPayload[qId] = _selectedAnswers[i + 1]!;
      }
    }
    try {
      final result = await ApiService().submitExam(examId, answersPayload);
      if (mounted) {
        setState(() {
          _submittingExam = false;
          _examAttempt = result['attempt'] as Map<String, dynamic>?;
          _activeTab = 'exam-submitted';
        });
        _fetchOnlineExams();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _submittingExam = false);
        final msg = e.toString().replaceFirst('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit exam: $msg'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _viewExamResults(Map<String, dynamic> exam) async {
    setState(() {
      _selectedExam = exam;
    });
    final examId = exam['id'].toString();
    try {
      final attemptRes = await ApiService().getExamAttempt(examId);
      if (mounted) {
        setState(() {
          _examAttempt = attemptRes;
          _activeTab = 'exam-results';
        });
      }
    } catch (e) {
      if (mounted) {
        final msg = e.toString().replaceFirst('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  void dispose() {
    _examTimer?.cancel();
    _meetingRefreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchUpcomingMeetings() async {
    if (_loadingMeetings) return;
    _loadingMeetings = true;
    try {
      final meetings = await ApiService().getUpcomingLiveClasses();
      if (mounted) setState(() => _upcomingMeetings = meetings);
    } catch (_) {
      // Keep the last successful dashboard data visible if the network is unavailable.
    } finally {
      _loadingMeetings = false;
    }
  }

  String _meetingTimeLabel(Map<String, dynamic> meeting) {
    final start = DateTime.tryParse(
      meeting['startTime']?.toString() ?? '',
    )?.toLocal();
    final end = DateTime.tryParse(
      meeting['endTime']?.toString() ?? '',
    )?.toLocal();
    if (start == null) return 'Time to be confirmed';
    final date =
        '${start.year}-${start.month.toString().padLeft(2, '0')}-${start.day.toString().padLeft(2, '0')}';
    final startTime = TimeOfDay.fromDateTime(start).format(context);
    final endTime = end == null
        ? ''
        : ' – ${TimeOfDay.fromDateTime(end).format(context)}';
    return '$date  $startTime$endTime';
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
                if (_isClassroomHubTab(_activeTab))
                  Expanded(child: _buildClassroomHubWidget(_activeTab))
                else
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

  bool _isClassroomHubTab(String tab) {
    return tab == 'classrooms' ||
        tab == 'join-classroom' ||
        tab == 'assignments' ||
        tab == 'meet';
  }

  Widget _buildClassroomHubWidget(String tab) {
    int initialIdx = 0;
    if (tab == 'assignments') {
      initialIdx = 1;
    } else if (tab == 'meet') {
      initialIdx = 2;
    } else if (tab == 'join-classroom') {
      initialIdx = 3;
    }
    return ClassroomHubScreen(
      key: ValueKey('student-classroom-$tab'),
      userRole: 'student',
      initialIndex: initialIdx,
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
        'id': 'classrooms',
        'title': 'My Classrooms',
        'icon': Icons.school_outlined,
      },
      {
        'id': 'join-classroom',
        'title': 'Join Classroom',
        'icon': Icons.group_add_outlined,
      },
      {
        'id': 'assignments',
        'title': 'Assignments',
        'icon': Icons.assignment_turned_in_outlined,
      },
      {
        'id': 'my-submissions',
        'title': 'My Submissions',
        'icon': Icons.task_outlined,
      },
      {
        'id': 'exams',
        'title': 'Examinations',
        'icon': Icons.assignment_outlined,
      },
      {
        'id': 'exam-results',
        'title': 'Exam Results',
        'icon': Icons.emoji_events_outlined,
      },
      {'id': 'meet', 'title': 'Google Meet', 'icon': Icons.video_call_outlined},
      {
        'id': 'announcements',
        'title': 'Announcements',
        'icon': Icons.campaign_outlined,
      },
      {
        'id': 'materials',
        'title': 'Study Materials',
        'icon': Icons.menu_book_outlined,
      },
      {
        'id': 'attendance',
        'title': 'Attendance',
        'icon': Icons.fact_check_outlined,
      },
      {
        'id': 'schedule',
        'title': 'Class Schedule',
        'icon': Icons.calendar_today_outlined,
      },
      {
        'id': 'timetable',
        'title': 'Weekly Timetable',
        'icon': Icons.grid_view_outlined,
      },
      {
        'id': 'parents',
        'title': 'Parent Portal',
        'icon': Icons.family_restroom_outlined,
      },
      {'id': 'profile', 'title': 'My Profile', 'icon': Icons.person_outline},
      {
        'id': 'leaves',
        'title': 'Leave Applications',
        'icon': Icons.event_available_outlined,
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
                    Text(
                      'EduChain',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: Color(0xFF00337F),
                      ),
                    ),
                    Text(
                      'Student Academic Desk',
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
                    user?.name.isNotEmpty == true
                        ? user!.name[0].toUpperCase()
                        : 'S',
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
                        user?.name ?? 'Rahul Sharma',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: AppColors.textMain,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Roll: ${user?.rollNumber ?? "1023"}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.studentPrimary,
                          fontWeight: FontWeight.w600,
                        ),
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
                final isSelected =
                    _activeTab == id ||
                    (_activeTab.startsWith('exam-') && id == 'exams');
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Material(
                    color: Colors.transparent,
                    child: ListTile(
                      dense: true,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      tileColor: isSelected
                          ? const Color(0xFFF3E8FF)
                          : Colors.transparent,
                      leading: Icon(
                        item['icon'] as IconData,
                        size: 20,
                        color: isSelected
                            ? AppColors.studentPrimary
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
                              ? AppColors.studentPrimary
                              : AppColors.textMain,
                        ),
                      ),
                      onTap: () {
                        setState(() => _activeTab = id);
                        nav.setPortalTab(id);
                        if (id == 'exams') {
                          _fetchOnlineExams();
                        } else if (id == 'my-submissions') {
                          _fetchSubmissionsData();
                        }
                      },
                    ),
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
                _getTabTitle(_activeTab),
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
              const PortalNotificationBell(role: 'student'),
              const SizedBox(width: 8),
              // User Chip
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
      case 'classrooms':
        return 'My Classrooms (Google Classroom)';
      case 'join-classroom':
        return 'Join New Classroom';
      case 'assignments':
        return 'Assignments & To-Do List';
      case 'my-submissions':
        return 'My Submissions & Completed Work';
      case 'meet':
        return 'Google Meet Live Classes';
      case 'announcements':
        return 'Announcements';
      case 'leaves':
        return 'Leave Applications';
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
      case 'my-submissions':
        return _buildMySubmissionsTab();
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
      case 'classrooms':
        return const ClassroomHubScreen(userRole: 'student');
      case 'announcements':
      case 'leaves':
        return PortalModulesScreen(
          key: ValueKey('$_activeTab-${widget.initialTargetId ?? ''}'),
          role: 'student',
          module: _activeTab,
          user: user,
          targetId: widget.initialTargetId,
        );
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
        PortalAnnouncementPreview(role: 'student'),
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
                  const Text(
                    'Welcome Back!',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.name ?? 'Rahul Sharma',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Class: ${user?.className ?? "BCA - Sem 3"} • Roll No: ${user?.rollNumber ?? "1023"}',
                    style: const TextStyle(fontSize: 13, color: Colors.white70),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  children: [
                    Text(
                      'TERM STATUS',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Semester 3',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        _buildUpcomingAssignmentsCard(),
        const SizedBox(height: 16),
        _buildUpcomingMeetingsCard(),
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
                    const Text(
                      "Today's Lectures",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildLectureItem(
                      '10:00 AM - 11:30 AM',
                      'Database Systems (CS-301)',
                      'Hall 302 • Dr. Amit Sharma',
                      'Scheduled',
                    ),
                    const Divider(color: AppColors.border),
                    _buildLectureItem(
                      '11:45 AM - 01:15 PM',
                      'Data Structures & Algorithms',
                      'Lab 2 • Prof. Rajesh Gupta',
                      'In Progress',
                    ),
                    const Divider(color: AppColors.border),
                    _buildLectureItem(
                      '02:00 PM - 03:30 PM',
                      'Computer Networks (CS-303)',
                      'Hall 105 • Prof. Sunita Rao',
                      'Upcoming',
                    ),
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
                    const Text(
                      'Quick Access',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildQuickAction(
                      'Take Online Exam',
                      Icons.quiz_outlined,
                      () => setState(() => _activeTab = 'exams'),
                    ),
                    const SizedBox(height: 10),
                    _buildQuickAction(
                      'View Grade Card',
                      Icons.grade_outlined,
                      () => setState(() => _activeTab = 'grades'),
                    ),
                    const SizedBox(height: 10),
                    _buildQuickAction(
                      'Download Study Notes',
                      Icons.download_outlined,
                      () => setState(() => _activeTab = 'materials'),
                    ),
                    const SizedBox(height: 10),
                    _buildQuickAction(
                      'Parent Meeting Request',
                      Icons.connect_without_contact,
                      () => setState(() => _activeTab = 'parents'),
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

  Widget _buildUpcomingAssignmentsCard() {
    final assigned =
        (_studentSubmissionsData?['assigned'] as List?)
            ?.cast<Map<String, dynamic>>() ??
        [];
    final missing =
        (_studentSubmissionsData?['missing'] as List?)
            ?.cast<Map<String, dynamic>>() ??
        [];
    final done =
        (_studentSubmissionsData?['done'] as List?)
            ?.cast<Map<String, dynamic>>() ??
        [];
    final assignments = [...assigned, ...missing, ...done].take(6).toList();
    return Container(
      width: double.infinity,
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
            children: [
              const Icon(
                Icons.assignment_outlined,
                color: AppColors.studentPrimary,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'My Assignments',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
              ),
              IconButton(
                tooltip: 'Refresh assignments',
                onPressed: () => _fetchSubmissionsData(),
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          if (_loadingSubmissions && _studentSubmissionsData == null)
            const Padding(
              padding: EdgeInsets.all(12),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (assignments.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Text(
                'No pending assignments for your enrolled classes.',
                style: TextStyle(color: AppColors.textMuted),
              ),
            )
          else
            ...assignments.map((assignment) {
              final assignmentId = assignment['id']?.toString() ?? '';
              final classroomId = assignment['classroomId']?.toString() ?? '';
              final isMissing = assignment['submissionStatus'] == 'MISSING';
              final score = assignment['myScore'] ?? assignment['score'];
              final feedback = assignment['feedback']?.toString();
              final status =
                  assignment['submissionStatus']?.toString() ?? 'ASSIGNED';
              return Container(
                margin: const EdgeInsets.only(top: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isMissing
                      ? const Color(0xFFFEF2F2)
                      : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isMissing ? Colors.red.shade200 : AppColors.border,
                  ),
                ),
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 460),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            assignment['title']?.toString() ?? 'Assignment',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Class: ${assignment['classroomName'] ?? 'Class'}  •  Subject: ${assignment['subject']?.toString().isNotEmpty == true ? assignment['subject'] : assignment['topic'] ?? 'General'}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textMuted,
                            ),
                          ),
                          Text(
                            'Due: ${assignment['dueDate'] ?? 'No due date'}',
                            style: TextStyle(
                              fontSize: 11,
                              color: isMissing
                                  ? Colors.red.shade700
                                  : AppColors.textMuted,
                            ),
                          ),
                          Text(
                            'Status: $status${score != null ? '  •  Score: $score / ${assignment['pointsPossible'] ?? 100}' : ''}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.studentPrimary,
                            ),
                          ),
                          if (feedback != null && feedback.trim().isNotEmpty)
                            Text(
                              'Feedback: $feedback',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textMuted,
                              ),
                            ),
                        ],
                      ),
                    ),
                    OutlinedButton(
                      onPressed: assignmentId.isEmpty
                          ? null
                          : () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AssignmentViewScreen(
                                  assignmentId: assignmentId,
                                  classroomId: classroomId,
                                  userRole: 'student',
                                ),
                              ),
                            ).then((_) => _fetchSubmissionsData()),
                      child: const Text('Open Assignment'),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildUpcomingMeetingsCard() {
    final meetings = _upcomingMeetings
        .where(
          (meeting) =>
              meeting['status']?.toString().toUpperCase() != 'CANCELLED',
        )
        .toList();
    return Container(
      width: double.infinity,
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
            children: [
              const Icon(Icons.video_call_outlined, color: AppColors.primary),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Upcoming Google Meet Classes',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
              ),
              IconButton(
                tooltip: 'Refresh meetings',
                onPressed: _fetchUpcomingMeetings,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          if (_loadingMeetings && meetings.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (meetings.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'No upcoming meetings for your enrolled classes.',
                style: TextStyle(color: AppColors.textMuted),
              ),
            )
          else
            ...meetings.map((meeting) {
              final isLive = meeting['isLiveNow'] == true;
              return Container(
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isLive
                      ? Colors.green.shade50
                      : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isLive ? Colors.green.shade300 : AppColors.border,
                  ),
                ),
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  runSpacing: 12,
                  spacing: 16,
                  children: [
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 480),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            meeting['title']?.toString() ?? 'Live class',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Class: ${meeting['classroomName'] ?? 'Class'}  •  Subject: ${meeting['subject']?.toString().isNotEmpty == true ? meeting['subject'] : '—'}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textMuted,
                            ),
                          ),
                          Text(
                            'Teacher: ${meeting['hostName'] ?? 'Teacher'}  •  ${_meetingTimeLabel(meeting)}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textMuted,
                            ),
                          ),
                          if (isLive)
                            const Padding(
                              padding: EdgeInsets.only(top: 4),
                              child: Text(
                                'LIVE NOW',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.open_in_new, size: 16),
                      label: const Text('Join Google Meet'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isLive
                            ? Colors.green
                            : AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () async {
                        try {
                          final result = await ApiService().joinLiveClass(
                            meeting['id'].toString(),
                          );
                          final url = Uri.parse(
                            (result['meetLink'] ?? meeting['meetLink'])
                                .toString(),
                          );
                          if (!await launchUrl(
                                url,
                                mode: LaunchMode.externalApplication,
                              ) &&
                              mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Could not open Google Meet.'),
                              ),
                            );
                          }
                        } catch (e) {
                          if (mounted)
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  e.toString().replaceFirst('Exception: ', ''),
                                ),
                                backgroundColor: AppColors.error,
                              ),
                            );
                        }
                      },
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildLectureItem(
    String time,
    String title,
    String subtitle,
    String status,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.studentPrimary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.access_time,
                  color: AppColors.studentPrimary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: AppColors.textMain,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$time • $subtitle',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
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
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 12,
              color: AppColors.textLight,
            ),
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
                  user?.name.isNotEmpty == true
                      ? user!.name[0].toUpperCase()
                      : 'R',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user?.name ?? 'Rahul Sharma',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Roll Number: ${user?.rollNumber ?? "1023"} • ${user?.className ?? "BCA - Sem 3"}',
                    style: const TextStyle(color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 6),
                  const StatusBadge(
                    label: 'Enrolled & Verified',
                    status: 'active',
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 28),
          const Divider(color: AppColors.border),
          const SizedBox(height: 20),
          const Text(
            'Academic Information',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 14),
          _buildInfoRow(
            'Registered Email',
            user?.email ?? 'rahul@institute.com',
          ),
          _buildInfoRow(
            'Course / Degree',
            user?.course ?? 'Bachelor of Computer Applications',
          ),
          _buildInfoRow('Current Semester', user?.semester ?? 'Semester 3'),
          _buildInfoRow(
            'Institute Name',
            user?.instituteName ?? 'Apex Institute of Technology',
          ),
          _buildInfoRow('Institute Code', user?.instituteCode ?? 'INST-2025'),
          const SizedBox(height: 24),
          const Text(
            'Parent / Guardian Details',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 14),
          _buildInfoRow('Father Name', user?.fatherName ?? 'Rakesh Sharma'),
          _buildInfoRow('Father Phone', user?.fatherPhone ?? '+91 98765 43210'),
          _buildInfoRow('Mother Name', user?.motherName ?? 'Pooja Sharma'),
          _buildInfoRow(
            'Residential Address',
            user?.address ?? '123, Green Park, Delhi - 110016',
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

  // 3. Attendance Tab
  Widget _buildAttendanceTab() {
    final subjects = [
      {'name': 'Database Systems', 'held': 40, 'attended': 38, 'rate': 95.0},
      {
        'name': 'Data Structures & Algorithms',
        'held': 44,
        'attended': 40,
        'rate': 90.9,
      },
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
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Cumulative Attendance',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      '92.4%',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        color: AppColors.accentGreen,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Status: Eligible for final examinations (Threshold: 75%)',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 8,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Attendance Rules',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '• Minimum 75% attendance mandatory in each course to sit for semester exams.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '• Medical leaves must be approved by class coordinator within 3 working days.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

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
              const Text(
                'Course Attendance Breakdown',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
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
                          Text(
                            s['name'] as String,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            '${s['attended']} / ${s['held']} (${rate.toStringAsFixed(1)}%)',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      LinearProgressIndicator(
                        value: rate / 100,
                        backgroundColor: AppColors.bgPage,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          rate >= 75 ? AppColors.accentGreen : AppColors.error,
                        ),
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
      {
        'code': 'CS-301',
        'title': 'Database Management Systems',
        'credits': 4,
        'grade': 'A+',
        'score': 92,
      },
      {
        'code': 'CS-302',
        'title': 'Data Structures & Algorithms',
        'credits': 4,
        'grade': 'A',
        'score': 88,
      },
      {
        'code': 'CS-303',
        'title': 'Operating Systems',
        'credits': 4,
        'grade': 'B+',
        'score': 79,
      },
      {
        'code': 'CS-304',
        'title': 'Web Technologies & Frameworks',
        'credits': 3,
        'grade': 'A+',
        'score': 95,
      },
      {
        'code': 'MA-301',
        'title': 'Applied Numerical Mathematics',
        'credits': 4,
        'grade': 'A',
        'score': 85,
      },
    ];

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
                  Text(
                    'Semester Grade Report',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  Text(
                    'Semester 2 Result Card • Official Transcript',
                    style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Grade report downloaded as PDF!'),
                    ),
                  );
                },
                icon: const Icon(Icons.download, size: 16),
                label: const Text('Download PDF'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.studentPrimary,
                ),
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
                      Text(
                        g['title'] as String,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '${g['code']} • Credits: ${g['credits']}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        '${g['score']}%',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.studentPrimary.withValues(
                            alpha: 0.1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          g['grade'] as String,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: AppColors.studentPrimary,
                            fontSize: 14,
                          ),
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

  // 4B. My Submissions Tab
  Widget _buildMySubmissionsTab() {
    final doneList = (_studentSubmissionsData?['done'] as List?) ?? [];
    final assignedList = (_studentSubmissionsData?['assigned'] as List?) ?? [];
    final missingList = (_studentSubmissionsData?['missing'] as List?) ?? [];

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
                  Text(
                    'My Assignment Submissions & Work History',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textMain,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Track turned-in assignments, inspect grades, evaluation remarks and private feedback.',
                    style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(
                  Icons.refresh,
                  color: AppColors.studentPrimary,
                ),
                tooltip: 'Refresh Submissions',
                onPressed: _fetchSubmissionsData,
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Counters Row
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Completed / Turned In',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${doneList.length}',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.green.shade900,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Assigned Pending',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${assignedList.length}',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.blue.shade900,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Missing Deadlines',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${missingList.length}',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.red.shade900,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          if (_loadingSubmissions)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(),
              ),
            )
          else if (doneList.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  children: [
                    const Icon(
                      Icons.task_outlined,
                      size: 54,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'No assignments turned in yet.',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Complete assigned coursework from your classes to see your submission history.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.assignment_turned_in_outlined),
                      label: const Text('View Pending Assignments'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.studentPrimary,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () =>
                          setState(() => _activeTab = 'assignments'),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: doneList.length,
              itemBuilder: (ctx, idx) {
                final item = doneList[idx] as Map<String, dynamic>;
                final classroomName =
                    item['classroomName']?.toString() ?? 'Classroom';
                final title = item['title']?.toString() ?? 'Assignment';
                final dueDate = item['dueDate']?.toString() ?? '';
                final submissionStatus =
                    item['submissionStatus']?.toString() ??
                    item['status']?.toString() ??
                    'TURNED_IN';
                final isGraded =
                    submissionStatus == 'GRADED' ||
                    submissionStatus == 'RETURNED' ||
                    item['score'] != null ||
                    item['myScore'] != null;
                final score = item['score'] ?? item['myScore'];
                final points = item['points'] ?? 100;
                final submissionTime = item['submittedAt']?.toString() ?? '';

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
                            color: isGraded
                                ? const Color(0xFFF0FDF4)
                                : const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            isGraded ? Icons.verified : Icons.task_alt,
                            color: isGraded ? Colors.green : Colors.blue,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: AppColors.textMain,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$classroomName ${dueDate.isNotEmpty ? "• Due: $dueDate" : ""} ${submissionTime.isNotEmpty ? "• Submitted: $submissionTime" : ""}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textMuted,
                                ),
                              ),
                              if (item['feedback'] != null &&
                                  item['feedback'].toString().isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.comment,
                                        size: 12,
                                        color: AppColors.textMuted,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Teacher feedback: "${item['feedback']}"',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontStyle: FontStyle.italic,
                                          color: AppColors.textMain,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isGraded
                                    ? Colors.green.shade50
                                    : Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: isGraded ? Colors.green : Colors.blue,
                                ),
                              ),
                              child: Text(
                                isGraded
                                    ? 'GRADED: $score / $points'
                                    : submissionStatus.replaceAll('_', ' '),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: isGraded
                                      ? Colors.green.shade800
                                      : Colors.blue.shade800,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            OutlinedButton.icon(
                              icon: const Icon(Icons.open_in_new, size: 14),
                              label: const Text('View Work'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.studentPrimary,
                                side: const BorderSide(
                                  color: AppColors.studentPrimary,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                              ),
                              onPressed: () {
                                final aId =
                                    item['assignmentId']?.toString() ??
                                    item['id']?.toString() ??
                                    '';
                                final cId =
                                    item['classroomId']?.toString() ?? '';
                                if (aId.isNotEmpty) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => AssignmentViewScreen(
                                        assignmentId: aId,
                                        classroomId: cId,
                                        userRole: 'student',
                                      ),
                                    ),
                                  );
                                }
                              },
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

  // 5. Schedule Tab
  Widget _buildScheduleTab() {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
    final scheduleMap = {
      'Mon': [
        {
          'time': '09:00 - 10:30',
          'course': 'Database Systems',
          'room': 'Hall 302',
          'faculty': 'Dr. Amit Sharma',
        },
        {
          'time': '11:00 - 12:30',
          'course': 'Data Structures Lab',
          'room': 'Lab 1',
          'faculty': 'Prof. Rajesh Gupta',
        },
      ],
      'Tue': [
        {
          'time': '10:00 - 11:30',
          'course': 'Operating Systems',
          'room': 'Hall 105',
          'faculty': 'Prof. Sunita Rao',
        },
        {
          'time': '01:00 - 02:30',
          'course': 'Web Technologies',
          'room': 'Lab 3',
          'faculty': 'Dr. Amit Sharma',
        },
      ],
      'Wed': [
        {
          'time': '09:00 - 10:30',
          'course': 'Applied Mathematics',
          'room': 'Hall 201',
          'faculty': 'Dr. Ramanujan',
        },
        {
          'time': '11:00 - 12:30',
          'course': 'Database Lab',
          'room': 'Lab 2',
          'faculty': 'Dr. Amit Sharma',
        },
      ],
      'Thu': [
        {
          'time': '10:00 - 11:30',
          'course': 'Data Structures & Algorithms',
          'room': 'Hall 302',
          'faculty': 'Prof. Rajesh Gupta',
        },
      ],
      'Fri': [
        {
          'time': '09:00 - 10:30',
          'course': 'Web Development Workshop',
          'room': 'Seminar Hall',
          'faculty': 'Guest Faculty',
        },
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
                  backgroundColor: isSel
                      ? AppColors.studentPrimary
                      : Colors.white,
                  foregroundColor: isSel ? Colors.white : AppColors.textMain,
                  elevation: 0,
                  side: BorderSide(
                    color: isSel ? AppColors.studentPrimary : AppColors.border,
                  ),
                ),
                child: Text(d),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
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
              Text(
                "$_selectedDay's Timetable",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              ...currentList.map(
                (c) => Padding(
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
                            Text(
                              c['course']!,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${c['room']} • Faculty: ${c['faculty']}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            c['time']!,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.studentPrimary,
                            ),
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

  // 6. Materials Tab
  Widget _buildMaterialsTab() {
    final materials = [
      {
        'title': 'Relational Schema & 3NF Normalization.pdf',
        'course': 'Database Systems',
        'size': '4.2 MB',
        'date': 'May 02, 2025',
      },
      {
        'title': 'Balanced BST & Graph Algorithms.pdf',
        'course': 'Algorithms',
        'size': '6.8 MB',
        'date': 'Apr 28, 2025',
      },
      {
        'title': 'Virtual Memory & Page Replacement.pdf',
        'course': 'Operating Systems',
        'size': '3.1 MB',
        'date': 'Apr 24, 2025',
      },
      {
        'title': 'REST API Architecture & JSON Schemas.pdf',
        'course': 'Web Technologies',
        'size': '2.5 MB',
        'date': 'Apr 20, 2025',
      },
    ];

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
          const Text(
            'Lecture Materials & Resources',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          const Text(
            'Download notes, slides and reference materials uploaded by instructors.',
            style: TextStyle(fontSize: 13, color: AppColors.textMuted),
          ),
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
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.picture_as_pdf,
                            color: AppColors.error,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              m['title']!,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${m['course']} • ${m['size']} • Uploaded: ${m['date']}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.download,
                        color: AppColors.studentPrimary,
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Downloading ${m["title"]}...'),
                          ),
                        );
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

  // Retained as a named legacy implementation while the active tab uses the primary method above.
  // ignore: unused_element
  Widget _buildMySubmissionsTabLegacy() {
    final doneList = (_studentSubmissionsData?['done'] as List?) ?? [];
    final assignedList = (_studentSubmissionsData?['assigned'] as List?) ?? [];
    final missingList = (_studentSubmissionsData?['missing'] as List?) ?? [];

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
                  Text(
                    'My Assignment Submissions & Work History',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textMain,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Track turned-in assignments, inspect grades, evaluation remarks and private feedback.',
                    style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(
                  Icons.refresh,
                  color: AppColors.studentPrimary,
                ),
                tooltip: 'Refresh Submissions',
                onPressed: _fetchSubmissionsData,
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Counters Row
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Completed / Turned In',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${doneList.length}',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.green.shade900,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Assigned Pending',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${assignedList.length}',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.blue.shade900,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Missing Deadlines',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${missingList.length}',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.red.shade900,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          if (_loadingSubmissions)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(),
              ),
            )
          else if (doneList.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  children: [
                    const Icon(
                      Icons.task_outlined,
                      size: 54,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'No assignments turned in yet.',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Complete assigned coursework from your classes to see your submission history.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.assignment_turned_in_outlined),
                      label: const Text('View Pending Assignments'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.studentPrimary,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () =>
                          setState(() => _activeTab = 'assignments'),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: doneList.length,
              itemBuilder: (ctx, idx) {
                final item = doneList[idx] as Map<String, dynamic>;
                final classroomName =
                    item['classroomName']?.toString() ?? 'Classroom';
                final title = item['title']?.toString() ?? 'Assignment';
                final dueDate = item['dueDate']?.toString() ?? '';
                final isGraded =
                    item['status'] == 'GRADED' || item['score'] != null;
                final score = item['score'];
                final points = item['points'] ?? 100;
                final submissionTime = item['submittedAt']?.toString() ?? '';

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
                            color: isGraded
                                ? const Color(0xFFF0FDF4)
                                : const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            isGraded ? Icons.verified : Icons.task_alt,
                            color: isGraded ? Colors.green : Colors.blue,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: AppColors.textMain,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$classroomName ${dueDate.isNotEmpty ? "• Due: $dueDate" : ""} ${submissionTime.isNotEmpty ? "• Submitted: $submissionTime" : ""}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textMuted,
                                ),
                              ),
                              if (item['feedback'] != null &&
                                  item['feedback'].toString().isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.comment,
                                        size: 12,
                                        color: AppColors.textMuted,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Teacher feedback: "${item['feedback']}"',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontStyle: FontStyle.italic,
                                          color: AppColors.textMain,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isGraded
                                    ? Colors.green.shade50
                                    : Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: isGraded ? Colors.green : Colors.blue,
                                ),
                              ),
                              child: Text(
                                isGraded
                                    ? 'GRADED: $score / $points'
                                    : 'TURNED IN',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: isGraded
                                      ? Colors.green.shade800
                                      : Colors.blue.shade800,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            OutlinedButton.icon(
                              icon: const Icon(Icons.open_in_new, size: 14),
                              label: const Text('View Work'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.studentPrimary,
                                side: const BorderSide(
                                  color: AppColors.studentPrimary,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                              ),
                              onPressed: () {
                                final aId =
                                    item['assignmentId']?.toString() ??
                                    item['id']?.toString() ??
                                    '';
                                final cId =
                                    item['classroomId']?.toString() ?? '';
                                if (aId.isNotEmpty) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => AssignmentViewScreen(
                                        assignmentId: aId,
                                        classroomId: cId,
                                        userRole: 'student',
                                      ),
                                    ),
                                  );
                                }
                              },
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

  // 7. Timetable Tab
  Widget _buildTimetableTab() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weekly Academic Timetable Matrix',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          SizedBox(height: 8),
          Text(
            'Complete 5-day class matrix for BCA Semester 3 (Section A)',
            style: TextStyle(fontSize: 13, color: AppColors.textMuted),
          ),
          SizedBox(height: 24),
          // Simple visual timetable grid
          Text(
            '• Monday: 09:00 DBMS (H-302) | 11:00 DSA Lab (L-1) | 02:00 Web Tech (H-102)',
          ),
          SizedBox(height: 10),
          Text(
            '• Tuesday: 10:00 OS (H-105) | 01:00 Web Tech Lab (L-3) | 03:00 Maths (H-201)',
          ),
          SizedBox(height: 10),
          Text(
            '• Wednesday: 09:00 Maths (H-201) | 11:00 DBMS Lab (L-2) | 02:00 DSA (H-302)',
          ),
          SizedBox(height: 10),
          Text(
            '• Thursday: 10:00 DSA (H-302) | 01:00 OS Lab (L-1) | 03:00 DBMS (H-302)',
          ),
          SizedBox(height: 10),
          Text(
            '• Friday: 09:00 Workshop (Seminar Hall) | 02:00 Faculty Mentoring',
          ),
        ],
      ),
    );
  }

  // 8. Parents Tab
  Widget _buildParentsTab(UserModel? user) {
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
          const Text(
            'Parent & Guardian Portal',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          const Text(
            'Registered contact information and Parent-Teacher Meeting (PTM) records.',
            style: TextStyle(fontSize: 13, color: AppColors.textMuted),
          ),
          const SizedBox(height: 24),
          _buildInfoRow('Father Name', user?.fatherName ?? 'Rakesh Sharma'),
          _buildInfoRow('Father Phone', user?.fatherPhone ?? '+91 98765 43210'),
          _buildInfoRow(
            'Father Email',
            user?.fatherEmail ?? 'rakesh@example.com',
          ),
          _buildInfoRow('Mother Name', user?.motherName ?? 'Pooja Sharma'),
          _buildInfoRow('Mother Phone', user?.motherPhone ?? '+91 98765 43211'),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'PTM meeting scheduled for next Friday 04:00 PM.',
                  ),
                ),
              );
            },
            icon: const Icon(Icons.event, size: 16),
            label: const Text('Schedule PTM Meeting'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.studentPrimary,
            ),
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
                        'Online Examinations',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Official institutional examinations and real-time assessments.',
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
                      color: AppColors.studentPrimary,
                    ),
                    tooltip: 'Refresh Exams',
                    onPressed: _fetchOnlineExams,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (_loadingExams)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (_onlineExams.isEmpty)
                Container(
                  padding: const EdgeInsets.all(32),
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      const Icon(
                        Icons.assignment_outlined,
                        size: 48,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'No examinations scheduled at this time.',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textMuted,
                        ),
                      ),
                      if (_examError != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          _examError!,
                          style: const TextStyle(
                            color: AppColors.error,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                )
              else
                ..._onlineExams.map((exam) {
                  final title = exam['title']?.toString() ?? 'Examination';
                  final code = exam['code']?.toString() ?? '';
                  final subject = exam['subject']?.toString() ?? '';
                  final duration = exam['durationMinutes']?.toString() ?? '60';
                  final totalMarks = exam['totalMarks']?.toString() ?? '100';
                  final passingMarks = exam['passingMarks']?.toString() ?? '40';
                  final attemptStatus =
                      exam['attemptStatus']?.toString() ?? 'NOT_ATTEMPTED';
                  final resultsReleased = exam['resultsReleased'] == true;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppColors.bgPage,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.studentPrimary.withValues(
                                      alpha: 0.12,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.assignment,
                                    color: AppColors.studentPrimary,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '$title ${code.isNotEmpty ? "($code)" : ""}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Subject: $subject • Duration: $duration Mins • Total Marks: $totalMarks • Passing: $passingMarks',
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
                          ),
                          const SizedBox(width: 12),
                          if (attemptStatus == 'SUBMITTED') ...[
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const StatusBadge(
                                  label: 'EXAM ALREADY SUBMITTED',
                                  status: 'completed',
                                ),
                                const SizedBox(height: 6),
                                ElevatedButton(
                                  onPressed: () => _viewExamResults(exam),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: resultsReleased
                                        ? AppColors.studentPrimary
                                        : Colors.grey.shade600,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 8,
                                    ),
                                  ),
                                  child: Text(
                                    resultsReleased
                                        ? 'View Results'
                                        : 'Results Pending',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                          ] else if (attemptStatus == 'IN_PROGRESS') ...[
                            ElevatedButton(
                              onPressed: () => _openExamInstructions(exam),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.accentOrange,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                              ),
                              child: const Text('Resume Exam'),
                            ),
                          ] else ...[
                            ElevatedButton(
                              onPressed: () => _openExamInstructions(exam),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.studentPrimary,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 10,
                                ),
                              ),
                              child: const Text('Start Exam'),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }),
            ],
          ),
        ),
      ],
    );
  }

  // 10. Exam Instructions Tab
  Widget _buildExamInstructionsTab() {
    final title = _selectedExam?['title']?.toString() ?? 'Examination';
    final code = _selectedExam?['code']?.toString() ?? '';
    final subject = _selectedExam?['subject']?.toString() ?? '';
    final duration = _selectedExam?['durationMinutes']?.toString() ?? '60';
    final totalMarks = _selectedExam?['totalMarks']?.toString() ?? '100';
    final qCount = _liveQuestions.isNotEmpty
        ? _liveQuestions.length
        : (_selectedExam?['totalQuestions']?.toString() ?? '5');
    final instructions =
        _selectedExam?['instructions']?.toString() ??
        'Please read all questions carefully before submitting. Navigating away may trigger proctor warnings.';

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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Online Examination Instructions: $title',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '$subject ${code.isNotEmpty ? "($code)" : ""} • Duration: $duration Mins • Total Marks: $totalMarks',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              OutlinedButton(
                onPressed: () => setState(() => _activeTab = 'exams'),
                child: const Text('Back to Exams'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(color: AppColors.border),
          const SizedBox(height: 16),
          Text(
            '1. Examination Duration: $duration minutes. Countdown timer activates immediately upon clicking "Agree & Launch Examination Hall".',
          ),
          const SizedBox(height: 8),
          Text('2. Total Questions: $qCount multiple-choice questions.'),
          const SizedBox(height: 8),
          const Text(
            '3. Single Attempt Rule: Each student is permitted exactly ONE attempt per exam. A second attempt is strictly blocked.',
          ),
          const SizedBox(height: 8),
          const Text(
            '4. Answer Persistence: Answers are saved as you proceed. You can review and change your selected option prior to final submission.',
          ),
          const SizedBox(height: 8),
          Text('5. Specific Instructions: $instructions'),
          const SizedBox(height: 24),
          Row(
            children: [
              Checkbox(
                value: _instructionsAccepted,
                onChanged: (v) =>
                    setState(() => _instructionsAccepted = v ?? false),
              ),
              const Expanded(
                child: Text(
                  'I have read and agree to comply with all online examination guidelines, anti-cheating policies, and rules.',
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _instructionsAccepted ? _startLiveExam : null,
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
    final title = _selectedExam?['title']?.toString() ?? 'Online Examination';
    if (_liveQuestions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 16),
            const Text(
              'No questions loaded for this examination.',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => setState(() => _activeTab = 'exams'),
              child: const Text('Return to Exams List'),
            ),
          ],
        ),
      );
    }

    final qIdx = (_currentQuestion - 1).clamp(0, _liveQuestions.length - 1);
    final currentQ = _liveQuestions[qIdx];
    final questionType = currentQ['questionType']?.toString() ?? 'MCQ_SINGLE';
    final qText =
        currentQ['question']?.toString() ??
        currentQ['text']?.toString() ??
        currentQ['q']?.toString() ??
        'Question';

    Map<String, String> optionsMap = {};
    if (currentQ['options'] is Map) {
      optionsMap = (currentQ['options'] as Map).map(
        (k, v) => MapEntry(k.toString(), v.toString()),
      );
    } else if (currentQ['options'] is List) {
      final optsList = currentQ['options'] as List;
      final labels = ['A', 'B', 'C', 'D', 'E'];
      for (var i = 0; i < optsList.length; i++) {
        final key = i < labels.length ? labels[i] : '$i';
        optionsMap[key] = optsList[i].toString();
      }
    }

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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Live Examination Session • Auto-proctored & Persistent',
                      style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.errorBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.error.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.timer, color: AppColors.error, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      _formatTime(_examTimeSeconds),
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        color: AppColors.error,
                      ),
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
                          'Question $_currentQuestion of ${_liveQuestions.length}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.studentPrimary,
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: () {
                            setState(() {
                              if (_flaggedQuestions.contains(
                                _currentQuestion,
                              )) {
                                _flaggedQuestions.remove(_currentQuestion);
                              } else {
                                _flaggedQuestions.add(_currentQuestion);
                              }
                            });
                          },
                          icon: Icon(
                            _flaggedQuestions.contains(_currentQuestion)
                                ? Icons.flag
                                : Icons.outlined_flag,
                            size: 16,
                            color: _flaggedQuestions.contains(_currentQuestion)
                                ? AppColors.accentOrange
                                : AppColors.textMuted,
                          ),
                          label: Text(
                            _flaggedQuestions.contains(_currentQuestion)
                                ? 'Flagged'
                                : 'Flag for Review',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      qText,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (optionsMap.isEmpty)
                      TextFormField(
                        key: ValueKey('answer-$_currentQuestion'),
                        initialValue: _selectedAnswers[_currentQuestion] ?? '',
                        minLines: questionType == 'LONG_ANSWER' ? 4 : 1,
                        maxLines: questionType == 'LONG_ANSWER' ? 8 : 3,
                        decoration: const InputDecoration(
                          labelText: 'Your answer',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) => _saveAnswerLocallyAndRemote(
                          _currentQuestion,
                          value,
                        ),
                      )
                    else
                      ...optionsMap.entries.map((opt) {
                        final isSelected = (questionType == 'MCQ_MULTI'
                            ? (_selectedAnswers[_currentQuestion] ?? '')
                                  .split(',')
                                  .contains(opt.key)
                            : _selectedAnswers[_currentQuestion] == opt.key);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: InkWell(
                            onTap: () {
                              if (questionType == 'MCQ_MULTI') {
                                final selected =
                                    (_selectedAnswers[_currentQuestion] ?? '')
                                        .split(',')
                                        .where((key) => key.isNotEmpty)
                                        .toSet();
                                if (!selected.add(opt.key))
                                  selected.remove(opt.key);
                                _saveAnswerLocallyAndRemote(
                                  _currentQuestion,
                                  (selected.toList()..sort()).join(','),
                                );
                              } else {
                                _saveAnswerLocallyAndRemote(
                                  _currentQuestion,
                                  opt.key,
                                );
                              }
                            },
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFFF3E8FF)
                                    : AppColors.bgPage,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.studentPrimary
                                      : AppColors.border,
                                  width: isSelected ? 1.5 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  if (questionType == 'MCQ_MULTI')
                                    Icon(
                                      isSelected
                                          ? Icons.check_box
                                          : Icons.check_box_outline_blank,
                                      color: isSelected
                                          ? AppColors.studentPrimary
                                          : AppColors.textMuted,
                                    )
                                  else
                                    Text(
                                      '${opt.key}. ',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        color: isSelected
                                            ? AppColors.studentPrimary
                                            : AppColors.textMain,
                                      ),
                                    ),
                                  Expanded(
                                    child: Text(
                                      opt.value,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: isSelected
                                            ? AppColors.studentPrimary
                                            : AppColors.textMain,
                                      ),
                                    ),
                                  ),
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
                          onPressed: _currentQuestion > 1
                              ? () => setState(() => _currentQuestion--)
                              : null,
                          child: const Text('Previous'),
                        ),
                        if (_currentQuestion < _liveQuestions.length)
                          ElevatedButton(
                            onPressed: () => setState(() => _currentQuestion++),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.studentPrimary,
                            ),
                            child: const Text('Next Question'),
                          )
                        else
                          ElevatedButton(
                            onPressed: _submittingExam ? null : _submitLiveExam,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.success,
                            ),
                            child: _submittingExam
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('Submit Final Exam'),
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
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Question Navigator',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: List.generate(_liveQuestions.length, (idx) {
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
                              border: Border.all(
                                color: isCur
                                    ? AppColors.studentPrimary
                                    : AppColors.border,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '$qNum',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                color: isCur
                                    ? Colors.white
                                    : AppColors.textMain,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _submittingExam ? null : _submitLiveExam,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        minimumSize: const Size.fromHeight(40),
                      ),
                      child: _submittingExam
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('Submit Exam'),
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
    final title = _selectedExam?['title']?.toString() ?? 'Examination';
    final resultsReleased = _examAttempt?['resultsReleased'] == true;

    return Container(
      padding: const EdgeInsets.all(36),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.successBg,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle,
              color: AppColors.success,
              size: 54,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Exam Successfully Submitted!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: AppColors.textMain,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your answers for $title have been persisted in the database.',
            style: const TextStyle(fontSize: 14, color: AppColors.textMuted),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => setState(() => _activeTab = 'exam-results'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.studentPrimary,
                ),
                child: Text(
                  resultsReleased
                      ? 'View Exam Results'
                      : 'Check Results Status',
                ),
              ),
              const SizedBox(width: 14),
              OutlinedButton(
                onPressed: () => setState(() => _activeTab = 'exams'),
                child: const Text('Return to Exams List'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 13. Exam Results Tab
  Widget _buildExamResultsTab() {
    final title = _selectedExam?['title']?.toString() ?? 'Online Examination';
    final resultsReleased = _examAttempt?['resultsReleased'] == true;

    if (!resultsReleased) {
      return Container(
        padding: const EdgeInsets.all(36),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_clock_outlined,
                color: AppColors.accentOrange,
                size: 54,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Results Pending Release',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: AppColors.textMain,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Your submission for $title has been recorded into the database.\nPer academic policy, results will become visible once the instructor or administrator releases them.',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textMuted,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            ElevatedButton(
              onPressed: () => setState(() => _activeTab = 'exams'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.studentPrimary,
              ),
              child: const Text('Back to Examinations'),
            ),
          ],
        ),
      );
    }

    final score = _examAttempt?['score']?.toString() ?? '0';
    final totalMarks = _examAttempt?['totalMarks']?.toString() ?? '100';
    final percentage = _examAttempt?['percentage']?.toString() ?? '0';
    final passed = _examAttempt?['passed'] == true;
    final totalQ = _examAttempt?['totalQuestions']?.toString() ?? '0';
    final correctQ = _examAttempt?['correctAnswers']?.toString() ?? '0';
    final incorrectQ = _examAttempt?['incorrectAnswers']?.toString() ?? '0';

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
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
                    'Examination Scorecard',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$title Official Results',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: passed ? AppColors.successBg : AppColors.errorBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  passed ? 'PASSED' : 'FAILED',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: passed ? AppColors.success : AppColors.error,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(color: AppColors.border),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildResultStat(
                  'Score',
                  '$score / $totalMarks',
                  AppColors.studentPrimary,
                ),
              ),
              Expanded(
                child: _buildResultStat(
                  'Percentage',
                  '$percentage%',
                  passed ? AppColors.accentGreen : AppColors.error,
                ),
              ),
              Expanded(
                child: _buildResultStat(
                  'Correct Answers',
                  '$correctQ / $totalQ',
                  AppColors.success,
                ),
              ),
              Expanded(
                child: _buildResultStat(
                  'Incorrect Answers',
                  '$incorrectQ / $totalQ',
                  AppColors.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          ElevatedButton(
            onPressed: () => setState(() => _activeTab = 'exams'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.studentPrimary,
            ),
            child: const Text('Return to Examinations'),
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
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
