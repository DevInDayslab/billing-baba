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
    this.user = 'Admin',
    this.godown = 'Main Location',
  });

  final String id;
  final String invoiceNo;
  final DateTime date;
  final String partyName;
  final String transactionType;
  final String paymentType;
  final SaleInvoiceStatus status;
  final double amount;
  final double balance;
  final String user;
  final String godown;

  SaleInvoiceModel copyWith({
    String? id,
    String? invoiceNo,
    DateTime? date,
    String? partyName,
    String? transactionType,
    String? paymentType,
    SaleInvoiceStatus? status,
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
      transactionType: transactionType ?? this.transactionType,
      paymentType: paymentType ?? this.paymentType,
      status: status ?? this.status,
      amount: amount ?? this.amount,
      balance: balance ?? this.balance,
      user: user ?? this.user,
      godown: godown ?? this.godown,
    );
  }
}
