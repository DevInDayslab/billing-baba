// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_state_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SubscriptionStateController)
final subscriptionStateControllerProvider =
    SubscriptionStateControllerProvider._();

final class SubscriptionStateControllerProvider
    extends
        $AsyncNotifierProvider<SubscriptionStateController, SubscriptionState> {
  SubscriptionStateControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'subscriptionStateControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$subscriptionStateControllerHash();

  @$internal
  @override
  SubscriptionStateController create() => SubscriptionStateController();
}

String _$subscriptionStateControllerHash() =>
    r'a3d8733e744b3d43e3897468605f35d88f8bfa6d';

abstract class _$SubscriptionStateController
    extends $AsyncNotifier<SubscriptionState> {
  FutureOr<SubscriptionState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<SubscriptionState>, SubscriptionState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<SubscriptionState>, SubscriptionState>,
              AsyncValue<SubscriptionState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
