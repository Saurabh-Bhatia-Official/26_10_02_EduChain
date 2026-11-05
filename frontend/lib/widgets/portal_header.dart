import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../providers/navigation_provider.dart';
import '../providers/auth_provider.dart';

class PortalHeader extends StatelessWidget {
  final String backTarget;
  final String backLabel;
  final VoidCallback? onLogout;

  const PortalHeader({
    super.key,
    this.backTarget = 'home',
    this.backLabel = 'Back to Home',
    this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final nav = Provider.of<NavigationProvider>(context, listen: false);
    final auth = Provider.of<AuthProvider>(context);

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo & Title
          InkWell(
            onTap: () => nav.navigateTo('home'),
            borderRadius: BorderRadius.circular(8),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.account_balance,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Institute Portal',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMain,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),

          // Actions
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: () => nav.navigateTo(backTarget),
                icon: Icon(
                  backTarget == 'home' ? Icons.home_outlined : Icons.arrow_back,
                  size: 16,
                  color: AppColors.textMuted,
                ),
                label: Text(
                  backLabel,
                  style: const TextStyle(
                    color: AppColors.textMain,
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  side: const BorderSide(color: AppColors.border),
                  backgroundColor: AppColors.bgPage,
                ),
              ),
              if (onLogout != null && auth.isAuthenticated) ...[
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: onLogout,
                  icon: const Icon(Icons.logout, size: 16, color: Colors.white),
                  label: const Text('Logout'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

