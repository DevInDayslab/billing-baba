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
    required this.paidAmount,
    required this.balanceDue,
    required this.documentDate,
    this.dueDate,
    this.supplierInvoiceNumber,
    this.notes,
    this.paymentMode,
  });

  final String id;
  final PurchaseDocumentType documentType;
  final PurchaseDocumentStatus documentStatus;
  final String documentNumber;
  final String documentSeries;
  final String partyId;
  final String partyName;
  final double amount;
  final double paidAmount;
  final double balanceDue;
  final DateTime documentDate;
  final DateTime? dueDate;
  final String? supplierInvoiceNumber;
  final String? notes;
  final String? paymentMode;
}

class PurchaseDocumentMapper {
  static PurchaseDocumentRecord toRecord(
    PurchaseDocumentDto dto, {
    String partyName = '',
  }) {
    final amount = double.tryParse(dto.totalAmount) ?? 0;
    final paid = double.tryParse(dto.paidAmount) ?? 0;
    final documentStatus =
        PurchaseDocumentStatus.fromApiValue(dto.status) ??
        PurchaseDocumentStatus.draft;
    final documentType =
        PurchaseDocumentType.fromApiValue(dto.documentType) ??
        PurchaseDocumentType.purchaseBill;
    final dueDate = dto.dueDate != null
        ? DateTime.tryParse(dto.dueDate!)
        : null;
    final balanceDue = documentStatus == PurchaseDocumentStatus.cancelled
        ? 0.0
        : (amount - paid).clamp(0.0, double.infinity);

    return PurchaseDocumentRecord(
      id: dto.id,
      documentType: documentType,
      documentStatus: documentStatus,
      documentNumber: dto.documentNumber ?? 'Draft',
      documentSeries: dto.documentSeries,
      partyId: dto.partyId,
      partyName: partyName,
      amount: amount,
      paidAmount: paid,
      balanceDue: balanceDue,
      documentDate:
          DateTime.tryParse(dto.documentDate) ?? DateTime.now(),
      dueDate: dueDate,
      supplierInvoiceNumber: dto.supplierInvoiceNumber,
      notes: dto.notes,
      paymentMode: dto.paymentMode,
    );
  }

  static PurchaseBillModel toBillModel(
    PurchaseDocumentDto dto, {
    String partyName = '',
  }) {
    final record = toRecord(dto, partyName: partyName);
    final status = _mapBillPaymentStatus(record);
    final paymentType = _mapPaymentType(
      record.documentStatus,
      record.amount,
      record.paidAmount,
      record.paymentMode,
    );

    return PurchaseBillModel(
      id: record.id,
      invoiceNo: record.documentNumber,
      date: record.documentDate,
      partyName: record.partyName,
      partyId: record.partyId,
      paymentType: paymentType,
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
      receivedPaid: record.paidAmount,
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
    final effectivePaid =
        dto.allocations.isEmpty && amount > 0 ? amount : allocated;

    return PaymentOutModel(
      id: dto.id,
      receiptNo: dto.referenceNumber ?? dto.id.substring(0, 8),
      date: DateTime.tryParse(dto.paymentDate) ?? DateTime.now(),
      partyName: partyName,
      partyId: dto.partyId,
      paymentType: PurchasePaymentModes.toUi(dto.paymentMode),
      totalAmount: amount,
      paidAmount: effectivePaid,
      status: effectivePaid >= amount && amount > 0
          ? PaymentOutStatus.paid
          : PaymentOutStatus.pending,
      description: dto.notes ?? '',
    );
  }

  static String _mapPaymentType(
    PurchaseDocumentStatus documentStatus,
    double amount,
    double paid,
    String? paymentMode,
  ) {
    if (documentStatus == PurchaseDocumentStatus.draft) {
      return 'Credit';
    }
    if (amount > 0 && paid >= amount) {
      return paymentMode != null
          ? PurchasePaymentModes.toUi(paymentMode)
          : 'Cash';
    }
    return 'Credit';
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

    final balance = record.balanceDue;
    final paid = record.paidAmount;
    final amount = record.amount;

    if (amount <= 0 || balance <= 0 || paid >= amount) {
      return PurchaseBillStatus.paid;
    }

    if (_isPastDue(record.dueDate, record.documentDate)) {
      return PurchaseBillStatus.overdue;
    }

    if (paid > 0) {
      return PurchaseBillStatus.partiallyPaid;
    }

    return PurchaseBillStatus.unpaid;
  }

  static bool _isPastDue(DateTime? dueDate, DateTime documentDate) {
    final due = dueDate ?? documentDate;
    final dueDay = DateTime(due.year, due.month, due.day);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return today.isAfter(dueDay);
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
