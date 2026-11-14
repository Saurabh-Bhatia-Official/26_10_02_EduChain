import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../providers/navigation_provider.dart';
import '../providers/auth_provider.dart';

class Navbar extends StatelessWidget {
  final Function(String sectionId)? onScrollToSection;

  const Navbar({super.key, this.onScrollToSection});

  @override
  Widget build(BuildContext context) {
    final nav = Provider.of<NavigationProvider>(context);
    final auth = Provider.of<AuthProvider>(context);
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          bottom: BorderSide(color: AppColors.border, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo
          InkWell(
            onTap: () => nav.navigateTo('home'),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    'assets/images/educhain_icon.png',
                    width: 38,
                    height: 38,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RichText(
                      text: const TextSpan(
                        children: [
                          TextSpan(
                            text: 'Edu',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF00337F),
                              letterSpacing: -0.5,
                            ),
                          ),
                          TextSpan(
                            text: 'Chain',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF00A88F),
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Text(
                      'One Platform, Endless Possibilities',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF00337F),
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Desktop Links
          if (isDesktop)
            Row(
              children: [
                _NavLink(
                  title: 'Home',
                  isActive: nav.currentPage == 'home',
                  onTap: () => nav.navigateTo('home'),
                ),
                _NavLink(
                  title: 'About',
                  isActive: false,
                  onTap: () => onScrollToSection?.call('about'),
                ),
                _NavLink(
                  title: 'Features',
                  isActive: false,
                  onTap: () => onScrollToSection?.call('features'),
                ),
                _NavLink(
                  title: 'Contact',
                  isActive: false,
                  onTap: () => onScrollToSection?.call('contact'),
                ),
              ],
            ),

          // Auth / Role Buttons
          Flexible(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (auth.isAuthenticated) ...[
                if (auth.isTeacher) ...[
                  OutlinedButton.icon(
                    onPressed: () => nav.navigateTo('teacher-dashboard'),
                    icon: const Icon(Icons.school, size: 16, color: AppColors.teacherPrimary),
                    label: Text(
                      '${auth.currentUser?.name ?? "Instructor"} (Instructor)',
                      style: const TextStyle(color: AppColors.teacherPrimary, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: const Color(0xFFE0F2FE),
                      side: const BorderSide(color: Color(0xFFBAE6FD)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => nav.navigateTo('teacher-dashboard'),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.teacherPrimary),
                    child: const Text('Instructor Portal'),
                  ),
                ] else if (auth.isStudent) ...[
                  OutlinedButton.icon(
                    onPressed: () => nav.navigateTo('student-dashboard'),
                    icon: const Icon(Icons.person, size: 16, color: AppColors.studentPrimary),
                    label: Text(
                      '${auth.currentUser?.name ?? "Student"} (Student)',
                      style: const TextStyle(color: AppColors.studentPrimary, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: const Color(0xFFF3E8FF),
                      side: const BorderSide(color: Color(0xFFD8B4FE)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => nav.navigateTo('student-dashboard'),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.studentPrimary),
                    child: const Text('Student Portal'),
                  ),
                ] else if (auth.isAdmin) ...[
                  ElevatedButton.icon(
                    onPressed: () => nav.navigateTo('admin-dashboard'),
                    icon: const Icon(Icons.admin_panel_settings, size: 16),
                    label: const Text('Admin Portal'),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.adminPrimary),
                  ),
                ] else ...[
                  // Institute
                  OutlinedButton.icon(
                    onPressed: () => nav.navigateTo('institute-home'),
                    icon: const Icon(Icons.verified, size: 16, color: AppColors.institutePrimary),
                    label: Text(
                      auth.currentUser?.instituteName ?? 'Verified Campus',
                      style: const TextStyle(color: AppColors.institutePrimary, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: const Color(0xFFE0F2FE),
                      side: const BorderSide(color: Color(0xFFBAE6FD)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => nav.navigateTo('institute-home'),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.institutePrimary),
                    child: const Text('Institute Home'),
                  ),
                ],
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () async {
                    final role = auth.currentUser?.role;
                    await auth.logout();
                    if (role == 'student') {
                      nav.navigateTo('student-login');
                    } else if (role == 'teacher') {
                      nav.navigateTo('teacher-login');
                    } else if (role == 'admin') {
                      nav.navigateTo('admin-login');
                    } else if (role == 'institute') {
                      nav.navigateTo('institute-login');
                    } else {
                      nav.navigateTo('select-role');
                    }
                  },
                  icon: const Icon(Icons.logout, size: 20, color: AppColors.textMuted),
                  tooltip: 'Logout',
                ),
              ] else ...[
                OutlinedButton(
                  onPressed: () => nav.navigateTo('institute-login'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary, width: 1.5),
                    backgroundColor: AppColors.primaryLight,
                  ),
                  child: const Text('INSTITUTE Login'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => nav.navigateTo('institute-register'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  child: const Text('INSTITUTE Register'),
                ),
              ],
            ],
          ),
        ),
      ),
    ],
  ),
);
}
}

class _NavLink extends StatelessWidget {
  final String title;
  final bool isActive;
  final VoidCallback onTap;

  const _NavLink({
    required this.title,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              color: isActive ? AppColors.primary : AppColors.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}
