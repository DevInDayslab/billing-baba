import 'package:billing_baba/features/other_income/models/dto/other_income_dto.dart';
import 'package:billing_baba/features/other_income/models/other_income_model.dart';
import 'package:billing_baba/features/purchases/purchase_constants.dart';

class OtherIncomeMapper {
  const OtherIncomeMapper._();

  static IncomeCategoryVariant _categoryVariantFromName(String? name) {
    final normalized = name?.trim().toLowerCase() ?? '';
    if (normalized.contains('loyalty')) {
      return IncomeCategoryVariant.loyaltyRedeemed;
    }
    if (normalized.contains('payment-in discount') ||
        normalized.contains('payment in discount')) {
      return IncomeCategoryVariant.paymentInDiscount;
    }
    return IncomeCategoryVariant.standard;
  }

  static IncomeCategoryVariant _categoryVariant(IncomeCategoryDto dto) {
    if (!dto.isSystem) {
      return IncomeCategoryVariant.standard;
    }
    return _categoryVariantFromName(dto.name);
  }

  static IncomeCategoryModel toCategoryModel(IncomeCategoryDto dto) {
    final type = dto.categoryType == 'indirect'
        ? IncomeCategoryType.indirect
        : IncomeCategoryType.direct;

    return IncomeCategoryModel(
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

  static OtherIncomeTransactionModel toTransactionModel(OtherIncomeDto dto) {
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
        ? OtherIncomeStatus.paid
        : isPaid
        ? OtherIncomeStatus.partial
        : OtherIncomeStatus.pending;

    final categoryVariant = _categoryVariantFromName(dto.categoryName);
    final isSyncManaged =
        dto.sourceReferenceId != null && dto.sourceReferenceId!.isNotEmpty;

    final incomeItemId = dto.incomeItemId;
    return OtherIncomeTransactionModel(
      id: dto.id,
      categoryId: dto.categoryId,
      incomeItemId: incomeItemId,
      itemId: incomeItemId ??
          itemGroupKey(
            categoryId: dto.categoryId,
            description: description,
          ),
      date: DateTime.tryParse(dto.incomeDate) ?? DateTime.now(),
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

  static List<OtherIncomeTransactionModel> toTransactionModels(
    List<OtherIncomeDto> dtos,
  ) {
    return dtos.map(toTransactionModel).toList(growable: false);
  }

  static IncomeCatalogItemModel toCatalogItemModel(IncomeItemDto dto) {
    return IncomeCatalogItemModel(
      id: dto.id,
      name: dto.name,
      hsnSac: dto.hsnSac,
      price: double.tryParse(dto.price) ?? 0,
      priceIsTaxInclusive: dto.priceIsTaxInclusive,
      taxRate: double.tryParse(dto.taxRate) ?? 0,
    );
  }

  static List<IncomeItemModel> catalogToListItems(
    List<IncomeCatalogItemModel> catalog, {
    List<OtherIncomeTransactionModel> transactions = const [],
  }) {
    return catalog.map((item) {
      final linked = transactions.where(
        (transaction) => transaction.incomeItemId == item.id,
      );
      final total = linked.fold<double>(
        0,
        (sum, transaction) => sum + (transaction.amount ?? 0),
      );
      return IncomeItemModel(
        id: item.id,
        name: item.name,
        category: '',
        amount: total > 0 ? total : item.price,
        description: item.name,
        defaultPrice: item.price,
      );
    }).toList();
  }

  static List<IncomeItemModel> groupTransactionsToItems(
    List<OtherIncomeTransactionModel> transactions, {
    Map<String, String> categoryNames = const {},
  }) {
    final grouped = <String, List<OtherIncomeTransactionModel>>{};

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

      return IncomeItemModel(
        id: entry.key,
        name: description.isNotEmpty ? description : 'Unnamed item',
        category: categoryNames[categoryId] ?? categoryId,
        amount: total,
        description: description,
      );
    }).toList();
  }
}
