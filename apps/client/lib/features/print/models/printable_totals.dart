/// Document totals for printable output.
class PrintableTotals {
  const PrintableTotals({
    required this.subtotal,
    required this.discountTotal,
    required this.taxAmount,
    required this.totalAmount,
    this.paidAmount,
    this.balanceDue,
  });

  final String subtotal;
  final String discountTotal;
  final String taxAmount;
  final String totalAmount;
  final String? paidAmount;
  final String? balanceDue;
}
