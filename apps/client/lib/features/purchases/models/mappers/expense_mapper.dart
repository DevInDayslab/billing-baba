import 'package:billing_baba/features/purchases/models/dto/expense_dto.dart';
import 'package:billing_baba/features/purchases/models/expense_model.dart';
import 'package:billing_baba/features/purchases/purchase_constants.dart';

class ExpenseMapper {
  const ExpenseMapper._();

  static ExpenseCategoryVariant _categoryVariantFromName(String? name) {
    final normalized = name?.trim().toLowerCase() ?? '';
    if (normalized.contains('loyalty')) {
      return ExpenseCategoryVariant.loyaltyRedeemed;
    }
    if (normalized.contains('payment-in discount') ||
        normalized.contains('payment in discount')) {
      return ExpenseCategoryVariant.paymentInDiscount;
    }
    return ExpenseCategoryVariant.standard;
  }

  static ExpenseCategoryVariant _categoryVariant(ExpenseCategoryDto dto) {
    if (!dto.isSystem) {
      return ExpenseCategoryVariant.standard;
    }
    return _categoryVariantFromName(dto.name);
  }

  static ExpenseCategoryModel toCategoryModel(ExpenseCategoryDto dto) {
    final type = dto.categoryType == 'indirect'
        ? ExpenseCategoryType.indirect
        : ExpenseCategoryType.direct;

    return ExpenseCategoryModel(
      id: dto.id,
      name: dto.name,
      type: type,
      variant: _categoryVariant(dto),
      totalAmount: double.tryParse(dto.totalAmount) ?? 0,
      balance: 0,
    );
  }

  static String itemGroupKey({
    required String categoryId,
    required String description,
  }) {
    return '$categoryId|${description.trim()}';
  }

  static ExpenseTransactionModel toTransactionModel(ExpenseDto dto) {
    final description = dto.description?.trim() ?? '';
    final paymentMode = dto.paymentMode;
    final amount = double.tryParse(dto.amount) ?? 0;
    final balanceDue = dto.balanceDue != null
        ? double.tryParse(dto.balanceDue!) ?? 0
        : null;
    final loyaltyPoints = dto.loyaltyPoints != null
        ? double.tryParse(dto.loyaltyPoints!) ?? 0
        : null;
    final loyaltyValue = loyaltyPoints != null && loyaltyPoints > 0
        ? amount
        : null;
    final isPaid = paymentMode != null && paymentMode.isNotEmpty;
    final balance = balanceDue ?? (isPaid ? 0 : amount);
    final status = balance <= 0
        ? ExpenseStatus.paid
        : isPaid
        ? ExpenseStatus.partial
        : ExpenseStatus.pending;

    final categoryVariant = _categoryVariantFromName(dto.categoryName);
    final isSyncManaged =
        dto.sourceReferenceId != null && dto.sourceReferenceId!.isNotEmpty;

    return ExpenseTransactionModel(
      id: dto.id,
      categoryId: dto.categoryId,
      itemId: itemGroupKey(
        categoryId: dto.categoryId,
        description: description,
      ),
      date: DateTime.tryParse(dto.expenseDate) ?? DateTime.now(),
      transactionNo: dto.referenceNumber?.trim().isNotEmpty == true
          ? dto.referenceNumber!.trim()
          : dto.id.substring(0, 8),
      party: dto.partyName?.trim() ?? '',
      paymentType: paymentMode == null
          ? null
          : PurchasePaymentModes.toUi(paymentMode),
      amount: amount,
      balance: balance,
      dueDate: dto.dueDate != null ? DateTime.tryParse(dto.dueDate!) : null,
      status: status,
      loyaltyPoints: loyaltyPoints,
      loyaltyValue: loyaltyValue,
      categoryVariant: categoryVariant,
      isSyncManaged: isSyncManaged,
    );
  }

  static List<ExpenseTransactionModel> toTransactionModels(
    List<ExpenseDto> dtos,
  ) {
    return dtos.map(toTransactionModel).toList(growable: false);
  }

  static List<ExpenseItemModel> groupTransactionsToItems(
    List<ExpenseTransactionModel> transactions, {
    Map<String, String> categoryNames = const {},
  }) {
    final grouped = <String, List<ExpenseTransactionModel>>{};

    for (final transaction in transactions) {
      final key = transaction.itemId;
      if (key == null || key.isEmpty) continue;
      grouped.putIfAbsent(key, () => []).add(transaction);
    }

    return grouped.entries.map((entry) {
      final txns = entry.value;
      final first = txns.first;
      final categoryId = first.categoryId ?? '';
      final separatorIndex = entry.key.indexOf('|');
      final description = separatorIndex >= 0
          ? entry.key.substring(separatorIndex + 1)
          : '';
      final total = txns.fold<double>(
        0,
        (sum, transaction) => sum + (transaction.amount ?? 0),
      );

      return ExpenseItemModel(
        id: entry.key,
        name: description.isNotEmpty ? description : 'Unnamed item',
        category: categoryNames[categoryId] ?? categoryId,
        amount: total,
        description: description,
      );
    }).toList();
  }
}
