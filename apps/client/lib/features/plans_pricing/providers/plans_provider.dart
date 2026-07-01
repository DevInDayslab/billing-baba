import 'package:billing_baba/features/plans_pricing/models/plan_model.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'plans_provider.g.dart';

/// Approximate ratio observed between 3-year and 1-year mobile pricing.
// TODO(team): replace with real backend pricing values for desktop 1-year plans.
const _oneYearPlaceholderRatio = 2.6;

PlanPricing _placeholderOneYearPricing({
  required double threeYearOriginal,
  required PlanPricing threeYear,
  required String ctaLabel,
}) {
  final discounted = threeYear.discountedPrice / _oneYearPlaceholderRatio;
  return PlanPricing(
    originalPrice: threeYearOriginal / _oneYearPlaceholderRatio,
    discountedPrice: discounted,
    perMonthPrice: discounted / 12,
    ctaLabel: ctaLabel,
  );
}

const _desktopCardFeatures = [
  PlanFeature(
    name: 'Vyapar POS Billing',
    goldIncluded: false,
    platinumIncluded: true,
  ),
  PlanFeature(
    name: 'Manage godowns & Transfer stock',
    goldIncluded: false,
    platinumIncluded: true,
  ),
  PlanFeature(
    name: 'Loyalty Points',
    goldIncluded: false,
    platinumIncluded: true,
  ),
  PlanFeature(
    name: 'Custom Label Printing',
    goldIncluded: false,
    platinumIncluded: true,
  ),
  PlanFeature(
    name: 'WhatsApp Connect',
    goldIncluded: true,
    platinumIncluded: true,
  ),
  PlanFeature(
    name: 'Marketing Tools',
    goldIncluded: false,
    platinumIncluded: true,
  ),
  PlanFeature(
    name: 'Ads Manager',
    goldIncluded: false,
    platinumIncluded: true,
  ),
  PlanFeature(
    name: 'Create your own online store',
    goldIncluded: false,
    platinumIncluded: true,
  ),
  PlanFeature(
    name: 'Send Bulk WhatsApp Messages',
    goldIncluded: true,
    platinumIncluded: true,
  ),
  PlanFeature(
    name: 'Automate Payment Reminders',
    goldIncluded: true,
    platinumIncluded: true,
  ),
  PlanFeature(
    name: 'Manufacturing Transactions',
    goldIncluded: false,
    platinumIncluded: true,
  ),
  PlanFeature(
    name: 'Create multiple companies',
    goldValue: '5 companies',
    platinumValue: 'unlimited',
  ),
  PlanFeature(
    name: 'Field Sales Man live tracking',
    goldIncluded: false,
    platinumIncluded: true,
  ),
  PlanFeature(
    name: 'Generate E-way Bills',
    goldValue: 'unlimited',
    platinumValue: 'unlimited',
  ),
  PlanFeature(
    name: 'Sync data across devices',
    goldIncluded: true,
    platinumIncluded: true,
  ),
  PlanFeature(
    name: 'Send Invoice(s) on Whatsapp Unlimited',
    goldIncluded: true,
    platinumIncluded: true,
  ),
  PlanFeature(
    name: 'Multi-currency support',
    goldIncluded: false,
    platinumIncluded: true,
  ),
  PlanFeature(
    name: 'Barcode Generation',
    goldIncluded: true,
    platinumIncluded: true,
  ),
  PlanFeature(
    name: 'Batch & Expiry Tracking',
    goldIncluded: false,
    platinumIncluded: true,
  ),
  PlanFeature(
    name: 'Item Variants',
    goldIncluded: false,
    platinumIncluded: true,
  ),
  PlanFeature(
    name: 'Purchase Orders',
    goldIncluded: true,
    platinumIncluded: true,
  ),
  PlanFeature(
    name: 'Delivery Challan',
    goldIncluded: true,
    platinumIncluded: true,
  ),
  PlanFeature(
    name: 'Estimate & Quotation',
    goldIncluded: true,
    platinumIncluded: true,
  ),
  PlanFeature(
    name: 'Proforma Invoice',
    goldIncluded: true,
    platinumIncluded: true,
  ),
  PlanFeature(
    name: 'Credit Note',
    goldIncluded: true,
    platinumIncluded: true,
  ),
  PlanFeature(
    name: 'Debit Note',
    goldIncluded: true,
    platinumIncluded: true,
  ),
  PlanFeature(
    name: 'Sales Return',
    goldIncluded: true,
    platinumIncluded: true,
  ),
  PlanFeature(
    name: 'Purchase Return',
    goldIncluded: true,
    platinumIncluded: true,
  ),
  PlanFeature(
    name: 'Expense Tracking',
    goldIncluded: true,
    platinumIncluded: true,
  ),
  PlanFeature(
    name: 'Income Tracking',
    goldIncluded: true,
    platinumIncluded: true,
  ),
  PlanFeature(
    name: 'Bank Reconciliation',
    goldIncluded: false,
    platinumIncluded: true,
  ),
  PlanFeature(
    name: 'TDS/TCS Reports',
    goldIncluded: false,
    platinumIncluded: true,
  ),
  PlanFeature(
    name: 'GST Reports',
    goldIncluded: true,
    platinumIncluded: true,
  ),
];

const _mobileCardFeatures = [
  PlanFeature(
    name: 'Manage godowns & Transfer stock',
    goldIncluded: false,
    platinumIncluded: true,
  ),
  PlanFeature(
    name: 'Loyalty Points',
    goldIncluded: false,
    platinumIncluded: true,
  ),
  PlanFeature(
    name: 'Marketing Tools',
    goldIncluded: false,
    platinumIncluded: true,
  ),
  PlanFeature(
    name: 'Create your own online store',
    goldIncluded: false,
    platinumIncluded: true,
  ),
  PlanFeature(
    name: 'Share Greetings & Offers on WhatsApp',
    goldIncluded: true,
    platinumIncluded: true,
  ),
  PlanFeature(
    name: 'Manufacturing Transactions',
    goldIncluded: false,
    platinumIncluded: true,
  ),
  PlanFeature(
    name: 'Create multiple companies',
    goldValue: '5 companies',
    platinumValue: 'unlimited',
  ),
  PlanFeature(
    name: 'Barcode Generation',
    goldIncluded: true,
    platinumIncluded: true,
  ),
  PlanFeature(
    name: 'Batch & Expiry Tracking',
    goldIncluded: false,
    platinumIncluded: true,
  ),
  PlanFeature(
    name: 'Purchase Orders',
    goldIncluded: true,
    platinumIncluded: true,
  ),
  PlanFeature(
    name: 'Delivery Challan',
    goldIncluded: true,
    platinumIncluded: true,
  ),
  PlanFeature(
    name: 'Estimate & Quotation',
    goldIncluded: true,
    platinumIncluded: true,
  ),
  PlanFeature(
    name: 'Credit Note',
    goldIncluded: true,
    platinumIncluded: true,
  ),
  PlanFeature(
    name: 'Debit Note',
    goldIncluded: true,
    platinumIncluded: true,
  ),
  PlanFeature(
    name: 'Sales Return',
    goldIncluded: true,
    platinumIncluded: true,
  ),
  PlanFeature(
    name: 'Expense Tracking',
    goldIncluded: true,
    platinumIncluded: true,
  ),
  PlanFeature(
    name: 'Income Tracking',
    goldIncluded: true,
    platinumIncluded: true,
  ),
  PlanFeature(
    name: 'GST Reports',
    goldIncluded: true,
    platinumIncluded: true,
  ),
  PlanFeature(
    name: 'Item Variants',
    goldIncluded: false,
    platinumIncluded: true,
  ),
  PlanFeature(
    name: 'Proforma Invoice',
    goldIncluded: true,
    platinumIncluded: true,
  ),
  PlanFeature(
    name: 'Purchase Return',
    goldIncluded: true,
    platinumIncluded: true,
  ),
  PlanFeature(
    name: 'Automate Payment Reminders',
    goldIncluded: true,
    platinumIncluded: true,
  ),
  PlanFeature(
    name: 'Send Bulk WhatsApp Messages',
    goldIncluded: true,
    platinumIncluded: true,
  ),
];

const Map<PlanPlatform, List<PlanFeature>> _featuresByPlatform = {
  PlanPlatform.desktopMobile: _desktopCardFeatures,
  PlanPlatform.desktop: _desktopCardFeatures,
  PlanPlatform.mobile: _mobileCardFeatures,
};

@riverpod
class PlanFeatures extends _$PlanFeatures {
  @override
  List<PlanFeature> build() {
    return const [
      PlanFeature(
        name: 'Vyapar POS Billing',
        goldIncluded: false,
        platinumIncluded: true,
      ),
      PlanFeature(
        name: 'Manage godowns & Transfer stock',
        goldIncluded: false,
        platinumIncluded: true,
      ),
      PlanFeature(
        name: 'Field Sales Man live tracking',
        goldIncluded: false,
        platinumIncluded: true,
      ),
      PlanFeature(
        name: 'Generate E-way Bills',
        goldValue: 'unlimited',
        platinumValue: 'unlimited',
      ),
      PlanFeature(
        name: 'Custom Label Printing',
        goldIncluded: false,
        platinumIncluded: true,
      ),
      PlanFeature(
        name: 'Manufacturing Transactions',
        goldIncluded: false,
        platinumIncluded: true,
      ),
      PlanFeature(
        name: 'Sync data across devices',
        goldIncluded: true,
        platinumIncluded: true,
      ),
      PlanFeature(
        name: 'Create multiple companies',
        goldValue: '5 companies',
        platinumValue: 'unlimited',
      ),
      PlanFeature(
        name: 'Send Invoice(s) on Whatsapp Unlimited',
        goldIncluded: true,
        platinumIncluded: true,
      ),
      PlanFeature(
        name: 'Multi-currency support',
        goldIncluded: false,
        platinumIncluded: true,
      ),
      PlanFeature(
        name: 'WhatsApp Connect',
        goldIncluded: true,
        platinumIncluded: true,
        category: 'Party Management',
      ),
      PlanFeature(
        name: 'Loyalty Points',
        goldIncluded: false,
        platinumIncluded: true,
      ),
      PlanFeature(
        name: 'Automate Payment Reminders',
        goldIncluded: true,
        platinumIncluded: true,
      ),
    ];
  }
}

@riverpod
class PricingPlans extends _$PricingPlans {
  @override
  List<PricingPlan> build() {
    const goldDesktopMobileThreeYears = PlanPricing(
      originalPrice: 18699,
      discountedPrice: 7919.20,
      perMonthPrice: 219.98,
      ctaLabel: 'Renew Gold',
    );
    const goldDesktopThreeYears = PlanPricing(
      originalPrice: 17099,
      discountedPrice: 7279.20,
      perMonthPrice: 202.20,
      ctaLabel: 'Renew Gold',
    );
    const goldMobileThreeYears = PlanPricing(
      originalPrice: 3299,
      discountedPrice: 1359.20,
      perMonthPrice: 37.76,
      ctaLabel: 'Get Vyapar Gold',
    );
    const goldMobileOneYear = PlanPricing(
      originalPrice: 1399,
      discountedPrice: 719.10,
      perMonthPrice: 59.93,
      ctaLabel: 'Get Vyapar Gold',
    );

    const platinumDesktopMobileThreeYears = PlanPricing(
      originalPrice: 52999,
      discountedPrice: 20129.56,
      perMonthPrice: 559.15,
      ctaLabel: 'Upgrade to Platinum',
    );
    const platinumDesktopThreeYears = PlanPricing(
      originalPrice: 42999,
      discountedPrice: 17044.62,
      perMonthPrice: 473.46,
      ctaLabel: 'Upgrade to Platinum',
    );
    const platinumMobileThreeYears = PlanPricing(
      originalPrice: 9999,
      discountedPrice: 4239.20,
      perMonthPrice: 117.76,
      ctaLabel: 'Get Vyapar Platinum',
    );
    const platinumMobileOneYear = PlanPricing(
      originalPrice: 4299,
      discountedPrice: 1889.10,
      perMonthPrice: 157.42,
      ctaLabel: 'Get Vyapar Platinum',
    );

    return [
      PricingPlan(
        name: 'Gold',
        isMostPopular: false,
        featuresByPlatform: _featuresByPlatform,
        pricing: {
          (PlanPlatform.desktopMobile, PlanDuration.threeYears):
              goldDesktopMobileThreeYears,
          (PlanPlatform.desktop, PlanDuration.threeYears): goldDesktopThreeYears,
          (PlanPlatform.mobile, PlanDuration.threeYears): goldMobileThreeYears,
          (PlanPlatform.mobile, PlanDuration.oneYear): goldMobileOneYear,
          // TODO(team): replace placeholder 1-year desktop pricing with real backend values.
          (PlanPlatform.desktopMobile, PlanDuration.oneYear):
              _placeholderOneYearPricing(
            threeYearOriginal: 18699,
            threeYear: goldDesktopMobileThreeYears,
            ctaLabel: 'Renew Gold',
          ),
          (PlanPlatform.desktop, PlanDuration.oneYear): _placeholderOneYearPricing(
            threeYearOriginal: 17099,
            threeYear: goldDesktopThreeYears,
            ctaLabel: 'Renew Gold',
          ),
        },
      ),
      PricingPlan(
        name: 'Platinum',
        isMostPopular: true,
        featuresByPlatform: _featuresByPlatform,
        pricing: {
          (PlanPlatform.desktopMobile, PlanDuration.threeYears):
              platinumDesktopMobileThreeYears,
          (PlanPlatform.desktop, PlanDuration.threeYears):
              platinumDesktopThreeYears,
          (PlanPlatform.mobile, PlanDuration.threeYears): platinumMobileThreeYears,
          (PlanPlatform.mobile, PlanDuration.oneYear): platinumMobileOneYear,
          // TODO(team): replace placeholder 1-year desktop pricing with real backend values.
          (PlanPlatform.desktopMobile, PlanDuration.oneYear):
              _placeholderOneYearPricing(
            threeYearOriginal: 52999,
            threeYear: platinumDesktopMobileThreeYears,
            ctaLabel: 'Upgrade to Platinum',
          ),
          (PlanPlatform.desktop, PlanDuration.oneYear): _placeholderOneYearPricing(
            threeYearOriginal: 42999,
            threeYear: platinumDesktopThreeYears,
            ctaLabel: 'Upgrade to Platinum',
          ),
        },
      ),
    ];
  }
}

/// Scales [silver] addon pricing by [discountedRatio] / [originalRatio] vs Silver 3-year D+M.
Map<PlanPriceKey, AddonPricing> _scaledAddonPricing({
  required Map<PlanPriceKey, AddonPricing> silver,
  required double originalRatio,
  required double discountedRatio,
}) {
  return {
    for (final entry in silver.entries)
      entry.key: AddonPricing(
        originalPrice: (entry.value.originalPrice * originalRatio).roundToDouble(),
        discountedPrice:
            (entry.value.discountedPrice * discountedRatio).roundToDouble(),
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
