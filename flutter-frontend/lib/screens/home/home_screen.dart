import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../constants/app_colors.dart';
import '../../providers/navigation_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/footer.dart';

/// Redesigned Modern, Premium & Visually Engaging Homepage for EduChain
/// Inspired by the reference design with matching theme, colors, gradients,
/// typography, and creative architectural illustration.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _homeKey = GlobalKey();
  final GlobalKey _aboutKey = GlobalKey();
  final GlobalKey _featuresKey = GlobalKey();
  final GlobalKey _contactKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final nav = Provider.of<NavigationProvider>(context, listen: false);
    final offset = _scrollController.offset;

    if (offset < 200) {
      if (nav.activeSection != 'home') {
        nav.setActiveSection('home');
      }
    }
  }

  void scrollToSection(String sectionId) {
    final nav = Provider.of<NavigationProvider>(context, listen: false);
    nav.setActiveSection(sectionId);

    if (sectionId == 'home') {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 650),
          curve: Curves.easeInOutCubic,
        );
      }
      return;
    }

    GlobalKey? targetKey;
    if (sectionId == 'about') targetKey = _aboutKey;
    if (sectionId == 'features') targetKey = _featuresKey;
    if (sectionId == 'contact') targetKey = _contactKey;

    if (targetKey != null && targetKey.currentContext != null) {
      Scrollable.ensureVisible(
        targetKey.currentContext!,
        duration: const Duration(milliseconds: 650),
        curve: Curves.easeInOutCubic,
        alignment: 0.05,
      );
    }
  }

  Future<void> _safeLaunchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    } catch (_) {
      // Ignored for platform safety
    }
  }

  @override
  Widget build(BuildContext context) {
    final nav = Provider.of<NavigationProvider>(context);
    final auth = Provider.of<AuthProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1024;
    final isTablet = screenWidth >= 680 && screenWidth < 1024;
    final isInstituteLoggedIn = auth.isInstitute;

    // React to section navigation requests from Navbar or other widgets
    if (nav.targetSection != null) {
      final target = nav.targetSection!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        scrollToSection(target);
        nav.clearTargetSection();
      });
    }

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            // Anchor for top/home section
            SizedBox(key: _homeKey, height: 1),

            // 1. Institute Active Verified Banner (when authenticated)
            if (isInstituteLoggedIn)
              _buildInstituteActiveBanner(context, nav, auth),

            // 2. Premium Hero Section with Clean Campus Architectural Art & Stats
            _buildHeroSection(
              context,
              nav,
              auth,
              isDesktop,
              isTablet,
              isInstituteLoggedIn,
            ),

            // 3. Management Feature Cards Section
            Container(
              key: _featuresKey,
              color: Colors.white,
              child: _buildFeaturesSection(isDesktop, isTablet),
            ),

            // 4. "Why Choose EduChain?" Grid
            Container(
              color: const Color(0xFFF8FAFC),
              child: _buildWhyChooseSection(isDesktop, isTablet),
            ),

            // 5. About Us Showcase Section
            Container(
              key: _aboutKey,
              color: Colors.white,
              child: _buildAboutSection(
                context,
                nav,
                isDesktop,
                isTablet,
                isInstituteLoggedIn,
              ),
            ),

            // 6. Institute Onboarding Dark Gradient CTA Card
            Container(
              color: const Color(0xFFF8FAFC),
              child: _buildOnboardingCtaSection(
                context,
                nav,
                isDesktop,
                isInstituteLoggedIn,
              ),
            ),

            // 7. Contact Details Section
            Container(
              key: _contactKey,
              color: Colors.white,
              child: _buildContactSection(isDesktop, isTablet),
            ),

            // 8. Footer with Section Scroll Callback
            Footer(onScrollToSection: scrollToSection),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // 1. VERIFIED ACTIVE INSTITUTE BANNER
  // =========================================================================
  Widget _buildInstituteActiveBanner(
    BuildContext context,
    NavigationProvider nav,
    AuthProvider auth,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE0F2FE), Color(0xFFF0F9FF)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        border: const Border(
          bottom: BorderSide(color: Color(0xFFBAE6FD), width: 1.5),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1240),
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 16,
            runSpacing: 10,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0284C7),
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0284C7).withValues(alpha: 0.25),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Text(
                      'INSTITUTE VERIFIED',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 13.5,
                          color: Color(0xFF0369A1),
                          fontFamily: 'Inter',
                        ),
                        children: [
                          const TextSpan(text: 'Active Session: '),
                          TextSpan(
                            text:
                                auth.currentUser?.instituteName ??
                                'Apex Institute of Technology',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          TextSpan(
                            text:
                                ' (${auth.currentUser?.instituteCode ?? "INST-2025"})',
                            style: const TextStyle(color: Color(0xFF0284C7)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => nav.navigateTo('institute-home'),
                icon: const Text(
                  'Open Institute Dashboard',
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                ),
                label: const Icon(Icons.arrow_forward_rounded, size: 15),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0284C7),
                  foregroundColor: Colors.white,
                  elevation: 2,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================================
  // 2. HERO SECTION
  // =========================================================================
  Widget _buildHeroSection(
    BuildContext context,
    NavigationProvider nav,
    AuthProvider auth,
    bool isDesktop,
    bool isTablet,
    bool isInstituteLoggedIn,
  ) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        gradient: RadialGradient(
          center: Alignment(0.6, -0.6),
          radius: 1.2,
          colors: [
            Color(0xFFE0F2FE),
            Color(0xFFF0F9FF),
            Color(0xFFF8FAFC),
          ],
          stops: [0.0, 0.45, 1.0],
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: 24,
        vertical: isDesktop ? 60 : 36,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1240),
          child: Column(
            children: [
              if (isDesktop)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Left Column: Hero Text & CTAs
                    Expanded(
                      flex: 6,
                      child: _buildHeroLeftContent(
                        context,
                        nav,
                        isInstituteLoggedIn,
                      ),
                    ),
                    const SizedBox(width: 52),
                    // Right Column: Clean Architectural Campus Art
                    Expanded(
                      flex: 5,
                      child: _buildHeroIllustration(),
                    ),
                  ],
                )
              else
                Column(
                  children: [
                    _buildHeroLeftContent(context, nav, isInstituteLoggedIn),
                    const SizedBox(height: 44),
                    _buildHeroIllustration(),
                  ],
                ),

              const SizedBox(height: 52),

              // Trust & Scale Metrics Strip
              _buildHeroTrustMetrics(isDesktop, isTablet),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroLeftContent(
    BuildContext context,
    NavigationProvider nav,
    bool isInstituteLoggedIn,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sparkle pill badge inspired by reference website
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFE0F2FE),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: const Color(0xFF0284C7).withValues(alpha: 0.25),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0284C7).withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.auto_awesome_rounded,
                size: 14,
                color: Color(0xFF0284C7),
              ),
              SizedBox(width: 8),
              Text(
                'ACADEMIC MANAGEMENT PLATFORM',
                style: TextStyle(
                  color: Color(0xFF0284C7),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 22),

        // Hero Main Title with Reference Gradient
        RichText(
          text: const TextSpan(
            style: TextStyle(
              fontSize: 44,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
              letterSpacing: -1.2,
              height: 1.12,
              fontFamily: 'Inter',
            ),
            children: [
              TextSpan(text: 'Welcome to \n'),
              TextSpan(
                text: 'Edu',
                style: TextStyle(
                  color: Color(0xFF00337F),
                  fontWeight: FontWeight.w900,
                ),
              ),
              TextSpan(
                text: 'Chain',
                style: TextStyle(
                  color: Color(0xFF00A88F),
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // Brand Subhead
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFEFF6FF), Color(0xFFE0F2FE)],
            ),
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Text(
            'One Platform, Endless Possibilities',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF00337F),
              letterSpacing: -0.3,
            ),
          ),
        ),

        const SizedBox(height: 14),

        // Lead Description
        const Text(
          'Manage your institute, teachers and students from one platform.',
          style: TextStyle(
            fontSize: 16.5,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B),
            height: 1.45,
          ),
        ),

        const SizedBox(height: 8),

        // Subtitle text from reference design
        const Text(
          'A smart and simple solution for academic management, designed to make education more efficient, coordinated, and organized.',
          style: TextStyle(
            fontSize: 14.5,
            color: Color(0xFF64748B),
            height: 1.6,
          ),
        ),

        const SizedBox(height: 32),

        // Hero Action Buttons
        Wrap(
          spacing: 14,
          runSpacing: 12,
          children: [
            if (isInstituteLoggedIn) ...[
              _buildPrimaryGradientButton(
                label: 'Go to Institute Dashboard',
                icon: Icons.account_balance_rounded,
                onPressed: () => nav.navigateTo('institute-home'),
              ),
              _buildSecondaryOutlineButton(
                label: 'Open Role Gateway',
                icon: Icons.people_alt_rounded,
                onPressed: () => nav.navigateTo('select-role'),
              ),
            ] else ...[
              _buildPrimaryGradientButton(
                label: 'INSTITUTE Login',
                icon: Icons.login_rounded,
                onPressed: () => nav.navigateTo('institute-login'),
              ),
              _buildSecondaryOutlineButton(
                label: 'INSTITUTE Register',
                icon: Icons.domain_add_rounded,
                onPressed: () => nav.navigateTo('institute-register'),
              ),
            ],
          ],
        ),
      ],
    );
  }

  // Primary Gradient Button
  Widget _buildPrimaryGradientButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return _HoverScaleButton(
      onPressed: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0284C7), Color(0xFF0369A1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0284C7).withValues(alpha: 0.35),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: Colors.white),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Secondary Outline Button
  Widget _buildSecondaryOutlineButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return _HoverScaleButton(
      onPressed: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFCBD5E1), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: const Color(0xFF0F172A)),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Clean Campus Hero Illustration (without floating badges)
  Widget _buildHeroIllustration() {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 520, maxHeight: 370),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.07),
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
          BoxShadow(
            color: const Color(0xFF0284C7).withValues(alpha: 0.06),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: const _AcademicCampusCanvasArt(),
      ),
    );
  }

  // Hero Trust Metrics Strip
  Widget _buildHeroTrustMetrics(bool isDesktop, bool isTablet) {
    final metrics = [
      {
        'value': '500+',
        'label': 'Partner Institutes',
        'icon': Icons.apartment_rounded,
        'color': const Color(0xFF0284C7),
      },
      {
        'value': '50,000+',
        'label': 'Active Students',
        'icon': Icons.school_rounded,
        'color': const Color(0xFF7C3AED),
      },
      {
        'value': '3,200+',
        'label': 'Verified Faculty',
        'icon': Icons.people_alt_rounded,
        'color': const Color(0xFF0D9488),
      },
      {
        'value': '99.9%',
        'label': 'Platform Reliability',
        'icon': Icons.shield_rounded,
        'color': const Color(0xFFEA580C),
      },
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: isDesktop
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: metrics.asMap().entries.map((entry) {
                final isLast = entry.key == metrics.length - 1;
                return Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildMetricItem(entry.value),
                      if (!isLast) ...[
                        const Spacer(),
                        Container(
                          width: 1,
                          height: 36,
                          color: const Color(0xFFE2E8F0),
                        ),
                        const Spacer(),
                      ],
                    ],
                  ),
                );
              }).toList(),
            )
          : Wrap(
              alignment: WrapAlignment.spaceEvenly,
              spacing: 24,
              runSpacing: 20,
              children: metrics.map((m) => _buildMetricItem(m)).toList(),
            ),
    );
  }

  Widget _buildMetricItem(Map<String, dynamic> metric) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: (metric['color'] as Color).withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            metric['icon'] as IconData,
            color: metric['color'] as Color,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              metric['value'] as String,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
                letterSpacing: -0.5,
              ),
            ),
            Text(
              metric['label'] as String,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // =========================================================================
  // 3. FEATURES SECTION ("OUR FEATURES")
  // =========================================================================
  Widget _buildFeaturesSection(bool isDesktop, bool isTablet) {
    final features = [
      {
        'title': 'Institute Management',
        'desc':
            'Manage institute administration, campus settings, and role-based access controls efficiently.',
        'status': 'Institute Administration',
        'color': const Color(0xFF0284C7),
        'bgLight': const Color(0xFFE0F2FE),
        'borderLight': const Color(0xFFBAE6FD),
        'icon': Icons.account_balance_rounded,
      },
      {
        'title': 'Teacher Management',
        'desc':
            'Manage classes, faculty schedules, lesson planning, and student marks grading seamlessly.',
        'status': 'Faculty Management',
        'color': const Color(0xFF0D9488),
        'bgLight': const Color(0xFFCCFBF1),
        'borderLight': const Color(0xFF99F6E4),
        'icon': Icons.groups_rounded,
      },
      {
        'title': 'Student Management',
        'desc':
            'Access learning resources, timetable schedules, course progress, and exam report cards.',
        'status': 'Student Dashboard',
        'color': const Color(0xFF7C3AED),
        'bgLight': const Color(0xFFF3E8FF),
        'borderLight': const Color(0xFFE9D5FF),
        'icon': Icons.school_rounded,
      },
      {
        'title': 'Examination & Results',
        'desc':
            'Manage online assessments, generate verified report cards, and monitor academic analytics.',
        'status': 'Academic Analytics',
        'color': const Color(0xFFEA580C),
        'bgLight': const Color(0xFFFFEDD5),
        'borderLight': const Color(0xFFFED7AA),
        'icon': Icons.assignment_turned_in_rounded,
      },
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 72),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1240),
          child: Column(
            children: [
              _buildSectionHeader(
                label: 'OUR FEATURES',
                title: 'Everything You Need in One Portal',
                subtitle:
                    'Simplify academic administration with specialized tools designed for institutes, teachers, and students.',
              ),
              const SizedBox(height: 52),
              if (isDesktop)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: features.map((f) {
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: _FeatureCard(feature: f),
                      ),
                    );
                  }).toList(),
                )
              else if (isTablet)
                Wrap(
                  spacing: 20,
                  runSpacing: 20,
                  children: features.map((f) {
                    return SizedBox(
                      width: (1240 - 20) / 2 > 300 ? 320 : double.infinity,
                      child: _FeatureCard(feature: f),
                    );
                  }).toList(),
                )
              else
                Column(
                  children: features.map((f) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: _FeatureCard(feature: f),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================================
  // 4. WHY CHOOSE SECTION
  // =========================================================================
  Widget _buildWhyChooseSection(bool isDesktop, bool isTablet) {
    final items = [
      {
        'title': 'Secure & Reliable',
        'desc':
            'Your institution data is protected with role authentication and audit trails.',
        'icon': Icons.shield_outlined,
      },
      {
        'title': 'Easy to Use',
        'desc':
            'Clean, intuitive user interface designed for fast daily academic operations.',
        'icon': Icons.bolt_rounded,
      },
      {
        'title': 'Role Based Access',
        'desc':
            'Dedicated and separated portals for Institute, Admin, Teacher, and Student.',
        'icon': Icons.lock_outline_rounded,
      },
      {
        'title': 'Access Anywhere',
        'desc':
            'Fully responsive system available across desktops, tablets, and smartphones.',
        'icon': Icons.devices_rounded,
      },
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 72),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1240),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 28,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0284C7),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Why Choose EduChain?',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 36),
              if (isDesktop)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: items.map((item) {
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: _WhyChooseCard(item: item),
                      ),
                    );
                  }).toList(),
                )
              else if (isTablet)
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: items.map((item) {
                    return SizedBox(
                      width: 320,
                      child: _WhyChooseCard(item: item),
                    );
                  }).toList(),
                )
              else
                Column(
                  children: items.map((item) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _WhyChooseCard(item: item),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================================
  // 5. ABOUT US SECTION
  // =========================================================================
  Widget _buildAboutSection(
    BuildContext context,
    NavigationProvider nav,
    bool isDesktop,
    bool isTablet,
    bool isInstituteLoggedIn,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 76),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1240),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            padding: EdgeInsets.all(isDesktop ? 48 : 28),
            child: isDesktop
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Left content
                      Expanded(
                        flex: 6,
                        child: _buildAboutContent(
                          context,
                          nav,
                          isInstituteLoggedIn,
                        ),
                      ),
                      const SizedBox(width: 48),
                      // Right visual card preview
                      Expanded(
                        flex: 5,
                        child: _buildAboutVisualPanel(),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      _buildAboutContent(context, nav, isInstituteLoggedIn),
                      const SizedBox(height: 36),
                      _buildAboutVisualPanel(),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildAboutContent(
    BuildContext context,
    NavigationProvider nav,
    bool isInstituteLoggedIn,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFE0F2FE),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: const Color(0xFF0284C7).withValues(alpha: 0.25),
            ),
          ),
          child: const Text(
            'ABOUT US',
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0284C7),
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 16),
        RichText(
          text: const TextSpan(
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
              letterSpacing: -0.6,
              height: 1.2,
              fontFamily: 'Inter',
            ),
            children: [
              TextSpan(text: 'Making Academic Management \n'),
              TextSpan(
                text: 'Simple and Smart',
                style: TextStyle(color: Color(0xFF0284C7)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'EduChain is designed to bring essential academic activities together in one organized platform. It helps institutes manage administration and supports teachers and students with a centralized digital experience.',
          style: TextStyle(
            fontSize: 15,
            color: Color(0xFF475569),
            height: 1.65,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Our goal is to simplify everyday academic tasks, improve coordination, and make important educational information easier to manage.',
          style: TextStyle(
            fontSize: 15,
            color: Color(0xFF475569),
            height: 1.65,
          ),
        ),
        const SizedBox(height: 24),
        // 3 Key benefits chips
        _buildAboutBenefitRow(
          Icons.shield_rounded,
          'Organized access management',
          const Color(0xFF0284C7),
        ),
        const SizedBox(height: 10),
        _buildAboutBenefitRow(
          Icons.menu_book_rounded,
          'Centralized academic resources',
          const Color(0xFF0D9488),
        ),
        const SizedBox(height: 10),
        _buildAboutBenefitRow(
          Icons.people_alt_rounded,
          'Dedicated support for faculty and students',
          const Color(0xFF7C3AED),
        ),
        const SizedBox(height: 32),
        _buildPrimaryGradientButton(
          label: isInstituteLoggedIn
              ? 'Open Institute Dashboard'
              : 'Register Your Institute',
          icon: Icons.arrow_forward_rounded,
          onPressed: () => nav.navigateTo(
            isInstituteLoggedIn ? 'institute-home' : 'institute-register',
          ),
        ),
      ],
    );
  }

  Widget _buildAboutBenefitRow(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 10),
          Text(
            text,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutVisualPanel() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF0F9FF), Color(0xFFE0F2FE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFBAE6FD)),
      ),
      child: Column(
        children: [
          Row(
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
                    'Unified Digital Campus',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  Text(
                    'Connected Academic Ecosystem',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF0369A1),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildRolePreviewRow(
            'Institute Administration',
            'Campus settings, courses, timetable, security',
            Icons.domain_rounded,
            const Color(0xFF0284C7),
          ),
          const SizedBox(height: 12),
          _buildRolePreviewRow(
            'Faculty & Instructor Portal',
            'Lectures, grading, student performance, syllabus',
            Icons.groups_rounded,
            const Color(0xFF0D9488),
          ),
          const SizedBox(height: 12),
          _buildRolePreviewRow(
            'Student Learning Desk',
            'Exam results, study resources, daily attendance',
            Icons.school_rounded,
            const Color(0xFF7C3AED),
          ),
        ],
      ),
    );
  }

  Widget _buildRolePreviewRow(
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // 6. INSTITUTE ONBOARDING DARK CTA SECTION
  // =========================================================================
  Widget _buildOnboardingCtaSection(
    BuildContext context,
    NavigationProvider nav,
    bool isDesktop,
    bool isInstituteLoggedIn,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1240),
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.3),
                  blurRadius: 28,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 48 : 28,
              vertical: isDesktop ? 44 : 32,
            ),
            child: isDesktop
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: _buildCtaText(),
                      ),
                      const SizedBox(width: 32),
                      _buildCtaButtons(nav, isInstituteLoggedIn),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCtaText(),
                      const SizedBox(height: 24),
                      _buildCtaButtons(nav, isInstituteLoggedIn),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildCtaText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF0284C7).withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: const Color(0xFF38BDF8).withValues(alpha: 0.4),
                ),
              ),
              child: const Text(
                'GET STARTED TODAY',
                style: TextStyle(
                  color: Color(0xFF38BDF8),
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Text(
          'Get Started with EduChain Portal',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Log in to your verified institute account to access dedicated admin, faculty, and student portals.',
          style: TextStyle(
            fontSize: 14.5,
            color: Color(0xFF94A3B8),
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildCtaButtons(NavigationProvider nav, bool isInstituteLoggedIn) {
    return Wrap(
      spacing: 12,
      runSpacing: 10,
      children: [
        if (isInstituteLoggedIn) ...[
          ElevatedButton(
            onPressed: () => nav.navigateTo('institute-home'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0284C7),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 4,
            ),
            child: const Text(
              'Open Institute Dashboard',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
          ),
          OutlinedButton(
            onPressed: () => nav.navigateTo('select-role'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Color(0xFF475569), width: 1.5),
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Role Gateway',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ] else ...[
          ElevatedButton(
            onPressed: () => nav.navigateTo('institute-login'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0284C7),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 4,
            ),
            child: const Text(
              'INSTITUTE Login',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
          ),
          OutlinedButton(
            onPressed: () => nav.navigateTo('institute-register'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Color(0xFF475569), width: 1.5),
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Register Institute',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ],
    );
  }

  // =========================================================================
  // 7. CONTACT SECTION
  // =========================================================================
  Widget _buildContactSection(bool isDesktop, bool isTablet) {
    final contacts = [
      {
        'title': 'Email Us',
        'desc': 'Send us your questions or inquiries anytime.',
        'detail': 'support@yourinstituteportal.com',
        'icon': Icons.email_outlined,
        'actionUrl': 'mailto:support@yourinstituteportal.com',
      },
      {
        'title': 'Call Us',
        'desc': 'Contact our support team for direct assistance.',
        'detail': '+91 00000 00000',
        'icon': Icons.phone_in_talk_outlined,
        'actionUrl': 'tel:+910000000000',
      },
      {
        'title': 'Our Campus Office',
        'desc': 'EduChain Support Office',
        'detail': 'Tech City Campus, Innovation Tower, Suite 400',
        'icon': Icons.location_on_outlined,
        'actionUrl': null,
      },
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 76),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1240),
          child: Column(
            children: [
              _buildSectionHeader(
                label: 'CONTACT US',
                title: 'Get in Touch with Our Team',
                subtitle:
                    'Have questions about EduChain or need assistance setting up your campus? Contact our support team.',
              ),
              const SizedBox(height: 52),
              if (isDesktop)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: contacts.map((c) {
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: _ContactCard(
                          contact: c,
                          onTap: c['actionUrl'] != null
                              ? () => _safeLaunchUrl(c['actionUrl'] as String)
                              : null,
                        ),
                      ),
                    );
                  }).toList(),
                )
              else
                Column(
                  children: contacts.map((c) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: _ContactCard(
                        contact: c,
                        onTap: c['actionUrl'] != null
                            ? () => _safeLaunchUrl(c['actionUrl'] as String)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================================
  // REUSABLE SECTION HEADER
  // =========================================================================
  Widget _buildSectionHeader({
    required String label,
    required String title,
    required String subtitle,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFE0F2FE),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: const Color(0xFF0284C7).withValues(alpha: 0.25),
            ),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0284C7),
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
            letterSpacing: -0.6,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Text(
            subtitle,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF64748B),
              height: 1.55,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

// ===========================================================================
// SUB-WIDGETS & HOVER COMPONENTS
// ===========================================================================

/// Feature Card with Interactive Hover Lift & Accent Colors
class _FeatureCard extends StatefulWidget {
  final Map<String, dynamic> feature;

  const _FeatureCard({required this.feature});

  @override
  State<_FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<_FeatureCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final f = widget.feature;
    final Color color = f['color'] as Color;
    final Color bgLight = f['bgLight'] as Color;
    final Color borderLight = f['borderLight'] as Color;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0, _isHovered ? -6 : 0, 0),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: _isHovered ? color.withValues(alpha: 0.5) : const Color(0xFFE2E8F0),
            width: _isHovered ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: _isHovered
                  ? color.withValues(alpha: 0.12)
                  : const Color(0xFF0F172A).withValues(alpha: 0.04),
              blurRadius: _isHovered ? 24 : 12,
              offset: Offset(0, _isHovered ? 10 : 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon Square Box
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: bgLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(f['icon'] as IconData, color: color, size: 26),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              f['title'] as String,
              style: const TextStyle(
                fontSize: 17.5,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              f['desc'] as String,
              style: const TextStyle(
                fontSize: 13.5,
                color: Color(0xFF64748B),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 22),
            // Verified Status Tag
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: bgLight,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: borderLight),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle_rounded, size: 14, color: color),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      f['status'] as String,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Why Choose Benefit Card with Hover Feedback
class _WhyChooseCard extends StatefulWidget {
  final Map<String, dynamic> item;

  const _WhyChooseCard({required this.item});

  @override
  State<_WhyChooseCard> createState() => _WhyChooseCardState();
}

class _WhyChooseCardState extends State<_WhyChooseCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0, _isHovered ? -4 : 0, 0),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _isHovered ? const Color(0xFF38BDF8) : const Color(0xFFE2E8F0),
            width: _isHovered ? 1.4 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: _isHovered
                  ? const Color(0xFF0284C7).withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.02),
              blurRadius: _isHovered ? 16 : 6,
              offset: Offset(0, _isHovered ? 6 : 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFE0F2FE),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                widget.item['icon'] as IconData,
                color: const Color(0xFF0284C7),
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.item['title'] as String,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    widget.item['desc'] as String,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: Color(0xFF64748B),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Contact Card with Clickable URLs & Hover Styling
class _ContactCard extends StatefulWidget {
  final Map<String, dynamic> contact;
  final VoidCallback? onTap;

  const _ContactCard({required this.contact, this.onTap});

  @override
  State<_ContactCard> createState() => _ContactCardState();
}

class _ContactCardState extends State<_ContactCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final c = widget.contact;
    final isClickable = widget.onTap != null;

    return MouseRegion(
      cursor: isClickable ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          transform: Matrix4.translationValues(0, _isHovered ? -5 : 0, 0),
          padding: const EdgeInsets.all(26),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: _isHovered ? const Color(0xFF38BDF8) : const Color(0xFFE2E8F0),
              width: _isHovered ? 1.5 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: _isHovered
                    ? const Color(0xFF0284C7).withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.02),
                blurRadius: _isHovered ? 20 : 8,
                offset: Offset(0, _isHovered ? 8 : 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Icon(
                  c['icon'] as IconData,
                  color: const Color(0xFF0284C7),
                  size: 24,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                c['title'] as String,
                style: const TextStyle(
                  fontSize: 17.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                c['desc'] as String,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF64748B),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      c['detail'] as String,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: isClickable
                            ? (_isHovered
                                ? const Color(0xFF0369A1)
                                : const Color(0xFF0284C7))
                            : const Color(0xFF0F172A),
                        decoration: (isClickable && _isHovered)
                            ? TextDecoration.underline
                            : TextDecoration.none,
                      ),
                    ),
                  ),
                  if (isClickable)
                    Icon(
                      Icons.arrow_outward_rounded,
                      size: 15,
                      color: _isHovered
                          ? const Color(0xFF0369A1)
                          : const Color(0xFF0284C7),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Generic Hover Scale Wrapper for Buttons
class _HoverScaleButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;

  const _HoverScaleButton({required this.child, required this.onPressed});

  @override
  State<_HoverScaleButton> createState() => _HoverScaleButtonState();
}

class _HoverScaleButtonState extends State<_HoverScaleButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedScale(
          scale: _isHovered ? 1.02 : 1.0,
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOutCubic,
          child: widget.child,
        ),
      ),
    );
  }
}

// ===========================================================================
// VECTOR CAMPUS HERO ARTWORK (Inspired by InstituteBuildingIllustration.jsx)
// ===========================================================================
class _AcademicCampusCanvasArt extends StatelessWidget {
  const _AcademicCampusCanvasArt();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 360,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFBAE6FD), Color(0xFFE0F2FE), Color(0xFFF8FAFC)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.0, 0.55, 1.0],
        ),
      ),
      child: CustomPaint(
        painter: _CampusArchitecturalPainter(),
      ),
    );
  }
}

class _CampusArchitecturalPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Sun & Radiant Ambient Glow
    final sunPaint = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0xFFFDE047), Color(0xFFF59E0B), Colors.transparent],
        stops: [0.0, 0.6, 1.0],
      ).createShader(Rect.fromCircle(center: Offset(w * 0.85, h * 0.22), radius: 60));
    canvas.drawCircle(Offset(w * 0.85, h * 0.22), 50, sunPaint);

    // 2. Soft Background Clouds
    final cloudPaint = Paint()..color = Colors.white.withValues(alpha: 0.65);
    _drawCloud(canvas, Offset(w * 0.18, h * 0.18), 24, cloudPaint);
    _drawCloud(canvas, Offset(w * 0.62, h * 0.14), 28, cloudPaint);

    // 3. Ground / Lawns
    final groundRect = Rect.fromLTWH(0, h * 0.78, w, h * 0.22);
    final groundPaint = Paint()..color = const Color(0xFFCBD5E1);
    canvas.drawRect(groundRect, groundPaint);

    final grassRect = Rect.fromLTWH(0, h * 0.77, w, 8);
    final grassPaint = Paint()..color = const Color(0xFF10B981);
    canvas.drawRect(grassRect, grassPaint);

    // 4. Classical Academic Building Base
    final buildingW = w * 0.64;
    final buildingH = h * 0.44;
    final buildingX = (w - buildingW) / 2;
    final buildingY = h * 0.77 - buildingH;

    // Building Main Wall with Subtle Gradient
    final wallRect = Rect.fromLTWH(buildingX, buildingY, buildingW, buildingH);
    final wallPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFFFFFF), Color(0xFFE2E8F0)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(wallRect);
    canvas.drawRRect(RRect.fromRectAndRadius(wallRect, const Radius.circular(6)), wallPaint);

    final wallBorderPaint = Paint()
      ..color = const Color(0xFF94A3B8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRRect(RRect.fromRectAndRadius(wallRect, const Radius.circular(6)), wallBorderPaint);

    // 5. Neoclassical Classical Pediment (Triangle Roof)
    final pedimentPath = Path()
      ..moveTo(w / 2, buildingY - (h * 0.18))
      ..lineTo(buildingX - (w * 0.04), buildingY)
      ..lineTo(buildingX + buildingW + (w * 0.04), buildingY)
      ..close();

    final pedimentPaint = Paint()
      ..shader = LinearGradient(
        colors: const [Color(0xFF0284C7), Color(0xFF0369A1)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(pedimentPath.getBounds());
    canvas.drawPath(pedimentPath, pedimentPaint);

    // Pediment Border
    final pedimentBorderPaint = Paint()
      ..color = const Color(0xFF00337F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawPath(pedimentPath, pedimentBorderPaint);

    // 6. Central Dome over pediment
    final domeRect = Rect.fromLTWH(
      w / 2 - 28,
      buildingY - (h * 0.26),
      56,
      44,
    );
    final domePaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF38BDF8), Color(0xFF0284C7)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(domeRect);
    canvas.drawArc(domeRect, math.pi, math.pi, true, domePaint);

    // Flagpole & EduChain Flag
    final flagPolePaint = Paint()
      ..color = const Color(0xFF0F172A)
      ..strokeWidth = 2.0;
    canvas.drawLine(
      Offset(w / 2, buildingY - (h * 0.26)),
      Offset(w / 2, buildingY - (h * 0.32)),
      flagPolePaint,
    );
    final flagPath = Path()
      ..moveTo(w / 2, buildingY - (h * 0.32))
      ..lineTo(w / 2 + 18, buildingY - (h * 0.29))
      ..lineTo(w / 2, buildingY - (h * 0.26))
      ..close();
    final flagPaint = Paint()..color = const Color(0xFF00A88F);
    canvas.drawPath(flagPath, flagPaint);

    // 7. Clock in Pediment
    final clockCenter = Offset(w / 2, buildingY - (h * 0.07));
    final clockPaint = Paint()..color = Colors.white;
    final clockBorder = Paint()
      ..color = const Color(0xFF0369A1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawCircle(clockCenter, 16, clockPaint);
    canvas.drawCircle(clockCenter, 16, clockBorder);

    // Clock Hands
    final handPaint = Paint()
      ..color = const Color(0xFF0F172A)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(clockCenter, Offset(clockCenter.dx, clockCenter.dy - 10), handPaint);
    canvas.drawLine(clockCenter, Offset(clockCenter.dx + 7, clockCenter.dy), handPaint);

    // 8. Pillars / Columns
    final columnPositions = [
      buildingX + (buildingW * 0.12),
      buildingX + (buildingW * 0.28),
      buildingX + (buildingW * 0.44),
      buildingX + (buildingW * 0.56),
      buildingX + (buildingW * 0.72),
      buildingX + (buildingW * 0.88),
    ];

    for (final colX in columnPositions) {
      final colRect = Rect.fromLTWH(colX - 6, buildingY + 6, 12, buildingH - 12);
      final colPaint = Paint()..color = const Color(0xFFF8FAFC);
      final colStroke = Paint()
        ..color = const Color(0xFFCBD5E1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;
      canvas.drawRect(colRect, colPaint);
      canvas.drawRect(colRect, colStroke);

      // Capital & Base
      final capPaint = Paint()..color = const Color(0xFF94A3B8);
      canvas.drawRect(Rect.fromLTWH(colX - 8, buildingY + 2, 16, 5), capPaint);
      canvas.drawRect(Rect.fromLTWH(colX - 8, buildingY + buildingH - 8, 16, 6), capPaint);
    }

    // 9. Central Entrance Door
    final doorW = 38.0;
    final doorH = 54.0;
    final doorRect = Rect.fromLTWH(
      (w - doorW) / 2,
      buildingY + buildingH - doorH,
      doorW,
      doorH,
    );
    final doorPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF0284C7), Color(0xFF00337F)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(doorRect);
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        doorRect,
        topLeft: const Radius.circular(16),
        topRight: const Radius.circular(16),
      ),
      doorPaint,
    );

    // 10. Symmetric Glazed Windows
    final windowPaint = Paint()..color = const Color(0xFF38BDF8).withValues(alpha: 0.85);
    final windowPositions = [
      Offset(buildingX + (buildingW * 0.19), buildingY + 28),
      Offset(buildingX + (buildingW * 0.19), buildingY + 64),
      Offset(buildingX + (buildingW * 0.79), buildingY + 28),
      Offset(buildingX + (buildingW * 0.79), buildingY + 64),
    ];

    for (final wp in windowPositions) {
      final winRect = Rect.fromLTWH(wp.dx - 10, wp.dy, 20, 26);
      canvas.drawRRect(RRect.fromRectAndRadius(winRect, const Radius.circular(4)), windowPaint);
    }

    // 11. Landscape Trees on flanks
    _drawTree(canvas, Offset(buildingX - 30, h * 0.77), 22);
    _drawTree(canvas, Offset(buildingX + buildingW + 30, h * 0.77), 22);
  }

  void _drawCloud(Canvas canvas, Offset center, double radius, Paint paint) {
    canvas.drawCircle(center, radius, paint);
    canvas.drawCircle(Offset(center.dx - (radius * 0.8), center.dy + 4), radius * 0.7, paint);
    canvas.drawCircle(Offset(center.dx + (radius * 0.8), center.dy + 4), radius * 0.75, paint);
  }

  void _drawTree(Canvas canvas, Offset base, double crownRadius) {
    // Trunk
    final trunkPaint = Paint()..color = const Color(0xFF78350F);
    canvas.drawRect(Rect.fromLTWH(base.dx - 4, base.dy - 20, 8, 20), trunkPaint);

    // Foliage
    final foliagePaint = Paint()..color = const Color(0xFF10B981);
    canvas.drawCircle(Offset(base.dx, base.dy - 26), crownRadius, foliagePaint);
    final foliageHighlight = Paint()..color = const Color(0xFF34D399);
    canvas.drawCircle(Offset(base.dx - 4, base.dy - 30), crownRadius * 0.5, foliageHighlight);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
