// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_service_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(subscriptionService)
final subscriptionServiceProvider = SubscriptionServiceProvider._();

final class SubscriptionServiceProvider
    extends
        $FunctionalProvider<
          AsyncValue<SubscriptionService>,
          SubscriptionService,
          FutureOr<SubscriptionService>
        >
    with
        $FutureModifier<SubscriptionService>,
        $FutureProvider<SubscriptionService> {
  SubscriptionServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'subscriptionServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$subscriptionServiceHash();

  @$internal
  @override
  $FutureProviderElement<SubscriptionService> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SubscriptionService> create(Ref ref) {
    return subscriptionService(ref);
  }
}

String _$subscriptionServiceHash() =>
    r'a3a367d1e888052b73f3b1d081bdcceddd55bc70';
