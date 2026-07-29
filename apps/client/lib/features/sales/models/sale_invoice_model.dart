import 'package:billing_baba/features/sales/sales_constants.dart';

enum SaleInvoiceStatus {
  paid,
  unpaid,
  partiallyPaid,
  overdue,
  cancelled,
}

enum SaleInvoiceSyncState {
  none,
  savedLocally,
  syncing,
  synced,
  conflict,
}

class SaleInvoiceSummaryData {
  const SaleInvoiceSummaryData({
    required this.totalSalesAmount,
    required this.receivedAmount,
    required this.balanceAmount,
    this.loyaltyPointsRewarded = 0,
    this.totalDiscountRedeemed = 0,
  });

  final double totalSalesAmount;
  final double receivedAmount;
  final double balanceAmount;
  final double loyaltyPointsRewarded;
  final double totalDiscountRedeemed;
}

class SaleInvoiceModel {
  const SaleInvoiceModel({
    required this.id,
    required this.invoiceNo,
    required this.date,
    required this.partyName,
    required this.transactionType,
    required this.paymentType,
    required this.status,
    required this.amount,
    required this.balance,
    this.documentStatus = SalesDocumentStatus.finalized,
    this.partyId,
    this.documentSeries,
    this.user = 'Admin',
    this.godown = 'Main Location',
    this.firm = 'Main Firm',
    this.loyaltyRedeemed = 0,
    this.dueDate,
    this.syncState = SaleInvoiceSyncState.none,
  });

  final String id;
  final String invoiceNo;
  final DateTime date;
  final String partyName;
  final String? partyId;
  final String transactionType;
  final String paymentType;
  final SaleInvoiceStatus status;
  final SalesDocumentStatus documentStatus;
  final String? documentSeries;
  final double amount;
  final double balance;
  final String user;
  final String godown;
  final String firm;
  final double loyaltyRedeemed;
  final DateTime? dueDate;
  final SaleInvoiceSyncState syncState;

  bool get isDraft => documentStatus == SalesDocumentStatus.draft;

  bool get isCancelled => documentStatus == SalesDocumentStatus.cancelled;

  SaleInvoiceModel copyWith({
    String? id,
    String? invoiceNo,
    DateTime? date,
    String? partyName,
    String? partyId,
    String? transactionType,
    String? paymentType,
    SaleInvoiceStatus? status,
    SalesDocumentStatus? documentStatus,
    String? documentSeries,
    double? amount,
    double? balance,
    String? user,
    String? godown,
    String? firm,
    double? loyaltyRedeemed,
    DateTime? dueDate,
    SaleInvoiceSyncState? syncState,
  }) {
    return SaleInvoiceModel(
      id: id ?? this.id,
      invoiceNo: invoiceNo ?? this.invoiceNo,
      date: date ?? this.date,
      partyName: partyName ?? this.partyName,
      partyId: partyId ?? this.partyId,
      transactionType: transactionType ?? this.transactionType,
      paymentType: paymentType ?? this.paymentType,
      status: status ?? this.status,
      documentStatus: documentStatus ?? this.documentStatus,
      documentSeries: documentSeries ?? this.documentSeries,
      amount: amount ?? this.amount,
      balance: balance ?? this.balance,
      user: user ?? this.user,
      godown: godown ?? this.godown,
      firm: firm ?? this.firm,
      loyaltyRedeemed: loyaltyRedeemed ?? this.loyaltyRedeemed,
      dueDate: dueDate ?? this.dueDate,
      syncState: syncState ?? this.syncState,
    );
  }
}

class PaginatedSaleInvoices {
  const PaginatedSaleInvoices({
    required this.items,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    this.summary,
  });

  final List<SaleInvoiceModel> items;
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final SaleInvoiceSummaryData? summary;
}
