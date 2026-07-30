enum PaymentOutStatus { paid, pending, cancelled }

class PaymentOutModel {
  const PaymentOutModel({
    required this.id,
    required this.receiptNo,
    required this.date,
    required this.partyName,
    required this.paymentType,
    required this.status,
    required this.totalAmount,
    required this.paidAmount,
    this.partyId,
    this.discount = 0,
    this.description = '',
    this.user = 'Admin',
    this.firm = 'All Firms',
  });

  final String id;
  final String receiptNo;
  final DateTime date;
  final String partyName;
  final String? partyId;
  final String paymentType;
  final PaymentOutStatus status;
  final double totalAmount;
  final double paidAmount;
  final double discount;
  final String description;
  final String user;
  final String firm;
}
