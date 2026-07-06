import 'package:billing_baba/features/pos/models/cart_item.dart';

class HeldBill {
  const HeldBill({
    required this.id,
    required this.items,
    required this.heldAt,
  });

  final String id;
  final List<CartItem> items;
  final DateTime heldAt;
}
