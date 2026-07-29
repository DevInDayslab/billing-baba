import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// POS page header with title and settings action.
class PosPageTitleBar extends StatelessWidget {
  const PosPageTitleBar({
    this.onHistoryTap,
    this.onSettingsTap,
    super.key,
  });

  final VoidCallback? onHistoryTap;
  final VoidCallback? onSettingsTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          'POS',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const Spacer(),
        if (onHistoryTap != null)
          IconButton(
            onPressed: onHistoryTap,
            icon: const Icon(Icons.history),
            color: AppColors.textSecondary,
            tooltip: 'History',
          ),
        if (onSettingsTap != null)
          IconButton(
            onPressed: onSettingsTap,
            icon: const Icon(Icons.settings_outlined),
            color: AppColors.textSecondary,
            tooltip: 'Settings',
          ),
      ],
    );
  }
}
