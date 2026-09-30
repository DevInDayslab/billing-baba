import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/shared/widgets/forms/form_field_label.dart';
import 'package:billing_baba/shared/widgets/forms/form_spacing.dart';
import 'package:flutter/material.dart';

/// Label + fixed-height control + optional error text.
class AppFormField extends StatelessWidget {
  const AppFormField({
    required this.label,
    required this.child,
    this.hasError = false,
    this.errorText,
    this.fixedHeight = true,
    this.floatingLabel = false,
    super.key,
  });

  final String label;
  final Widget child;
  final bool hasError;
  final String? errorText;

  /// When true, wraps [child] in a fixed [FormSpacing.inputHeight] box.
  final bool fixedHeight;

  /// Label is rendered inside the control (floating); no heading above the field.
  final bool floatingLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!floatingLabel) ...[
          FormFieldLabel(label: label, hasError: hasError),
          const SizedBox(height: FormSpacing.label),
        ],
        if (fixedHeight)
          SizedBox(
            height: FormSpacing.inputHeight,
            width: double.infinity,
            child: Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                height: FormSpacing.inputHeight,
                width: double.infinity,
                child: child,
              ),
            ),
          )
        else
          child,
        if (hasError && errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs, left: 2),
            child: Text(
              errorText!,
              style: const TextStyle(
                fontSize: AppTypography.labelSmallSize,
                color: AppColors.error,
              ),
            ),
          ),
      ],
    );
  }
}
