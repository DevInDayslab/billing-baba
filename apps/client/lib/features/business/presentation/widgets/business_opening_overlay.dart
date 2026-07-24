import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class BusinessOpeningOverlay extends StatelessWidget {
  const BusinessOpeningOverlay({
    this.message = 'Opening company…',
    this.subtitle = 'Loading dashboard and company data',
    this.opaque = false,
    this.whiteBackground = false,
    super.key,
  });

  final String message;
  final String? subtitle;
  final bool opaque;
  final bool whiteBackground;

  @override
  Widget build(BuildContext context) {
    final backdropColor = !opaque
        ? Colors.black.withValues(alpha: 0.45)
        : whiteBackground
        ? AppColors.surface
        : AppColors.background;

    return AbsorbPointer(
      child: ColoredBox(
        color: backdropColor,
        child: Center(
          child: Material(
            color: AppColors.surface,
            borderRadius: AppRadius.lgBorder,
            elevation: 8,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.lg,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 36,
                    height: 36,
                    child: CircularProgressIndicator(strokeWidth: 3),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    message,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      subtitle!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
