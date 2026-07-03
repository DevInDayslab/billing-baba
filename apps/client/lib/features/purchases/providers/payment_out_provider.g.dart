// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_out_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PaymentOutRecords)
final paymentOutRecordsProvider = PaymentOutRecordsProvider._();

final class PaymentOutRecordsProvider
    extends $NotifierProvider<PaymentOutRecords, List<PaymentOutModel>> {
  PaymentOutRecordsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'paymentOutRecordsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$paymentOutRecordsHash();

  @$internal
  @override
  PaymentOutRecords create() => PaymentOutRecords();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<PaymentOutModel> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<PaymentOutModel>>(value),
    );
  }
}

String _$paymentOutRecordsHash() => r'c5b2cf4564dd5f0c0f551ce1838fbfc84f37099e';

abstract class _$PaymentOutRecords extends $Notifier<List<PaymentOutModel>> {
  List<PaymentOutModel> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<List<PaymentOutModel>, List<PaymentOutModel>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<PaymentOutModel>, List<PaymentOutModel>>,
              List<PaymentOutModel>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(PaymentOutFilters)
final paymentOutFiltersProvider = PaymentOutFiltersProvider._();

final class PaymentOutFiltersProvider
    extends $NotifierProvider<PaymentOutFilters, PaymentOutFiltersState> {
  PaymentOutFiltersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'paymentOutFiltersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$paymentOutFiltersHash();

  @$internal
  @override
  PaymentOutFilters create() => PaymentOutFilters();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PaymentOutFiltersState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PaymentOutFiltersState>(value),
    );
  }
}

String _$paymentOutFiltersHash() => r'aab30c972a21999976bfd4f9652f8eeef1f4208b';

abstract class _$PaymentOutFilters extends $Notifier<PaymentOutFiltersState> {
  PaymentOutFiltersState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<PaymentOutFiltersState, PaymentOutFiltersState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PaymentOutFiltersState, PaymentOutFiltersState>,
              PaymentOutFiltersState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(filteredPaymentOutRecords)
final filteredPaymentOutRecordsProvider = FilteredPaymentOutRecordsProvider._();

final class FilteredPaymentOutRecordsProvider
    extends
        $FunctionalProvider<
          List<PaymentOutModel>,
          List<PaymentOutModel>,
          List<PaymentOutModel>
        >
    with $Provider<List<PaymentOutModel>> {
  FilteredPaymentOutRecordsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'filteredPaymentOutRecordsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$filteredPaymentOutRecordsHash();

  @$internal
  @override
  $ProviderElement<List<PaymentOutModel>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<PaymentOutModel> create(Ref ref) {
    return filteredPaymentOutRecords(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<PaymentOutModel> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<PaymentOutModel>>(value),
    );
  }
}

String _$filteredPaymentOutRecordsHash() =>
    r'235a147831d1dc3db1edc96fa758e06ad87aad5d';

@ProviderFor(paginatedPaymentOutRecords)
final paginatedPaymentOutRecordsProvider =
    PaginatedPaymentOutRecordsProvider._();

final class PaginatedPaymentOutRecordsProvider
    extends
        $FunctionalProvider<
          PaginatedPaymentOut,
          PaginatedPaymentOut,
          PaginatedPaymentOut
        >
    with $Provider<PaginatedPaymentOut> {
  PaginatedPaymentOutRecordsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'paginatedPaymentOutRecordsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$paginatedPaymentOutRecordsHash();

  @$internal
  @override
  $ProviderElement<PaginatedPaymentOut> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PaginatedPaymentOut create(Ref ref) {
    return paginatedPaymentOutRecords(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PaginatedPaymentOut value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PaginatedPaymentOut>(value),
    );
  }
}

String _$paginatedPaymentOutRecordsHash() =>
    r'd1c98767b7769c46f6a2b6a712e5da19cf92406c';

@ProviderFor(paymentOutSummary)
final paymentOutSummaryProvider = PaymentOutSummaryProvider._();

final class PaymentOutSummaryProvider
    extends
        $FunctionalProvider<
          PaymentOutSummaryData,
          PaymentOutSummaryData,
          PaymentOutSummaryData
        >
    with $Provider<PaymentOutSummaryData> {
  PaymentOutSummaryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'paymentOutSummaryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$paymentOutSummaryHash();

  @$internal
  @override
  $ProviderElement<PaymentOutSummaryData> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PaymentOutSummaryData create(Ref ref) {
    return paymentOutSummary(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PaymentOutSummaryData value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PaymentOutSummaryData>(value),
    );
  }
}

String _$paymentOutSummaryHash() => r'e0f14890f487d0acc1cce012609ebb7e88fcaeaa';

@ProviderFor(PaymentOutForm)
final paymentOutFormProvider = PaymentOutFormProvider._();

final class PaymentOutFormProvider
    extends $NotifierProvider<PaymentOutForm, PaymentOutFormState> {
  PaymentOutFormProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'paymentOutFormProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$paymentOutFormHash();

  @$internal
  @override
  PaymentOutForm create() => PaymentOutForm();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PaymentOutFormState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PaymentOutFormState>(value),
    );
  }
}

String _$paymentOutFormHash() => r'e178999aa0d8aa213762356ed84514fc624f39c3';

abstract class _$PaymentOutForm extends $Notifier<PaymentOutFormState> {
  PaymentOutFormState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<PaymentOutFormState, PaymentOutFormState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PaymentOutFormState, PaymentOutFormState>,
              PaymentOutFormState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
