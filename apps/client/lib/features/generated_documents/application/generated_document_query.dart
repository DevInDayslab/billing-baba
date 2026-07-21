import 'package:billing_baba/features/print/models/print_request.dart';

class GeneratedDocumentQuery {
  const GeneratedDocumentQuery({
    required this.documentKind,
    required this.sourceType,
    required this.sourceId,
  });

  final String documentKind;
  final String sourceType;
  final String sourceId;
}

GeneratedDocumentQuery? generatedDocumentQueryForPrintRequest(
  PrintRequest request,
) {
  return switch (request) {
    SaleInvoicePrintRequest(:final id) ||
    CreditNotePrintRequest(:final id) ||
    SaleOrderPrintRequest(:final id) =>
      GeneratedDocumentQuery(
        documentKind: 'invoice_pdf',
        sourceType: 'sale_document',
        sourceId: id,
      ),
    EstimatePrintRequest(:final id) ||
    ProformaInvoicePrintRequest(:final id) =>
      GeneratedDocumentQuery(
        documentKind: 'estimate_pdf',
        sourceType: 'sale_document',
        sourceId: id,
      ),
    DeliveryChallanPrintRequest(:final id) => GeneratedDocumentQuery(
        documentKind: 'delivery_challan_pdf',
        sourceType: 'sale_document',
        sourceId: id,
      ),
    PurchaseBillPrintRequest(:final id) ||
    DebitNotePrintRequest(:final id) ||
    PurchaseOrderPrintRequest(:final id) =>
      GeneratedDocumentQuery(
        documentKind: 'purchase_pdf',
        sourceType: 'purchase_document',
        sourceId: id,
      ),
    PaymentInPrintRequest(:final id) ||
    PaymentOutPrintRequest(:final id) =>
      GeneratedDocumentQuery(
        documentKind: 'receipt_pdf',
        sourceType: 'payment',
        sourceId: id,
      ),
    _ => null,
  };
}
