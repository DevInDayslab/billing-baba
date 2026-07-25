import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_aligned_table.dart';
import 'package:flutter/material.dart';

export 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_aligned_table.dart';

/// @deprecated Use [ReportAlignedDataRow] inside [ReportSyncScrollTable].
class ReportSimpleDataRow extends StatelessWidget {
  const ReportSimpleDataRow({
    required this.cells,
    super.key,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppSpacing.md,
      vertical: AppSpacing.sm,
    ),
  });

  final List<ReportSimpleCell> cells;
  final EdgeInsets padding;

  static const dataStyle = TextStyle(
    fontSize: 13,
    color: AppColors.textPrimary,
  );

  @override
  Widget build(BuildContext context) {
    return ReportAlignedDataRow(
      padding: padding,
      cells: [
        for (final cell in cells)
          cell.expanded
              ? ReportAlignedCell.flex(
                  alignment: cell.alignment,
                  child: cell.child,
                )
              : ReportAlignedCell.fixed(
                  cell.width ?? 80,
                  alignment: cell.alignment,
                  child: cell.child,
                ),
      ],
    );
  }
}

class ReportSimpleCell {
  const ReportSimpleCell({
    required this.child,
    this.width,
    this.alignment = Alignment.centerLeft,
    this.expanded = false,
  });

  final Widget child;
  final double? width;
  final Alignment alignment;
  final bool expanded;
}

/// @deprecated Use [ReportAlignedRowStrip].
class ReportDataRowContainer extends StatelessWidget {
  const ReportDataRowContainer({
    required this.index,
    required this.child,
    super.key,
  });

  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ReportAlignedRowStrip(index: index, child: child);
  }
}
