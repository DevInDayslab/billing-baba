import 'package:billing_baba/features/purchases/purchase_constants.dart';

enum PurchaseBillStatus {
  paid,
  unpaid,
  partiallyPaid,
  overdue,
  cancelled,
}

class PurchaseBillModel {
  const PurchaseBillModel({
    required this.id,
    required this.invoiceNo,
    required this.date,
    required this.partyName,
    required this.paymentType,
    required this.status,
    required this.amount,
    required this.balanceDue,
    required this.dueDate,
    this.partyId,
    this.documentStatus,
    this.user = 'Admin',
    this.firm = 'All Firms',
  });

  final String id;
  final String invoiceNo;
  final DateTime date;
  final String partyName;
  final String? partyId;
  final String paymentType;
  final PurchaseBillStatus status;
  final PurchaseDocumentStatus? documentStatus;
  final double amount;
  final double balanceDue;
  final DateTime dueDate;
  final String user;
  final String firm;

  double get paidAmount => amount - balanceDue;

  bool get isDraft => documentStatus == PurchaseDocumentStatus.draft;
}
