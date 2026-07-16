import 'package:billing_baba/features/inventory/models/dto/pagination_meta_dto.dart';

class SalesDocumentLineDto {
  const SalesDocumentLineDto({
    required this.id,
    required this.itemId,
    required this.quantity,
    required this.unit,
    required this.unitPrice,
    required this.discountAmount,
    required this.taxType,
    required this.taxRate,
    required this.cgstAmount,
    required this.sgstAmount,
    required this.igstAmount,
    required this.lineTotal,
    required this.sortOrder,
    this.marketPrice,
  });

  factory SalesDocumentLineDto.fromJson(Map<String, dynamic> json) {
    return SalesDocumentLineDto(
      id: json['id'] as String,
      itemId: json['item_id'] as String,
      quantity: json['quantity'] as String,
      unit: json['unit'] as String,
      unitPrice: json['unit_price'] as String,
      marketPrice: json['market_price'] as String?,
      discountAmount: json['discount_amount'] as String? ?? '0',
      taxType: json['tax_type'] as String? ?? 'none',
      taxRate: json['tax_rate'] as String? ?? '0',
      cgstAmount: json['cgst_amount'] as String? ?? '0',
      sgstAmount: json['sgst_amount'] as String? ?? '0',
      igstAmount: json['igst_amount'] as String? ?? '0',
      lineTotal: json['line_total'] as String,
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
    );
  }

  final String id;
  final String itemId;
  final String quantity;
  final String unit;
  final String unitPrice;
  final String? marketPrice;
  final String discountAmount;
  final String taxType;
  final String taxRate;
  final String cgstAmount;
  final String sgstAmount;
  final String igstAmount;
  final String lineTotal;
  final int sortOrder;
}

class SalesDocumentDto {
  const SalesDocumentDto({
    required this.id,
    required this.documentType,
    required this.status,
    required this.documentSeries,
    required this.isGstFormal,
    required this.subtotal,
    required this.discountTotal,
    required this.taxAmount,
    required this.totalAmount,
    required this.documentDate,
    required this.createdAt,
    required this.updatedAt,
    this.paidAmount = '0',
    this.paymentMode,
    this.documentNumber,
    this.partyId,
    this.partyStateCode,
    this.convertedFromId,
    this.posSessionId,
    this.notes,
    this.createdBy,
    this.createdByName,
    this.godownName,
    this.lines = const [],
  });

  factory SalesDocumentDto.fromJson(Map<String, dynamic> json) {
    final lines = json['lines'];
    return SalesDocumentDto(
      id: json['id'] as String,
      documentType: json['document_type'] as String,
      status: json['status'] as String,
      documentNumber: json['document_number'] as String?,
      documentSeries: json['document_series'] as String,
      partyId: json['party_id'] as String?,
      isGstFormal: json['is_gst_formal'] as bool? ?? false,
      partyStateCode: json['party_state_code'] as String?,
      subtotal: json['subtotal'] as String? ?? '0',
      discountTotal: json['discount_total'] as String? ?? '0',
      taxAmount: json['tax_amount'] as String? ?? '0',
      totalAmount: json['total_amount'] as String? ?? '0',
      paidAmount: json['paid_amount'] as String? ?? '0',
      paymentMode: json['payment_mode'] as String?,
      documentDate: json['document_date'] as String,
      convertedFromId: json['converted_from_id'] as String?,
      posSessionId: json['pos_session_id'] as String?,
      notes: json['notes'] as String?,
      createdBy: json['created_by'] as String?,
      createdByName: json['created_by_name'] as String?,
      godownName: json['godown_name'] as String?,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      lines: lines is List
          ? lines
                .whereType<Map<String, dynamic>>()
                .map(SalesDocumentLineDto.fromJson)
                .toList()
          : const [],
    );
  }

  final String id;
  final String documentType;
  final String status;
  final String? documentNumber;
  final String documentSeries;
  final String? partyId;
  final bool isGstFormal;
  final String? partyStateCode;
  final String subtotal;
  final String discountTotal;
  final String taxAmount;
  final String totalAmount;
  final String paidAmount;
  final String? paymentMode;
  final String documentDate;
  final String? convertedFromId;
  final String? posSessionId;
  final String? notes;
  final String? createdBy;
  final String? createdByName;
  final String? godownName;
  final String createdAt;
  final String updatedAt;
  final List<SalesDocumentLineDto> lines;
}

class SalesDocumentsListSummaryDto {
  const SalesDocumentsListSummaryDto({
    required this.totalAmount,
    required this.receivedAmount,
    required this.balanceAmount,
  });

  factory SalesDocumentsListSummaryDto.fromJson(Map<String, dynamic> json) {
    return SalesDocumentsListSummaryDto(
      totalAmount: json['total_amount'] as String? ?? '0',
      receivedAmount: json['received_amount'] as String? ?? '0',
      balanceAmount: json['balance_amount'] as String? ?? '0',
    );
  }

  final String totalAmount;
  final String receivedAmount;
  final String balanceAmount;
}

class PaginatedSalesDocumentsDto {
  const PaginatedSalesDocumentsDto({
    required this.documents,
    required this.meta,
    this.summary,
  });

  factory PaginatedSalesDocumentsDto.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final meta = json['meta'];
    final summary = json['summary'];
    return PaginatedSalesDocumentsDto(
      documents: data is List
          ? data
                .whereType<Map<String, dynamic>>()
                .map(SalesDocumentDto.fromJson)
                .toList()
          : const [],
      meta: meta is Map<String, dynamic>
          ? PaginationMetaDto.fromJson(meta)
          : const PaginationMetaDto(page: 1, limit: 20, total: 0),
      summary: summary is Map<String, dynamic>
          ? SalesDocumentsListSummaryDto.fromJson(summary)
          : null,
    );
  }

  final List<SalesDocumentDto> documents;
  final PaginationMetaDto meta;
  final SalesDocumentsListSummaryDto? summary;
}

class PaymentAllocationDto {
  const PaymentAllocationDto({
    required this.id,
    required this.paymentId,
    required this.allocatedAmount,
    this.salesDocumentId,
    this.purchaseDocumentId,
  });

  factory PaymentAllocationDto.fromJson(Map<String, dynamic> json) {
    return PaymentAllocationDto(
      id: json['id'] as String,
      paymentId: json['payment_id'] as String,
      salesDocumentId: json['sales_document_id'] as String?,
      purchaseDocumentId: json['purchase_document_id'] as String?,
      allocatedAmount: json['allocated_amount'] as String,
    );
  }

  final String id;
  final String paymentId;
  final String? salesDocumentId;
  final String? purchaseDocumentId;
  final String allocatedAmount;
}

class PaymentDto {
  const PaymentDto({
    required this.id,
    required this.partyId,
    required this.direction,
    required this.amount,
    required this.paymentMode,
    required this.paymentDate,
    required this.createdAt,
    required this.updatedAt,
    this.referenceNumber,
    this.notes,
    this.shortPaymentHandling,
    this.allocations = const [],
  });

  factory PaymentDto.fromJson(Map<String, dynamic> json) {
    final allocations = json['allocations'];
    return PaymentDto(
      id: json['id'] as String,
      partyId: json['party_id'] as String,
      direction: json['direction'] as String,
      amount: json['amount'] as String,
      paymentMode: json['payment_mode'] as String,
      paymentDate: json['payment_date'] as String,
      referenceNumber: json['reference_number'] as String?,
      notes: json['notes'] as String?,
      shortPaymentHandling: json['short_payment_handling'] as String?,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      allocations: allocations is List
          ? allocations
                .whereType<Map<String, dynamic>>()
                .map(PaymentAllocationDto.fromJson)
                .toList()
          : const [],
    );
  }

  final String id;
  final String partyId;
  final String direction;
  final String amount;
  final String paymentMode;
  final String paymentDate;
  final String? referenceNumber;
  final String? notes;
  final String? shortPaymentHandling;
  final String createdAt;
  final String updatedAt;
  final List<PaymentAllocationDto> allocations;
}

class PaginatedPaymentsDto {
  const PaginatedPaymentsDto({
    required this.payments,
    required this.meta,
  });

  factory PaginatedPaymentsDto.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final meta = json['meta'];
    return PaginatedPaymentsDto(
      payments: data is List
          ? data
                .whereType<Map<String, dynamic>>()
                .map(PaymentDto.fromJson)
                .toList()
          : const [],
      meta: meta is Map<String, dynamic>
          ? PaginationMetaDto.fromJson(meta)
          : const PaginationMetaDto(page: 1, limit: 20, total: 0),
    );
  }

  final List<PaymentDto> payments;
  final PaginationMetaDto meta;
}
