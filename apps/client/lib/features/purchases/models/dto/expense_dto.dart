import 'package:billing_baba/features/inventory/models/dto/pagination_meta_dto.dart';

class ExpenseCategoryDto {
  const ExpenseCategoryDto({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ExpenseCategoryDto.fromJson(Map<String, dynamic> json) {
    return ExpenseCategoryDto(
      id: json['id'] as String,
      name: json['name'] as String,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );
  }

  final String id;
  final String name;
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
    this.partyId,
    this.description,
    this.paymentMode,
  });

  factory ExpenseDto.fromJson(Map<String, dynamic> json) {
    return ExpenseDto(
      id: json['id'] as String,
      categoryId: json['category_id'] as String,
      amount: json['amount'] as String,
      expenseDate: json['expense_date'] as String,
      partyId: json['party_id'] as String?,
      description: json['description'] as String?,
      paymentMode: json['payment_mode'] as String?,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );
  }

  final String id;
  final String categoryId;
  final String amount;
  final String expenseDate;
  final String? partyId;
  final String? description;
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
