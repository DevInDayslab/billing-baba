/// Printable document kinds supported by the print engine.
enum PrintableDocumentKind {
  saleInvoice,
  purchaseBill,
  estimate,
  proformaInvoice,
  deliveryChallan,
  creditNote,
  debitNote,
  saleOrder,
  purchaseOrder,
  paymentIn,
  paymentOut;

  String get label => switch (this) {
    PrintableDocumentKind.saleInvoice => 'Sales Invoice',
    PrintableDocumentKind.purchaseBill => 'Purchase Bill',
    PrintableDocumentKind.estimate => 'Estimate',
    PrintableDocumentKind.proformaInvoice => 'Proforma Invoice',
    PrintableDocumentKind.deliveryChallan => 'Delivery Challan',
    PrintableDocumentKind.creditNote => 'Credit Note',
    PrintableDocumentKind.debitNote => 'Debit Note',
    PrintableDocumentKind.saleOrder => 'Sale Order',
    PrintableDocumentKind.purchaseOrder => 'Purchase Order',
    PrintableDocumentKind.paymentIn => 'Payment In',
    PrintableDocumentKind.paymentOut => 'Payment Out',
  };

  /// Commercial documents rendered by the A4 commercial template.
  bool get isCommercial => switch (this) {
    saleInvoice ||
    purchaseBill ||
    estimate ||
    proformaInvoice ||
    deliveryChallan ||
    creditNote ||
    debitNote ||
    saleOrder ||
    purchaseOrder =>
      true,
    paymentIn || paymentOut => false,
  };
}
