import 'package:billing_baba/features/purchases/models/purchase_bill_model.dart';
import 'package:billing_baba/features/purchases/purchase_constants.dart';

class PurchaseReturnModel {
  const PurchaseReturnModel({
    required this.id,
    required this.debitNoteNo,
    required this.date,
    required this.partyName,
    required this.categoryName,
    required this.type,
    required this.status,
    required this.total,
    required this.receivedPaid,
    required this.balance,
    required this.dueDate,
    this.partyId,
    this.documentStatus,
    this.paymentType = 'Cash',
    this.user = 'Admin',
    this.firm = 'All Firms',
    this.godown = 'Main Godown',
  });

  final String id;
  final String debitNoteNo;
  final DateTime date;
  final String partyName;
  final String? partyId;
  final String categoryName;
  final String type;
  final PurchaseBillStatus status;
  final PurchaseDocumentStatus? documentStatus;
  final double total;
  final double receivedPaid;
  final double balance;
  final DateTime dueDate;
  final String paymentType;
  final String user;
  final String firm;
  final String godown;
}
