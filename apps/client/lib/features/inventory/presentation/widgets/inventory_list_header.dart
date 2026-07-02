import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/inventory_styles.dart';
import 'package:flutter/material.dart';

class InventoryListHeader extends StatelessWidget {
  const InventoryListHeader({
    required this.columns,
    super.key,
  });

  final List<InventoryListColumn> columns;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 10,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFF5F5F5),
        border: Border(bottom: BorderSide(color: inventoryCardBorder)),
      ),
      child: Row(
        children: [
          for (var i = 0; i < columns.length; i++) ...[
            if (i > 0) const SizedBox(width: AppSpacing.sm),
            Expanded(
              flex: columns[i].flex,
              child: Row(
                children: [
                  Text(
                    columns[i].label,
                    style: InventoryStyles.listHeaderStyle,
                  ),
                  if (columns[i].showFilter) ...[
                    const SizedBox(width: 4),
                    Icon(
                      Icons.filter_list,
                      size: 14,
                      color: Colors.grey.shade500,
                    ),
                  ],
                ],
              ),
            ),
          ],
          const SizedBox(width: 28),
        ],
      ),
    );
  }
}

class InventoryListColumn {
  const InventoryListColumn({
    required this.label,
    this.flex = 1,
    this.showFilter = false,
  });

  final String label;
  final int flex;
  final bool showFilter;
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

class InventoryListRowMenu extends StatelessWidget {
  const InventoryListRowMenu({
    this.menuItems,
    this.onSelected,
    super.key,
  });

  final List<PopupMenuEntry<String>>? menuItems;
  final ValueChanged<String>? onSelected;

  static const _iconColor = Color(0xFF616161);

  static const _defaultMenuItems = <PopupMenuEntry<String>>[
    PopupMenuItem(value: 'Edit', child: Text('Edit')),
    PopupMenuItem(value: 'Delete', child: Text('Delete')),
  ];

  @override
  Widget build(BuildContext context) {
    return InventoryPopupMenuButton<String>(
      tooltip: 'More options',
      offset: const Offset(0, 28),
      onSelected:
          onSelected ??
          (value) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('$value coming soon')),
            );
          },
      itemBuilder: (context) => menuItems ?? _defaultMenuItems,
      child: const SizedBox(
        width: 28,
        height: 28,
        child: Icon(Icons.more_vert, size: 18, color: _iconColor),
      ),
    );
  }
}
