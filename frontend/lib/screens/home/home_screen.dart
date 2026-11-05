import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../constants/app_colors.dart';
import '../../providers/navigation_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/illustrations.dart';
import '../../widgets/footer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _aboutKey = GlobalKey();
  final GlobalKey _featuresKey = GlobalKey();
  final GlobalKey _contactKey = GlobalKey();

  void scrollToSection(String sectionId) {
    GlobalKey? targetKey;
    if (sectionId == 'about') targetKey = _aboutKey;
    if (sectionId == 'features') targetKey = _featuresKey;
    if (sectionId == 'contact') targetKey = _contactKey;

    if (targetKey != null && targetKey.currentContext != null) {
      Scrollable.ensureVisible(
        targetKey.currentContext!,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final nav = Provider.of<NavigationProvider>(context, listen: false);
    final auth = Provider.of<AuthProvider>(context);
    final isDesktop = MediaQuery.of(context).size.width >= 900;
    final isInstituteLoggedIn = auth.isInstitute;

    return SingleChildScrollView(
      controller: _scrollController,
      child: Column(
        children: [
          // If Institute is logged in, show active verified banner
          if (isInstituteLoggedIn)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              color: const Color(0xFFEFF6FF),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 16,
                    runSpacing: 10,
                    children: [
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 12,
                        runSpacing: 6,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2563EB),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Institute Verified',
                              style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                            ),
                          ),
                          Text(
                            'Logged in to ${auth.currentUser?.instituteName ?? "Apex Institute"} (${auth.currentUser?.instituteCode ?? "INST-2025"})',
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF1E3A8A)),
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                        onPressed: () => nav.navigateTo('institute-home'),
                        icon: const Icon(Icons.arrow_forward, size: 14),
                        label: const Text('Open Institute Dashboard'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Hero Section
          Container(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: isDesktop ? 64 : 36),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: isDesktop
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 6,
                            child: _buildHeroContent(context, nav, isInstituteLoggedIn),
                          ),
                          const SizedBox(width: 48),
                          const Expanded(
                            flex: 5,
                            child: Center(child: InstituteIllustration(size: 320)),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          _buildHeroContent(context, nav, isInstituteLoggedIn),
                          const SizedBox(height: 36),
                          const InstituteIllustration(size: 240),
                        ],
                      ),
              ),
            ),
          ),

          // Features Section
          Container(
            key: _featuresKey,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 64),
            color: Colors.white,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Column(
                  children: [
                    _buildSectionHeader(
                      label: 'OUR FEATURES',
                      title: 'Everything You Need in One Portal',
                      subtitle: 'Simplify academic administration with tools designed for institutes, teachers, and students.',
                    ),
                    const SizedBox(height: 48),
                    _buildFeaturesGrid(isDesktop),
                  ],
                ),
              ),
            ),
          ),

          // Why Choose Section
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 64),
            color: AppColors.bgPage,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Column(
                  children: [
                    const Text(
                      'Why Choose EduChain?',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textMain,
                        letterSpacing: -0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    _buildWhyChooseGrid(isDesktop),
                  ],
                ),
              ),
            ),
          ),

          // About Section
          Container(
            key: _aboutKey,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 64),
            color: Colors.white,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ABOUT US',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    RichText(
                      text: const TextSpan(
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.textMain),
                        children: [
                          TextSpan(text: 'Making Academic Management '),
                          TextSpan(text: 'Simple and Smart', style: TextStyle(color: AppColors.primary)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'EduChain is designed to bring essential academic activities together in one organized platform. It helps institutes manage administration and supports teachers and students with a centralized digital experience.',
                      style: TextStyle(fontSize: 15, color: AppColors.textMuted, height: 1.6),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Our goal is to simplify everyday academic tasks, improve coordination, and make important educational information easier to manage.',
                      style: TextStyle(fontSize: 15, color: AppColors.textMuted, height: 1.6),
                    ),
                    const SizedBox(height: 24),
                    _buildAboutBenefit(Icons.verified_user, 'Organized access management'),
                    const SizedBox(height: 12),
                    _buildAboutBenefit(Icons.menu_book, 'Centralized academic resources'),
                    const SizedBox(height: 12),
                    _buildAboutBenefit(Icons.people, 'Support for teachers and students'),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: () => nav.navigateTo(isInstituteLoggedIn ? 'institute-home' : 'institute-register'),
                      icon: const Icon(Icons.arrow_forward, size: 16),
                      label: Text(isInstituteLoggedIn ? 'Open Institute Dashboard' : 'Register Your Institute'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Onboarding CTA Card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
            color: AppColors.bgPage,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Container(
                  padding: const EdgeInsets.all(36),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: isDesktop
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Expanded(
                              flex: 7,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Get Started with EduChain',
                                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Log in to your verified institute account to access dedicated admin, faculty, and student portals.',
                                    style: TextStyle(fontSize: 14, color: Color(0xFF94A3B8), height: 1.5),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 24),
                            Row(
                              children: [
                                ElevatedButton(
                                  onPressed: () => nav.navigateTo('institute-login'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                                  ),
                                  child: const Text('INSTITUTE Login'),
                                ),
                                const SizedBox(width: 12),
                                OutlinedButton(
                                  onPressed: () => nav.navigateTo('institute-register'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    side: const BorderSide(color: Colors.white54),
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                                  ),
                                  child: const Text('Register Institute'),
                                ),
                              ],
                            ),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Get Started with EduChain',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Log in to your verified institute account to access portals.',
                              style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                            ),
                            const SizedBox(height: 20),
                            Wrap(
                              spacing: 12,
                              runSpacing: 10,
                              children: [
                                ElevatedButton(
                                  onPressed: () => nav.navigateTo('institute-login'),
                                  child: const Text('INSTITUTE Login'),
                                ),
                                OutlinedButton(
                                  onPressed: () => nav.navigateTo('institute-register'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    side: const BorderSide(color: Colors.white54),
                                  ),
                                  child: const Text('Register Institute'),
                                ),
                              ],
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),

          // Contact Section
          Container(
            key: _contactKey,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 64),
            color: Colors.white,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Column(
                  children: [
                    _buildSectionHeader(
                      label: 'CONTACT US',
                      title: 'Get in Touch with Our Team',
                      subtitle: 'Have questions about EduChain or need assistance setting up your campus? Contact our support team.',
                    ),
                    const SizedBox(height: 48),
                    _buildContactGrid(isDesktop),
                  ],
                ),
              ),
            ),
          ),

          // Footer
          Footer(onScrollToSection: scrollToSection),
        ],
      ),
    );
  }

  Widget _buildHeroContent(BuildContext context, NavigationProvider nav, bool isInstituteLoggedIn) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.auto_awesome, size: 14, color: AppColors.primary),
              SizedBox(width: 8),
              Text(
                'Academic Management Platform',
                style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        RichText(
          text: const TextSpan(
            style: TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.w900,
              color: AppColors.textMain,
              letterSpacing: -1,
              height: 1.15,
            ),
            children: [
              TextSpan(text: 'Welcome to \n'),
              TextSpan(
                text: 'Edu',
                style: TextStyle(color: Color(0xFF00337F)),
              ),
              TextSpan(
                text: 'Chain',
                style: TextStyle(color: Color(0xFF00A88F)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'One Platform, Endless Possibilities',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF00337F),
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Manage your institute, teachers and students seamlessly from one unified platform.',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.textMain),
        ),
        const SizedBox(height: 8),
        const Text(
          'A smart and modern solution for academic management, designed to make education more efficient and organized.',
          style: TextStyle(fontSize: 15, color: AppColors.textMuted, height: 1.5),
        ),
        const SizedBox(height: 32),
        Wrap(
          spacing: 14,
          runSpacing: 12,
          children: [
            if (isInstituteLoggedIn) ...[
              ElevatedButton.icon(
                onPressed: () => nav.navigateTo('institute-home'),
                icon: const Icon(Icons.account_balance, size: 18),
                label: const Text('Go to Institute Dashboard'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => nav.navigateTo('select-role'),
                icon: const Icon(Icons.people, size: 18),
                label: const Text('Open Role Gateway'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
                ),
              ),
            ] else ...[
              ElevatedButton.icon(
                onPressed: () => nav.navigateTo('institute-login'),
                icon: const Icon(Icons.login, size: 18),
                label: const Text('INSTITUTE Login'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => nav.navigateTo('institute-register'),
                icon: const Icon(Icons.account_balance, size: 18),
                label: const Text('INSTITUTE Register'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildSectionHeader({required String label, required String title, required String subtitle}) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
            letterSpacing: 1.4,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            color: AppColors.textMain,
            letterSpacing: -0.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 650),
          child: Text(
            subtitle,
            style: const TextStyle(fontSize: 15, color: AppColors.textMuted, height: 1.5),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturesGrid(bool isDesktop) {
    final features = [
      {
        'title': 'Institute Management',
        'desc': 'Manage institute administration, campus settings, and role-based access controls efficiently.',
        'status': 'Institute Administration',
        'color': AppColors.primary,
        'icon': Icons.account_balance,
      },
      {
        'title': 'Teacher Management',
        'desc': 'Manage classes, faculty schedules, lesson planning, and student marks grading.',
        'status': 'Faculty Management',
        'color': AppColors.teacherPrimary,
        'icon': Icons.people,
      },
      {
        'title': 'Student Management',
        'desc': 'Access learning resources, timetable schedules, course progress, and exam results.',
        'status': 'Student Dashboard',
        'color': AppColors.studentPrimary,
        'icon': Icons.school,
      },
      {
        'title': 'Examination & Results',
        'desc': 'Manage online assessments, generate verified report cards, and monitor academic analytics.',
        'status': 'Academic Analytics',
        'color': AppColors.accentOrange,
        'icon': Icons.assignment_turned_in,
      },
    ];

    return isDesktop
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: features.map((f) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: _buildFeatureCard(f),
                ),
              );
            }).toList(),
          )
        : Column(
            children: features.map((f) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildFeatureCard(f),
              );
            }).toList(),
          );
  }

  Widget _buildFeatureCard(Map<String, dynamic> f) {
    final Color color = f['color'] as Color;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(f['icon'] as IconData, color: color, size: 26),
          ),
          const SizedBox(height: 18),
          Text(
            f['title'] as String,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textMain),
          ),
          const SizedBox(height: 10),
          Text(
            f['desc'] as String,
            style: const TextStyle(fontSize: 13, color: AppColors.textMuted, height: 1.5),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Icon(Icons.check_circle, size: 14, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  f['status'] as String,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWhyChooseGrid(bool isDesktop) {
    final items = [
      {
        'title': 'Secure & Reliable',
        'desc': 'Your institution data is protected with role authentication and audit trails.',
        'icon': Icons.shield_outlined,
      },
      {
        'title': 'Easy to Use',
        'desc': 'Clean, intuitive user interface designed for fast daily academic operations.',
        'icon': Icons.bolt,
      },
      {
        'title': 'Role Based Access',
        'desc': 'Dedicated and separated portals for Institute, Admin, Teacher, and Student.',
        'icon': Icons.lock_outline,
      },
      {
        'title': 'Access Anywhere',
        'desc': 'Fully responsive system available across desktops, tablets, and smartphones.',
        'icon': Icons.devices,
      },
    ];

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: items.map((item) {
        return Container(
          width: isDesktop ? 270 : double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(item['icon'] as IconData, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['title'] as String,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textMain),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item['desc'] as String,
                      style: const TextStyle(fontSize: 12, color: AppColors.textMuted, height: 1.4),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAboutBenefit(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 10),
        Text(
          text,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textMain),
        ),
      ],
    );
  }

  Widget _buildContactGrid(bool isDesktop) {
    final contacts = [
      {
        'title': 'Email Us',
        'desc': 'Send us your questions or inquiries anytime.',
        'detail': 'support@yourinstituteportal.com',
        'icon': Icons.email_outlined,
        'action': () => launchUrl(Uri.parse('mailto:support@yourinstituteportal.com')),
      },
      {
        'title': 'Call Us',
        'desc': 'Contact our support team for direct assistance.',
        'detail': '+91 00000 00000',
        'icon': Icons.phone_outlined,
        'action': () => launchUrl(Uri.parse('tel:+910000000000')),
      },
      {
        'title': 'Our Campus Office',
        'desc': 'EduChain Support Office',
        'detail': 'Tech City Campus, Innovation Tower, Suite 400',
        'icon': Icons.location_on_outlined,
        'action': null,
      },
    ];

    return isDesktop
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: contacts.map((c) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: _buildContactCard(c),
                ),
              );
            }).toList(),
          )
        : Column(
            children: contacts.map((c) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildContactCard(c),
              );
            }).toList(),
          );
  }

  Widget _buildContactCard(Map<String, dynamic> c) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.bgPage,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Icon(c['icon'] as IconData, color: AppColors.primary, size: 24),
          ),
          const SizedBox(height: 18),
          Text(
            c['title'] as String,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textMain),
          ),
          const SizedBox(height: 6),
          Text(
            c['desc'] as String,
            style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
          ),
          const SizedBox(height: 14),
          InkWell(
            onTap: c['action'] as VoidCallback?,
            child: Text(
              c['detail'] as String,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: c['action'] != null ? AppColors.primary : AppColors.textMain,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
