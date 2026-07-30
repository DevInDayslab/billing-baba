import 'package:billing_baba/features/pos/models/cart_item.dart';
import 'package:billing_baba/features/pos/models/payment_entry.dart';

class HeldBill {
  const HeldBill({
    required this.id,
    required this.items,
    required this.heldAt,
    this.payments = const [],
    this.customerName,
    this.notes,
  });

  final String id;
  final List<CartItem> items;
  final DateTime heldAt;
  final List<PaymentEntry> payments;
  final String? customerName;
  final String? notes;
}
