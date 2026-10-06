import 'package:billing_baba/features/plans_pricing/models/plan_model.dart';
import 'package:billing_baba/features/subscription/domain/models/subscription_plan_type.dart';

/// Maps mobile Plans & Pricing selection to subscription API plan codes.
SubscriptionPlanType subscriptionPlanTypeFor(PricingPlan plan) {
  return plan.isGold
      ? SubscriptionPlanType.gold
      : SubscriptionPlanType.platinum;
}
