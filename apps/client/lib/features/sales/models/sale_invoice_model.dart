import 'package:billing_baba/features/sales/sales_constants.dart';

enum SaleInvoiceStatus {
  paid,
  unpaid,
  partiallyPaid,
  overdue,
  cancelled,
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
    this.user = 'Admin',
    this.godown = 'Main Location',
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
  final double amount;
  final double balance;
  final String user;
  final String godown;

  bool get isDraft => documentStatus == SalesDocumentStatus.draft;

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
    double? amount,
    double? balance,
    String? user,
    String? godown,
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
      amount: amount ?? this.amount,
      balance: balance ?? this.balance,
      user: user ?? this.user,
      godown: godown ?? this.godown,
    );
  }
}

class PaginatedSaleInvoices {
  const PaginatedSaleInvoices({
    required this.items,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
  });

  final List<SaleInvoiceModel> items;
  final int currentPage;
  final int totalPages;
  final int totalItems;
}
