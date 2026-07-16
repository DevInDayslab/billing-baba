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
    PartyLedgerFilter.sales => transaction.entryType == 'sale',
    PartyLedgerFilter.purchases => transaction.entryType == 'purchase',
    PartyLedgerFilter.payments => transaction.entryType == 'payment',
    PartyLedgerFilter.returns => transaction.entryType == 'return',
  };
}

class PartyLedgerSummaryModel {
  const PartyLedgerSummaryModel({
    required this.openingBalance,
    required this.outstanding,
    required this.receiveAmount,
    required this.payableAmount,
    required this.isActive,
    required this.totalSales,
    required this.totalPurchases,
    required this.totalPayments,
    this.creditLimit,
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
    required this.debit,
    required this.credit,
    required this.balanceAfter,
    this.referenceId,
    this.referenceType,
    this.referenceNumber,
    this.description,
    this.direction,
  });

  final String id;
  final DateTime date;
  final DateTime createdAt;
  final String type;
  final String entryType;
  final String? referenceId;
  final String? referenceType;
  final String? referenceNumber;
  final String? description;
  final double debit;
  final double credit;
  final double balanceAfter;
  final String? direction;
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
