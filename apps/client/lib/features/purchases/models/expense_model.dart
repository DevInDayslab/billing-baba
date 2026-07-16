enum ExpenseStatus { paid, pending, partial }

enum ExpenseCategoryType { direct, indirect }

/// Determines which transaction columns to show in the detail panel.
enum ExpenseCategoryVariant { standard, loyaltyRedeemed }

class ExpenseCategoryModel {
  const ExpenseCategoryModel({
    required this.id,
    required this.name,
    required this.type,
    required this.variant,
    required this.totalAmount,
    required this.balance,
  });

  final String id;
  final String name;
  final ExpenseCategoryType type;
  final ExpenseCategoryVariant variant;
  final double totalAmount;
  final double balance;

  String get typeLabel => switch (type) {
    ExpenseCategoryType.direct => 'Direct Expense',
    ExpenseCategoryType.indirect => 'Indirect Expense',
  };
}

class ExpenseTransactionModel {
  const ExpenseTransactionModel({
    required this.id,
    required this.date,
    required this.transactionNo,
    required this.party,
    this.categoryId,
    this.itemId,
    this.paymentType,
    this.amount,
    this.balance,
    this.dueDate,
    this.status,
    this.loyaltyPoints,
    this.loyaltyValue,
  });

  final String id;
  final String? categoryId;
  final String? itemId;
  final DateTime date;
  final String transactionNo;
  final String party;
  final String? paymentType;
  final double? amount;
  final double? balance;
  final DateTime? dueDate;
  final ExpenseStatus? status;
  final double? loyaltyPoints;
  final double? loyaltyValue;
}

class ExpenseItemModel {
  const ExpenseItemModel({
    required this.id,
    required this.name,
    required this.category,
    required this.amount,
    this.description = '',
  });

  final String id;
  final String name;
  final String category;
  final double amount;
  final String description;
}

/// Legacy flat expense record kept for compatibility.
class ExpenseModel {
  const ExpenseModel({
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
  final ExpenseStatus status;
  final double amount;
  final String user;
  final String firm;
}
