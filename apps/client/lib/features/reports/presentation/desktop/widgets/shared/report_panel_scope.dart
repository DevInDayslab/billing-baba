import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Ensures report panels receive bounded height for [Expanded] children.
class ReportPanelScope extends StatelessWidget {
  const ReportPanelScope({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
      child: SizedBox.expand(child: child),
    );
  }
}
