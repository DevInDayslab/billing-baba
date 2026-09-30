import 'package:billing_baba/features/inventory/models/item_model.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/inventory_bulk_item_dialogs.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/shared/sales_action_menu_button.dart';
import 'package:flutter/material.dart';

List<SalesActionMenuItem> buildInventoryItemBulkMenuItems({
  required BuildContext context,
  required ItemType itemType,
}) {
  return [
    SalesActionMenuItem(
      label: 'Bulk Inactive',
      onSelected: () async {
        if (!context.mounted) return;
        await showBulkInactiveItemsDialog(context, itemType: itemType);
      },
    ),
    SalesActionMenuItem(
      label: 'Bulk Active',
      onSelected: () async {
        if (!context.mounted) return;
        await showBulkActiveItemsDialog(context, itemType: itemType);
      },
    ),
    SalesActionMenuItem(
      label: 'Bulk Assign Code',
      onSelected: () async {
        if (!context.mounted) return;
        await showBulkAssignCodeDialog(context, itemType: itemType);
      },
    ),
    SalesActionMenuItem(
      label: 'Assign Units',
      onSelected: () async {
        if (!context.mounted) return;
        await showBulkAssignUnitsDialog(context, itemType: itemType);
      },
    ),
    SalesActionMenuItem(
      label: 'Bulk Update Items',
      onSelected: () async {
        if (!context.mounted) return;
        await showBulkUpdateItemsDialog(context, itemType: itemType);
      },
    ),
  ];
}
