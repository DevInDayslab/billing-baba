abstract final class PurchaseConstants {
  static const purchaseBillSeries = 'PB';
  static const purchaseOrderSeries = 'PO';
  static const purchaseReturnSeries = 'DN';

  /// API date fields (`due_date`, `expense_date`, query `from`/`to`) expect YYYY-MM-DD.
  static String formatApiDate(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}

enum PurchaseDocumentType {
  purchaseOrder,
  purchaseBill,
  purchaseReturn;

  String get apiValue => switch (this) {
    PurchaseDocumentType.purchaseOrder => 'purchase_order',
    PurchaseDocumentType.purchaseBill => 'purchase_bill',
    PurchaseDocumentType.purchaseReturn => 'purchase_return',
  };

  static PurchaseDocumentType? fromApiValue(String value) => switch (value) {
    'purchase_order' => PurchaseDocumentType.purchaseOrder,
    'purchase_bill' => PurchaseDocumentType.purchaseBill,
    'purchase_return' => PurchaseDocumentType.purchaseReturn,
    _ => null,
  };
}

enum PurchaseDocumentStatus {
  draft,
  finalized,
  cancelled,
  converted;

  String get apiValue => name;

  static PurchaseDocumentStatus? fromApiValue(String value) =>
      PurchaseDocumentStatus.values.cast<PurchaseDocumentStatus?>().firstWhere(
        (status) => status?.name == value,
        orElse: () => null,
      );
}

abstract final class PurchasePaymentModes {
  static String toApi(String uiLabel) => switch (uiLabel) {
    'Cash' => 'cash',
    'UPI' => 'upi',
    'Cheque' => 'cheque',
    'Bank Transfer' => 'bank_transfer',
    'Card' => 'card',
    'Wallet' => 'other',
    'Others' => 'other',
    'Online' => 'upi',
    'Credit' => 'other',
    _ => 'other',
  };

  static String toUi(String apiValue) => switch (apiValue) {
    'cash' => 'Cash',
    'upi' => 'UPI',
    'cheque' => 'Cheque',
    'bank_transfer' => 'Bank Transfer',
    'card' => 'Card',
    _ => 'Cash',
  };
}
