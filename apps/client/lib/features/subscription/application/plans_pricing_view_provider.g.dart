// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plans_pricing_view_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PlansPricingView)
final plansPricingViewProvider = PlansPricingViewProvider._();

final class PlansPricingViewProvider
    extends $AsyncNotifierProvider<PlansPricingView, PlansPricingViewData> {
  PlansPricingViewProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'plansPricingViewProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$plansPricingViewHash();

  @$internal
  @override
  PlansPricingView create() => PlansPricingView();
}

String _$plansPricingViewHash() => r'e9f199605db892073e63c5b9b191cddd6e269ffc';

abstract class _$PlansPricingView extends $AsyncNotifier<PlansPricingViewData> {
  FutureOr<PlansPricingViewData> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<PlansPricingViewData>, PlansPricingViewData>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<PlansPricingViewData>,
                PlansPricingViewData
              >,
              AsyncValue<PlansPricingViewData>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
