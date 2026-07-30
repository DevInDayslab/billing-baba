import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Vyapar-style outlined field with a floating label on the border.
class MobileBusinessProfileLabeledField extends StatelessWidget {
  const MobileBusinessProfileLabeledField({
    required this.label,
    required this.controller,
    super.key,
    this.hintText,
    this.errorText,
    this.keyboardType,
    this.minLines = 1,
    this.maxLines = 1,
    this.textCapitalization = TextCapitalization.none,
    this.suffix,
    this.onChanged,
    this.inputFormatters,
  });

  final String label;
  final TextEditingController controller;
  final String? hintText;
  final String? errorText;
  final TextInputType? keyboardType;
  final int minLines;
  final int maxLines;
  final TextCapitalization textCapitalization;
  final Widget? suffix;
  final VoidCallback? onChanged;
  final List<TextInputFormatter>? inputFormatters;

  static const _borderColor = Color(0xFFD7DCE3);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasError = errorText != null && errorText!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            TextField(
              controller: controller,
              onChanged: onChanged == null ? null : (_) => onChanged!(),
              keyboardType: keyboardType,
              minLines: minLines,
              maxLines: maxLines,
              textCapitalization: textCapitalization,
              inputFormatters: inputFormatters,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: hintText,
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  suffix == null ? AppSpacing.lg : AppSpacing.md,
                  suffix == null ? AppSpacing.md : 96,
                  AppSpacing.md,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: AppRadius.mdBorder,
                  borderSide: BorderSide(
                    color: hasError ? AppColors.error : _borderColor,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: AppRadius.mdBorder,
                  borderSide: BorderSide(
                    color: hasError ? AppColors.error : AppColors.primary,
                    width: 1.4,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: AppRadius.mdBorder,
                  borderSide: const BorderSide(color: AppColors.error),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: AppRadius.mdBorder,
                  borderSide: const BorderSide(color: AppColors.error, width: 1.4),
                ),
              ),
            ),
            if (suffix != null)
              Positioned(
                top: 0,
                bottom: 0,
                right: AppSpacing.sm,
                child: Center(child: suffix),
              ),
            Positioned(
              left: AppSpacing.md,
              top: -8,
              child: Container(
                color: AppColors.surface,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: hasError
                        ? AppColors.error
                        : AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
        if (hasError) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            errorText!,
            style: theme.textTheme.bodySmall?.copyWith(color: AppColors.error),
          ),
        ],
      ],
    );
  }
}
