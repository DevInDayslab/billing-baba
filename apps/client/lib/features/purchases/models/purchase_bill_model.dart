import 'package:billing_baba/features/purchases/purchase_constants.dart';

enum PurchaseBillStatus {
  paid,
  unpaid,
  partiallyPaid,
  overdue,
  cancelled,
}

enum PurchaseBillSyncState {
  none,
  savedLocally,
  syncing,
  synced,
  conflict,
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
    this.syncState = PurchaseBillSyncState.none,
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
  final PurchaseBillSyncState syncState;

  double get paidAmount => amount - balanceDue;

  bool get isDraft => documentStatus == PurchaseDocumentStatus.draft;

  PurchaseBillModel copyWith({
    String? id,
    String? invoiceNo,
    DateTime? date,
    String? partyName,
    String? partyId,
    String? paymentType,
    PurchaseBillStatus? status,
    PurchaseDocumentStatus? documentStatus,
    double? amount,
    double? balanceDue,
    DateTime? dueDate,
    String? user,
    String? firm,
    PurchaseBillSyncState? syncState,
  }) {
    return PurchaseBillModel(
      id: id ?? this.id,
      invoiceNo: invoiceNo ?? this.invoiceNo,
      date: date ?? this.date,
      partyName: partyName ?? this.partyName,
      partyId: partyId ?? this.partyId,
      paymentType: paymentType ?? this.paymentType,
      status: status ?? this.status,
      documentStatus: documentStatus ?? this.documentStatus,
      amount: amount ?? this.amount,
      balanceDue: balanceDue ?? this.balanceDue,
      dueDate: dueDate ?? this.dueDate,
      user: user ?? this.user,
      firm: firm ?? this.firm,
      syncState: syncState ?? this.syncState,
    );
  }
}
