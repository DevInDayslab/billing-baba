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
  paymentOut,
  expense,
  fixedAssetPurchase,
  saleFa,
  jobWorkOrder,
  posReceipt;

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
    PrintableDocumentKind.expense => 'Expense',
    PrintableDocumentKind.fixedAssetPurchase => 'Fixed Asset Purchase',
    PrintableDocumentKind.saleFa => 'Sale FA',
    PrintableDocumentKind.jobWorkOrder => 'Job Work Order',
    PrintableDocumentKind.posReceipt => 'POS Receipt',
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
    purchaseOrder => true,
    paymentIn ||
    paymentOut ||
    expense ||
    fixedAssetPurchase ||
    saleFa ||
    jobWorkOrder ||
    posReceipt => false,
  };

  /// Voucher documents rendered by the A4 voucher template.
  bool get isVoucher => switch (this) {
    paymentIn ||
    paymentOut ||
    expense ||
    fixedAssetPurchase ||
    saleFa ||
    jobWorkOrder =>
      true,
    saleInvoice ||
    purchaseBill ||
    estimate ||
    proformaInvoice ||
    deliveryChallan ||
    creditNote ||
    debitNote ||
    saleOrder ||
    purchaseOrder ||
    posReceipt => false,
  };
}
