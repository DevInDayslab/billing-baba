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
    extends
        $NotifierProvider<
          DeliveryChallanFormNotifier,
          DeliveryChallanFormState
        > {
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
    r'2bd402dedefe9d9b8ac92203265119d36630eda6';

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

@ProviderFor(deliveryChallanTotalTax)
final deliveryChallanTotalTaxProvider = DeliveryChallanTotalTaxProvider._();

final class DeliveryChallanTotalTaxProvider
    extends $FunctionalProvider<double, double, double>
    with $Provider<double> {
  DeliveryChallanTotalTaxProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deliveryChallanTotalTaxProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deliveryChallanTotalTaxHash();

  @$internal
  @override
  $ProviderElement<double> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  double create(Ref ref) {
    return deliveryChallanTotalTax(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(double value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<double>(value),
    );
  }
}

String _$deliveryChallanTotalTaxHash() =>
    r'cd71d4f47b9046a47cb3b3aa2923108e54acb999';

@ProviderFor(deliveryChallanGrandTotal)
final deliveryChallanGrandTotalProvider = DeliveryChallanGrandTotalProvider._();

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
    r'9ad8d5a8e031632cd7cd22dd697e6d3f15b32d90';
