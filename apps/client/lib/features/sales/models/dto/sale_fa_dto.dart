import 'package:billing_baba/features/inventory/models/dto/pagination_meta_dto.dart';

class SaleFaAssetDto {
  const SaleFaAssetDto({
    required this.id,
    required this.assetName,
    required this.salePrice,
    required this.qty,
    required this.taxRate,
    required this.taxAmount,
    required this.lineTotal,
    required this.sortOrder,
    this.itemCode,
    this.assetCategory,
    this.serialNumber,
    this.location,
    this.description,
    this.purchaseFixedAssetId,
  });

  factory SaleFaAssetDto.fromJson(Map<String, dynamic> json) {
    return SaleFaAssetDto(
      id: json['id'] as String,
      assetName: json['asset_name'] as String,
      itemCode: json['item_code'] as String?,
      assetCategory: json['asset_category'] as String?,
      serialNumber: json['serial_number'] as String?,
      salePrice: json['sale_price'] as String,
      location: json['location'] as String?,
      description: json['description'] as String?,
      qty: json['qty'] as String? ?? '1.0000',
      taxRate: json['tax_rate'] as String? ?? '0.0000',
      taxAmount: json['tax_amount'] as String? ?? '0.0000',
      lineTotal: json['line_total'] as String,
      sortOrder: json['sort_order'] as int? ?? 0,
      purchaseFixedAssetId: json['purchase_fixed_asset_id'] as String?,
    );
  }

  final String id;
  final String assetName;
  final String? itemCode;
  final String? assetCategory;
  final String? serialNumber;
  final String salePrice;
  final String? location;
  final String? description;
  final String qty;
  final String taxRate;
  final String taxAmount;
  final String lineTotal;
  final int sortOrder;
  final String? purchaseFixedAssetId;
}

class SaleFaBatchListDto {
  const SaleFaBatchListDto({
    required this.id,
    required this.partyId,
    required this.partyName,
    required this.saleDate,
    required this.totalAmount,
    required this.balanceDue,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.referenceNumber,
    this.dueDate,
    this.paymentMode,
  });

  factory SaleFaBatchListDto.fromJson(Map<String, dynamic> json) {
    return SaleFaBatchListDto(
      id: json['id'] as String,
      partyId: json['party_id'] as String,
      partyName: json['party_name'] as String,
      referenceNumber: json['reference_number'] as String?,
      saleDate: json['sale_date'] as String,
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
  final String saleDate;
  final String? dueDate;
  final String? paymentMode;
  final String totalAmount;
  final String balanceDue;
  final String status;
  final String createdAt;
  final String updatedAt;
}

class SaleFaBatchDto {
  const SaleFaBatchDto({
    required this.id,
    required this.partyId,
    required this.partyName,
    required this.saleDate,
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

  factory SaleFaBatchDto.fromJson(Map<String, dynamic> json) {
    final assetsJson = json['assets'];
    return SaleFaBatchDto(
      id: json['id'] as String,
      partyId: json['party_id'] as String,
      partyName: json['party_name'] as String,
      referenceNumber: json['reference_number'] as String?,
      saleDate: json['sale_date'] as String,
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
                .map(SaleFaAssetDto.fromJson)
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
  final String saleDate;
  final String? dueDate;
  final String? paymentMode;
  final String subtotal;
  final String taxAmount;
  final String totalAmount;
  final String balanceDue;
  final String status;
  final String? notes;
  final String? description;
  final List<SaleFaAssetDto> assets;
  final String createdAt;
  final String updatedAt;
}

class PaginatedSaleFaBatchesDto {
  const PaginatedSaleFaBatchesDto({
    required this.batches,
    required this.meta,
  });

  factory PaginatedSaleFaBatchesDto.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final meta = json['meta'];
    return PaginatedSaleFaBatchesDto(
      batches: data is List
          ? data
                .whereType<Map<String, dynamic>>()
                .map(SaleFaBatchListDto.fromJson)
                .toList()
          : const [],
      meta: meta is Map<String, dynamic>
          ? PaginationMetaDto.fromJson(meta)
          : const PaginationMetaDto(page: 1, limit: 20, total: 0),
    );
  }

  final List<SaleFaBatchListDto> batches;
  final PaginationMetaDto meta;
}
