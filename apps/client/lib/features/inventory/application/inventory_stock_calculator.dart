import 'package:billing_baba/features/inventory/models/item_model.dart';
import 'package:billing_baba/features/inventory/models/product_transaction_model.dart';

class ItemStockMetrics {
  const ItemStockMetrics({
    required this.physicalQuantity,
    required this.reservedQuantity,
  });

  final double physicalQuantity;
  final double reservedQuantity;

  double get availableForSale =>
      (physicalQuantity - reservedQuantity).clamp(0, double.infinity);
}

abstract final class InventoryStockCalculator {
  static ItemStockMetrics metricsFromItem(InventoryItem? item) {
    final physical = item?.quantity ?? 0;
    final reserved = item?.reservedQuantity ?? 0;
    return ItemStockMetrics(
      physicalQuantity: physical,
      reservedQuantity: reserved,
    );
  }

  static Map<String, double> stockAfterByTransactionId(
    List<ProductTransaction> transactions,
  ) {
    final chronological = [...transactions]
      ..sort((a, b) => a.date.compareTo(b.date));
    final result = <String, double>{};
    var running = 0.0;

    for (final transaction in chronological) {
      running += transaction.signedQuantity;
      result[transaction.id] = running;
    }

    return result;
  }

  static double? lastPurchasePrice(List<ProductTransaction> transactions) {
    for (final transaction in transactions) {
      if (transaction.movementType == 'purchase' &&
          transaction.pricePerUnit > 0) {
        return transaction.pricePerUnit;
      }
    }
    return null;
  }
}
