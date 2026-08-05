import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Profile completion label and progress bar for the mobile business profile.
class MobileBusinessProfileCompletionSection extends StatelessWidget {
  const MobileBusinessProfileCompletionSection({
    required this.percent,
    super.key,
  });

  final int percent;

  static const _progressBlue = AppColors.primary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final clamped = percent.clamp(0, 100);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Profile $clamped% complete.',
            style: theme.textTheme.titleSmall?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: clamped / 100,
              minHeight: 6,
              backgroundColor: const Color(0xFFE8ECF1),
              color: _progressBlue,
            ),
          ),
        ],
      ),
    );
  }
}
