import 'package:billing_baba/core/utils/date_time_utils.dart';
import 'package:billing_baba/features/sales/models/dto/sales_document_dto.dart';
import 'package:billing_baba/features/sales/models/payment_in_model.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_model.dart';
import 'package:billing_baba/features/sales/sales_constants.dart';

class SalesDocumentMapper {
  static SaleInvoiceModel toInvoiceModel(
    SalesDocumentDto dto, {
    String partyName = '',
    String firmName = 'Main Firm',
    String fallbackUserName = 'Admin',
    String fallbackGodownName = 'Main Location',
  }) {
    final amount = double.tryParse(dto.totalAmount) ?? 0;
    final paid = double.tryParse(dto.paidAmount) ?? 0;
    final documentStatus =
        SalesDocumentStatus.fromApiValue(dto.status) ??
        SalesDocumentStatus.draft;
    final balance = documentStatus == SalesDocumentStatus.cancelled
        ? 0.0
        : (amount - paid).clamp(0.0, double.infinity);
    final status = _mapPaymentStatus(documentStatus, amount, paid);
    final paymentType = _mapPaymentType(
      documentStatus,
      amount,
      paid,
      dto.paymentMode,
    );

    return SaleInvoiceModel(
      id: dto.id,
      invoiceNo: dto.documentNumber ?? 'Draft',
      date: DateTimeUtils.parseApiDateTime(dto.documentDate),
      partyName: partyName,
      partyId: dto.partyId,
      documentSeries: dto.documentSeries,
      transactionType: _mapDocumentTypeLabel(dto.documentType),
      paymentType: paymentType,
      status: status,
      documentStatus: documentStatus,
      amount: amount,
      balance: balance,
      user: dto.createdByName?.trim().isNotEmpty == true
          ? dto.createdByName!.trim()
          : fallbackUserName,
      godown: dto.godownName?.trim().isNotEmpty == true
          ? dto.godownName!.trim()
          : fallbackGodownName,
      firm: firmName,
    );
  }

  static PaymentInModel toPaymentInModel(
    PaymentDto dto, {
    String partyName = '',
  }) {
    final amount = double.tryParse(dto.amount) ?? 0;
    final allocated = dto.allocations.fold<double>(
      0,
      (sum, allocation) =>
          sum + (double.tryParse(allocation.allocatedAmount) ?? 0),
    );

    return PaymentInModel(
      id: dto.id,
      receiptNo: dto.referenceNumber ?? dto.id.substring(0, 8),
      date: DateTimeUtils.parseApiDateTime(dto.paymentDate),
      partyName: partyName,
      partyId: dto.partyId,
      paymentType: SalesPaymentModes.toUi(dto.paymentMode),
      totalAmount: amount,
      receivedAmount: allocated > 0 ? allocated : amount,
      status: _mapPaymentInStatus(amount, allocated),
    );
  }

  static PaymentInStatus _mapPaymentInStatus(double amount, double allocated) {
    if (allocated <= 0) {
      return PaymentInStatus.unused;
    }
    if (allocated >= amount && amount > 0) {
      return PaymentInStatus.paid;
    }
    return PaymentInStatus.partial;
  }

  static String _mapDocumentTypeLabel(String type) => switch (type) {
    'estimate' => 'Estimate',
    'sale_order' => 'Sale Order',
    'delivery_challan' => 'Delivery Challan',
    'tax_invoice' => 'Sale',
    'bill_of_supply' => 'Bill of Supply',
    'normal_invoice' => 'Normal Invoice',
    'pos' => 'POS',
    'sales_return' => 'Credit Note',
    _ => type,
  };

  static String _mapPaymentType(
    SalesDocumentStatus documentStatus,
    double amount,
    double paid,
    String? paymentMode,
  ) {
    if (documentStatus == SalesDocumentStatus.draft) {
      return 'Credit';
    }
    if (amount > 0 && paid >= amount) {
      return paymentMode != null ? SalesPaymentModes.toUi(paymentMode) : 'Cash';
    }
    return 'Credit';
  }

  static SaleInvoiceStatus _mapPaymentStatus(
    SalesDocumentStatus documentStatus,
    double amount,
    double paid,
  ) {
    if (documentStatus == SalesDocumentStatus.cancelled) {
      return SaleInvoiceStatus.cancelled;
    }
    if (documentStatus == SalesDocumentStatus.draft) {
      return SaleInvoiceStatus.unpaid;
    }
    if (documentStatus == SalesDocumentStatus.converted) {
      return SaleInvoiceStatus.paid;
    }
    if (amount <= 0 || paid >= amount) {
      return SaleInvoiceStatus.paid;
    }
    if (paid > 0) {
      return SaleInvoiceStatus.partiallyPaid;
    }
    return SaleInvoiceStatus.unpaid;
  }

  static String seriesForType(SalesDocumentType type) => switch (type) {
    SalesDocumentType.estimate => SalesConstants.estimateSeries,
    SalesDocumentType.saleOrder => SalesConstants.saleOrderSeries,
    SalesDocumentType.deliveryChallan => SalesConstants.challanSeries,
    SalesDocumentType.salesReturn => SalesConstants.creditNoteSeries,
    _ => SalesConstants.defaultDocumentSeries,
  };
}
