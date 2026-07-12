import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/inventory_styles.dart';
import 'package:flutter/material.dart';

export 'inventory_list_row_menu.dart';

class InventoryListHeader extends StatelessWidget {
  const InventoryListHeader({
    required this.columns,
    super.key,
  });

  final List<InventoryListColumn> columns;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 12,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFF5F5F5),
        border: Border(bottom: BorderSide(color: inventoryCardBorder)),
      ),
      child: InventoryListRowLayout(
        flexValues: [for (final column in columns) column.flex],
        children: [
          for (final column in columns)
            _HeaderCell(column: column),
        ],
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
    this.trailing = const SizedBox(width: 28),
    super.key,
  });

  final List<int> flexValues;
  final List<Widget> children;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    assert(
      flexValues.length == children.length,
      'flexValues and children must have the same length',
    );

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
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell({required this.column});

  final InventoryListColumn column;

  @override
  Widget build(BuildContext context) {
    if (column.trailing != null && !column.alignEnd) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              column.label,
              style: InventoryStyles.listHeaderStyle,
              overflow: TextOverflow.ellipsis,
            ),
          ),
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
          child: Text(
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

class InventoryListColumn {
  const InventoryListColumn({
    required this.label,
    this.flex = 1,
    this.showFilter = false,
    this.alignEnd = false,
    this.leading,
    this.trailing,
  });

  final String label;
  final int flex;
  final bool showFilter;
  final bool alignEnd;
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

