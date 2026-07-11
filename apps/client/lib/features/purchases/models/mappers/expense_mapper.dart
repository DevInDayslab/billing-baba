import 'package:billing_baba/features/purchases/models/dto/expense_dto.dart';
import 'package:billing_baba/features/purchases/models/expense_model.dart';
import 'package:billing_baba/features/purchases/purchase_constants.dart';

class ExpenseMapper {
  const ExpenseMapper._();

  static ExpenseCategoryModel toCategoryModel(ExpenseCategoryDto dto) {
    final type = dto.categoryType == 'indirect'
        ? ExpenseCategoryType.indirect
        : ExpenseCategoryType.direct;
    final variant =
        dto.isSystem && dto.name.toLowerCase().contains('loyalty')
        ? ExpenseCategoryVariant.loyaltyRedeemed
        : ExpenseCategoryVariant.standard;

    return ExpenseCategoryModel(
      id: dto.id,
      name: dto.name,
      type: type,
      variant: variant,
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
    final isPaid = paymentMode != null && paymentMode.isNotEmpty;

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
      balance: isPaid ? 0 : amount,
      status: isPaid ? ExpenseStatus.paid : ExpenseStatus.pending,
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
