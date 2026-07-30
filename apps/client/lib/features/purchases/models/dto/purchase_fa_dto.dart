import 'package:billing_baba/features/inventory/models/dto/pagination_meta_dto.dart';

class PurchaseFaAssetDto {
  const PurchaseFaAssetDto({
    required this.id,
    required this.assetName,
    required this.purchasePrice,
    required this.qty,
    required this.taxRate,
    required this.taxAmount,
    required this.lineTotal,
    required this.sortOrder,
    this.assetCategory,
    this.serialNumber,
    this.location,
    this.warrantyExpiry,
    this.description,
    this.purchaseDocumentId,
  });

  factory PurchaseFaAssetDto.fromJson(Map<String, dynamic> json) {
    return PurchaseFaAssetDto(
      id: json['id'] as String,
      assetName: json['asset_name'] as String,
      assetCategory: json['asset_category'] as String?,
      serialNumber: json['serial_number'] as String?,
      purchasePrice: json['purchase_price'] as String,
      location: json['location'] as String?,
      warrantyExpiry: json['warranty_expiry'] as String?,
      description: json['description'] as String?,
      qty: json['qty'] as String? ?? '1.0000',
      taxRate: json['tax_rate'] as String? ?? '0.0000',
      taxAmount: json['tax_amount'] as String? ?? '0.0000',
      lineTotal: json['line_total'] as String,
      sortOrder: json['sort_order'] as int? ?? 0,
      purchaseDocumentId: json['purchase_document_id'] as String?,
    );
  }

  final String id;
  final String assetName;
  final String? assetCategory;
  final String? serialNumber;
  final String purchasePrice;
  final String? location;
  final String? warrantyExpiry;
  final String? description;
  final String qty;
  final String taxRate;
  final String taxAmount;
  final String lineTotal;
  final int sortOrder;
  final String? purchaseDocumentId;
}

class PurchaseFaBatchListDto {
  const PurchaseFaBatchListDto({
    required this.id,
    required this.partyId,
    required this.partyName,
    required this.purchaseDate,
    required this.totalAmount,
    required this.balanceDue,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.referenceNumber,
    this.dueDate,
    this.paymentMode,
  });

  factory PurchaseFaBatchListDto.fromJson(Map<String, dynamic> json) {
    return PurchaseFaBatchListDto(
      id: json['id'] as String,
      partyId: json['party_id'] as String,
      partyName: json['party_name'] as String,
      referenceNumber: json['reference_number'] as String?,
      purchaseDate: json['purchase_date'] as String,
      dueDate: json['due_date'] as String?,
      paymentMode: json['payment_mode'] as String?,
      totalAmount: json['total_amount'] as String,
      balanceDue: json['balance_due'] as String,
      status: json['status'] as String,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );
  }

  final String id;
  final String partyId;
  final String partyName;
  final String? referenceNumber;
  final String purchaseDate;
  final String? dueDate;
  final String? paymentMode;
  final String totalAmount;
  final String balanceDue;
  final String status;
  final String createdAt;
  final String updatedAt;
}

class PurchaseFaBatchDto {
  const PurchaseFaBatchDto({
    required this.id,
    required this.partyId,
    required this.partyName,
    required this.purchaseDate,
    required this.subtotal,
    required this.taxAmount,
    required this.totalAmount,
    required this.balanceDue,
    required this.status,
    required this.assets,
    required this.createdAt,
    required this.updatedAt,
    this.referenceNumber,
    this.dueDate,
    this.paymentMode,
    this.notes,
    this.description,
  });

  factory PurchaseFaBatchDto.fromJson(Map<String, dynamic> json) {
    final assetsJson = json['assets'];
    return PurchaseFaBatchDto(
      id: json['id'] as String,
      partyId: json['party_id'] as String,
      partyName: json['party_name'] as String,
      referenceNumber: json['reference_number'] as String?,
      purchaseDate: json['purchase_date'] as String,
      dueDate: json['due_date'] as String?,
      paymentMode: json['payment_mode'] as String?,
      subtotal: json['subtotal'] as String? ?? '0.0000',
      taxAmount: json['tax_amount'] as String? ?? '0.0000',
      totalAmount: json['total_amount'] as String,
      balanceDue: json['balance_due'] as String,
      status: json['status'] as String,
      notes: json['notes'] as String?,
      description: json['description'] as String?,
      assets: assetsJson is List
          ? assetsJson
                .whereType<Map<String, dynamic>>()
                .map(PurchaseFaAssetDto.fromJson)
                .toList()
          : const [],
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );
  }

  final String id;
  final String partyId;
  final String partyName;
  final String? referenceNumber;
  final String purchaseDate;
  final String? dueDate;
  final String? paymentMode;
  final String subtotal;
  final String taxAmount;
  final String totalAmount;
  final String balanceDue;
  final String status;
  final String? notes;
  final String? description;
  final List<PurchaseFaAssetDto> assets;
  final String createdAt;
  final String updatedAt;
}

class PaginatedPurchaseFaBatchesDto {
  const PaginatedPurchaseFaBatchesDto({
    required this.batches,
    required this.meta,
  });

  factory PaginatedPurchaseFaBatchesDto.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final meta = json['meta'];
    return PaginatedPurchaseFaBatchesDto(
      batches: data is List
          ? data
                .whereType<Map<String, dynamic>>()
                .map(PurchaseFaBatchListDto.fromJson)
                .toList()
          : const [],
      meta: meta is Map<String, dynamic>
          ? PaginationMetaDto.fromJson(meta)
          : const PaginationMetaDto(page: 1, limit: 20, total: 0),
    );
  }

  final List<PurchaseFaBatchListDto> batches;
  final PaginationMetaDto meta;
}
