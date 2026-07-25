// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_plans_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SubscriptionPlans)
final subscriptionPlansProvider = SubscriptionPlansProvider._();

final class SubscriptionPlansProvider
    extends $AsyncNotifierProvider<SubscriptionPlans, List<SubscriptionPlan>> {
  SubscriptionPlansProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'subscriptionPlansProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$subscriptionPlansHash();

  @$internal
  @override
  SubscriptionPlans create() => SubscriptionPlans();
}

String _$subscriptionPlansHash() => r'36d0bd5b6e63d980ece359aa5f1615ddad54aee2';

abstract class _$SubscriptionPlans
    extends $AsyncNotifier<List<SubscriptionPlan>> {
  FutureOr<List<SubscriptionPlan>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<List<SubscriptionPlan>>, List<SubscriptionPlan>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<SubscriptionPlan>>,
                List<SubscriptionPlan>
              >,
              AsyncValue<List<SubscriptionPlan>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
