import 'package:billing_baba/features/inventory/models/inventory_transaction_filters.dart';
import 'package:billing_baba/features/inventory/models/product_transaction_model.dart';

abstract final class InventoryTransactionTableService {
  static List<ProductTransaction> applyFiltersAndSort({
    required List<ProductTransaction> transactions,
    required InventoryTransactionFiltersState filters,
  }) {
    final filtered = transactions.where((transaction) {
      if (filters.typeColumnFilter != null &&
          !filters.typeColumnFilter!.matches(transaction.transactionType)) {
        return false;
      }
      if (filters.invoiceRefColumnFilter != null &&
          !filters.invoiceRefColumnFilter!.matches(
            _invoiceRefLabel(transaction),
          )) {
        return false;
      }
      if (filters.partyColumnFilter != null &&
          !filters.partyColumnFilter!.matches(transaction.partyName)) {
        return false;
      }
      if (filters.dateColumnFilter != null &&
          !filters.dateColumnFilter!.matches(transaction.date)) {
        return false;
      }
      if (filters.quantityColumnFilter != null &&
          !filters.quantityColumnFilter!.matches(transaction.quantity)) {
        return false;
      }
      if (filters.priceColumnFilter != null &&
          !filters.priceColumnFilter!.matches(transaction.pricePerUnit)) {
        return false;
      }
      if (filters.statusColumnFilter != null &&
          !filters.statusColumnFilter!.matches(transaction.status)) {
        return false;
      }
      return true;
    }).toList();

    if (filters.sortDirection == InventoryTransactionSortDirection.none) {
      return filtered;
    }

    final ascending =
        filters.sortDirection == InventoryTransactionSortDirection.ascending;
    final sorted = [...filtered];
    sorted.sort((a, b) {
      final comparison = switch (filters.sortColumn) {
        InventoryTransactionSortColumn.type =>
          a.transactionType.compareTo(b.transactionType),
        InventoryTransactionSortColumn.invoiceRef =>
          _invoiceRefLabel(a).compareTo(_invoiceRefLabel(b)),
        InventoryTransactionSortColumn.party =>
          a.partyName.compareTo(b.partyName),
        InventoryTransactionSortColumn.date => a.date.compareTo(b.date),
        InventoryTransactionSortColumn.quantity =>
          a.quantity.compareTo(b.quantity),
        InventoryTransactionSortColumn.pricePerUnit =>
          a.pricePerUnit.compareTo(b.pricePerUnit),
        InventoryTransactionSortColumn.status =>
          a.status.compareTo(b.status),
      };
      return ascending ? comparison : -comparison;
    });
    return sorted;
  }

  static String _invoiceRefLabel(ProductTransaction transaction) {
    final ref = transaction.invoiceRefNo.trim();
    if (ref.isNotEmpty) return ref;
    return transaction.referenceNo.trim();
  }

  static List<String> uniqueTypeOptions(List<ProductTransaction> transactions) {
    return transactions
        .map((transaction) => transaction.transactionType)
        .where((value) => value.trim().isNotEmpty)
        .toSet()
        .toList()
      ..sort();
  }

  static List<String> uniqueStatusOptions(
    List<ProductTransaction> transactions,
  ) {
    return transactions
        .map((transaction) => transaction.status)
        .where((value) => value.trim().isNotEmpty)
        .toSet()
        .toList()
      ..sort();
  }
}
