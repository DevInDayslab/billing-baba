import 'package:billing_baba/features/plans_pricing/models/plan_model.dart';
import 'package:flutter/material.dart';

/// Scales [silver] addon pricing by [discountedRatio] / [originalRatio] vs Silver 3-year D+M.
Map<PlanPriceKey, AddonPricing> _scaledAddonPricing({
  required Map<PlanPriceKey, AddonPricing> silver,
  required double originalRatio,
  required double discountedRatio,
}) {
  return {
    for (final entry in silver.entries)
      entry.key: AddonPricing(
        originalPrice: (entry.value.originalPrice * originalRatio)
            .roundToDouble(),
        discountedPrice: (entry.value.discountedPrice * discountedRatio)
            .roundToDouble(),
      ),
  };
}

const Map<(PlanPlatform, PlanDuration), AddonPricing> _silverAddonPricing = {
  (PlanPlatform.desktopMobile, PlanDuration.threeYears): AddonPricing(
    originalPrice: 7499,
    discountedPrice: 4399,
  ),
  (PlanPlatform.desktop, PlanDuration.threeYears): AddonPricing(
    originalPrice: 6499,
    discountedPrice: 3799,
  ),
  (PlanPlatform.mobile, PlanDuration.threeYears): AddonPricing(
    originalPrice: 2999,
    discountedPrice: 1799,
  ),
  (PlanPlatform.desktopMobile, PlanDuration.oneYear): AddonPricing(
    originalPrice: 2999,
    discountedPrice: 1799,
  ),
  (PlanPlatform.desktop, PlanDuration.oneYear): AddonPricing(
    originalPrice: 2599,
    discountedPrice: 1499,
  ),
  (PlanPlatform.mobile, PlanDuration.oneYear): AddonPricing(
    originalPrice: 1299,
    discountedPrice: 799,
  ),
};

List<AddonPlan> buildAddonPlans() {
  const goldOriginalRatio = 9099 / 7499;
  const goldDiscountedRatio = 4799 / 4399;
  const proOriginalRatio = 18999 / 7499;
  const proDiscountedRatio = 9999 / 4399;

  return [
    const AddonPlan(
      id: 'silver',
      name: 'Vyapar Silver',
      pricing: _silverAddonPricing,
      iconColor: Color(0xFF546E7A),
      iconBgColor: Color(0xFFECEFF1),
    ),
    AddonPlan(
      id: 'gold',
      name: 'Vyapar Gold',
      pricing: _scaledAddonPricing(
        silver: _silverAddonPricing,
        originalRatio: goldOriginalRatio,
        discountedRatio: goldDiscountedRatio,
      ),
      isHighlighted: true,
    ),
    AddonPlan(
      id: 'manufacturing',
      name: 'Manufacturing Pro',
      pricing: _scaledAddonPricing(
        silver: _silverAddonPricing,
        originalRatio: proOriginalRatio,
        discountedRatio: proDiscountedRatio,
      ),
      iconColor: const Color(0xFF5E35B1),
      iconBgColor: const Color(0xFFEDE7F6),
    ),
    AddonPlan(
      id: 'retail',
      name: 'Retail Pro',
      pricing: _scaledAddonPricing(
        silver: _silverAddonPricing,
        originalRatio: proOriginalRatio,
        discountedRatio: proDiscountedRatio,
      ),
      icon: Icons.flag_outlined,
      iconColor: const Color(0xFF00897B),
      iconBgColor: const Color(0xFFE0F2F1),
    ),
    AddonPlan(
      id: 'distributor',
      name: 'Distributor Pro',
      pricing: _scaledAddonPricing(
        silver: _silverAddonPricing,
        originalRatio: proOriginalRatio,
        discountedRatio: proDiscountedRatio,
      ),
      icon: Icons.flag_outlined,
      iconColor: const Color(0xFF1565C0),
      iconBgColor: const Color(0xFFE3F2FD),
    ),
  ];
}
