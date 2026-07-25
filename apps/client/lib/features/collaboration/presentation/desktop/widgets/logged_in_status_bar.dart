import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class LoggedInStatusBar extends StatelessWidget {
  const LoggedInStatusBar({
    required this.loggedInPhone,
    super.key,
  });

  final String loggedInPhone;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          'Currently synced as',
          style: TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary.withValues(alpha: 0.9),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          loggedInPhone,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        const Icon(
          Icons.cloud_done_outlined,
          size: 16,
          color: Color(0xFF2E7D32),
        ),
      ],
    );
  }
}
