import 'package:billing_baba/features/plans_pricing/models/plan_model.dart';
import 'package:billing_baba/features/subscription/domain/models/subscription_plan_type.dart';

/// Client-side overlay merged onto live API plan catalog responses.
class SubscriptionPlanMetadata {
  const SubscriptionPlanMetadata({
    required this.description,
    required this.durationLabel,
    required this.deviceLimit,
    required this.licenseType,
    required this.cardFeatures, required this.priceMultipliers, required this.originalPriceMultiplier, this.badge,
    this.isPopular = false,
  });

  final String description;
  final String durationLabel;
  final int deviceLimit;
  final String licenseType;
  final String? badge;
  final bool isPopular;
  final Map<PlanPlatform, List<PlanFeature>> cardFeatures;
  final Map<PlanPriceKey, double> priceMultipliers;
  final double originalPriceMultiplier;
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

const Map<PlanPlatform, List<PlanFeature>> subscriptionFeaturesByPlatform = {
  PlanPlatform.desktopMobile: _desktopCardFeatures,
  PlanPlatform.desktop: _desktopCardFeatures,
  PlanPlatform.mobile: _mobileCardFeatures,
};

const List<PlanFeature> subscriptionComparisonFeatures = [
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

/// Ratios relative to canonical API base price (Desktop+Mobile, 365 days).
Map<PlanPriceKey, double> _priceMultipliersForPlan({
  required double baseOneYearDesktopMobile,
  required double threeYearDesktopMobile,
  required double threeYearDesktop,
  required double threeYearMobile,
  required double oneYearMobile,
}) {
  return {
    (PlanPlatform.desktopMobile, PlanDuration.oneYear): 1,
    (
      PlanPlatform.desktopMobile,
      PlanDuration.threeYears,
    ): threeYearDesktopMobile / baseOneYearDesktopMobile,
    (PlanPlatform.desktop, PlanDuration.threeYears):
        threeYearDesktop / baseOneYearDesktopMobile,
    (PlanPlatform.mobile, PlanDuration.threeYears):
        threeYearMobile / baseOneYearDesktopMobile,
    (PlanPlatform.mobile, PlanDuration.oneYear):
        oneYearMobile / baseOneYearDesktopMobile,
    (PlanPlatform.desktop, PlanDuration.oneYear):
        threeYearDesktop / baseOneYearDesktopMobile / 2.6,
  };
}

const _goldBaseOneYear = 3046.0;
const _platinumBaseOneYear = 7742.0;

final Map<SubscriptionPlanType, SubscriptionPlanMetadata>
subscriptionPlanMetadataRegistry = {
  SubscriptionPlanType.gold: SubscriptionPlanMetadata(
    description: 'Essential billing and inventory tools for growing businesses.',
    durationLabel: '1 Year',
    deviceLimit: 2,
    licenseType: 'Desktop + Mobile',
    cardFeatures: subscriptionFeaturesByPlatform,
    priceMultipliers: _priceMultipliersForPlan(
      baseOneYearDesktopMobile: _goldBaseOneYear,
      threeYearDesktopMobile: 7919.20,
      threeYearDesktop: 7279.20,
      threeYearMobile: 1359.20,
      oneYearMobile: 719.10,
    ),
    originalPriceMultiplier: 18699 / 7919.20,
  ),
  SubscriptionPlanType.platinum: SubscriptionPlanMetadata(
    description: 'Advanced features for scaling businesses with full control.',
    durationLabel: '1 Year',
    deviceLimit: 5,
    licenseType: 'Desktop + Mobile',
    badge: 'Most Popular',
    isPopular: true,
    cardFeatures: subscriptionFeaturesByPlatform,
    priceMultipliers: _priceMultipliersForPlan(
      baseOneYearDesktopMobile: _platinumBaseOneYear,
      threeYearDesktopMobile: 20129.56,
      threeYearDesktop: 17044.62,
      threeYearMobile: 4239.20,
      oneYearMobile: 1889.10,
    ),
    originalPriceMultiplier: 52999 / 20129.56,
  ),
};

SubscriptionPlanMetadata metadataFor(SubscriptionPlanType planType) {
  return subscriptionPlanMetadataRegistry[planType] ??
      subscriptionPlanMetadataRegistry[SubscriptionPlanType.gold]!;
}

List<String> featureNamesFor(SubscriptionPlanType planType) {
  return subscriptionFeaturesByPlatform[PlanPlatform.desktopMobile]!
      .where((feature) => !feature.isCategoryHeader)
      .map((feature) => feature.name)
      .toList();
}
