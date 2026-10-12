import 'package:billing_baba/features/pos/models/pos_item.dart';

class CartItem {
  const CartItem({
    required this.item,
    required this.quantity,
    this.discountPercent = 0,
    this.allowInsufficientStock = false,
    this.unitPriceOverride,
  });

  final PosItem item;
  final int quantity;
  final double discountPercent;

  /// When true, quantity is not capped by on-hand stock (negative stock on sale).
  final bool allowInsufficientStock;

  /// Per-line sale rate; falls back to [PosItem.price] when null.
  final double? unitPriceOverride;

  double get unitPrice => unitPriceOverride ?? item.price;

  double get grossTotal => unitPrice * quantity;

  double get discountAmount => grossTotal * discountPercent / 100;

  double get lineTotal => grossTotal - discountAmount;

  CartItem copyWith({
    PosItem? item,
    int? quantity,
    double? discountPercent,
    bool? allowInsufficientStock,
    double? unitPriceOverride,
    bool clearUnitPriceOverride = false,
  }) {
    return CartItem(
      item: item ?? this.item,
      quantity: quantity ?? this.quantity,
      discountPercent: discountPercent ?? this.discountPercent,
      allowInsufficientStock:
          allowInsufficientStock ?? this.allowInsufficientStock,
      unitPriceOverride: clearUnitPriceOverride
          ? null
          : (unitPriceOverride ?? this.unitPriceOverride),
    );
  }
}
