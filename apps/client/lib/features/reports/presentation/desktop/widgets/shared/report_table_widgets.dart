import 'dart:math' as math;

import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_card.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_theme.dart';
import 'package:flutter/material.dart';

class ReportTableHeaderCell extends StatelessWidget {
  const ReportTableHeaderCell({
    required this.label,
    this.width,
    this.showFilter = true,
    this.alignment = Alignment.centerLeft,
    super.key,
  });

  final String label;
  final double? width;
  final bool showFilter;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    final child = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            label,
            style: reportTableHeaderStyle,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (showFilter) ...[
          const SizedBox(width: 4),
          Icon(
            Icons.filter_list,
            size: 14,
            color: AppColors.textSecondary.withValues(alpha: 0.7),
          ),
        ],
      ],
    );

    final aligned = Align(alignment: alignment, child: child);
    if (width != null) {
      return SizedBox(width: width, child: aligned);
    }
    return aligned;
  }
}

class ReportTableHeaderRow extends StatelessWidget {
  const ReportTableHeaderRow({
    required this.children,
    this.minWidth = 960,
    super.key,
  });

  final List<Widget> children;
  final double minWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: reportTableHeaderBg,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (!constraints.maxWidth.isFinite) {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: minWidth,
                child: Row(children: children),
              ),
            );
          }

          final tableWidth = math.max(constraints.maxWidth, minWidth);
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: tableWidth,
              child: Row(children: children),
            ),
          );
        },
      ),
    );
  }
}

class ReportTableShell extends StatelessWidget {
  const ReportTableShell({
    required this.header,
    required this.body,
    this.toolbar,
    super.key,
  });

  final Widget? toolbar;
  final Widget header;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    return ReportCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ?toolbar,
          if (toolbar != null)
            const Divider(height: 1, color: reportCardBorder),
          header,
          const Divider(height: 1, color: reportCardBorder),
          body,
        ],
      ),
    );
  }
}
