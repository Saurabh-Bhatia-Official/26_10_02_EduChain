import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../providers/navigation_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/portal_header.dart';

class SelectRoleScreen extends StatefulWidget {
  final String initialMode;
  const SelectRoleScreen({super.key, this.initialMode = 'login'});

  @override
  State<SelectRoleScreen> createState() => _SelectRoleScreenState();
}

class _SelectRoleScreenState extends State<SelectRoleScreen> {
  late String _activeMode;
  bool _copiedCode = false;

  @override
  void initState() {
    super.initState();
    _activeMode = widget.initialMode;
  }

  void _copyCode(String code) {
    Clipboard.setData(ClipboardData(text: code));
    setState(() => _copiedCode = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Institute code copied!'), duration: Duration(seconds: 1)),
    );
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copiedCode = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final nav = Provider.of<NavigationProvider>(context, listen: false);
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.currentUser;
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    final instituteCode = user?.instituteCode ?? 'INST-2025';
    final instituteName = user?.instituteName ?? 'Apex Institute of Technology';
    final isInstituteLoggedIn = auth.isInstitute;

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: Column(
        children: [
          PortalHeader(
            backTarget: isInstituteLoggedIn ? 'institute-home' : 'home',
            backLabel: isInstituteLoggedIn ? 'Back to Institute Home' : 'Back to Home',
            onLogout: isInstituteLoggedIn
                ? () async {
                    await auth.logout();
                    nav.navigateTo('institute-login');
                  }
                : null,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1100),
                  child: Column(
                    children: [
                      // Creative Institute Hub Banner
                      Container(
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            isDesktop
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            width: 52,
                                            height: 52,
                                            decoration: BoxDecoration(
                                              color: AppColors.primary,
                                              borderRadius: BorderRadius.circular(14),
                                            ),
                                            child: const Icon(Icons.account_balance, color: Colors.white, size: 28),
                                          ),
                                          const SizedBox(width: 16),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white.withValues(alpha: 0.15),
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    child: const Text('Verified Academic Campus', style: TextStyle(color: Colors.white70, fontSize: 11)),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                    decoration: BoxDecoration(
                                                      color: AppColors.successBg,
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    child: const Text('● Live Portal', style: TextStyle(color: AppColors.success, fontSize: 11, fontWeight: FontWeight.w700)),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                instituteName,
                                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white),
                                              ),
                                              const SizedBox(height: 2),
                                              const Text(
                                                'Academic Management Hub & Role Access Launchpad',
                                                style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          InkWell(
                                            onTap: () => _copyCode(instituteCode),
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                              decoration: BoxDecoration(
                                                color: Colors.white.withValues(alpha: 0.1),
                                                borderRadius: BorderRadius.circular(10),
                                                border: Border.all(color: Colors.white24),
                                              ),
                                              child: Row(
                                                children: [
                                                  Text('Code: $instituteCode', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                                                  const SizedBox(width: 8),
                                                  Icon(_copiedCode ? Icons.check : Icons.copy, size: 14, color: _copiedCode ? AppColors.accentGreen : Colors.white70),
                                                ],
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          IconButton(
                                            onPressed: () async {
                                              await auth.logout();
                                              nav.navigateTo('institute-login');
                                            },
                                            icon: const Icon(Icons.logout, color: Colors.white70, size: 20),
                                            tooltip: 'Logout',
                                          ),
                                        ],
                                      ),
                                    ],
                                  )
                                : Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        instituteName,
                                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white),
                                      ),
                                      const SizedBox(height: 8),
                                      InkWell(
                                        onTap: () => _copyCode(instituteCode),
                                        child: Text('Code: $instituteCode (tap to copy)', style: const TextStyle(color: AppColors.secondary, fontSize: 13)),
                                      ),
                                    ],
                                  ),
                            const SizedBox(height: 24),
                            const Divider(color: Colors.white12),
                            const SizedBox(height: 16),
                            // Metrics strip
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildMetric('1,420+', 'Enrolled Students', Icons.school, AppColors.studentPrimary),
                                _buildMetric('86', 'Faculty Instructors', Icons.people, AppColors.teacherPrimary),
                                _buildMetric('24', 'Active Courses', Icons.layers, AppColors.accentPurple),
                                _buildMetric('2025-2026', 'Academic Year', Icons.event_note, AppColors.accentOrange),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Campus announcement banner
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFBFDBFE)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.campaign, color: AppColors.primary, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  style: const TextStyle(fontSize: 13, color: Color(0xFF1E3A8A)),
                                  children: [
                                    const TextSpan(text: 'Campus Tip: Share your Institute Code '),
                                    TextSpan(text: instituteCode, style: const TextStyle(fontWeight: FontWeight.w800)),
                                    const TextSpan(text: ' with your teachers and students so they can directly register and link with this campus.'),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Mode Switcher Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _activeMode == 'login' ? 'Role Authentication Gateway' : 'New Role Registration Hub',
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textMain),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _activeMode == 'login' ? 'Select a role to open the dedicated login interface.' : 'Select a role to create and link a new user profile.',
                                style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(
                              children: [
                                _buildModeButton('login', 'Login as Role', Icons.login),
                                _buildModeButton('register', 'Register New User', Icons.person_add_alt),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Role Cards
                      if (_activeMode == 'login')
                        _buildLoginCards(isDesktop, nav)
                      else
                        _buildRegisterCards(isDesktop, nav),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(String value, String label, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.15), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white)),
            Text(label, style: const TextStyle(fontSize: 10, color: Colors.white70)),
          ],
        ),
      ],
    );
  }

  Widget _buildModeButton(String mode, String label, IconData icon) {
    final isActive = _activeMode == mode;
    return InkWell(
      onTap: () => setState(() => _activeMode = mode),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, size: 15, color: isActive ? Colors.white : AppColors.textMuted),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isActive ? Colors.white : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginCards(bool isDesktop, NavigationProvider nav) {
    final roles = [
      {
        'title': 'Administrator Login',
        'badge': 'System Admin',
        'desc': 'Institute administration, role directory, class scheduling, and reports.',
        'features': ['Manage students & instructors', 'Master timetable configuration', 'Academic planning & analytics', 'Full administrative authority'],
        'color': AppColors.adminPrimary,
        'icon': Icons.admin_panel_settings,
        'route': 'admin-login',
        'btn': 'Enter as Admin',
      },
      {
        'title': 'Teacher / Instructor Login',
        'badge': 'Faculty Member',
        'desc': 'Class management, attendance logging, course curriculum, and student marks.',
        'features': ['Class roster & student records', 'Course & syllabus progression', 'Lecture timetables & notes', 'Student evaluation & feedback'],
        'color': AppColors.teacherPrimary,
        'icon': Icons.cast_for_education,
        'route': 'teacher-login',
        'btn': 'Enter as Teacher',
      },
      {
        'title': 'Student Portal Login',
        'badge': 'Enrolled Student',
        'desc': 'Access attendance percentage, exam hall, verified marksheets, and timetable.',
        'features': ['Live examination & results', 'Attendance tracking with stats', 'Class schedules & lecture notes', 'Parent communications log'],
        'color': AppColors.studentPrimary,
        'icon': Icons.school,
        'route': 'student-login',
        'btn': 'Enter as Student',
      },
    ];

    return isDesktop
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: roles.map((r) => Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: _buildRoleCard(r, nav)))).toList(),
          )
        : Column(
            children: roles.map((r) => Padding(padding: const EdgeInsets.only(bottom: 16), child: _buildRoleCard(r, nav))).toList(),
          );
  }

  Widget _buildRegisterCards(bool isDesktop, NavigationProvider nav) {
    final roles = [
      {
        'title': 'Student Registration',
        'badge': 'New Student',
        'desc': 'Create a student profile linked with this verified campus code.',
        'features': ['Instant batch & roll number link', 'Access to online learning portal', 'Exam hall seating eligibility', 'Parent portal connectivity'],
        'color': AppColors.studentPrimary,
        'icon': Icons.school,
        'route': 'student-register',
        'btn': 'Register as Student',
      },
      {
        'title': 'Teacher Registration',
        'badge': 'New Faculty',
        'desc': 'Create an instructor profile linked with this verified campus code.',
        'features': ['Department & employee ID link', 'Class & subject assignment', 'Curriculum syllabus manager', 'Academic records authority'],
        'color': AppColors.teacherPrimary,
        'icon': Icons.cast_for_education,
        'route': 'teacher-register',
        'btn': 'Register as Teacher',
      },
    ];

    return isDesktop
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: roles.map((r) => Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: _buildRoleCard(r, nav)))).toList(),
          )
        : Column(
            children: roles.map((r) => Padding(padding: const EdgeInsets.only(bottom: 16), child: _buildRoleCard(r, nav))).toList(),
          );
  }

  Widget _buildRoleCard(Map<String, dynamic> r, NavigationProvider nav) {
    final Color color = r['color'] as Color;
    final List<String> features = r['features'] as List<String>;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(r['icon'] as IconData, color: color, size: 24),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  r['badge'] as String,
                  style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            r['title'] as String,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textMain),
          ),
          const SizedBox(height: 6),
          Text(
            r['desc'] as String,
            style: const TextStyle(fontSize: 13, color: AppColors.textMuted, height: 1.4),
          ),
          const SizedBox(height: 18),
          const Divider(color: AppColors.border),
          const SizedBox(height: 14),
          ...features.map((f) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(Icons.check, size: 14, color: color),
                    const SizedBox(width: 8),
                    Expanded(child: Text(f, style: const TextStyle(fontSize: 12, color: AppColors.textMain))),
                  ],
                ),
              )),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: () => nav.navigateTo(r['route'] as String),
              style: ElevatedButton.styleFrom(backgroundColor: color),
              child: Text(r['btn'] as String),
            ),
          ),
        ],
      ),
    );
  }
}

