import 'package:billing_baba/features/inventory/models/item_model.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/inventory_detail_header.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/inventory_item_detail_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Product ledger detail panel — thin wrapper over the shared item detail panel.
class ProductDetailPanel extends ConsumerWidget {
  const ProductDetailPanel({
    required this.itemId,
    required this.fallbackItem,
    super.key,
  });

  final String itemId;
  final InventoryItem fallbackItem;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InventoryItemDetailPanel(
      itemId: itemId,
      fallbackItem: fallbackItem,
      mode: InventoryDetailHeaderMode.product,
    );
  }
}
