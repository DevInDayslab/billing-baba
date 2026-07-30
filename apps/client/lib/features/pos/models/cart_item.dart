import 'package:billing_baba/features/pos/models/pos_item.dart';

class CartItem {
  const CartItem({
    required this.item,
    required this.quantity,
    this.discountPercent = 0,
  });

  final PosItem item;
  final int quantity;
  final double discountPercent;

  double get grossTotal => item.price * quantity;

  double get discountAmount => grossTotal * discountPercent / 100;

  double get lineTotal => grossTotal - discountAmount;

  CartItem copyWith({
    PosItem? item,
    int? quantity,
    double? discountPercent,
  }) {
    return CartItem(
      item: item ?? this.item,
      quantity: quantity ?? this.quantity,
      discountPercent: discountPercent ?? this.discountPercent,
    );
  }
}
