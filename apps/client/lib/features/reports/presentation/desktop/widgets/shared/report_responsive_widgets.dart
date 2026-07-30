import 'dart:math' as math;

import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_theme.dart';
import 'package:flutter/material.dart';

/// Horizontally scrolls [child] when it is wider than the viewport.
class ReportHorizontalScroll extends StatelessWidget {
  const ReportHorizontalScroll({
    required this.child,
    this.minWidth,
    super.key,
  });

  final Widget child;
  final double? minWidth;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (!constraints.maxWidth.isFinite) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: child,
          );
        }

        final resolvedMinWidth = minWidth ?? constraints.maxWidth;
        final contentWidth = math.max(constraints.maxWidth, resolvedMinWidth);

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: contentWidth,
            child: child,
          ),
        );
      },
    );
  }
}

/// Title with trailing action buttons that wrap on narrow widths.
class ReportTitleActionsRow extends StatelessWidget {
  const ReportTitleActionsRow({
    required this.title,
    this.titleStyle,
    this.actions = const [],
    super.key,
  });

  final String title;
  final TextStyle? titleStyle;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.sm,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          title,
          style:
              titleStyle ??
              const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
        ),
        ...actions,
      ],
    );
  }
}

/// Footer totals that wrap instead of overflowing on narrow widths.
class ReportFooterTotalsBar extends StatelessWidget {
  const ReportFooterTotalsBar({
    required this.items,
    this.backgroundColor = reportTableHeaderBg,
    super.key,
  });

  final List<Widget> items;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: const Border(top: BorderSide(color: reportCardBorder)),
      ),
      child: Wrap(
        spacing: AppSpacing.lg,
        runSpacing: AppSpacing.sm,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: items,
      ),
    );
  }
}
