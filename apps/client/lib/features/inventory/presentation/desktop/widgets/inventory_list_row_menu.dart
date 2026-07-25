import 'package:billing_baba/features/sales/presentation/desktop/widgets/shared/sales_action_menu_button.dart';
import 'package:flutter/material.dart';

/// Three-dot row menu anchored to the trigger icon (filter-dropdown style).
class InventoryListRowMenu extends StatelessWidget {
  const InventoryListRowMenu({
    this.items,
    this.onSelected,
    super.key,
  });

  final List<String>? items;
  final ValueChanged<String>? onSelected;

  static const _defaultItems = ['Edit', 'Delete'];

  @override
  Widget build(BuildContext context) {
    final labels = items ?? _defaultItems;
    return SalesActionMenuButton(
      items: [
        for (final label in labels)
          SalesActionMenuItem(
            label: label,
            onSelected: () async {
              if (onSelected != null) {
                onSelected!(label);
                return;
              }
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$label coming soon')),
              );
            },
          ),
      ],
    );
  }
}
