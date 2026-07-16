import 'package:billing_baba/features/print/models/printable_document.dart';
import 'package:billing_baba/features/print/models/printable_document_kind.dart';

/// Layout configuration for a commercial document PDF.
class CommercialDocumentLayoutConfig {
  const CommercialDocumentLayoutConfig({
    required this.title,
    required this.documentNumberLabel,
    required this.partyHeading,
    required this.showGstColumns,
    required this.showTaxSummary,
    required this.showAmountInWords,
    required this.showSignature,
    this.footerNote,
    this.showDueDate = false,
    this.showSupplierInvoiceNumber = false,
    this.emptyPartyLabel = 'Walk-in Customer',
  });

  final String title;
  final String documentNumberLabel;
  final String partyHeading;
  final bool showGstColumns;
  final bool showTaxSummary;
  final bool showAmountInWords;
  final bool showSignature;
  final String? footerNote;
  final bool showDueDate;
  final bool showSupplierInvoiceNumber;
  final String emptyPartyLabel;

  static const _quotationFooterNote =
      'This is a quotation and not a tax invoice. '
      'Prices and availability are subject to change.';

  static CommercialDocumentLayoutConfig forDocument(PrintableDocument document) {
    final kind = document.kind;
    final meta = document.metadata;
    final isGst = meta.isGstFormal;
    final isBillOfSupply = meta.apiDocumentType == 'bill_of_supply';

    return switch (kind) {
      PrintableDocumentKind.saleInvoice => CommercialDocumentLayoutConfig(
        title: isBillOfSupply ? 'BILL OF SUPPLY' : 'TAX INVOICE',
        documentNumberLabel: 'Invoice No',
        partyHeading: 'Bill To',
        showGstColumns: isGst,
        showTaxSummary: isGst,
        showAmountInWords: true,
        showSignature: true,
      ),
      PrintableDocumentKind.purchaseBill => CommercialDocumentLayoutConfig(
        title: 'PURCHASE BILL',
        documentNumberLabel: 'Bill No',
        partyHeading: 'Supplier',
        showGstColumns: isGst,
        showTaxSummary: isGst,
        showAmountInWords: true,
        showSignature: true,
        showDueDate: true,
        showSupplierInvoiceNumber: true,
        emptyPartyLabel: 'Supplier',
      ),
      PrintableDocumentKind.estimate => CommercialDocumentLayoutConfig(
        title: 'QUOTATION',
        documentNumberLabel: 'Quotation No',
        partyHeading: 'Bill To',
        showGstColumns: isGst,
        showTaxSummary: isGst,
        showAmountInWords: true,
        showSignature: true,
        footerNote: _quotationFooterNote,
      ),
      PrintableDocumentKind.proformaInvoice => CommercialDocumentLayoutConfig(
        title: 'PROFORMA INVOICE',
        documentNumberLabel: 'Proforma No',
        partyHeading: 'Bill To',
        showGstColumns: isGst,
        showTaxSummary: isGst,
        showAmountInWords: true,
        showSignature: true,
      ),
      PrintableDocumentKind.deliveryChallan => CommercialDocumentLayoutConfig(
        title: 'DELIVERY CHALLAN',
        documentNumberLabel: 'Challan No',
        partyHeading: 'Ship To',
        showGstColumns: isGst,
        showTaxSummary: false,
        showAmountInWords: false,
        showSignature: true,
      ),
      PrintableDocumentKind.creditNote => CommercialDocumentLayoutConfig(
        title: 'CREDIT NOTE',
        documentNumberLabel: 'Credit Note No',
        partyHeading: 'Bill To',
        showGstColumns: isGst,
        showTaxSummary: isGst,
        showAmountInWords: true,
        showSignature: true,
      ),
      PrintableDocumentKind.debitNote => CommercialDocumentLayoutConfig(
        title: 'DEBIT NOTE',
        documentNumberLabel: 'Debit Note No',
        partyHeading: 'Supplier',
        showGstColumns: isGst,
        showTaxSummary: isGst,
        showAmountInWords: true,
        showSignature: true,
        emptyPartyLabel: 'Supplier',
      ),
      PrintableDocumentKind.saleOrder => CommercialDocumentLayoutConfig(
        title: 'SALE ORDER',
        documentNumberLabel: 'Order No',
        partyHeading: 'Bill To',
        showGstColumns: isGst,
        showTaxSummary: isGst,
        showAmountInWords: false,
        showSignature: true,
      ),
      PrintableDocumentKind.purchaseOrder => CommercialDocumentLayoutConfig(
        title: 'PURCHASE ORDER',
        documentNumberLabel: 'Order No',
        partyHeading: 'Supplier',
        showGstColumns: isGst,
        showTaxSummary: isGst,
        showAmountInWords: false,
        showSignature: true,
        showDueDate: true,
        emptyPartyLabel: 'Supplier',
      ),
      PrintableDocumentKind.paymentIn ||
      PrintableDocumentKind.paymentOut ||
      PrintableDocumentKind.expense ||
      PrintableDocumentKind.fixedAssetPurchase ||
      PrintableDocumentKind.saleFa ||
      PrintableDocumentKind.jobWorkOrder ||
      PrintableDocumentKind.posReceipt =>
        throw StateError('Voucher documents use A4VoucherTemplate'),
    };
  }
}
