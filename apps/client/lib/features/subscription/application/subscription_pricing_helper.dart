import 'package:billing_baba/features/plans_pricing/models/plan_model.dart';
import 'package:billing_baba/features/subscription/models/subscription_models.dart';

PlanPricing applyApiPricing({
  required PlanPricing fallback,
  required SubscriptionPlanModel? apiPlan,
  required String ctaLabel,
}) {
  if (apiPlan == null || apiPlan.price <= 0) {
    return fallback.copyWithCtaLabel(ctaLabel);
  }

  // API price is the annual purchase amount. Keep mock original for display
  // strikethrough so prices don't jump when the plans API resolves.
  return PlanPricing(
    originalPrice: fallback.originalPrice,
    discountedPrice: apiPlan.price,
    perMonthPrice: apiPlan.price / 12,
    ctaLabel: ctaLabel,
  );
}

String goldCtaLabel(CurrentSubscriptionModel? current) {
  if (current == null || current.plan == SubscriptionPlanCode.noPlan) {
    return 'Get Gold';
  }
  if (current.plan == SubscriptionPlanCode.gold) {
    return 'Renew Gold';
  }
  return 'Get Gold';
}

String platinumCtaLabel(CurrentSubscriptionModel? current) {
  if (current?.plan == SubscriptionPlanCode.platinum) {
    return 'Renew Platinum';
  }
  if (current?.plan == SubscriptionPlanCode.gold) {
    return 'Upgrade to Platinum';
  }
  return 'Get Platinum';
}

SubscriptionPlanModel? findApiPlan(
  List<SubscriptionPlanModel> plans,
  SubscriptionPlanCode code,
) {
  for (final plan in plans) {
    if (plan.plan == code && plan.isActive) {
      return plan;
    }
  }
  return null;
}

extension PlanPricingCopy on PlanPricing {
  PlanPricing copyWithCtaLabel(String ctaLabel) {
    return PlanPricing(
      originalPrice: originalPrice,
      discountedPrice: discountedPrice,
      perMonthPrice: perMonthPrice,
      ctaLabel: ctaLabel,
    );
  }
}
