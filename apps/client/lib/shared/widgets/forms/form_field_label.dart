import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_field_decoration.dart';
import 'package:flutter/material.dart';

/// Standard label above a form control.
class FormFieldLabel extends StatelessWidget {
  const FormFieldLabel({
    required this.label,
    this.hasError = false,
    super.key,
  });

  final String label;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: saleFieldLabelStyle.copyWith(
        color: hasError ? AppColors.error : AppColors.textSecondary,
      ),
    );
  }
}
