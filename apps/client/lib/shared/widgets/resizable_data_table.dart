import 'dart:math' as math;

import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/core/theme/list_panel_theme.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

const _defaultMaxColumnWidth = 420.0;
const _gridBorderColor = Color(0xFFE0E0E0);
const _resizeGripWidth = 6.0;
const _headerHeight = 36.0;
const _rowHeight = 44.0;

class ResizableDataColumn {
  const ResizableDataColumn({
    required this.header,
    required this.initialWidth,
    this.minWidth = 48,
    this.maxWidth = _defaultMaxColumnWidth,
    this.resizable = true,
  });

  final Widget header;
  final double initialWidth;
  final double minWidth;
  final double maxWidth;
  final bool resizable;
}

class ResizableDataRow {
  const ResizableDataRow({
    required this.cells,
    this.backgroundColor,
    this.isSelected = false,
    this.onTap,
  });

  final List<Widget> cells;
  final Color? backgroundColor;
  final bool isSelected;
  final VoidCallback? onTap;
}

/// Excel-style table: fixed column widths, drag right border to resize one column,
/// columns to the right shift horizontally, horizontal scroll when wider than viewport.
class ResizableDataTable extends StatefulWidget {
  const ResizableDataTable({
    required this.columns,
    required this.rows,
    this.headerBackgroundColor = const Color(0xFFF5F7FA),
    this.rowBorderColor = _gridBorderColor,
    this.shrinkToFit = false,
    this.expandToFill = true,
    super.key,
  });

  final List<ResizableDataColumn> columns;
  final List<ResizableDataRow> rows;
  final Color headerBackgroundColor;
  final Color rowBorderColor;

  /// When true, proportionally narrows columns to fit the viewport instead of
  /// showing a horizontal scrollbar (until the user manually resizes a column).
  final bool shrinkToFit;

  /// When true, grows columns to use extra viewport width. When false, columns
  /// stay at their natural width (still shrink-to-fit when [shrinkToFit]).
  final bool expandToFill;

  @override
  State<ResizableDataTable> createState() => _ResizableDataTableState();
}

class _ResizableDataTableState extends State<ResizableDataTable> {
  late final ScrollController _horizontalScrollController;
  late List<double> _columnWidths;
  int? _activeResizeColumnIndex;
  bool _hasManualResize = false;

  @override
  void initState() {
    super.initState();
    _horizontalScrollController = ScrollController();
    _columnWidths = [
      for (final column in widget.columns) column.initialWidth,
    ];
  }

  @override
  void didUpdateWidget(covariant ResizableDataTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.columns.length != widget.columns.length) {
      _columnWidths = [
        for (final column in widget.columns) column.initialWidth,
      ];
      _hasManualResize = false;
    }
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    super.dispose();
  }

  double get _tableWidth =>
      _columnWidths.fold<double>(0, (sum, width) => sum + width);

  List<double> _shrinkColumnWidthsToFit(
    List<double> widths,
    double availableWidth,
  ) {
    var total = widths.fold<double>(0, (sum, w) => sum + w);
    if (total <= availableWidth) {
      return widths;
    }

    final fitted = List<double>.from(widths);
    final scale = availableWidth / total;
    for (var i = 0; i < fitted.length; i++) {
      final column = widget.columns[i];
      fitted[i] = (fitted[i] * scale).clamp(column.minWidth, column.maxWidth);
    }

    total = fitted.fold<double>(0, (sum, w) => sum + w);
    var deficit = total - availableWidth;
    var guard = 0;
    while (deficit > 0.5 && guard < 32) {
      guard++;
      final shrinkable = <int>[];
      for (var i = 0; i < fitted.length; i++) {
        if (fitted[i] > widget.columns[i].minWidth) {
          shrinkable.add(i);
        }
      }
      if (shrinkable.isEmpty) {
        break;
      }
      final slice = deficit / shrinkable.length;
      var reduced = 0.0;
      for (final index in shrinkable) {
        final column = widget.columns[index];
        final maxReduce = fitted[index] - column.minWidth;
        final reduce = math.min(slice, maxReduce);
        fitted[index] -= reduce;
        reduced += reduce;
      }
      deficit -= reduced;
      if (reduced < 0.5) {
        break;
      }
    }

    return _normalizeWidthsToTarget(fitted, availableWidth);
  }

  List<double> _normalizeWidthsToTarget(
    List<double> widths,
    double targetWidth,
  ) {
    if (!targetWidth.isFinite || targetWidth <= 0 || widths.isEmpty) {
      return widths;
    }

    var total = widths.fold<double>(0, (sum, w) => sum + w);
    var delta = targetWidth - total;
    if (delta.abs() < 0.5) {
      return widths;
    }

    final normalized = List<double>.from(widths);
    if (delta > 0) {
      for (var i = normalized.length - 1; i >= 0; i--) {
        if (!widget.columns[i].resizable) continue;
        final column = widget.columns[i];
        final room = column.maxWidth - normalized[i];
        if (room <= 0) continue;
        final add = math.min(delta, room);
        normalized[i] += add;
        delta -= add;
        if (delta < 0.5) break;
      }
      return normalized;
    }

    delta = -delta;
    var guard = 0;
    while (delta > 0.5 && guard < 32) {
      guard++;
      final shrinkable = <int>[];
      for (var i = 0; i < normalized.length; i++) {
        if (normalized[i] > widget.columns[i].minWidth) {
          shrinkable.add(i);
        }
      }
      if (shrinkable.isEmpty) break;

      final slice = delta / shrinkable.length;
      var reduced = 0.0;
      for (final index in shrinkable) {
        final column = widget.columns[index];
        final maxReduce = normalized[index] - column.minWidth;
        final reduce = math.min(slice, maxReduce);
        normalized[index] -= reduce;
        reduced += reduce;
      }
      delta -= reduced;
      if (reduced < 0.5) break;
    }

    return normalized;
  }

  /// Expands resizable columns proportionally when the viewport is wider than
  /// the natural table width so the grid fills available space (e.g. when the
  /// sidebar collapses). When shrink-to-fit is enabled, narrows columns to avoid
  /// horizontal scroll when the table is wider than the viewport.
  List<double> _displayColumnWidths(double availableWidth) {
    if (_hasManualResize || !availableWidth.isFinite || availableWidth <= 0) {
      return List<double>.from(_columnWidths);
    }

    final naturalWidth = _tableWidth;
    if (naturalWidth > availableWidth && widget.shrinkToFit) {
      return _shrinkColumnWidthsToFit(
        List<double>.from(_columnWidths),
        availableWidth,
      );
    }

    if (naturalWidth >= availableWidth || !widget.expandToFill) {
      return List<double>.from(_columnWidths);
    }

    var extra = availableWidth - naturalWidth;
    final displayWidths = List<double>.from(_columnWidths);

    while (extra > 0.5) {
      final growableIndices = <int>[];
      var growableTotal = 0.0;

      for (var i = 0; i < widget.columns.length; i++) {
        final column = widget.columns[i];
        if (column.resizable && displayWidths[i] < column.maxWidth) {
          growableIndices.add(i);
          growableTotal += displayWidths[i];
        }
      }

      if (growableIndices.isEmpty || growableTotal <= 0) {
        break;
      }

      var distributed = 0.0;
      for (final index in growableIndices) {
        final column = widget.columns[index];
        final proportion = displayWidths[index] / growableTotal;
        final targetWidth = displayWidths[index] + extra * proportion;
        final nextWidth = targetWidth.clamp(column.minWidth, column.maxWidth);
        distributed += nextWidth - displayWidths[index];
        displayWidths[index] = nextWidth;
      }

      extra -= distributed;
      if (distributed < 0.5) {
        break;
      }
    }

    if (extra > 0.5) {
      for (var i = widget.columns.length - 1; i >= 0; i--) {
        if (!widget.columns[i].resizable) continue;
        displayWidths[i] += extra;
        break;
      }
    }

    return displayWidths;
  }

  double _columnOffset(int columnIndex, List<double> widths) {
    var offset = 0.0;
    for (var i = 0; i < columnIndex; i++) {
      offset += widths[i];
    }
    return offset;
  }

  void _resizeColumn(int columnIndex, double delta) {
    if (delta == 0) return;

    final column = widget.columns[columnIndex];
    final currentWidth = _columnWidths[columnIndex];
    final nextWidth = (currentWidth + delta).clamp(
      column.minWidth,
      column.maxWidth,
    );
    if (nextWidth == currentWidth) return;

    setState(() {
      _hasManualResize = true;
      _columnWidths[columnIndex] = nextWidth;
    });
  }

  @override
  Widget build(BuildContext context) {
    assert(
      widget.rows.every((row) => row.cells.length == widget.columns.length),
      'Each row must have the same number of cells as columns',
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final displayWidths = _displayColumnWidths(availableWidth);
        final displayTableWidth = displayWidths.fold<double>(
          0,
          (sum, width) => sum + width,
        );
        final childWidth = availableWidth.isFinite &&
                !_hasManualResize &&
                widget.expandToFill
            ? math.max(displayTableWidth, availableWidth)
            : displayTableWidth;
        final needsHorizontalScroll =
            availableWidth.isFinite && displayTableWidth > availableWidth;

        final table = SizedBox(
          width: childWidth,
          child: _buildTableBody(displayWidths, constraints),
        );

        if (!needsHorizontalScroll) {
          return table;
        }

        return Scrollbar(
          controller: _horizontalScrollController,
          thumbVisibility: true,
          interactive: true,
          notificationPredicate: (notification) => notification.depth == 0,
          child: SingleChildScrollView(
            controller: _horizontalScrollController,
            scrollDirection: Axis.horizontal,
            dragStartBehavior: DragStartBehavior.down,
            child: table,
          ),
        );
      },
    );
  }

  Widget _buildTableBody(
    List<double> displayWidths,
    BoxConstraints constraints,
  ) {
    final dataRows = [
      for (final row in widget.rows) _buildDataRow(row, displayWidths),
    ];
    final resizeOverlay = _activeResizeColumnIndex == null
        ? null
        : Positioned(
            left:
                _columnOffset(_activeResizeColumnIndex!, displayWidths) +
                displayWidths[_activeResizeColumnIndex!],
            top: 0,
            bottom: 0,
            child: IgnorePointer(
              child: Container(
                width: 2,
                color: AppColors.primary,
              ),
            ),
          );

    final canPinHeader =
        constraints.maxHeight.isFinite &&
        widget.rows.isNotEmpty &&
        constraints.maxHeight > _headerHeight;
    final bodyMaxHeight = canPinHeader
        ? constraints.maxHeight - _headerHeight
        : null;

    final rowsColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: dataRows,
    );

    final body = bodyMaxHeight == null
        ? rowsColumn
        : SizedBox(
            height: bodyMaxHeight,
            child: Scrollbar(
              thumbVisibility: true,
              child: SingleChildScrollView(
                child: rowsColumn,
              ),
            ),
          );

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeaderRow(displayWidths),
            if (widget.rows.isNotEmpty) body,
          ],
        ),
        ?resizeOverlay,
      ],
    );
  }

  Widget _buildHeaderRow(List<double> displayWidths) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: widget.headerBackgroundColor,
        border: Border(
          bottom: BorderSide(color: widget.rowBorderColor),
        ),
      ),
      child: SizedBox(
        height: _headerHeight,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < widget.columns.length; i++)
                  _buildCell(
                    columnWidth: displayWidths[i],
                    child: widget.columns[i].header,
                  ),
              ],
            ),
            for (var i = 0; i < widget.columns.length; i++)
              if (widget.columns[i].resizable)
                Positioned(
                  left:
                      _columnOffset(i, displayWidths) +
                      displayWidths[i] -
                      _resizeGripWidth / 2,
                  top: 0,
                  bottom: 0,
                  width: _resizeGripWidth,
                  child: _ColumnResizeGrip(
                    isActive: _activeResizeColumnIndex == i,
                    onDragStart: () {
                      setState(() => _activeResizeColumnIndex = i);
                    },
                    onDragUpdate: (delta) => _resizeColumn(i, delta),
                    onDragEnd: () {
                      setState(() => _activeResizeColumnIndex = null);
                    },
                  ),
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataRow(ResizableDataRow row, List<double> displayWidths) {
    final backgroundColor = row.isSelected
        ? listPanelSelectedRowColor
        : row.backgroundColor;

    final rowContent = DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border(
          bottom: BorderSide(color: widget.rowBorderColor),
        ),
      ),
      child: SizedBox(
        height: _rowHeight,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < widget.columns.length; i++)
              _buildCell(
                columnWidth: displayWidths[i],
                child: row.cells[i],
              ),
          ],
        ),
      ),
    );

    if (row.onTap == null) {
      return rowContent;
    }

    return Material(
      color: backgroundColor ?? Colors.transparent,
      child: InkWell(
        onTap: row.onTap,
        hoverColor: listPanelSelectedRowColor.withValues(alpha: 0.65),
        child: rowContent,
      ),
    );
  }

  Widget _buildCell({
    required double columnWidth,
    required Widget child,
  }) {
    return SizedBox(
      width: columnWidth,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(
            right: BorderSide(color: _gridBorderColor),
          ),
        ),
        child: ClipRect(child: child),
      ),
    );
  }
}

class _ColumnResizeGrip extends StatefulWidget {
  const _ColumnResizeGrip({
    required this.isActive,
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
  });

  final bool isActive;
  final VoidCallback onDragStart;
  final ValueChanged<double> onDragUpdate;
  final VoidCallback onDragEnd;

  @override
  State<_ColumnResizeGrip> createState() => _ColumnResizeGripState();
}

class _ColumnResizeGripState extends State<_ColumnResizeGrip> {
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.resizeColumn,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragStart: (_) => widget.onDragStart(),
        onHorizontalDragUpdate: (details) {
          widget.onDragUpdate(details.delta.dx);
        },
        onHorizontalDragEnd: (_) => widget.onDragEnd(),
        onHorizontalDragCancel: widget.onDragEnd,
        child: Center(
          child: Container(
            width: widget.isActive ? 2 : 1,
            color: widget.isActive ? AppColors.primary : _gridBorderColor,
          ),
        ),
      ),
    );
  }
}
