import 'package:billing_baba/features/pos/models/payment_entry.dart';
import 'package:billing_baba/features/pos/models/pos_sale_line_item.dart';
import 'package:billing_baba/features/pos/pos_constants.dart';

/// A completed POS bill shown on the landing list or receipt.
class PosSale {
  const PosSale({
    required this.id,
    required this.docNumber,
    required this.completedAt,
    required this.totalAmount,
    required this.taxAmount,
    required this.finalAmount,
    required this.itemCount,
    this.partyId,
    this.customerName,
    this.paymentMethod,
    this.payments = const [],
    this.items = const [],
    this.notes,
  });

  final String id;
  final String docNumber;
  final DateTime completedAt;
  final double totalAmount;
  final double taxAmount;
  final double finalAmount;
  final int itemCount;
  final String? partyId;
  final String? customerName;
  final String? paymentMethod;
  final List<PaymentEntry> payments;
  final List<PosSaleLineItem> items;
  final String? notes;

  /// Backward-compatible alias used by landing list.
  String get billNo => docNumber;

  /// Backward-compatible alias used by landing list.
  double get amount => finalAmount;

  String get displayName => customerName?.trim().isNotEmpty == true
      ? customerName!
      : PosConstants.walkInCustomerLabel;
}
