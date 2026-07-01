// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delivery_challan_form_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(DeliveryChallanFormNotifier)
final deliveryChallanFormProvider = DeliveryChallanFormNotifierProvider._();

final class DeliveryChallanFormNotifierProvider
    extends $NotifierProvider<DeliveryChallanFormNotifier, DeliveryChallanFormState> {
  DeliveryChallanFormNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deliveryChallanFormProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deliveryChallanFormNotifierHash();

  @$internal
  @override
  DeliveryChallanFormNotifier create() => DeliveryChallanFormNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DeliveryChallanFormState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DeliveryChallanFormState>(value),
    );
  }
}

String _$deliveryChallanFormNotifierHash() =>
    r'a1b2c3d4e5f60718293a4b5c6d7e8f9012345678';

abstract class _$DeliveryChallanFormNotifier
    extends $Notifier<DeliveryChallanFormState> {
  DeliveryChallanFormState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<DeliveryChallanFormState, DeliveryChallanFormState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DeliveryChallanFormState, DeliveryChallanFormState>,
              DeliveryChallanFormState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(SavedDeliveryChallansNotifier)
final savedDeliveryChallansProvider = SavedDeliveryChallansNotifierProvider._();

final class SavedDeliveryChallansNotifierProvider
    extends
        $NotifierProvider<SavedDeliveryChallansNotifier, List<SavedDeliveryChallan>> {
  SavedDeliveryChallansNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'savedDeliveryChallansProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$savedDeliveryChallansNotifierHash();

  @$internal
  @override
  SavedDeliveryChallansNotifier create() => SavedDeliveryChallansNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<SavedDeliveryChallan> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<SavedDeliveryChallan>>(value),
    );
  }
}

String _$savedDeliveryChallansNotifierHash() =>
    r'b2c3d4e5f60718293a4b5c6d7e8f901234567890';

abstract class _$SavedDeliveryChallansNotifier
    extends $Notifier<List<SavedDeliveryChallan>> {
  List<SavedDeliveryChallan> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref
        as $Ref<List<SavedDeliveryChallan>, List<SavedDeliveryChallan>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                List<SavedDeliveryChallan>,
                List<SavedDeliveryChallan>
              >,
              List<SavedDeliveryChallan>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(deliveryChallanGrandTotal)
final deliveryChallanGrandTotalProvider =
    DeliveryChallanGrandTotalProvider._();

final class DeliveryChallanGrandTotalProvider
    extends $FunctionalProvider<double, double, double>
    with $Provider<double> {
  DeliveryChallanGrandTotalProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deliveryChallanGrandTotalProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deliveryChallanGrandTotalHash();

  @$internal
  @override
  $ProviderElement<double> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  double create(Ref ref) {
    return deliveryChallanGrandTotal(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(double value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<double>(value),
    );
  }
}

String _$deliveryChallanGrandTotalHash() =>
    r'c3d4e5f60718293a4b5c6d7e8f90123456789012';
