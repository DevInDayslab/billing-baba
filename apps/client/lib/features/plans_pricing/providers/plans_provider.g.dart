// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plans_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PlanFeatures)
final planFeaturesProvider = PlanFeaturesProvider._();

final class PlanFeaturesProvider
    extends $NotifierProvider<PlanFeatures, List<PlanFeature>> {
  PlanFeaturesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'planFeaturesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$planFeaturesHash();

  @$internal
  @override
  PlanFeatures create() => PlanFeatures();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<PlanFeature> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<PlanFeature>>(value),
    );
  }
}

String _$planFeaturesHash() => r'94df43cbad909ad9532e580f77864e71467df664';

abstract class _$PlanFeatures extends $Notifier<List<PlanFeature>> {
  List<PlanFeature> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<List<PlanFeature>, List<PlanFeature>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<PlanFeature>, List<PlanFeature>>,
              List<PlanFeature>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(PricingPlans)
final pricingPlansProvider = PricingPlansProvider._();

final class PricingPlansProvider
    extends $NotifierProvider<PricingPlans, List<PricingPlan>> {
  PricingPlansProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pricingPlansProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pricingPlansHash();

  @$internal
  @override
  PricingPlans create() => PricingPlans();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<PricingPlan> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<PricingPlan>>(value),
    );
  }
}

String _$pricingPlansHash() => r'3851d5465dfbc8a2b44c812030a93b3e1181c0e2';

abstract class _$PricingPlans extends $Notifier<List<PricingPlan>> {
  List<PricingPlan> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<List<PricingPlan>, List<PricingPlan>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<PricingPlan>, List<PricingPlan>>,
              List<PricingPlan>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
