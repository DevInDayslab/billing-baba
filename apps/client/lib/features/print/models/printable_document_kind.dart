/// Printable document kinds supported by the print engine.
enum PrintableDocumentKind {
  saleInvoice,
  purchaseBill,
  estimate,
  proformaInvoice,
  deliveryChallan,
  creditNote,
  debitNote,
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
    PrintableDocumentKind.paymentIn => 'Payment In',
    PrintableDocumentKind.paymentOut => 'Payment Out',
  };
}
