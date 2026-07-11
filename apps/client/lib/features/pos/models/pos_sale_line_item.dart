/// A line item snapshot stored on a completed POS sale.
class PosSaleLineItem {
  const PosSaleLineItem({
    required this.name,
    required this.quantity,
    required this.lineTotal,
  });

  final String name;
  final int quantity;
  final double lineTotal;
}
