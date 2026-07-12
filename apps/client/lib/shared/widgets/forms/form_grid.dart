import 'package:billing_baba/shared/widgets/forms/form_spacing.dart';
import 'package:flutter/material.dart';

/// A cell in a [FormGrid] with a 1–12 column span.
class FormGridCell {
  const FormGridCell({
    required this.span,
    required this.child,
  }) : assert(
         span >= 1 && span <= FormSpacing.columns,
         'FormGridCell.span must be between 1 and ${FormSpacing.columns}',
       );

  final int span;
  final Widget child;
}

/// 12-column responsive form grid.
///
/// On widths below [FormSpacing.narrowBreakpoint], cells stack full-width.
class FormGrid extends StatelessWidget {
  const FormGrid({
    required this.cells,
    this.rowGap = FormSpacing.row,
    this.columnGap = FormSpacing.gutter,
    this.narrowBreakpoint = FormSpacing.narrowBreakpoint,
    super.key,
  });

  final List<FormGridCell> cells;
  final double rowGap;
  final double columnGap;
  final double narrowBreakpoint;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < narrowBreakpoint) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < cells.length; i++) ...[
                if (i > 0) SizedBox(height: rowGap),
                cells[i].child,
              ],
            ],
          );
        }

        final rows = <List<FormGridCell>>[];
        var current = <FormGridCell>[];
        var used = 0;

        for (final cell in cells) {
          if (used + cell.span > FormSpacing.columns && current.isNotEmpty) {
            rows.add(current);
            current = <FormGridCell>[];
            used = 0;
          }
          current.add(cell);
          used += cell.span;
          if (used >= FormSpacing.columns) {
            rows.add(current);
            current = <FormGridCell>[];
            used = 0;
          }
        }
        if (current.isNotEmpty) rows.add(current);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var r = 0; r < rows.length; r++) ...[
              if (r > 0) SizedBox(height: rowGap),
              _FormGridRow(
                cells: rows[r],
                columnGap: columnGap,
              ),
            ],
          ],
        );
      },
    );
  }
}

class _FormGridRow extends StatelessWidget {
  const _FormGridRow({
    required this.cells,
    required this.columnGap,
  });

  final List<FormGridCell> cells;
  final double columnGap;

  @override
  Widget build(BuildContext context) {
    // Use Expanded flex so equal spans render identical widths (no float drift).
    final usedSpan = cells.fold<int>(0, (sum, cell) => sum + cell.span);
    final trailing = FormSpacing.columns - usedSpan;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < cells.length; i++) ...[
          if (i > 0) SizedBox(width: columnGap),
          Expanded(
            flex: cells[i].span,
            child: cells[i].child,
          ),
        ],
        if (trailing > 0) Spacer(flex: trailing),
      ],
    );
  }
}
