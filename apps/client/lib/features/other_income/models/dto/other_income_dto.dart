import 'package:billing_baba/features/inventory/models/dto/pagination_meta_dto.dart';

class IncomeCategoryDto {
  const IncomeCategoryDto({
    required this.id,
    required this.name,
    required this.categoryType,
    required this.isSystem,
    required this.incomeCount,
    required this.totalAmount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory IncomeCategoryDto.fromJson(Map<String, dynamic> json) {
    return IncomeCategoryDto(
      id: json['id'] as String,
      name: json['name'] as String,
      categoryType: json['category_type'] as String? ?? 'direct',
      isSystem: json['is_system'] as bool? ?? false,
      incomeCount: json['income_count'] as int? ?? 0,
      totalAmount: json['total_amount'] as String? ?? '0',
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );
  }

  final String id;
  final String name;
  final String categoryType;
  final bool isSystem;
  final int incomeCount;
  final String totalAmount;
  final String createdAt;
  final String updatedAt;
}

class IncomeItemDto {
  const IncomeItemDto({
    required this.id,
    required this.name,
    required this.price,
    required this.priceIsTaxInclusive,
    required this.taxRate,
    required this.incomeCount,
    required this.totalAmount,
    required this.createdAt,
    required this.updatedAt,
    this.hsnSac,
  });

  factory IncomeItemDto.fromJson(Map<String, dynamic> json) {
    return IncomeItemDto(
      id: json['id'] as String,
      name: json['name'] as String,
      hsnSac: json['hsn_sac'] as String?,
      price: json['price'] as String? ?? '0',
      priceIsTaxInclusive: json['price_is_tax_inclusive'] as bool? ?? false,
      taxRate: json['tax_rate'] as String? ?? '0',
      incomeCount: json['income_count'] as int? ?? 0,
      totalAmount: json['total_amount'] as String? ?? '0',
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );
  }

  final String id;
  final String name;
  final String? hsnSac;
  final String price;
  final bool priceIsTaxInclusive;
  final String taxRate;
  final int incomeCount;
  final String totalAmount;
  final String createdAt;
  final String updatedAt;
}

class OtherIncomeDto {
  const OtherIncomeDto({
    required this.id,
    required this.categoryId,
    required this.amount,
    required this.incomeDate,
    required this.createdAt,
    required this.updatedAt,
    this.categoryName,
    this.incomeItemId,
    this.partyId,
    this.partyName,
    this.description,
    this.notes,
    this.referenceNumber,
    this.taxAmount,
    this.taxRate,
    this.attachments = const [],
    this.paymentMode,
    this.bankAccountId,
    this.sourceReferenceId,
    this.sourceReferenceType,
    this.loyaltyPoints,
    this.dueDate,
    this.balanceDue,
  });

  factory OtherIncomeDto.fromJson(Map<String, dynamic> json) {
    return OtherIncomeDto(
      id: json['id'] as String,
      categoryId: json['category_id'] as String,
      categoryName: json['category_name'] as String?,
      incomeItemId: json['income_item_id'] as String?,
      amount: json['amount'] as String,
      incomeDate: json['income_date'] as String,
      partyId: json['party_id'] as String?,
      partyName: json['party_name'] as String?,
      description: json['description'] as String?,
      notes: json['notes'] as String?,
      referenceNumber: json['reference_number'] as String?,
      taxAmount: json['tax_amount'] as String?,
      taxRate: json['tax_rate'] as String?,
      attachments: json['attachments'] is List
          ? (json['attachments'] as List).whereType<String>().toList(
              growable: false,
            )
          : const [],
      paymentMode: json['payment_mode'] as String?,
      bankAccountId: json['bank_account_id'] as String?,
      sourceReferenceId: json['source_reference_id'] as String?,
      sourceReferenceType: json['source_reference_type'] as String?,
      loyaltyPoints: json['loyalty_points'] as String?,
      dueDate: json['due_date'] as String?,
      balanceDue: json['balance_due'] as String?,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );
  }

  final String id;
  final String categoryId;
  final String? categoryName;
  final String? incomeItemId;
  final String amount;
  final String incomeDate;
  final String? partyId;
  final String? partyName;
  final String? description;
  final String? notes;
  final String? referenceNumber;
  final String? taxAmount;
  final String? taxRate;
  final List<String> attachments;
  final String? paymentMode;
  final String? bankAccountId;
  final String? sourceReferenceId;
  final String? sourceReferenceType;
  final String? loyaltyPoints;
  final String? dueDate;
  final String? balanceDue;
  final String createdAt;
  final String updatedAt;
}

class PaginatedOtherIncomesDto {
  const PaginatedOtherIncomesDto({required this.incomes, required this.meta});

  factory PaginatedOtherIncomesDto.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final meta = json['meta'];
    return PaginatedOtherIncomesDto(
      incomes: data is List
          ? data
                .whereType<Map<String, dynamic>>()
                .map(OtherIncomeDto.fromJson)
                .toList()
          : const [],
      meta: meta is Map<String, dynamic>
          ? PaginationMetaDto.fromJson(meta)
          : const PaginationMetaDto(page: 1, limit: 20, total: 0),
    );
  }

  final List<OtherIncomeDto> incomes;
  final PaginationMetaDto meta;
}

class PaginatedIncomeItemsDto {
  const PaginatedIncomeItemsDto({required this.items, required this.meta});

  factory PaginatedIncomeItemsDto.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final meta = json['meta'];
    return PaginatedIncomeItemsDto(
      items: data is List
          ? data
                .whereType<Map<String, dynamic>>()
                .map(IncomeItemDto.fromJson)
                .toList()
          : const [],
      meta: meta is Map<String, dynamic>
          ? PaginationMetaDto.fromJson(meta)
          : const PaginationMetaDto(page: 1, limit: 20, total: 0),
    );
  }

  final List<IncomeItemDto> items;
  final PaginationMetaDto meta;
}

class PaginatedIncomeCategoriesDto {
  const PaginatedIncomeCategoriesDto({
    required this.categories,
    required this.meta,
  });

  factory PaginatedIncomeCategoriesDto.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final meta = json['meta'];
    return PaginatedIncomeCategoriesDto(
      categories: data is List
          ? data
                .whereType<Map<String, dynamic>>()
                .map(IncomeCategoryDto.fromJson)
                .toList()
          : const [],
      meta: meta is Map<String, dynamic>
          ? PaginationMetaDto.fromJson(meta)
          : const PaginationMetaDto(page: 1, limit: 20, total: 0),
    );
  }

  final List<IncomeCategoryDto> categories;
  final PaginationMetaDto meta;
}
