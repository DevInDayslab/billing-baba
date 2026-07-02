import 'package:billing_baba/features/sales/models/sale_invoice_model.dart';

class PartyTransactionModel {
  const PartyTransactionModel({
    required this.id,
    required this.partyId,
    required this.invoiceNo,
    required this.date,
    required this.transactionType,
    required this.paymentType,
    required this.status,
    required this.amount,
    required this.balance,
  });

  final String id;
  final String partyId;
  final String invoiceNo;
  final DateTime date;
  final String transactionType;
  final String paymentType;
  final SaleInvoiceStatus status;
  final double amount;
  final double balance;

  PartyTransactionModel copyWith({
    String? id,
    String? partyId,
    String? invoiceNo,
    DateTime? date,
    String? transactionType,
    String? paymentType,
    SaleInvoiceStatus? status,
    double? amount,
    double? balance,
  }) {
    return PartyTransactionModel(
      id: id ?? this.id,
      partyId: partyId ?? this.partyId,
      invoiceNo: invoiceNo ?? this.invoiceNo,
      date: date ?? this.date,
      transactionType: transactionType ?? this.transactionType,
      paymentType: paymentType ?? this.paymentType,
      status: status ?? this.status,
      amount: amount ?? this.amount,
      balance: balance ?? this.balance,
    );
  }
}
