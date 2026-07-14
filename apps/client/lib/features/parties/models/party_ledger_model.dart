enum PartyLedgerFilter {
  all,
  sales,
  purchases,
  payments,
  returns;

  String get apiValue => switch (this) {
    PartyLedgerFilter.all => 'all',
    PartyLedgerFilter.sales => 'sales',
    PartyLedgerFilter.purchases => 'purchases',
    PartyLedgerFilter.payments => 'payments',
    PartyLedgerFilter.returns => 'returns',
  };

  String get label => switch (this) {
    PartyLedgerFilter.all => 'All',
    PartyLedgerFilter.sales => 'Sales',
    PartyLedgerFilter.purchases => 'Purchases',
    PartyLedgerFilter.payments => 'Payments',
    PartyLedgerFilter.returns => 'Returns',
  };

  bool matches(PartyLedgerTransactionModel transaction) => switch (this) {
    PartyLedgerFilter.all => true,
    PartyLedgerFilter.sales =>
      (transaction.source == 'sales_documents' &&
              transaction.sourceType != 'sales_return') ||
          transaction.source == 'sale_fa_batches' ||
          transaction.source == 'job_work_orders',
    PartyLedgerFilter.purchases =>
      (transaction.source == 'purchase_documents' &&
              transaction.sourceType != 'purchase_return') ||
          transaction.source == 'purchase_fa_batches' ||
          transaction.source == 'expenses',
    PartyLedgerFilter.payments => transaction.source == 'payments',
    PartyLedgerFilter.returns =>
      transaction.sourceType == 'sales_return' ||
      transaction.sourceType == 'purchase_return',
  };
}

class PartyLedgerSummaryModel {
  const PartyLedgerSummaryModel({
    required this.openingBalance,
    required this.outstanding,
    required this.receiveAmount,
    required this.payableAmount,
    required this.isActive, required this.totalSales, required this.totalPurchases, required this.totalPayments, this.creditLimit,
    this.lastTransactionDate,
  });

  final double openingBalance;
  final double outstanding;
  final double receiveAmount;
  final double payableAmount;
  final double? creditLimit;
  final bool isActive;
  final DateTime? lastTransactionDate;
  final double totalSales;
  final double totalPurchases;
  final double totalPayments;

  bool get hasReceivable => outstanding > 0;
  bool get hasPayable => outstanding < 0;
}

class PartyLedgerTransactionModel {
  const PartyLedgerTransactionModel({
    required this.id,
    required this.date,
    required this.createdAt,
    required this.type,
    required this.entryType,
    required this.source,
    required this.sourceType,
    required this.debit, required this.credit, required this.balanceAfter, required this.total, required this.balance, this.referenceId,
    this.referenceType,
    this.referenceNumber,
    this.description,
    this.documentDate,
    this.dueDate,
    this.status,
    this.direction,
    this.paymentStatus,
  });

  final String id;
  final DateTime date;
  final DateTime createdAt;
  final String type;
  final String entryType;
  final String source;
  final String sourceType;
  final String? referenceId;
  final String? referenceType;
  final String? referenceNumber;
  final String? description;
  final DateTime? documentDate;
  final DateTime? dueDate;
  final double total;
  final double balance;
  final String? status;
  final double debit;
  final double credit;
  final double balanceAfter;
  final String? direction;
  final String? paymentStatus;

  bool get isPayment => source == 'payments';
}

class PartyLedgerModel {
  const PartyLedgerModel({
    required this.partyId,
    required this.summary,
    required this.transactions,
  });

  final String partyId;
  final PartyLedgerSummaryModel summary;
  final List<PartyLedgerTransactionModel> transactions;
}

typedef PartyTimelineModel = PartyLedgerModel;
typedef PartyTimelineTransactionModel = PartyLedgerTransactionModel;
