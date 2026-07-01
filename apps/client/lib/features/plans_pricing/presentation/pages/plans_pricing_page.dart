import 'dart:async';

import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/plans_pricing/models/plan_model.dart';
import 'package:billing_baba/features/plans_pricing/presentation/widgets/buy_licenses_dialog.dart';
import 'package:billing_baba/features/plans_pricing/presentation/widgets/feature_comparison_row.dart';
import 'package:billing_baba/features/plans_pricing/presentation/widgets/license_info_dialog.dart';
import 'package:billing_baba/features/plans_pricing/presentation/widgets/plan_card.dart';
import 'package:billing_baba/features/plans_pricing/presentation/widgets/plan_card_compact.dart';
import 'package:billing_baba/features/plans_pricing/presentation/widgets/upgrade_plan_dialog.dart';
import 'package:billing_baba/features/plans_pricing/providers/plans_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _compactBreakpoint = 760.0;

class PlansPricingPage extends ConsumerStatefulWidget {
  const PlansPricingPage({super.key});

  @override
  ConsumerState<PlansPricingPage> createState() => _PlansPricingPageState();
}

class _PlansPricingPageState extends ConsumerState<PlansPricingPage> {
  static const _maxContentWidth = 960.0;

  bool _showFullComparison = false;
  bool _featuresExpanded = false;
  PlanPlatform _selectedPlatform = PlanPlatform.desktopMobile;
  PlanDuration _selectedDuration = PlanDuration.threeYears;
  PricingPlanType _selectedCompactPlan = PricingPlanType.platinum;

  int get _overviewFeatureLimit =>
      _selectedPlatform == PlanPlatform.mobile ? 6 : 10;

  void _openUpgradeDialog(double upgradeAmount) {
    unawaited(
      showUpgradePlanDialog(
        context,
        platform: _selectedPlatform,
        duration: _selectedDuration,
        upgradeAmount: upgradeAmount,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final features = ref.watch(planFeaturesProvider);
    final plans = ref.watch(pricingPlansProvider);
    final goldPlan = plans.firstWhere((p) => p.isGold);
    final platinumPlan = plans.firstWhere((p) => !p.isGold);
    final cardFeatures = goldPlan.featuresByPlatform[_selectedPlatform]!;
    final goldPricing =
        goldPlan.pricingFor(_selectedPlatform, _selectedDuration);
    final platinumPricing =
        platinumPlan.pricingFor(_selectedPlatform, _selectedDuration);

    final scrollContent = SingleChildScrollView(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.lg,
        bottom: _showFullComparison ? 80 : AppSpacing.lg,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _maxContentWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _PageHeader(
                showFullComparison: _showFullComparison,
                onBuyLicenses: () => showBuyLicensesDialog(context),
                onMenuSelected: (value) {
                  if (value == 'license_info') {
                    unawaited(
                      showLicenseInfoDialog(
                        context,
                        platform: _selectedPlatform,
                        duration: _selectedDuration,
                        upgradeAmount: platinumPricing.discountedPrice,
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: AppSpacing.md),
              _DiscontinuationBanner(),
              const SizedBox(height: AppSpacing.md),
              if (!_showFullComparison) ...[
                _FilterChips(
                  selectedPlatform: _selectedPlatform,
                  selectedDuration: _selectedDuration,
                  onPlatformChanged: (platform) =>
                      setState(() => _selectedPlatform = platform),
                  onDurationChanged: (duration) =>
                      setState(() => _selectedDuration = duration),
                ),
                const SizedBox(height: AppSpacing.lg),
                _OverviewPlanCards(
                  goldPlan: goldPlan,
                  platinumPlan: platinumPlan,
                  goldPricing: goldPricing,
                  platinumPricing: platinumPricing,
                  features: cardFeatures,
                  overviewFeatureLimit: _overviewFeatureLimit,
                  featuresExpanded: _featuresExpanded,
                  selectedCompactPlan: _selectedCompactPlan,
                  onCompactPlanChanged: (plan) =>
                      setState(() => _selectedCompactPlan = plan),
                  onToggleFeatures: () =>
                      setState(() => _featuresExpanded = !_featuresExpanded),
                  onViewAllFeatures: () =>
                      setState(() => _showFullComparison = true),
                  onUpgradePressed: () =>
                      _openUpgradeDialog(platinumPricing.discountedPrice),
                ),
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth < _compactBreakpoint) {
                      return const SizedBox.shrink();
                    }
                    return Column(
                      children: [
                        const SizedBox(height: AppSpacing.lg),
                        Center(
                          child: OutlinedButton(
                            onPressed: () =>
                                setState(() => _showFullComparison = true),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.error,
                              side: const BorderSide(color: AppColors.error),
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.lg,
                                vertical: AppSpacing.sm + 4,
                              ),
                            ),
                            child: const Text('Compare All Features'),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ] else ...[
                _ComparisonHeader(
                  goldPlan: goldPlan,
                  platinumPlan: platinumPlan,
                  goldPricing: goldPricing,
                  platinumPricing: platinumPricing,
                  features: cardFeatures,
                  overviewFeatureLimit: _overviewFeatureLimit,
                  onUpgradePressed: () =>
                      _openUpgradeDialog(platinumPricing.discountedPrice),
                ),
                const SizedBox(height: AppSpacing.lg),
                _FeatureComparisonTable(features: features),
              ],
            ],
          ),
        ),
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact =
              constraints.maxWidth < _compactBreakpoint && !_showFullComparison;

          if (isCompact) {
            final selectedPricing = _selectedCompactPlan == PricingPlanType.gold
                ? goldPricing
                : platinumPricing;

            return Column(
              children: [
                Expanded(child: scrollContent),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.sm,
                    AppSpacing.lg,
                    AppSpacing.lg,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 8,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    top: false,
                    child: FilledButton(
                      onPressed:
                          _selectedCompactPlan == PricingPlanType.platinum &&
                                  selectedPricing.ctaLabel ==
                                      'Upgrade to Platinum'
                              ? () => _openUpgradeDialog(
                                    selectedPricing.discountedPrice,
                                  )
                              : () {},
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.sm + 4,
                        ),
                        textStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      child: Text(selectedPricing.ctaLabel),
                    ),
                  ),
                ),
              ],
            );
          }

          return SizedBox.expand(
            child: Stack(
              fit: StackFit.expand,
              children: [
                scrollContent,
                if (_showFullComparison)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: AppSpacing.md,
                    child: Center(
                      child: OutlinedButton.icon(
                        onPressed: () =>
                            setState(() => _showFullComparison = false),
                        icon: const Icon(Icons.arrow_upward, size: 18),
                        label: const Text('Back To Plans'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textPrimary,
                          backgroundColor: AppColors.surface,
                          side: BorderSide(color: Colors.grey.shade300),
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                            vertical: AppSpacing.sm + 4,
                          ),
                          elevation: 2,
                          shadowColor: Colors.black26,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _PageHeader extends StatelessWidget {
  const _PageHeader({
    required this.showFullComparison,
    required this.onBuyLicenses,
    required this.onMenuSelected,
  });

  final bool showFullComparison;
  final VoidCallback onBuyLicenses;
  final ValueChanged<String> onMenuSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Plans & Pricing',
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
          ),
        ),
        if (!showFullComparison)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              OutlinedButton(
                onPressed: onBuyLicenses,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                  side: BorderSide(color: Colors.grey.shade400),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  minimumSize: const Size(0, 40),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Buy Additional Licenses',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              PopupMenuButton<String>(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints.tightFor(width: 40, height: 40),
                icon: const Icon(
                  Icons.more_vert,
                  color: AppColors.textSecondary,
                  size: 22,
                ),
                color: Colors.white,
                onSelected: onMenuSelected,
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'offline_payment',
                    child: Text(
                      'Offline Payment',
                      style: TextStyle(color: Colors.black87),
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'license_info',
                    child: Text(
                      'License Info',
                      style: TextStyle(color: Colors.black87),
                    ),
                  ),
                  const PopupMenuItem(
                    enabled: false,
                    value: 'version',
                    child: Text(
                      'Version: 1.0.67',
                      style: TextStyle(color: Colors.black54, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ],
          ),
      ],
    );
  }
}

class _DiscontinuationBanner extends StatelessWidget {
  static const _bannerBg = Color(0xFFFFF8E1);
  static const _bannerBorder = Color(0xFFFFE082);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: _bannerBg,
        borderRadius: AppRadius.mdBorder,
        border: Border.all(color: _bannerBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.amber.shade800, size: 22),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: RichText(
              text: const TextSpan(
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textPrimary,
                  height: 1.4,
                ),
                children: [
                  TextSpan(
                    text:
                        "We're discontinuing add-ons soon. Upgrade to the ",
                  ),
                  TextSpan(
                    text: 'Platinum',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  TextSpan(
                    text: ' plan to continue using all your favourite features.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips({
    required this.selectedPlatform,
    required this.selectedDuration,
    required this.onPlatformChanged,
    required this.onDurationChanged,
  });

  final PlanPlatform selectedPlatform;
  final PlanDuration selectedDuration;
  final ValueChanged<PlanPlatform> onPlatformChanged;
  final ValueChanged<PlanDuration> onDurationChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        PopupMenuButton<PlanPlatform>(
          initialValue: selectedPlatform,
          onSelected: onPlatformChanged,
          color: Colors.white,
          offset: const Offset(0, 40),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.mdBorder),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: PlanPlatform.desktopMobile,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Desktop + Mobile',
                    style: TextStyle(color: Colors.black87),
                  ),
                  if (selectedPlatform == PlanPlatform.desktopMobile)
                    const Icon(Icons.check, color: Colors.blue, size: 18),
                ],
              ),
            ),
            PopupMenuItem(
              value: PlanPlatform.desktop,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Desktop',
                    style: TextStyle(color: Colors.black87),
                  ),
                  if (selectedPlatform == PlanPlatform.desktop)
                    const Icon(Icons.check, color: Colors.blue, size: 18),
                ],
              ),
            ),
            PopupMenuItem(
              value: PlanPlatform.mobile,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Mobile',
                    style: TextStyle(color: Colors.black87),
                  ),
                  if (selectedPlatform == PlanPlatform.mobile)
                    const Icon(Icons.check, color: Colors.blue, size: 18),
                ],
              ),
            ),
          ],
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadius.mdBorder,
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  selectedPlatform.label,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                const Icon(
                  Icons.keyboard_arrow_down,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
        PopupMenuButton<PlanDuration>(
          initialValue: selectedDuration,
          onSelected: onDurationChanged,
          color: Colors.white,
          offset: const Offset(0, 40),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.mdBorder),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: PlanDuration.oneYear,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '1 Year',
                    style: TextStyle(color: Colors.black87),
                  ),
                  if (selectedDuration == PlanDuration.oneYear)
                    const Icon(Icons.check, color: Colors.blue, size: 18),
                ],
              ),
            ),
            PopupMenuItem(
              value: PlanDuration.threeYears,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '3 Years',
                    style: TextStyle(color: Colors.black87),
                  ),
                  if (selectedDuration == PlanDuration.threeYears)
                    const Icon(Icons.check, color: Colors.blue, size: 18),
                ],
              ),
            ),
          ],
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadius.mdBorder,
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  selectedDuration.label,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                const Icon(
                  Icons.keyboard_arrow_down,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _OverviewPlanCards extends StatelessWidget {
  const _OverviewPlanCards({
    required this.goldPlan,
    required this.platinumPlan,
    required this.goldPricing,
    required this.platinumPricing,
    required this.features,
    required this.overviewFeatureLimit,
    required this.featuresExpanded,
    required this.selectedCompactPlan,
    required this.onCompactPlanChanged,
    required this.onToggleFeatures,
    required this.onViewAllFeatures,
    required this.onUpgradePressed,
  });

  final PricingPlan goldPlan;
  final PricingPlan platinumPlan;
  final PlanPricing goldPricing;
  final PlanPricing platinumPricing;
  final List<PlanFeature> features;
  final int overviewFeatureLimit;
  final bool featuresExpanded;
  final PricingPlanType selectedCompactPlan;
  final ValueChanged<PricingPlanType> onCompactPlanChanged;
  final VoidCallback onToggleFeatures;
  final VoidCallback onViewAllFeatures;
  final VoidCallback onUpgradePressed;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < _compactBreakpoint) {
          return _buildCompactLayout();
        }

        final showUpgradeCta =
            platinumPricing.ctaLabel == 'Upgrade to Platinum';

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: PlanCard(
                  plan: goldPlan,
                  pricing: goldPricing,
                  features: features,
                  isGold: true,
                  overviewFeatureLimit: overviewFeatureLimit,
                  featuresExpanded: featuresExpanded,
                  onToggleFeatures: onToggleFeatures,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: PlanCard(
                  plan: platinumPlan,
                  pricing: platinumPricing,
                  features: features,
                  isGold: false,
                  overviewFeatureLimit: overviewFeatureLimit,
                  featuresExpanded: featuresExpanded,
                  onToggleFeatures: onToggleFeatures,
                  onCtaPressed:
                      showUpgradeCta ? onUpgradePressed : null,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCompactLayout() {
    final isGoldSelected = selectedCompactPlan == PricingPlanType.gold;
    final selectedPlan = isGoldSelected ? goldPlan : platinumPlan;
    final selectedPricing = isGoldSelected ? goldPricing : platinumPricing;
    final otherPlan = isGoldSelected ? platinumPlan : goldPlan;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PlanCardCompact(
          plan: selectedPlan,
          pricing: selectedPricing,
          features: features,
          isGold: isGoldSelected,
          onViewAllFeatures: onViewAllFeatures,
        ),
        const SizedBox(height: AppSpacing.md),
        PlanCompactSelectorRow(
          plan: otherPlan,
          isGold: otherPlan.isGold,
          onTap: () => onCompactPlanChanged(
            otherPlan.isGold ? PricingPlanType.gold : PricingPlanType.platinum,
          ),
        ),
      ],
    );
  }
}

class _ComparisonHeader extends StatelessWidget {
  const _ComparisonHeader({
    required this.goldPlan,
    required this.platinumPlan,
    required this.goldPricing,
    required this.platinumPricing,
    required this.features,
    required this.overviewFeatureLimit,
    required this.onUpgradePressed,
  });

  final PricingPlan goldPlan;
  final PricingPlan platinumPlan;
  final PlanPricing goldPricing;
  final PlanPricing platinumPricing;
  final List<PlanFeature> features;
  final int overviewFeatureLimit;
  final VoidCallback onUpgradePressed;

  @override
  Widget build(BuildContext context) {
    final showUpgradeCta = platinumPricing.ctaLabel == 'Upgrade to Platinum';

    return Row(
      children: [
        Expanded(
          child: PlanCard(
            plan: goldPlan,
            pricing: goldPricing,
            features: features,
            isGold: true,
            compact: true,
            overviewFeatureLimit: overviewFeatureLimit,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: PlanCard(
            plan: platinumPlan,
            pricing: platinumPricing,
            features: features,
            isGold: false,
            compact: true,
            overviewFeatureLimit: overviewFeatureLimit,
            onCtaPressed: showUpgradeCta ? onUpgradePressed : null,
          ),
        ),
      ],
    );
  }
}

class _FeatureComparisonTable extends StatelessWidget {
  const _FeatureComparisonTable({required this.features});

  final List<PlanFeature> features;

  @override
  Widget build(BuildContext context) {
    var dataRowIndex = 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: AppSpacing.sm),
          child: Text(
            'Features',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadius.lgBorder,
            border: Border.all(color: Colors.grey.shade200),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm + 4,
                ),
                color: AppColors.surface,
                child: const Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: SizedBox.shrink(),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          'Gold',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          'Platinum',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              ...features.map((feature) {
                final isEven = !feature.isCategoryHeader && dataRowIndex.isEven;
                if (!feature.isCategoryHeader) {
                  dataRowIndex++;
                }
                return FeatureComparisonRow(feature: feature, isEven: isEven);
              }),
            ],
          ),
        ),
      ],
    );
  }
}
