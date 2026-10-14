import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Journal entries list — unlocked by Settings → Accounting → Allow Journal entries.
class JournalEntriesPage extends StatelessWidget {
  const JournalEntriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Journal entries'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.menu_book_outlined,
                  size: 56,
                  color: AppColors.textSecondary.withValues(alpha: 0.5),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'No journal entries yet',
                  textAlign: TextAlign.center,
                  style: AppTypography.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Journal entry creation is enabled for your business. '
                  'Use this area to record manual debit and credit between '
                  'accounts when the feature is available in your build.',
                  textAlign: TextAlign.center,
                  style: AppTypography.inter(
                    fontSize: AppTypography.bodyMediumSize,
                    color: AppColors.textSecondary,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
