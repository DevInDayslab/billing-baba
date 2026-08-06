import 'package:billing_baba/features/subscription/application/subscription_order_pricing.dart';
import 'package:billing_baba/features/subscription/domain/models/subscription_plan.dart';
import 'package:billing_baba/features/subscription/domain/models/subscription_plan_type.dart';

/// Server-authoritative GST-inclusive pricing for Razorpay checkout.
class SubscriptionServerPricing {
  const SubscriptionServerPricing._();

  static const _gstRate = 0.18;

  static SubscriptionOrderPricing fromPlanAmount(double amountInclusive) {
    final subtotal = amountInclusive / (1 + _gstRate);
    final gstAmount = amountInclusive - subtotal;

    return SubscriptionOrderPricing(
      planListPrice: amountInclusive,
      planDiscount: 0,
      couponDiscount: 0,
      subtotal: subtotal,
      gstAmount: gstAmount,
      total: amountInclusive,
    );
  }

  static SubscriptionPlan? planFor(
    List<SubscriptionPlan> plans,
    SubscriptionPlanType planType,
  ) {
    for (final plan in plans) {
      if (plan.planType == planType) return plan;
    }
    return null;
  }
}
