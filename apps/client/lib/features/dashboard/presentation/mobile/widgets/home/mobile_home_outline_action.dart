import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Compact outline action button (Filter, Download).
class MobileHomeOutlineAction extends StatelessWidget {
  const MobileHomeOutlineAction({
    required this.icon,
    required this.label,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Material(
      color: AppColors.surface,
      borderRadius: AppRadius.buttonBorder,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.buttonBorder,
        child: Ink(
          width: 84,
          decoration: BoxDecoration(
            borderRadius: AppRadius.buttonBorder,
            border: Border.all(color: AppColors.chipBorder),
            boxShadow: AppShadows.subtle,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: 8,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: primary),
              const SizedBox(width: 4),
              Text(
                label,
                style: AppTypography.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
