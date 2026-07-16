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
  const factory PrintRequest.saleOrder(String id) = SaleOrderPrintRequest;
  const factory PrintRequest.purchaseOrder(String id) =
      PurchaseOrderPrintRequest;
  const factory PrintRequest.paymentIn(String id) = PaymentInPrintRequest;
  const factory PrintRequest.paymentOut(String id) = PaymentOutPrintRequest;
  const factory PrintRequest.expense(String id) = ExpensePrintRequest;
  const factory PrintRequest.fixedAssetPurchase(String id) =
      FixedAssetPurchasePrintRequest;
  const factory PrintRequest.saleFa(String id) = SaleFaPrintRequest;
  const factory PrintRequest.jobWorkOrder(String id) = JobWorkOrderPrintRequest;

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

final class SaleOrderPrintRequest extends PrintRequest {
  const SaleOrderPrintRequest(this.id);

  @override
  final String id;

  @override
  PrintableDocumentKind get kind => PrintableDocumentKind.saleOrder;
}

final class PurchaseOrderPrintRequest extends PrintRequest {
  const PurchaseOrderPrintRequest(this.id);

  @override
  final String id;

  @override
  PrintableDocumentKind get kind => PrintableDocumentKind.purchaseOrder;
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

final class ExpensePrintRequest extends PrintRequest {
  const ExpensePrintRequest(this.id);

  @override
  final String id;

  @override
  PrintableDocumentKind get kind => PrintableDocumentKind.expense;
}

final class FixedAssetPurchasePrintRequest extends PrintRequest {
  const FixedAssetPurchasePrintRequest(this.id);

  @override
  final String id;

  @override
  PrintableDocumentKind get kind => PrintableDocumentKind.fixedAssetPurchase;
}

final class SaleFaPrintRequest extends PrintRequest {
  const SaleFaPrintRequest(this.id);

  @override
  final String id;

  @override
  PrintableDocumentKind get kind => PrintableDocumentKind.saleFa;
}

final class JobWorkOrderPrintRequest extends PrintRequest {
  const JobWorkOrderPrintRequest(this.id);

  @override
  final String id;

  @override
  PrintableDocumentKind get kind => PrintableDocumentKind.jobWorkOrder;
}
