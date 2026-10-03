import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:lucide_icons_flutter/lucide_icons.dart';

class MobileFormSection extends StatelessWidget {
  const MobileFormSection({
    required this.title,
    required this.children,
    super.key,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: AppTypography.inter(
            fontSize: AppTypography.subtitleSize,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        ...children,
      ],
    );
  }
}

class MobileFormTextField extends StatelessWidget {
  const MobileFormTextField({
    required this.label,
    super.key,
    this.controller,
    this.value,
    this.onChanged,
    this.hint,
    this.keyboardType,
    this.readOnly = false,
    this.maxLines = 1,
    this.errorText,
    this.onTap,
    this.suffixIcon,
    this.inputFormatters,
  });

  final String label;
  final TextEditingController? controller;
  final String? value;
  final ValueChanged<String>? onChanged;
  final String? hint;
  final TextInputType? keyboardType;
  final bool readOnly;
  final int maxLines;
  final String? errorText;
  final VoidCallback? onTap;
  final Widget? suffixIcon;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.inter(
              fontSize: AppTypography.captionSize,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          TextField(
            controller: controller,
            readOnly: readOnly,
            onChanged: onChanged,
            onTap: onTap,
            maxLines: maxLines,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            decoration: InputDecoration(
              hintText: hint,
              filled: true,
              fillColor: AppColors.surface,
              errorText: errorText,
              suffixIcon: suffixIcon,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MobileFormPickerField extends StatelessWidget {
  const MobileFormPickerField({
    required this.label,
    required this.value,
    required this.onTap,
    super.key,
    this.errorText,
    this.placeholder = 'Select',
  });

  final String label;
  final String value;
  final VoidCallback onTap;
  final String? errorText;
  final String placeholder;

  @override
  Widget build(BuildContext context) {
    final display = value.trim().isEmpty ? placeholder : value;
    return MobileFormTextField(
      label: label,
      value: display,
      readOnly: true,
      onTap: onTap,
      errorText: errorText,
      suffixIcon: const Icon(LucideIcons.chevronRight),
    );
  }
}

Future<DateTime?> showMobileDatePicker(
  BuildContext context, {
  DateTime? initialDate,
}) async {
  final now = DateTime.now();
  final picked = await showDatePicker(
    context: context,
    initialDate: initialDate ?? now,
    firstDate: DateTime(now.year - 5),
    lastDate: DateTime(now.year + 5),
  );
  return picked;
}
