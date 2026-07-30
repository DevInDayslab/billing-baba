import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Signature placeholder with create/upload actions on the business profile.
class MobileBusinessProfileSignatureSection extends StatelessWidget {
  const MobileBusinessProfileSignatureSection({
    super.key,
    this.onCreate,
    this.onUpload,
  });

  final VoidCallback? onCreate;
  final VoidCallback? onUpload;

  static const _actionBlue = Color(0xFF42A5F5);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Signature',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          height: 120,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadius.mdBorder,
            border: Border.all(
              color: AppColors.textSecondary.withValues(alpha: 0.35),
              width: 1.2,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.draw_outlined,
                color: AppColors.textSecondary.withValues(alpha: 0.55),
                size: 28,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Create your signature here',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: _ActionChip(
                label: 'Create',
                onTap: onCreate,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _ActionChip(
                label: 'Upload',
                onTap: onUpload,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.label,
    this.onTap,
  });

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: MobileBusinessProfileSignatureSection._actionBlue
          .withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: Center(
            child: Text(
              label,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: MobileBusinessProfileSignatureSection._actionBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
