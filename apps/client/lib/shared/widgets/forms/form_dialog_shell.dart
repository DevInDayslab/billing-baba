import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/shared/widgets/forms/form_spacing.dart';
import 'package:flutter/material.dart';

/// Responsive width tier for entity add/edit modals.
enum FormDialogSize {
  compact,
  medium,
  large,
}

/// Shared responsive shell for ERP add/edit dialogs.
class FormDialogShell extends StatelessWidget {
  const FormDialogShell({
    required this.child,
    this.size = FormDialogSize.large,
    this.maxWidth,
    this.maxHeightFactor,
    super.key,
  });

  final Widget child;
  final FormDialogSize size;
  final double? maxWidth;
  final double? maxHeightFactor;

  double get _maxWidth => switch (size) {
    FormDialogSize.compact => FormSpacing.dialogCompactMaxWidth,
    FormDialogSize.medium => FormSpacing.dialogMediumMaxWidth,
    FormDialogSize.large => FormSpacing.dialogMaxWidth,
  };

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.sizeOf(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: screen.width < 640 ? AppSpacing.sm : AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? _maxWidth,
          maxHeight:
              screen.height *
              (maxHeightFactor ?? FormSpacing.dialogMaxHeightFactor),
        ),
        child: child,
      ),
    );
  }
}

/// Shows [child] inside a responsive [FormDialogShell].
Future<T?> showFormDialog<T>({
  required BuildContext context,
  required Widget child,
  FormDialogSize size = FormDialogSize.large,
  double? maxWidth,
  double? maxHeightFactor,
  bool barrierDismissible = true,
}) {
  return showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (context) => FormDialogShell(
      size: size,
      maxWidth: maxWidth,
      maxHeightFactor: maxHeightFactor,
      child: child,
    ),
  );
}
