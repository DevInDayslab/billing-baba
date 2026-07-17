import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/inventory_styles.dart';
import 'package:flutter/material.dart';

export 'inventory_list_row_menu.dart';

/// Header row height when column separators span the full header area.
const inventoryListHeaderHeight = 40.0;

/// Shorter header variant for compact list panels (e.g. parties).
const inventoryListHeaderCompactHeight = 30.0;

class InventoryListHeader extends StatelessWidget {
  const InventoryListHeader({
    required this.columns,
    this.includeTrailingSpace = true,
    this.showColumnSeparators = true,
    this.dividerAfterColumnIndex,
    this.height = inventoryListHeaderHeight,
    super.key,
  });

  final List<InventoryListColumn> columns;
  final bool includeTrailingSpace;
  final bool showColumnSeparators;

  /// When [showColumnSeparators] is false, draws a vertical divider after the
  /// column at this index (e.g. `0` between the first and second columns).
  final int? dividerAfterColumnIndex;
  final double height;

  @override
  Widget build(BuildContext context) {
    final isCompact = height < inventoryListHeaderHeight;
    final rowLayout = InventoryListRowLayout(
      flexValues: [for (final column in columns) column.flex],
      fixedWidths: [for (final column in columns) column.fixedWidth],
      alignEnds: [for (final column in columns) column.alignEnd],
      showColumnSeparators: showColumnSeparators,
      dividerAfterColumnIndex:
          showColumnSeparators ? null : dividerAfterColumnIndex,
      cellVerticalPadding: showColumnSeparators
          ? const EdgeInsets.symmetric(vertical: 12)
          : EdgeInsets.zero,
      trailing: includeTrailingSpace
          ? const SizedBox(width: 28)
          : const SizedBox.shrink(),
      children: [
        for (final column in columns) _HeaderCell(column: column),
      ],
    );

    return Container(
      clipBehavior: Clip.hardEdge,
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: showColumnSeparators ? 0 : (isCompact ? 6 : 12),
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFF5F5F5),
        border: Border(bottom: BorderSide(color: inventoryCardBorder)),
      ),
      child: SizedBox(
        height: height,
        child: rowLayout,
      ),
    );
  }
}

/// Row layout that mirrors [InventoryListHeader] column spacing so data rows
/// align without sub-pixel overflow.
class InventoryListRowLayout extends StatelessWidget {
  const InventoryListRowLayout({
    required this.flexValues,
    required this.children,
    this.fixedWidths,
    this.alignEnds,
    this.trailing = const SizedBox(width: 28),
    this.showColumnSeparators = true,
    this.dividerAfterColumnIndex,
    this.cellVerticalPadding = EdgeInsets.zero,
    super.key,
  });

  final List<int> flexValues;
  final List<Widget> children;
  final List<double?>? fixedWidths;
  final List<bool>? alignEnds;
  final Widget trailing;
  final bool showColumnSeparators;
  final int? dividerAfterColumnIndex;
  final EdgeInsets cellVerticalPadding;

  Alignment _cellAlignment(int index) {
    final alignEnd =
        (alignEnds != null && index < alignEnds!.length) && alignEnds![index];
    return alignEnd ? Alignment.centerRight : Alignment.centerLeft;
  }

  Widget _columnChild({
    required int index,
    required Widget child,
  }) {
    final fixedWidth = fixedWidths != null && index < fixedWidths!.length
        ? fixedWidths![index]
        : null;

    if (fixedWidth != null) {
      return SizedBox(width: fixedWidth, child: child);
    }

    return Expanded(
      flex: flexValues[index],
      child: child,
    );
  }

  Widget _wrapColumnChild({
    required int index,
    required Widget child,
  }) {
    if (dividerAfterColumnIndex == index) {
      return DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(
            right: BorderSide(color: inventoryCardBorder),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(right: AppSpacing.sm),
          child: child,
        ),
      );
    }

    return child;
  }

  @override
  Widget build(BuildContext context) {
    assert(
      flexValues.length == children.length,
      'flexValues and children must have the same length',
    );

    if (!showColumnSeparators) {
      return Row(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0 &&
                !(dividerAfterColumnIndex != null &&
                    dividerAfterColumnIndex == i - 1))
              const SizedBox(width: AppSpacing.sm),
            _columnChild(
              index: i,
              child: _wrapColumnChild(index: i, child: children[i]),
            ),
          ],
          trailing,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < children.length; i++)
          _columnChild(
            index: i,
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: i < children.length - 1
                    ? const Border(
                        right: BorderSide(color: inventoryCardBorder),
                      )
                    : null,
              ),
              child: Padding(
                padding: cellVerticalPadding.add(
                  EdgeInsets.only(
                    left: i == 0 ? 0 : AppSpacing.sm,
                    right: i < children.length - 1 ? AppSpacing.sm : 0,
                  ),
                ),
                child: Align(
                  alignment: _cellAlignment(i),
                  child: children[i],
                ),
              ),
            ),
          ),
        trailing,
      ],
    );
  }
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell({required this.column});

  final InventoryListColumn column;

  @override
  Widget build(BuildContext context) {
    if (column.trailing != null) {
      return Row(
        children: [
          Expanded(child: _SortableHeaderContent(column: column)),
          column.trailing!,
        ],
      );
    }

    return Row(
      children: [
        if (column.leading != null) ...[
          column.leading!,
          const SizedBox(width: 4),
        ],
        Expanded(child: _SortableHeaderContent(column: column)),
        if (column.showFilter) ...[
          const SizedBox(width: 4),
          Icon(
            Icons.filter_list,
            size: 14,
            color: Colors.grey.shade500,
          ),
        ],
      ],
    );
  }
}

class _SortableHeaderContent extends StatelessWidget {
  const _SortableHeaderContent({required this.column});

  final InventoryListColumn column;

  @override
  Widget build(BuildContext context) {
    final label = Text(
      column.label,
      textAlign: TextAlign.left,
      style: InventoryStyles.listHeaderStyle,
      overflow: TextOverflow.ellipsis,
    );

    if (!column.sortable || column.onSort == null) {
      return label;
    }

    final sortIcon = column.isSorted
        ? Icon(
            column.sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
            size: 14,
            color: Colors.grey.shade500,
          )
        : null;

    final labelRow = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(child: label),
        if (sortIcon != null) ...[
          const SizedBox(width: 4),
          sortIcon,
        ],
      ],
    );

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: column.onSort,
        behavior: HitTestBehavior.opaque,
        child: Align(
          alignment: Alignment.centerLeft,
          widthFactor: 1,
          child: labelRow,
        ),
      ),
    );
  }
}

class InventoryListColumn {
  const InventoryListColumn({
    required this.label,
    this.flex = 1,
    this.fixedWidth,
    this.showFilter = false,
    this.alignEnd = false,
    this.sortable = false,
    this.isSorted = false,
    this.sortAscending = true,
    this.onSort,
    this.leading,
    this.trailing,
  });

  final String label;
  final int flex;

  /// When set, this column uses a fixed width instead of [flex].
  final double? fixedWidth;
  final bool showFilter;

  /// When true, data cells in this column are right-aligned. Headers are
  /// always left-aligned.
  final bool alignEnd;
  final bool sortable;
  final bool isSorted;
  final bool sortAscending;
  final VoidCallback? onSort;
  final Widget? leading;
  final Widget? trailing;
}

class InventoryListEmptyState extends StatelessWidget {
  const InventoryListEmptyState({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Text(message, style: InventoryStyles.emptyStateStyle),
      ),
    );
  }
}
