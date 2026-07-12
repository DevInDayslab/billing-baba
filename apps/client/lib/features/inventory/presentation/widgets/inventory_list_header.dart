import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/inventory_styles.dart';
import 'package:flutter/material.dart';

export 'inventory_list_row_menu.dart';

/// Header row height when column separators span the full header area.
const inventoryListHeaderHeight = 40.0;

class InventoryListHeader extends StatelessWidget {
  const InventoryListHeader({
    required this.columns,
    this.includeTrailingSpace = true,
    this.showColumnSeparators = true,
    super.key,
  });

  final List<InventoryListColumn> columns;
  final bool includeTrailingSpace;
  final bool showColumnSeparators;

  @override
  Widget build(BuildContext context) {
    final rowLayout = InventoryListRowLayout(
      flexValues: [for (final column in columns) column.flex],
      alignEnds: [for (final column in columns) column.alignEnd],
      showColumnSeparators: showColumnSeparators,
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
        vertical: showColumnSeparators ? 0 : 12,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFF5F5F5),
        border: Border(bottom: BorderSide(color: inventoryCardBorder)),
      ),
      child: showColumnSeparators
          ? SizedBox(height: inventoryListHeaderHeight, child: rowLayout)
          : rowLayout,
    );
  }
}

/// Row layout that mirrors [InventoryListHeader] column spacing so data rows
/// align without sub-pixel overflow.
class InventoryListRowLayout extends StatelessWidget {
  const InventoryListRowLayout({
    required this.flexValues,
    required this.children,
    this.alignEnds,
    this.trailing = const SizedBox(width: 28),
    this.showColumnSeparators = true,
    this.cellVerticalPadding = EdgeInsets.zero,
    super.key,
  });

  final List<int> flexValues;
  final List<Widget> children;
  final List<bool>? alignEnds;
  final Widget trailing;
  final bool showColumnSeparators;
  final EdgeInsets cellVerticalPadding;

  Alignment _cellAlignment(int index) {
    final alignEnd =
        (alignEnds != null && index < alignEnds!.length) && alignEnds![index];
    return alignEnd ? Alignment.centerRight : Alignment.centerLeft;
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
            if (i > 0) const SizedBox(width: AppSpacing.sm),
            Expanded(
              flex: flexValues[i],
              child: children[i],
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
          Expanded(
            flex: flexValues[i],
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(child: _SortableLabel(column: column)),
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
        Expanded(
          child: column.sortable && column.onSort != null
              ? _SortableLabel(column: column)
              : Text(
                  column.label,
                  textAlign: column.alignEnd ? TextAlign.right : TextAlign.left,
                  style: InventoryStyles.listHeaderStyle,
                  overflow: TextOverflow.ellipsis,
                ),
        ),
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

class _SortableLabel extends StatelessWidget {
  const _SortableLabel({required this.column});

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

    if (!column.isSorted) {
      return InkWell(
        onTap: column.onSort,
        borderRadius: BorderRadius.circular(4),
        child: label,
      );
    }

    final sortIcon = Icon(
      column.sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
      size: 14,
      color: Colors.grey.shade500,
    );

    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(child: label),
        const SizedBox(width: 4),
        sortIcon,
      ],
    );

    return InkWell(
      onTap: column.onSort,
      borderRadius: BorderRadius.circular(4),
      child: content,
    );
  }
}

class InventoryListColumn {
  const InventoryListColumn({
    required this.label,
    this.flex = 1,
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
