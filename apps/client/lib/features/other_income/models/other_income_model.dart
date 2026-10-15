enum OtherIncomeStatus { paid, pending, partial }

enum IncomeCategoryType { direct, indirect }

/// Determines which transaction columns to show in the detail panel.
enum IncomeCategoryVariant { standard, loyaltyRedeemed, paymentInDiscount }

extension IncomeCategoryVariantX on IncomeCategoryVariant {
  /// Indirect expenses created automatically from sales/payments — not manual.
  bool get isSyncOnly =>
      this == IncomeCategoryVariant.loyaltyRedeemed ||
      this == IncomeCategoryVariant.paymentInDiscount;

  bool get isManual => !isSyncOnly;
}

class IncomeCategoryModel {
  const IncomeCategoryModel({
    required this.id,
    required this.name,
    required this.type,
    required this.variant,
    required this.totalAmount,
    required this.balance,
  });

  final String id;
  final String name;
  final IncomeCategoryType type;
  final IncomeCategoryVariant variant;
  final double totalAmount;
  final double balance;

  String get typeLabel => switch (type) {
    IncomeCategoryType.direct => 'Direct Income',
    IncomeCategoryType.indirect => 'Indirect Income',
  };
}

class OtherIncomeTransactionModel {
  const OtherIncomeTransactionModel({
    required this.id,
    required this.date,
    required this.transactionNo,
    required this.party,
    this.categoryId,
    this.incomeItemId,
    this.itemId,
    this.paymentType,
    this.amount,
    this.balance,
    this.dueDate,
    this.status,
    this.loyaltyPoints,
    this.loyaltyValue,
    this.categoryVariant = IncomeCategoryVariant.standard,
    this.isSyncManaged = false,
  });

  final String id;
  final String? categoryId;
  final String? incomeItemId;
  final String? itemId;
  final DateTime date;
  final String transactionNo;
  final String party;
  final String? paymentType;
  final double? amount;
  final double? balance;
  final DateTime? dueDate;
  final OtherIncomeStatus? status;
  final double? loyaltyPoints;
  final double? loyaltyValue;
  final IncomeCategoryVariant categoryVariant;
  final bool isSyncManaged;
}

class IncomeCatalogItemModel {
  const IncomeCatalogItemModel({
    required this.id,
    required this.name,
    required this.price,
    required this.priceIsTaxInclusive,
    required this.taxRate,
    this.hsnSac,
  });

  final String id;
  final String name;
  final String? hsnSac;
  final double price;
  final bool priceIsTaxInclusive;
  final double taxRate;
}

class IncomeItemModel {
  const IncomeItemModel({
    required this.id,
    required this.name,
    required this.category,
    required this.amount,
    this.description = '',
    this.defaultPrice = 0,
  });

  final String id;
  final String name;
  final String category;
  final double amount;
  final String description;
  final double defaultPrice;
}

/// Legacy flat expense record kept for compatibility.
class OtherIncomeModel {
  const OtherIncomeModel({
    required this.id,
    required this.expenseNo,
    required this.date,
    required this.category,
    required this.description,
    required this.paymentType,
    required this.status,
    required this.amount,
    this.user = 'Admin',
    this.firm = 'All Firms',
  });

  final String id;
  final String expenseNo;
  final DateTime date;
  final String category;
  final String description;
  final String paymentType;
  final OtherIncomeStatus status;
  final double amount;
  final String user;
  final String firm;
}
