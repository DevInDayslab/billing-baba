import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/shared/widgets/forms/form_spacing.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Compact disabled image-upload strip (Vyapar-style).
class ImagePickerPlaceholder extends StatelessWidget {
  const ImagePickerPlaceholder({
    this.title = 'Upload Image',
    this.subtitle = 'PNG JPG WEBP',
    this.hint = 'Coming Soon',
    this.height = FormSpacing.imageHeight,
    super.key,
  });

  final String title;
  final String subtitle;
  final String hint;
  final double height;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.forbidden,
      child: IgnorePointer(
        child: Container(
          width: double.infinity,
          height: height,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFFAFAFA),
            borderRadius: FormSpacing.cardBorderRadius,
            border: Border.all(color: const Color(0xFFE8E8E8)),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  border: Border.all(color: const Color(0xFFE0E0E0)),
                ),
                child: Icon(
                  LucideIcons.image,
                  size: 20,
                  color: AppColors.textSecondary.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$subtitle  ·  $hint',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
