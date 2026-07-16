import 'package:billing_baba/features/inventory/models/dto/pagination_meta_dto.dart';

class ExpenseCategoryDto {
  const ExpenseCategoryDto({
    required this.id,
    required this.name,
    required this.categoryType,
    required this.isSystem,
    required this.expenseCount,
    required this.totalAmount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ExpenseCategoryDto.fromJson(Map<String, dynamic> json) {
    return ExpenseCategoryDto(
      id: json['id'] as String,
      name: json['name'] as String,
      categoryType: json['category_type'] as String? ?? 'direct',
      isSystem: json['is_system'] as bool? ?? false,
      expenseCount: json['expense_count'] as int? ?? 0,
      totalAmount: json['total_amount'] as String? ?? '0',
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );
  }

  final String id;
  final String name;
  final String categoryType;
  final bool isSystem;
  final int expenseCount;
  final String totalAmount;
  final String createdAt;
  final String updatedAt;
}

class ExpenseDto {
  const ExpenseDto({
    required this.id,
    required this.categoryId,
    required this.amount,
    required this.expenseDate,
    required this.createdAt,
    required this.updatedAt,
    this.categoryName,
    this.partyId,
    this.partyName,
    this.description,
    this.notes,
    this.referenceNumber,
    this.taxAmount,
    this.taxRate,
    this.attachments = const [],
    this.paymentMode,
  });

  factory ExpenseDto.fromJson(Map<String, dynamic> json) {
    return ExpenseDto(
      id: json['id'] as String,
      categoryId: json['category_id'] as String,
      categoryName: json['category_name'] as String?,
      amount: json['amount'] as String,
      expenseDate: json['expense_date'] as String,
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
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );
  }

  final String id;
  final String categoryId;
  final String? categoryName;
  final String amount;
  final String expenseDate;
  final String? partyId;
  final String? partyName;
  final String? description;
  final String? notes;
  final String? referenceNumber;
  final String? taxAmount;
  final String? taxRate;
  final List<String> attachments;
  final String? paymentMode;
  final String createdAt;
  final String updatedAt;
}

class PaginatedExpensesDto {
  const PaginatedExpensesDto({required this.expenses, required this.meta});

  factory PaginatedExpensesDto.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final meta = json['meta'];
    return PaginatedExpensesDto(
      expenses: data is List
          ? data
                .whereType<Map<String, dynamic>>()
                .map(ExpenseDto.fromJson)
                .toList()
          : const [],
      meta: meta is Map<String, dynamic>
          ? PaginationMetaDto.fromJson(meta)
          : const PaginationMetaDto(page: 1, limit: 20, total: 0),
    );
  }

  final List<ExpenseDto> expenses;
  final PaginationMetaDto meta;
}

class PaginatedExpenseCategoriesDto {
  const PaginatedExpenseCategoriesDto({
    required this.categories,
    required this.meta,
  });

  factory PaginatedExpenseCategoriesDto.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final meta = json['meta'];
    return PaginatedExpenseCategoriesDto(
      categories: data is List
          ? data
                .whereType<Map<String, dynamic>>()
                .map(ExpenseCategoryDto.fromJson)
                .toList()
          : const [],
      meta: meta is Map<String, dynamic>
          ? PaginationMetaDto.fromJson(meta)
          : const PaginationMetaDto(page: 1, limit: 20, total: 0),
    );
  }

  final List<ExpenseCategoryDto> categories;
  final PaginationMetaDto meta;
}
