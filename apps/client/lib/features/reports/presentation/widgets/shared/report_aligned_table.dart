import 'dart:math' as math;

import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_table_widgets.dart' show ReportTableHeaderRow;
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_theme.dart';
import 'package:flutter/material.dart';

/// Fixed or flexible column used to keep headers and data rows aligned.
class ReportColumn {
  const ReportColumn.fixed(
    this.width, {
    this.alignment = Alignment.centerLeft,
  }) : flex = 0;

  const ReportColumn.flex({
    this.flex = 1,
    this.alignment = Alignment.centerLeft,
  }) : width = null;

  final double? width;
  final int flex;
  final Alignment alignment;

  bool get isFlex => width == null;
}

/// Header + body in a single horizontal scroll so columns stay aligned.
class ReportSyncScrollTable extends StatelessWidget {
  const ReportSyncScrollTable({
    required this.headerChildren,
    required this.rows,
    this.minWidth = 960,
    this.emptyState,
    super.key,
  });

  final List<Widget> headerChildren;
  final List<Widget> rows;
  final double minWidth;
  final Widget? emptyState;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final tableWidth = constraints.maxWidth.isFinite
            ? math.max(constraints.maxWidth, minWidth)
            : minWidth;

        return ClipRect(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: tableWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _TableHeaderStrip(children: headerChildren),
                  if (rows.isEmpty && emptyState != null)
                    emptyState!
                  else
                    ...rows,
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TableHeaderStrip extends StatelessWidget {
  const _TableHeaderStrip({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: reportTableHeaderBg,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(children: children),
      ),
    );
  }
}

/// Builds a data row whose columns match [ReportTableHeaderRow] / header widgets.
class ReportAlignedDataRow extends StatelessWidget {
  const ReportAlignedDataRow({
    required this.cells,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppSpacing.md,
      vertical: AppSpacing.sm,
    ),
    super.key,
  });

  final List<ReportAlignedCell> cells;
  final EdgeInsets padding;

  static const dataStyle = TextStyle(
    fontSize: 13,
    color: AppColors.textPrimary,
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        children: [
          for (final cell in cells) _buildCell(cell),
        ],
      ),
    );
  }

  Widget _buildCell(ReportAlignedCell cell) {
    final content = DefaultTextStyle(
      style: dataStyle,
      overflow: TextOverflow.ellipsis,
      maxLines: 2,
      child: cell.child,
    );

    final aligned = Align(alignment: cell.alignment, child: content);

    if (cell.flex > 0) {
      return Expanded(flex: cell.flex, child: aligned);
    }

    return SizedBox(width: cell.width, child: aligned);
  }
}

class ReportAlignedCell {
  const ReportAlignedCell({
    required this.child,
    this.width,
    this.flex = 0,
    this.alignment = Alignment.centerLeft,
  }) : assert(width != null || flex > 0, 'Provide width or flex');

  const ReportAlignedCell.flex({
    required this.child,
    this.flex = 1,
    this.alignment = Alignment.centerLeft,
  })  : width = null;

  const ReportAlignedCell.fixed(
    this.width, {
    required this.child,
    this.alignment = Alignment.centerLeft,
  }) : flex = 0;

  final Widget child;
  final double? width;
  final int flex;
  final Alignment alignment;
}

/// Alternating row background for aligned table rows.
class ReportAlignedRowStrip extends StatelessWidget {
  const ReportAlignedRowStrip({
    required this.index,
    required this.child,
    super.key,
  });

  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: index.isEven ? Colors.transparent : reportTableHeaderBg,
        border: const Border(bottom: BorderSide(color: reportCardBorder)),
      ),
      child: child,
    );
  }
}

/// Helper to build header + data from shared column specs.
List<Widget> buildAlignedHeaderRow(List<({String label, ReportColumn col})> specs) {
  return [
    for (final spec in specs)
      if (spec.col.isFlex)
        Expanded(
          flex: spec.col.flex,
          child: ReportAlignedHeaderCell(
            label: spec.label,
            alignment: spec.col.alignment,
          ),
        )
      else
        ReportAlignedHeaderCell(
          label: spec.label,
          width: spec.col.width,
          alignment: spec.col.alignment,
        ),
  ];
}

class ReportAlignedHeaderCell extends StatelessWidget {
  const ReportAlignedHeaderCell({
    required this.label,
    this.width,
    this.alignment = Alignment.centerLeft,
    this.showFilter = true,
    super.key,
  });

  final String label;
  final double? width;
  final Alignment alignment;
  final bool showFilter;

  @override
  Widget build(BuildContext context) {
    final child = Row(
      mainAxisSize: width != null ? MainAxisSize.max : MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            label,
            style: reportTableHeaderStyle.copyWith(fontSize: 11),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            softWrap: true,
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
