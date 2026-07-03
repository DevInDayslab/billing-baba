enum PurchaseOrderStatus {
  open,
  orderCompleted,
  partiallyReceived,
  cancelled,
}

class PurchaseOrderModel {
  const PurchaseOrderModel({
    required this.id,
    required this.orderNo,
    required this.date,
    required this.partyName,
    required this.status,
    required this.amount,
    required this.balanceDue,
    required this.dueDate,
    this.type = 'Purchase Order',
    this.user = 'Admin',
    this.firm = 'All Firms',
  });

  final String id;
  final String orderNo;
  final DateTime date;
  final String partyName;
  final PurchaseOrderStatus status;
  final double amount;
  final double balanceDue;
  final DateTime dueDate;
  final String type;
  final String user;
  final String firm;

  double get paidAmount => amount - balanceDue;
}
