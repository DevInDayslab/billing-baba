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
    this.syncState = PurchaseBillSyncState.none,
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
  final PurchaseBillSyncState syncState;

  bool get isDraft => documentStatus == PurchaseDocumentStatus.draft;

  PurchaseReturnModel copyWith({
    String? id,
    String? debitNoteNo,
    DateTime? date,
    String? partyName,
    String? partyId,
    String? categoryName,
    String? type,
    PurchaseBillStatus? status,
    PurchaseDocumentStatus? documentStatus,
    double? total,
    double? receivedPaid,
    double? balance,
    DateTime? dueDate,
    String? paymentType,
    String? user,
    String? firm,
    String? godown,
    PurchaseBillSyncState? syncState,
  }) {
    return PurchaseReturnModel(
      id: id ?? this.id,
      debitNoteNo: debitNoteNo ?? this.debitNoteNo,
      date: date ?? this.date,
      partyName: partyName ?? this.partyName,
      partyId: partyId ?? this.partyId,
      categoryName: categoryName ?? this.categoryName,
      type: type ?? this.type,
      status: status ?? this.status,
      documentStatus: documentStatus ?? this.documentStatus,
      total: total ?? this.total,
      receivedPaid: receivedPaid ?? this.receivedPaid,
      balance: balance ?? this.balance,
      dueDate: dueDate ?? this.dueDate,
      paymentType: paymentType ?? this.paymentType,
      user: user ?? this.user,
      firm: firm ?? this.firm,
      godown: godown ?? this.godown,
      syncState: syncState ?? this.syncState,
    );
  }
}
