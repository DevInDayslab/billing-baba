import 'package:billing_baba/features/plans_pricing/models/plan_model.dart';
import 'package:billing_baba/features/subscription/domain/models/current_subscription.dart';
import 'package:billing_baba/features/subscription/domain/models/subscription_plan.dart';
import 'package:billing_baba/features/subscription/domain/models/subscription_plan_type.dart';
import 'package:billing_baba/features/subscription/domain/subscription_plan_metadata.dart';

class PlansPricingViewData {
  const PlansPricingViewData({
    required this.plans,
    required this.comparisonFeatures,
  });

  final List<PricingPlan> plans;
  final List<PlanFeature> comparisonFeatures;
}

class PlansPricingMapper {
  const PlansPricingMapper._();

  static PlansPricingViewData build({
    required List<SubscriptionPlan> plans,
    required CurrentSubscription current,
  }) {
    final pricingPlans = plans.map((plan) => _toPricingPlan(plan, current)).toList();

    return PlansPricingViewData(
      plans: pricingPlans,
      comparisonFeatures: subscriptionComparisonFeatures,
    );
  }

  static PricingPlan _toPricingPlan(
    SubscriptionPlan plan,
    CurrentSubscription current,
  ) {
    final metadata = metadataFor(plan.planType);
    final pricing = <PlanPriceKey, PlanPricing>{};

    for (final entry in metadata.priceMultipliers.entries) {
      final key = entry.key;
      final multiplier = entry.value;
      final discountedPrice = plan.amount * multiplier;
      final originalPrice = discountedPrice * metadata.originalPriceMultiplier;
      final months = key.$2 == PlanDuration.threeYears ? 36 : 12;

      pricing[key] = PlanPricing(
        originalPrice: originalPrice,
        discountedPrice: discountedPrice,
        perMonthPrice: discountedPrice / months,
        ctaLabel: _ctaLabel(
          planType: plan.planType,
          current: current,
        ),
      );
    }

    return PricingPlan(
      name: plan.title,
      isMostPopular: plan.isPopular,
      featuresByPlatform: metadata.cardFeatures,
      pricing: pricing,
    );
  }

  static String _ctaLabel({
    required SubscriptionPlanType planType,
    required CurrentSubscription current,
  }) {
    return switch (planType) {
      SubscriptionPlanType.gold => current.isActiveGold
          ? 'Renew Gold'
          : 'Get Vyapar Gold',
      SubscriptionPlanType.platinum => current.isActivePlatinum
          ? 'Renew Platinum'
          : current.isActiveGold
          ? 'Upgrade to Platinum'
          : 'Get Vyapar Platinum',
      SubscriptionPlanType.none => 'Buy Now',
    };
  }
}
