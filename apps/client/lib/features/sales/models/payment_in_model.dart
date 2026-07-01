enum PaymentInStatus {
  used,
  unused,
}

class PaymentInModel {
  const PaymentInModel({
    required this.id,
    required this.receiptNo,
    required this.date,
    required this.partyName,
    required this.paymentType,
    required this.status,
    required this.totalAmount,
    required this.receivedAmount,
    this.discount = 0,
    this.description = '',
    this.user = 'Admin',
    this.godown = 'Main Location',
  });

  final String id;
  final String receiptNo;
  final DateTime date;
  final String partyName;
  final String paymentType;
  final PaymentInStatus status;
  final double totalAmount;
  final double receivedAmount;
  final double discount;
  final String description;
  final String user;
  final String godown;

  double get balanceDue => totalAmount - receivedAmount - discount;

  PaymentInModel copyWith({
    String? id,
    String? receiptNo,
    DateTime? date,
    String? partyName,
    String? paymentType,
    PaymentInStatus? status,
    double? totalAmount,
    double? receivedAmount,
    double? discount,
    String? description,
    String? user,
    String? godown,
  }) {
    return PaymentInModel(
      id: id ?? this.id,
      receiptNo: receiptNo ?? this.receiptNo,
      date: date ?? this.date,
      partyName: partyName ?? this.partyName,
      paymentType: paymentType ?? this.paymentType,
      status: status ?? this.status,
      totalAmount: totalAmount ?? this.totalAmount,
      receivedAmount: receivedAmount ?? this.receivedAmount,
      discount: discount ?? this.discount,
      description: description ?? this.description,
      user: user ?? this.user,
      godown: godown ?? this.godown,
    );
  }
}
