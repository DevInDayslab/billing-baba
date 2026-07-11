enum SaleFaStatus {
  paid,
  unpaid,
  partiallyPaid,
  overdue,
  cancelled,
}

class SaleFaModel {
  const SaleFaModel({
    required this.id,
    required this.batchId,
    required this.partyId,
    required this.invoiceNo,
    required this.date,
    required this.partyName,
    required this.paymentType,
    required this.status,
    required this.amount,
    required this.balanceDue,
    required this.dueDate,
    required this.createdAt,
    this.user = 'Admin',
    this.firm = 'All Firms',
  });

  final String id;
  final String batchId;
  final String partyId;
  final String invoiceNo;
  final DateTime date;
  final String partyName;
  final String paymentType;
  final SaleFaStatus status;
  final double amount;
  final double balanceDue;
  final DateTime dueDate;
  final DateTime createdAt;
  final String user;
  final String firm;

  double get paidAmount => amount - balanceDue;
}
