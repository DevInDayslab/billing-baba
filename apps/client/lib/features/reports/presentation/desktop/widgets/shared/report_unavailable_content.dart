import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Placeholder for reports that require accounting modules not yet available.
class ReportUnavailableContent extends StatelessWidget {
  const ReportUnavailableContent({
    required this.reportName,
    this.description,
    super.key,
  });

  final String reportName;
  final String? description;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.hourglass_empty_outlined,
                size: 56,
                color: AppColors.textSecondary.withValues(alpha: 0.5),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                reportName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                description ??
                    'This report is not available yet. It will be enabled '
                        'when the accounting module is ready.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.45,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
