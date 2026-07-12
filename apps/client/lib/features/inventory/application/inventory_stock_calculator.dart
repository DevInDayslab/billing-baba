import 'package:billing_baba/features/inventory/models/product_transaction_model.dart';

abstract final class InventoryStockCalculator {
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
      if (transaction.movementType == 'purchase' && transaction.pricePerUnit > 0) {
        return transaction.pricePerUnit;
      }
    }
    return null;
  }
}
