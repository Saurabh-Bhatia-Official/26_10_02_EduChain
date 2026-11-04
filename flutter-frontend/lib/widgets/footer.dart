import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../providers/navigation_provider.dart';

class Footer extends StatelessWidget {
  final Function(String sectionId)? onScrollToSection;

  const Footer({super.key, this.onScrollToSection});

  @override
  Widget build(BuildContext context) {
    final nav = Provider.of<NavigationProvider>(context, listen: false);
    final isDesktop = MediaQuery.of(context).size.width >= 800;

    return Container(
      padding: const EdgeInsets.only(top: 48, bottom: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isDesktop)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Brand
                      Expanded(
                        flex: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            InkWell(
                              onTap: () => nav.navigateTo('home'),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(Icons.account_balance, color: Colors.white, size: 18),
                                  ),
                                  const SizedBox(width: 10),
                                  const Text(
                                    'Institute Portal',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textMain,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'A smart and simple solution for academic management, designed to make education more efficient and organized.',
                              style: TextStyle(fontSize: 13, color: AppColors.textMuted, height: 1.5),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 32),

                      // Navigation
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Navigation',
                              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textMain),
                            ),
                            const SizedBox(height: 12),
                            _FooterLink(title: 'Home', onTap: () => nav.navigateTo('home')),
                            _FooterLink(title: 'About Platform', onTap: () => onScrollToSection?.call('about')),
                            _FooterLink(title: 'Management Features', onTap: () => onScrollToSection?.call('features')),
                            _FooterLink(title: 'Contact Us', onTap: () => onScrollToSection?.call('contact')),
                          ],
                        ),
                      ),

                      // Institute Access
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Institute Access',
                              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textMain),
                            ),
                            const SizedBox(height: 12),
                            _FooterLink(title: 'INSTITUTE Login', onTap: () => nav.navigateTo('institute-login')),
                            _FooterLink(title: 'Register Institute', onTap: () => nav.navigateTo('institute-register')),
                            _FooterLink(
                              title: 'Reset Password',
                              onTap: () => nav.navigateTo('forgot-password', {'role': 'institute'}),
                            ),
                          ],
                        ),
                      ),

                      // Role Portals
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Role Portals',
                              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textMain),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Admin, Teacher & Student dashboards are accessible after institute verification.',
                              style: TextStyle(fontSize: 12, color: AppColors.textMuted, height: 1.4),
                            ),
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: () => nav.navigateTo('institute-login'),
                              child: const Text(
                                'Unlock with Institute Code →',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Institute Portal',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textMain),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'A smart and simple solution for academic management.',
                        style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 16,
                        runSpacing: 8,
                        children: [
                          _FooterLink(title: 'Home', onTap: () => nav.navigateTo('home')),
                          _FooterLink(title: 'Institute Login', onTap: () => nav.navigateTo('institute-login')),
                          _FooterLink(title: 'Register', onTap: () => nav.navigateTo('institute-register')),
                        ],
                      ),
                    ],
                  ),

                const SizedBox(height: 36),
                const Divider(color: AppColors.border),
                const SizedBox(height: 16),

                // Copyright
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 16,
                  runSpacing: 10,
                  children: [
                    const Text(
                      '© 2025 Institute Portal. All rights reserved.',
                      style: TextStyle(fontSize: 12, color: AppColors.textLight),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          onTap: () => nav.navigateTo('home'),
                          child: const Text('Home', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                        ),
                        const SizedBox(width: 12),
                        const Text('•', style: TextStyle(fontSize: 12, color: AppColors.textLight)),
                        const SizedBox(width: 12),
                        InkWell(
                          onTap: () => onScrollToSection?.call('about'),
                          child: const Text('About', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                        ),
                        const SizedBox(width: 12),
                        const Text('•', style: TextStyle(fontSize: 12, color: AppColors.textLight)),
                        const SizedBox(width: 12),
                        InkWell(
                          onTap: () => onScrollToSection?.call('contact'),
                          child: const Text('Contact', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FooterLink extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _FooterLink({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        child: Text(
          title,
          style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
        ),
      ),
    );
  }
}
