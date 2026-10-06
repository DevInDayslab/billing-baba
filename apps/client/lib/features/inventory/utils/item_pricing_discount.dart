import 'package:billing_baba/features/inventory/models/add_item_form_model.dart';

/// MRP / sale-price discount helpers for the add-item pricing tab.
abstract final class ItemPricingDiscount {
  static double saleFromMrp({
    required double mrp,
    required double discount,
    required PriceDiscountKind kind,
  }) {
    if (mrp <= 0 || discount <= 0) return mrp > 0 ? mrp : 0;
    return switch (kind) {
      PriceDiscountKind.percentage => mrp * (1 - discount.clamp(0, 100) / 100),
      PriceDiscountKind.amount => (mrp - discount).clamp(0, double.infinity),
    };
  }

  static double percentFromMrp({
    required double mrp,
    required double salePrice,
  }) {
    if (mrp <= 0) return 0;
    final raw = (mrp - salePrice) / mrp * 100;
    if (raw.isNaN || raw.isInfinite) return 0;
    return raw.clamp(0, 100);
  }

  static String labelForKind(PriceDiscountKind kind) => switch (kind) {
    PriceDiscountKind.percentage => 'Percentage',
    PriceDiscountKind.amount => 'Amount',
  };

  static PriceDiscountKind kindFromLabel(String label) => label == 'Amount'
      ? PriceDiscountKind.amount
      : PriceDiscountKind.percentage;

  static const discountKindLabels = ['Percentage', 'Amount'];
}
