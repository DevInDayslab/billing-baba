import 'package:billing_baba/features/print/models/printable_document_kind.dart';

/// Strongly typed print request for a single document.
sealed class PrintRequest {
  const PrintRequest();

  const factory PrintRequest.saleInvoice(String id) = SaleInvoicePrintRequest;
  const factory PrintRequest.purchaseBill(String id) = PurchaseBillPrintRequest;
  const factory PrintRequest.estimate(String id) = EstimatePrintRequest;
  const factory PrintRequest.proformaInvoice(String id) =
      ProformaInvoicePrintRequest;
  const factory PrintRequest.deliveryChallan(String id) =
      DeliveryChallanPrintRequest;
  const factory PrintRequest.creditNote(String id) = CreditNotePrintRequest;
  const factory PrintRequest.debitNote(String id) = DebitNotePrintRequest;
  const factory PrintRequest.paymentIn(String id) = PaymentInPrintRequest;
  const factory PrintRequest.paymentOut(String id) = PaymentOutPrintRequest;

  String get id;
  PrintableDocumentKind get kind;
}

final class SaleInvoicePrintRequest extends PrintRequest {
  const SaleInvoicePrintRequest(this.id);

  @override
  final String id;

  @override
  PrintableDocumentKind get kind => PrintableDocumentKind.saleInvoice;
}

final class PurchaseBillPrintRequest extends PrintRequest {
  const PurchaseBillPrintRequest(this.id);

  @override
  final String id;

  @override
  PrintableDocumentKind get kind => PrintableDocumentKind.purchaseBill;
}

final class EstimatePrintRequest extends PrintRequest {
  const EstimatePrintRequest(this.id);

  @override
  final String id;

  @override
  PrintableDocumentKind get kind => PrintableDocumentKind.estimate;
}

final class ProformaInvoicePrintRequest extends PrintRequest {
  const ProformaInvoicePrintRequest(this.id);

  @override
  final String id;

  @override
  PrintableDocumentKind get kind => PrintableDocumentKind.proformaInvoice;
}

final class DeliveryChallanPrintRequest extends PrintRequest {
  const DeliveryChallanPrintRequest(this.id);

  @override
  final String id;

  @override
  PrintableDocumentKind get kind => PrintableDocumentKind.deliveryChallan;
}

final class CreditNotePrintRequest extends PrintRequest {
  const CreditNotePrintRequest(this.id);

  @override
  final String id;

  @override
  PrintableDocumentKind get kind => PrintableDocumentKind.creditNote;
}

final class DebitNotePrintRequest extends PrintRequest {
  const DebitNotePrintRequest(this.id);

  @override
  final String id;

  @override
  PrintableDocumentKind get kind => PrintableDocumentKind.debitNote;
}

final class PaymentInPrintRequest extends PrintRequest {
  const PaymentInPrintRequest(this.id);

  @override
  final String id;

  @override
  PrintableDocumentKind get kind => PrintableDocumentKind.paymentIn;
}

final class PaymentOutPrintRequest extends PrintRequest {
  const PaymentOutPrintRequest(this.id);

  @override
  final String id;

  @override
  PrintableDocumentKind get kind => PrintableDocumentKind.paymentOut;
}
