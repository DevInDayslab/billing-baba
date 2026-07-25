// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'current_subscription_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CurrentSubscriptionState)
final currentSubscriptionStateProvider = CurrentSubscriptionStateProvider._();

final class CurrentSubscriptionStateProvider
    extends
        $AsyncNotifierProvider<CurrentSubscriptionState, CurrentSubscription> {
  CurrentSubscriptionStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentSubscriptionStateProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentSubscriptionStateHash();

  @$internal
  @override
  CurrentSubscriptionState create() => CurrentSubscriptionState();
}

String _$currentSubscriptionStateHash() =>
    r'd679f3eeb19f4da601febaeda69c459327881703';

abstract class _$CurrentSubscriptionState
    extends $AsyncNotifier<CurrentSubscription> {
  FutureOr<CurrentSubscription> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<CurrentSubscription>, CurrentSubscription>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<CurrentSubscription>, CurrentSubscription>,
              AsyncValue<CurrentSubscription>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
