import 'package:billing_baba/features/subscription/presentation/desktop/review_order_summary_input.dart';

/// GST-inclusive order totals for the mobile subscription checkout flow.
class SubscriptionOrderPricing {
  const SubscriptionOrderPricing({
    required this.planListPrice,
    required this.planDiscount,
    required this.couponDiscount,
    required this.subtotal,
    required this.gstAmount,
    required this.total,
  });

  /// Original list price before any discounts (GST-inclusive).
  final double planListPrice;

  /// Built-in plan discount (list vs selected plan price).
  final double planDiscount;

  /// Additional coupon discount applied on the taxable base.
  final double couponDiscount;

  /// Taxable amount after plan and coupon discounts.
  final double subtotal;

  /// GST at 18% on [subtotal].
  final double gstAmount;

  /// Final payable amount.
  final double total;

  static const _gstRate = 0.18;

  factory SubscriptionOrderPricing.calculate({
    required ReviewOrderSummaryInput input,
    double couponDiscountOnTaxable = 0,
  }) {
    final planListPrice = input.originalPrice;
    final planDiscount = input.discountAmount;
    final baseTaxable = input.discountedPrice / (1 + _gstRate);
    final couponDiscount = couponDiscountOnTaxable
        .clamp(0, baseTaxable)
        .toDouble();
    final subtotal = baseTaxable - couponDiscount;
    final gstAmount = subtotal * _gstRate;
    final total = subtotal + gstAmount;

    return SubscriptionOrderPricing(
      planListPrice: planListPrice,
      planDiscount: planDiscount,
      couponDiscount: couponDiscount,
      subtotal: subtotal,
      gstAmount: gstAmount,
      total: total,
    );
  }
}
