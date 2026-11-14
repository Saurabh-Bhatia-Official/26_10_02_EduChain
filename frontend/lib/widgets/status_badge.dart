import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class StatusBadge extends StatelessWidget {
  final String label;
  final String status;

  const StatusBadge({super.key, required this.label, this.status = 'active'});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    Color border;

    switch (status.toLowerCase()) {
      case 'active':
      case 'completed':
      case 'verified':
      case 'healthy':
        bg = AppColors.successBg;
        fg = AppColors.success;
        border = AppColors.success.withValues(alpha: 0.3);
        break;
      case 'pending':
      case 'scheduled':
      case 'warning':
        bg = AppColors.warningBg;
        fg = AppColors.warning;
        border = AppColors.warning.withValues(alpha: 0.3);
        break;
      case 'inactive':
      case 'cancelled':
      case 'failed':
      case 'error':
        bg = AppColors.errorBg;
        fg = AppColors.error;
        border = AppColors.error.withValues(alpha: 0.3);
        break;
      default:
        bg = AppColors.infoBg;
        fg = AppColors.info;
        border = AppColors.info.withValues(alpha: 0.3);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(shape: BoxShape.circle, color: fg),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
