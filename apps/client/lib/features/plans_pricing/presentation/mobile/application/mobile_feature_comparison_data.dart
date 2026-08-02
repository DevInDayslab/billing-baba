import 'package:billing_baba/features/plans_pricing/models/plan_model.dart';

/// Display value for a feature comparison cell (Silver or Gold column).
sealed class MobileFeatureCellValue {
  const MobileFeatureCellValue();

  const factory MobileFeatureCellValue.included() = MobileFeatureIncluded;
  const factory MobileFeatureCellValue.excluded() = MobileFeatureExcluded;
  const factory MobileFeatureCellValue.text(String value) = MobileFeatureText;
}

class MobileFeatureIncluded extends MobileFeatureCellValue {
  const MobileFeatureIncluded();
}

class MobileFeatureExcluded extends MobileFeatureCellValue {
  const MobileFeatureExcluded();
}

class MobileFeatureText extends MobileFeatureCellValue {
  const MobileFeatureText(this.value);
  final String value;
}

class MobileFeatureComparisonItem {
  const MobileFeatureComparisonItem({
    required this.name,
    required this.silver,
    required this.gold,
  });

  final String name;
  final MobileFeatureCellValue silver;
  final MobileFeatureCellValue gold;
}

/// Vyapar mobile feature comparison rows (Silver vs Gold).
abstract final class MobileFeatureComparisonData {
  static const items = [
    MobileFeatureComparisonItem(
      name: 'Sync data across devices',
      silver: MobileFeatureCellValue.included(),
      gold: MobileFeatureCellValue.included(),
    ),
    MobileFeatureComparisonItem(
      name: 'Create multiple companies',
      silver: MobileFeatureCellValue.text('3'),
      gold: MobileFeatureCellValue.text('5'),
    ),
    MobileFeatureComparisonItem(
      name: 'Restore deleted transactions',
      silver: MobileFeatureCellValue.text('2'),
      gold: MobileFeatureCellValue.text('Unlimited'),
    ),
    MobileFeatureComparisonItem(
      name: 'Remove advertisement on invoices',
      silver: MobileFeatureCellValue.included(),
      gold: MobileFeatureCellValue.included(),
    ),
    MobileFeatureComparisonItem(
      name: 'Set multiple pricing for items',
      silver: MobileFeatureCellValue.included(),
      gold: MobileFeatureCellValue.included(),
    ),
    MobileFeatureComparisonItem(
      name: 'Set credit limit for parties',
      silver: MobileFeatureCellValue.excluded(),
      gold: MobileFeatureCellValue.included(),
    ),
    MobileFeatureComparisonItem(
      name: 'Add Fixed Assets',
      silver: MobileFeatureCellValue.included(),
      gold: MobileFeatureCellValue.included(),
    ),
    MobileFeatureComparisonItem(
      name: 'Balance Sheet',
      silver: MobileFeatureCellValue.included(),
      gold: MobileFeatureCellValue.included(),
    ),
    MobileFeatureComparisonItem(
      name: 'Billwise Profit & Loss',
      silver: MobileFeatureCellValue.included(),
      gold: MobileFeatureCellValue.included(),
    ),
    MobileFeatureComparisonItem(
      name: 'Partywise Profit & Loss',
      silver: MobileFeatureCellValue.excluded(),
      gold: MobileFeatureCellValue.included(),
    ),
    MobileFeatureComparisonItem(
      name: 'Item Batch & Serial Report',
      silver: MobileFeatureCellValue.included(),
      gold: MobileFeatureCellValue.included(),
    ),
    MobileFeatureComparisonItem(
      name: 'Add TCS on invoices',
      silver: MobileFeatureCellValue.excluded(),
      gold: MobileFeatureCellValue.included(),
    ),
    MobileFeatureComparisonItem(
      name: 'Different rates for each party',
      silver: MobileFeatureCellValue.excluded(),
      gold: MobileFeatureCellValue.included(),
    ),
    MobileFeatureComparisonItem(
      name: 'Create Multiple Firms',
      silver: MobileFeatureCellValue.text('3'),
      gold: MobileFeatureCellValue.text('5'),
    ),
    MobileFeatureComparisonItem(
      name: 'Check Profit on Invoices',
      silver: MobileFeatureCellValue.excluded(),
      gold: MobileFeatureCellValue.included(),
    ),
    MobileFeatureComparisonItem(
      name: 'Add Expenses with Input Tax Credit',
      silver: MobileFeatureCellValue.included(),
      gold: MobileFeatureCellValue.included(),
    ),
    MobileFeatureComparisonItem(
      name: 'Additional fields for items',
      silver: MobileFeatureCellValue.included(),
      gold: MobileFeatureCellValue.included(),
    ),
    MobileFeatureComparisonItem(
      name: 'Send transaction message to self',
      silver: MobileFeatureCellValue.excluded(),
      gold: MobileFeatureCellValue.included(),
    ),
    MobileFeatureComparisonItem(
      name: 'Send update message on transactions',
      silver: MobileFeatureCellValue.excluded(),
      gold: MobileFeatureCellValue.included(),
    ),
    MobileFeatureComparisonItem(
      name: 'Add TDS on invoices',
      silver: MobileFeatureCellValue.excluded(),
      gold: MobileFeatureCellValue.included(),
    ),
    MobileFeatureComparisonItem(
      name: 'Service reminders',
      silver: MobileFeatureCellValue.excluded(),
      gold: MobileFeatureCellValue.included(),
    ),
    MobileFeatureComparisonItem(
      name: 'Add Custom Fields for Items',
      silver: MobileFeatureCellValue.included(),
      gold: MobileFeatureCellValue.included(),
    ),
  ];
}

/// Vyapar mobile labels: Silver = lower tier, Gold = higher tier.
extension MobileComparisonPlanLabels on PricingPlanType {
  String get comparisonTierLabel => switch (this) {
    PricingPlanType.gold => 'Silver',
    PricingPlanType.platinum => 'Gold',
  };

  /// Maps Vyapar comparison tier to internal plan type.
  static PricingPlanType fromComparisonLabel(String label) => switch (label) {
    'Silver' => PricingPlanType.gold,
    'Gold' => PricingPlanType.platinum,
    _ => PricingPlanType.gold,
  };
}

/// Mobile display names for subscription plan cards (Silver / Gold).
extension MobilePricingPlanLabels on PricingPlan {
  String get mobileDisplayName =>
      (isGold ? PricingPlanType.gold : PricingPlanType.platinum)
          .comparisonTierLabel;
}
