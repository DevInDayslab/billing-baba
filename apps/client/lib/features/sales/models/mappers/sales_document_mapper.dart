import 'package:billing_baba/features/sales/models/dto/sales_document_dto.dart';
import 'package:billing_baba/features/sales/models/payment_in_model.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_model.dart';
import 'package:billing_baba/features/sales/sales_constants.dart';

class SalesDocumentMapper {
  static SaleInvoiceModel toInvoiceModel(
    SalesDocumentDto dto, {
    String partyName = '',
  }) {
    final amount = double.tryParse(dto.totalAmount) ?? 0;
    final status = _mapStatus(dto.status);

    return SaleInvoiceModel(
      id: dto.id,
      invoiceNo: dto.documentNumber ?? 'Draft',
      date: DateTime.tryParse(dto.documentDate) ?? DateTime.now(),
      partyName: partyName,
      transactionType: _mapDocumentTypeLabel(dto.documentType),
      paymentType: 'Credit',
      status: status,
      amount: amount,
      balance: dto.status == 'finalized' ? amount : 0,
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
      date: DateTime.tryParse(dto.paymentDate) ?? DateTime.now(),
      partyName: partyName,
      paymentType: dto.paymentMode,
      totalAmount: amount,
      receivedAmount: allocated,
      status: allocated >= amount && amount > 0
          ? PaymentInStatus.used
          : PaymentInStatus.unused,
    );
  }

  static String _mapDocumentTypeLabel(String type) => switch (type) {
    'estimate' => 'Estimate',
    'sale_order' => 'Sale Order',
    'delivery_challan' => 'Delivery Challan',
    'tax_invoice' => 'Tax Invoice',
    'bill_of_supply' => 'Bill of Supply',
    'normal_invoice' => 'Normal Invoice',
    'pos' => 'POS',
    'sales_return' => 'Credit Note',
    _ => type,
  };

  static SaleInvoiceStatus _mapStatus(String status) {
    return switch (status) {
      'cancelled' => SaleInvoiceStatus.cancelled,
      'converted' => SaleInvoiceStatus.paid,
      _ => SaleInvoiceStatus.unpaid,
    };
  }

  static String seriesForType(SalesDocumentType type) => switch (type) {
    SalesDocumentType.estimate => SalesConstants.estimateSeries,
    SalesDocumentType.saleOrder => SalesConstants.saleOrderSeries,
    SalesDocumentType.deliveryChallan => SalesConstants.challanSeries,
    SalesDocumentType.salesReturn => SalesConstants.creditNoteSeries,
    _ => SalesConstants.defaultDocumentSeries,
  };
}
