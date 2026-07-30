import 'package:billing_baba/features/parties/models/party_ledger_model.dart';

enum PartyProjectionSyncStatus {
  synced,
  syncPending,
  local,
}

/// Locally computed party profile snapshot built entirely from Drift.
class PartyProjection {
  const PartyProjection({
    required this.partyId,
    required this.ledger,
    required this.outstanding,
    required this.receivable,
    required this.payable,
    required this.openingBalance,
    required this.currentBalance,
    required this.transactionCount,
    required this.totalSales,
    required this.totalPurchases,
    required this.totalPayments,
    required this.totalReturns,
    required this.averageInvoiceValue,
    required this.pendingAmount,
    required this.syncStatus,
    this.lastTransaction,
    this.lastActivity,
    this.averagePaymentDays,
  });

  final String partyId;
  final PartyLedgerModel ledger;
  final double outstanding;
  final double receivable;
  final double payable;
  final double openingBalance;
  final double currentBalance;
  final DateTime? lastTransaction;
  final int transactionCount;
  final double totalSales;
  final double totalPurchases;
  final double totalPayments;
  final double totalReturns;
  final double averageInvoiceValue;
  final double? averagePaymentDays;
  final double pendingAmount;
  final DateTime? lastActivity;
  final PartyProjectionSyncStatus syncStatus;

  PartyLedgerSummaryModel get summary => ledger.summary;
  List<PartyLedgerTransactionModel> get transactions => ledger.transactions;
}
