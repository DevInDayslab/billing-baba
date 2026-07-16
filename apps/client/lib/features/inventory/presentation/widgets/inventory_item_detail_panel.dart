import 'package:billing_baba/features/inventory/models/item_model.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/adjust_stock_dialog.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/inventory_detail_header.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/inventory_transactions_table.dart';
import 'package:billing_baba/features/inventory/providers/inventory_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Canonical right-panel ledger workspace for Products and Services.
class InventoryItemDetailPanel extends ConsumerWidget {
  const InventoryItemDetailPanel({
    required this.itemId,
    required this.fallbackItem,
    required this.mode,
    super.key,
  });

  final String itemId;
  final InventoryItem fallbackItem;
  final InventoryDetailHeaderMode mode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(productDetailProvider(itemId));
    final displayItem = detailAsync.value ?? fallbackItem;
    final stockSummary = mode == InventoryDetailHeaderMode.product
        ? ref.watch(productStockSummaryProvider(itemId))
        : null;
    final contextData = ref.watch(productDetailContextProvider(itemId));
    final unitLabel = displayItem.baseUnitShortName ?? 'pcs';

    return Column(
      key: ValueKey(itemId),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InventoryDetailHeader(
          item: displayItem,
          mode: mode,
          stockSummary: stockSummary,
          categoryName: contextData.categoryName,
          actionLabel: mode == InventoryDetailHeaderMode.product
              ? 'Adjust Stock'
              : null,
          onAction: mode == InventoryDetailHeaderMode.product
              ? () => showAdjustStockDialog(context, item: displayItem)
              : null,
        ),
        const Divider(height: 1, thickness: 1),
        Expanded(
          child: InventoryTransactionsTable(
            itemId: itemId,
            unitLabel: unitLabel,
          ),
        ),
      ],
    );
  }
}
