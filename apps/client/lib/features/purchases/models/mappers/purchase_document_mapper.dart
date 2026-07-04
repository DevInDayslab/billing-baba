import 'package:billing_baba/features/purchases/models/dto/purchase_document_dto.dart';
import 'package:billing_baba/features/purchases/models/payment_out_model.dart';
import 'package:billing_baba/features/purchases/models/purchase_bill_model.dart';
import 'package:billing_baba/features/purchases/models/purchase_order_model.dart';
import 'package:billing_baba/features/purchases/models/purchase_return_model.dart';
import 'package:billing_baba/features/purchases/purchase_constants.dart';

class PurchaseDocumentRecord {
  const PurchaseDocumentRecord({
    required this.id,
    required this.documentType,
    required this.documentStatus,
    required this.documentNumber,
    required this.documentSeries,
    required this.partyId,
    required this.partyName,
    required this.amount,
    required this.balanceDue,
    required this.documentDate,
    this.dueDate,
    this.supplierInvoiceNumber,
    this.notes,
  });

  final String id;
  final PurchaseDocumentType documentType;
  final PurchaseDocumentStatus documentStatus;
  final String documentNumber;
  final String documentSeries;
  final String partyId;
  final String partyName;
  final double amount;
  final double balanceDue;
  final DateTime documentDate;
  final DateTime? dueDate;
  final String? supplierInvoiceNumber;
  final String? notes;
}

class PurchaseDocumentMapper {
  static PurchaseDocumentRecord toRecord(
    PurchaseDocumentDto dto, {
    String partyName = '',
  }) {
    final amount = double.tryParse(dto.totalAmount) ?? 0;
    final documentStatus =
        PurchaseDocumentStatus.fromApiValue(dto.status) ??
        PurchaseDocumentStatus.draft;
    final documentType =
        PurchaseDocumentType.fromApiValue(dto.documentType) ??
        PurchaseDocumentType.purchaseBill;
    final dueDate = dto.dueDate != null
        ? DateTime.tryParse(dto.dueDate!)
        : null;

    return PurchaseDocumentRecord(
      id: dto.id,
      documentType: documentType,
      documentStatus: documentStatus,
      documentNumber: dto.documentNumber ?? 'Draft',
      documentSeries: dto.documentSeries,
      partyId: dto.partyId,
      partyName: partyName,
      amount: amount,
      balanceDue: documentStatus == PurchaseDocumentStatus.cancelled
          ? 0
          : amount,
      documentDate:
          DateTime.tryParse(dto.documentDate) ?? DateTime.now(),
      dueDate: dueDate,
      supplierInvoiceNumber: dto.supplierInvoiceNumber,
      notes: dto.notes,
    );
  }

  static PurchaseBillModel toBillModel(
    PurchaseDocumentDto dto, {
    String partyName = '',
  }) {
    final record = toRecord(dto, partyName: partyName);
    final status = _mapBillPaymentStatus(record);

    return PurchaseBillModel(
      id: record.id,
      invoiceNo: record.documentNumber,
      date: record.documentDate,
      partyName: record.partyName,
      partyId: record.partyId,
      paymentType: 'Credit',
      status: status,
      documentStatus: record.documentStatus,
      amount: record.amount,
      balanceDue: record.balanceDue,
      dueDate: record.dueDate ?? record.documentDate,
    );
  }

  static PurchaseOrderModel toOrderModel(
    PurchaseDocumentDto dto, {
    String partyName = '',
  }) {
    final record = toRecord(dto, partyName: partyName);
    final status = _mapOrderStatus(record.documentStatus);

    return PurchaseOrderModel(
      id: record.id,
      orderNo: record.documentNumber,
      date: record.documentDate,
      partyName: record.partyName,
      partyId: record.partyId,
      status: status,
      documentStatus: record.documentStatus,
      amount: record.amount,
      balanceDue: record.balanceDue,
      dueDate: record.dueDate ?? record.documentDate,
    );
  }

  static PurchaseReturnModel toReturnModel(
    PurchaseDocumentDto dto, {
    String partyName = '',
  }) {
    final record = toRecord(dto, partyName: partyName);
    final status = _mapBillPaymentStatus(record);

    return PurchaseReturnModel(
      id: record.id,
      debitNoteNo: record.documentNumber,
      date: record.documentDate,
      partyName: record.partyName,
      partyId: record.partyId,
      categoryName: 'Purchase Return',
      type: 'Debit Note',
      status: status,
      documentStatus: record.documentStatus,
      total: record.amount,
      receivedPaid: record.amount - record.balanceDue,
      balance: record.balanceDue,
      dueDate: record.dueDate ?? record.documentDate,
    );
  }

  static PaymentOutModel toPaymentOutModel(
    PaymentDto dto, {
    String partyName = '',
  }) {
    final amount = double.tryParse(dto.amount) ?? 0;
    final allocated = dto.allocations.fold<double>(
      0,
      (sum, allocation) =>
          sum + (double.tryParse(allocation.allocatedAmount) ?? 0),
    );

    return PaymentOutModel(
      id: dto.id,
      receiptNo: dto.referenceNumber ?? dto.id.substring(0, 8),
      date: DateTime.tryParse(dto.paymentDate) ?? DateTime.now(),
      partyName: partyName,
      partyId: dto.partyId,
      paymentType: PurchasePaymentModes.toUi(dto.paymentMode),
      totalAmount: amount,
      paidAmount: allocated,
      status: allocated >= amount && amount > 0
          ? PaymentOutStatus.paid
          : PaymentOutStatus.pending,
      description: dto.notes ?? '',
    );
  }

  static PurchaseBillStatus _mapBillPaymentStatus(
    PurchaseDocumentRecord record,
  ) {
    if (record.documentStatus == PurchaseDocumentStatus.cancelled) {
      return PurchaseBillStatus.cancelled;
    }
    if (record.documentStatus == PurchaseDocumentStatus.draft) {
      return PurchaseBillStatus.unpaid;
    }
    if (record.documentStatus == PurchaseDocumentStatus.converted) {
      return PurchaseBillStatus.paid;
    }
    if (record.balanceDue <= 0) {
      return PurchaseBillStatus.paid;
    }
    if (record.balanceDue < record.amount) {
      return PurchaseBillStatus.partiallyPaid;
    }
    final due = record.dueDate ?? record.documentDate;
    if (DateTime.now().isAfter(due) && record.balanceDue > 0) {
      return PurchaseBillStatus.overdue;
    }
    return PurchaseBillStatus.unpaid;
  }

  static PurchaseOrderStatus _mapOrderStatus(
    PurchaseDocumentStatus documentStatus,
  ) {
    return switch (documentStatus) {
      PurchaseDocumentStatus.cancelled => PurchaseOrderStatus.cancelled,
      PurchaseDocumentStatus.converted =>
        PurchaseOrderStatus.partiallyReceived,
      PurchaseDocumentStatus.finalized => PurchaseOrderStatus.orderCompleted,
      _ => PurchaseOrderStatus.open,
    };
  }

  static String seriesForType(PurchaseDocumentType type) =>
      switch (type) {
        PurchaseDocumentType.purchaseBill =>
          PurchaseConstants.purchaseBillSeries,
        PurchaseDocumentType.purchaseOrder =>
          PurchaseConstants.purchaseOrderSeries,
        PurchaseDocumentType.purchaseReturn =>
          PurchaseConstants.purchaseReturnSeries,
      };
}
