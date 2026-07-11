import 'package:billing_baba/features/pos/models/payment_entry.dart';
import 'package:billing_baba/features/pos/models/pos_sale_line_item.dart';

/// A completed POS bill shown on the landing list.
class PosSale {
  const PosSale({
    required this.id,
    required this.billNo,
    required this.completedAt,
    required this.amount,
    required this.itemCount,
    this.customerName,
    this.payments = const [],
    this.items = const [],
  });

  final String id;
  final String billNo;
  final DateTime completedAt;
  final double amount;
  final int itemCount;
  final String? customerName;
  final List<PaymentEntry> payments;
  final List<PosSaleLineItem> items;

  String get displayName =>
      customerName?.trim().isNotEmpty == true ? customerName! : 'Walk-in Customer';
}
