// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_order_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CreateOrderController)
final createOrderControllerProvider = CreateOrderControllerProvider._();

final class CreateOrderControllerProvider
    extends
        $NotifierProvider<
          CreateOrderController,
          AsyncValue<CreateOrderResult?>
        > {
  CreateOrderControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'createOrderControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$createOrderControllerHash();

  @$internal
  @override
  CreateOrderController create() => CreateOrderController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<CreateOrderResult?> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<CreateOrderResult?>>(
        value,
      ),
    );
  }
}

String _$createOrderControllerHash() =>
    r'98b95ffc6d96b1f99b8ee5810065cad542fb9cca';

abstract class _$CreateOrderController
    extends $Notifier<AsyncValue<CreateOrderResult?>> {
  AsyncValue<CreateOrderResult?> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<CreateOrderResult?>,
              AsyncValue<CreateOrderResult?>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<CreateOrderResult?>,
                AsyncValue<CreateOrderResult?>
              >,
              AsyncValue<CreateOrderResult?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
