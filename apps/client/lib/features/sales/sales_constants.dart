abstract final class SalesConstants {
  static const defaultDocumentSeries = 'INV';
  static const estimateSeries = 'EST';
  static const saleOrderSeries = 'SO';
  static const challanSeries = 'DC';
  static const creditNoteSeries = 'CN';
  static const proformaSeries = 'PI';
  static const posSeries = 'POS';
}

enum SalesDocumentType {
  estimate,
  saleOrder,
  deliveryChallan,
  taxInvoice,
  billOfSupply,
  normalInvoice,
  pos,
  salesReturn;

  String get apiValue => switch (this) {
    SalesDocumentType.estimate => 'estimate',
    SalesDocumentType.saleOrder => 'sale_order',
    SalesDocumentType.deliveryChallan => 'delivery_challan',
    SalesDocumentType.taxInvoice => 'tax_invoice',
    SalesDocumentType.billOfSupply => 'bill_of_supply',
    SalesDocumentType.normalInvoice => 'normal_invoice',
    SalesDocumentType.pos => 'pos',
    SalesDocumentType.salesReturn => 'sales_return',
  };

  static SalesDocumentType? fromApiValue(String value) => switch (value) {
    'estimate' => SalesDocumentType.estimate,
    'sale_order' => SalesDocumentType.saleOrder,
    'delivery_challan' => SalesDocumentType.deliveryChallan,
    'tax_invoice' => SalesDocumentType.taxInvoice,
    'bill_of_supply' => SalesDocumentType.billOfSupply,
    'normal_invoice' => SalesDocumentType.normalInvoice,
    'pos' => SalesDocumentType.pos,
    'sales_return' => SalesDocumentType.salesReturn,
    _ => null,
  };
}

abstract final class SalesPaymentModes {
  static String toApi(String uiLabel) => switch (uiLabel) {
    'Cash' => 'cash',
    'UPI' => 'upi',
    'Cheque' => 'cheque',
    'Bank Transfer' => 'bank_transfer',
    'Online' => 'upi',
    'Credit' => 'other',
    'Card' => 'card',
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

enum SalesDocumentStatus {
  draft,
  finalized,
  cancelled,
  converted;

  String get apiValue => name;

  static SalesDocumentStatus? fromApiValue(String value) =>
      SalesDocumentStatus.values.cast<SalesDocumentStatus?>().firstWhere(
        (status) => status?.name == value,
        orElse: () => null,
      );
}
