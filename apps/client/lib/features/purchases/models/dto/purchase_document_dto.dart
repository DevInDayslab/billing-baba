import 'package:billing_baba/features/inventory/models/dto/pagination_meta_dto.dart';

export 'package:billing_baba/features/sales/models/dto/sales_document_dto.dart'
  show PaginatedPaymentsDto, PaymentAllocationDto, PaymentDto;

class PurchaseDocumentLineDto {
  const PurchaseDocumentLineDto({
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
  });

  factory PurchaseDocumentLineDto.fromJson(Map<String, dynamic> json) {
    return PurchaseDocumentLineDto(
      id: json['id'] as String,
      itemId: json['item_id'] as String,
      quantity: json['quantity'] as String,
      unit: json['unit'] as String,
      unitPrice: json['unit_price'] as String,
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
  final String discountAmount;
  final String taxType;
  final String taxRate;
  final String cgstAmount;
  final String sgstAmount;
  final String igstAmount;
  final String lineTotal;
  final int sortOrder;
}

class PurchaseDocumentDto {
  const PurchaseDocumentDto({
    required this.id,
    required this.documentType,
    required this.status,
    required this.documentSeries,
    required this.partyId,
    required this.isGstFormal,
    required this.subtotal,
    required this.discountTotal,
    required this.taxAmount,
    required this.totalAmount,
    required this.documentDate,
    required this.createdAt,
    required this.updatedAt,
    this.documentNumber,
    this.partyStateCode,
    this.convertedFromId,
    this.supplierInvoiceNumber,
    this.dueDate,
    this.notes,
    this.lines = const [],
  });

  factory PurchaseDocumentDto.fromJson(Map<String, dynamic> json) {
    final lines = json['lines'];
    return PurchaseDocumentDto(
      id: json['id'] as String,
      documentType: json['document_type'] as String,
      status: json['status'] as String,
      documentNumber: json['document_number'] as String?,
      documentSeries: json['document_series'] as String,
      partyId: json['party_id'] as String,
      isGstFormal: json['is_gst_formal'] as bool? ?? false,
      partyStateCode: json['party_state_code'] as String?,
      subtotal: json['subtotal'] as String? ?? '0',
      discountTotal: json['discount_total'] as String? ?? '0',
      taxAmount: json['tax_amount'] as String? ?? '0',
      totalAmount: json['total_amount'] as String? ?? '0',
      documentDate: json['document_date'] as String,
      convertedFromId: json['converted_from_id'] as String?,
      supplierInvoiceNumber: json['supplier_invoice_number'] as String?,
      dueDate: json['due_date'] as String?,
      notes: json['notes'] as String?,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      lines: lines is List
          ? lines
                .whereType<Map<String, dynamic>>()
                .map(PurchaseDocumentLineDto.fromJson)
                .toList()
          : const [],
    );
  }

  final String id;
  final String documentType;
  final String status;
  final String? documentNumber;
  final String documentSeries;
  final String partyId;
  final bool isGstFormal;
  final String? partyStateCode;
  final String subtotal;
  final String discountTotal;
  final String taxAmount;
  final String totalAmount;
  final String documentDate;
  final String? convertedFromId;
  final String? supplierInvoiceNumber;
  final String? dueDate;
  final String? notes;
  final String createdAt;
  final String updatedAt;
  final List<PurchaseDocumentLineDto> lines;
}

class PaginatedPurchaseDocumentsDto {
  const PaginatedPurchaseDocumentsDto({
    required this.documents,
    required this.meta,
  });

  factory PaginatedPurchaseDocumentsDto.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final meta = json['meta'];
    return PaginatedPurchaseDocumentsDto(
      documents: data is List
          ? data
                .whereType<Map<String, dynamic>>()
                .map(PurchaseDocumentDto.fromJson)
                .toList()
          : const [],
      meta: meta is Map<String, dynamic>
          ? PaginationMetaDto.fromJson(meta)
          : const PaginationMetaDto(page: 1, limit: 20, total: 0),
    );
  }

  final List<PurchaseDocumentDto> documents;
  final PaginationMetaDto meta;
}
