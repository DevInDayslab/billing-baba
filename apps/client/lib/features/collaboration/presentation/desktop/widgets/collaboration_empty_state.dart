import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/collaboration/presentation/desktop/widgets/collaboration_empty_illustration.dart';
import 'package:flutter/material.dart';

class CollaborationEmptyState extends StatelessWidget {
  const CollaborationEmptyState({
    required this.onInvitePressed,
    super.key,
  });

  final VoidCallback onInvitePressed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.lgBorder,
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.xxl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CollaborationEmptyIllustration(),
              const SizedBox(height: AppSpacing.lg),
              const Text(
                'No team members yet',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              const Text(
                'Invite accountants or employees to collaborate on your business.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              FilledButton.icon(
                onPressed: onInvitePressed,
                icon: const Icon(Icons.person_add_outlined, size: 18),
                label: const Text('Invite User'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
