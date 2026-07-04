import 'package:billing_baba/features/inventory/models/dto/pagination_meta_dto.dart';

class JobWorkRawMaterialDto {
  const JobWorkRawMaterialDto({
    required this.id,
    required this.itemId,
    required this.quantity,
    required this.unit,
    required this.purchasePrice,
    required this.lineTotal,
    required this.sortOrder,
  });

  factory JobWorkRawMaterialDto.fromJson(Map<String, dynamic> json) {
    return JobWorkRawMaterialDto(
      id: json['id'] as String,
      itemId: json['item_id'] as String,
      quantity: json['quantity'] as String,
      unit: json['unit'] as String,
      purchasePrice: json['purchase_price'] as String? ?? '0',
      lineTotal: json['line_total'] as String? ?? '0',
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
    );
  }

  final String id;
  final String itemId;
  final String quantity;
  final String unit;
  final String purchasePrice;
  final String lineTotal;
  final int sortOrder;
}

class JobWorkAdditionalCostDto {
  const JobWorkAdditionalCostDto({
    required this.id,
    required this.label,
    required this.amount,
    required this.sortOrder,
  });

  factory JobWorkAdditionalCostDto.fromJson(Map<String, dynamic> json) {
    return JobWorkAdditionalCostDto(
      id: json['id'] as String,
      label: json['label'] as String,
      amount: json['amount'] as String,
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
    );
  }

  final String id;
  final String label;
  final String amount;
  final int sortOrder;
}

class JobWorkOrderDto {
  const JobWorkOrderDto({
    required this.id,
    required this.status,
    required this.orderDate,
    required this.finishedGoodName,
    required this.finishedGoodQuantity,
    required this.finishedGoodUnit,
    required this.rawMaterialsTotal,
    required this.additionalCostsTotal,
    required this.grandTotal,
    required this.createdAt,
    required this.updatedAt,
    this.partyId,
    this.jobNumber,
    this.deliveryDate,
    this.notes,
    this.rawMaterials = const [],
    this.additionalCosts = const [],
  });

  factory JobWorkOrderDto.fromJson(Map<String, dynamic> json) {
    final rawMaterials = json['raw_materials'];
    final additionalCosts = json['additional_costs'];

    return JobWorkOrderDto(
      id: json['id'] as String,
      partyId: json['party_id'] as String?,
      jobNumber: json['job_number'] as String?,
      status: json['status'] as String,
      orderDate: json['order_date'] as String,
      deliveryDate: json['delivery_date'] as String?,
      finishedGoodName: json['finished_good_name'] as String,
      finishedGoodQuantity: json['finished_good_quantity'] as String? ?? '1',
      finishedGoodUnit: json['finished_good_unit'] as String? ?? 'PCS',
      rawMaterialsTotal: json['raw_materials_total'] as String? ?? '0',
      additionalCostsTotal: json['additional_costs_total'] as String? ?? '0',
      grandTotal: json['grand_total'] as String? ?? '0',
      notes: json['notes'] as String?,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      rawMaterials: rawMaterials is List
          ? rawMaterials
                .map(
                  (item) => JobWorkRawMaterialDto.fromJson(
                    item as Map<String, dynamic>,
                  ),
                )
                .toList()
          : const [],
      additionalCosts: additionalCosts is List
          ? additionalCosts
                .map(
                  (item) => JobWorkAdditionalCostDto.fromJson(
                    item as Map<String, dynamic>,
                  ),
                )
                .toList()
          : const [],
    );
  }

  final String id;
  final String? partyId;
  final String? jobNumber;
  final String status;
  final String orderDate;
  final String? deliveryDate;
  final String finishedGoodName;
  final String finishedGoodQuantity;
  final String finishedGoodUnit;
  final String rawMaterialsTotal;
  final String additionalCostsTotal;
  final String grandTotal;
  final String? notes;
  final String createdAt;
  final String updatedAt;
  final List<JobWorkRawMaterialDto> rawMaterials;
  final List<JobWorkAdditionalCostDto> additionalCosts;
}

class PaginatedJobWorkOrdersDto {
  const PaginatedJobWorkOrdersDto({
    required this.orders,
    required this.meta,
  });

  factory PaginatedJobWorkOrdersDto.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return PaginatedJobWorkOrdersDto(
      orders: data is List
          ? data
                .map(
                  (item) =>
                      JobWorkOrderDto.fromJson(item as Map<String, dynamic>),
                )
                .toList()
          : const [],
      meta: PaginationMetaDto.fromJson(
        (json['meta'] as Map<String, dynamic>?) ?? const {},
      ),
    );
  }

  final List<JobWorkOrderDto> orders;
  final PaginationMetaDto meta;
}
