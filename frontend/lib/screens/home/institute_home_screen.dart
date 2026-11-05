import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../providers/navigation_provider.dart';
import '../../providers/auth_provider.dart';

class InstituteHomeScreen extends StatefulWidget {
  const InstituteHomeScreen({super.key});

  @override
  State<InstituteHomeScreen> createState() => _InstituteHomeScreenState();
}

class _InstituteHomeScreenState extends State<InstituteHomeScreen> {
  bool _copiedCode = false;
  final TextEditingController _announcementController = TextEditingController();
  bool _announcementSent = false;

  void _copyCode(String code) {
    Clipboard.setData(ClipboardData(text: code));
    setState(() => _copiedCode = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Institute code copied to clipboard!'), duration: Duration(seconds: 2)),
    );
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copiedCode = false);
    });
  }

  void _sendAnnouncement() {
    if (_announcementController.text.trim().isEmpty) return;
    setState(() => _announcementSent = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Campus announcement broadcasted successfully!'), backgroundColor: AppColors.success),
    );
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _announcementController.clear();
        setState(() => _announcementSent = false);
      }
    });
  }

  @override
  void dispose() {
    _announcementController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nav = Provider.of<NavigationProvider>(context, listen: false);
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.currentUser;
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    final instituteName = user?.instituteName ?? 'Apex Institute of Technology';
    final instituteCode = user?.instituteCode ?? 'INST-2025';
    final verificationId = user?.verificationId ?? 'VRF-INST2025-2025';
    final accreditation = user?.accreditation ?? 'AICTE & UGC Recognized • Grade A+ NAAC Accredited';

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 24,
        title: Row(
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      instituteName,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textMain),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.successBg,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.verified, size: 12, color: AppColors.success),
                          SizedBox(width: 4),
                          Text('Verified', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.success)),
                        ],
                      ),
                    ),
                  ],
                ),
                Text(
                  'Code: $instituteCode • $accreditation',
                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
              ],
            ),
          ],
        ),
        actions: [
          ElevatedButton.icon(
            onPressed: () => nav.navigateTo('select-role'),
            icon: const Icon(Icons.layers, size: 16),
            label: const Text('Role Gateway'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
          ),
          const SizedBox(width: 10),
          IconButton(
            onPressed: () async {
              await auth.logout();
              nav.navigateTo('institute-login');
            },
            icon: const Icon(Icons.logout, color: AppColors.textMuted),
            tooltip: 'Logout',
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Banner
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: isDesktop
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Campus Administration Dashboard',
                                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.secondary, letterSpacing: 1),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  instituteName,
                                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.white),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Verification ID: $verificationId • Academic Session 2025–2026',
                                  style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                                ),
                              ],
                            ),
                            InkWell(
                              onTap: () => _copyCode(instituteCode),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.white24),
                                ),
                                child: Row(
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('Institute Code', style: TextStyle(fontSize: 10, color: Colors.white70)),
                                        Text(
                                          instituteCode,
                                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 14),
                                    Icon(
                                      _copiedCode ? Icons.check_circle : Icons.copy,
                                      color: _copiedCode ? AppColors.accentGreen : Colors.white,
                                      size: 20,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              instituteName,
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Code: $instituteCode',
                              style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                            ),
                          ],
                        ),
                ),
                const SizedBox(height: 24),

                // Metrics Row
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard('Enrolled Students', '1,420+', Icons.school, AppColors.studentPrimary),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard('Faculty Members', '86', Icons.people, AppColors.teacherPrimary),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard('Departments', '8', Icons.layers, AppColors.primary),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard('Active Courses', '24', Icons.menu_book, AppColors.accentOrange),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // Broadcast Announcement + Gateway Launchpad
                isDesktop
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 6, child: _buildAnnouncementCard()),
                          const SizedBox(width: 24),
                          Expanded(flex: 6, child: _buildRolePortalsCard(nav)),
                        ],
                      )
                    : Column(
                        children: [
                          _buildAnnouncementCard(),
                          const SizedBox(height: 24),
                          _buildRolePortalsCard(nav),
                        ],
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
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
            children: [
              Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: color, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textMain)),
        ],
      ),
    );
  }

  Widget _buildAnnouncementCard() {
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
          const Row(
            children: [
              Icon(Icons.campaign, color: AppColors.primary, size: 22),
              SizedBox(width: 10),
              Text(
                'Broadcast Campus Notice',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textMain),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Send an announcement to all students, instructors, and campus administrators.',
            style: TextStyle(fontSize: 13, color: AppColors.textMuted),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _announcementController,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Type campus announcement or urgent circular here...',
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _announcementSent ? null : _sendAnnouncement,
            icon: const Icon(Icons.send, size: 16),
            label: Text(_announcementSent ? 'Announcement Broadcasted' : 'Broadcast Announcement'),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildRolePortalsCard(NavigationProvider nav) {
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
          const Row(
            children: [
              Icon(Icons.launch, color: AppColors.primary, size: 22),
              SizedBox(width: 10),
              Text(
                'Role Portals Launchpad',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textMain),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Direct access to individual role dashboards for campus management.',
            style: TextStyle(fontSize: 13, color: AppColors.textMuted),
          ),
          const SizedBox(height: 16),
          _buildPortalTile(
            title: 'Administrator Portal',
            subtitle: '15 modules: student records, instructors, timetable, reports',
            icon: Icons.admin_panel_settings,
            color: AppColors.adminPrimary,
            onTap: () => nav.navigateTo('admin-dashboard'),
          ),
          const SizedBox(height: 10),
          _buildPortalTile(
            title: 'Faculty / Instructor Portal',
            subtitle: '12 modules: classes, enrolled students, curriculum, lectures',
            icon: Icons.cast_for_education,
            color: AppColors.teacherPrimary,
            onTap: () => nav.navigateTo('teacher-dashboard'),
          ),
          const SizedBox(height: 10),
          _buildPortalTile(
            title: 'Student Learning Portal',
            subtitle: '13 modules: grades, attendance, exam hall, study materials',
            icon: Icons.school,
            color: AppColors.studentPrimary,
            onTap: () => nav.navigateTo('student-dashboard'),
          ),
        ],
      ),
    );
  }

  Widget _buildPortalTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.bgPage,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textMain)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}

