// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_in_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PaymentInRecords)
final paymentInRecordsProvider = PaymentInRecordsProvider._();

final class PaymentInRecordsProvider
    extends $AsyncNotifierProvider<PaymentInRecords, List<PaymentInModel>> {
  PaymentInRecordsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'paymentInRecordsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$paymentInRecordsHash();

  @$internal
  @override
  PaymentInRecords create() => PaymentInRecords();
}

String _$paymentInRecordsHash() => r'c44f6e81971b7cd2c02f1600fc743fe8a6e70152';

abstract class _$PaymentInRecords extends $AsyncNotifier<List<PaymentInModel>> {
  FutureOr<List<PaymentInModel>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<List<PaymentInModel>>, List<PaymentInModel>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<PaymentInModel>>,
                List<PaymentInModel>
              >,
              AsyncValue<List<PaymentInModel>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(PaymentInFilters)
final paymentInFiltersProvider = PaymentInFiltersProvider._();

final class PaymentInFiltersProvider
    extends $NotifierProvider<PaymentInFilters, PaymentInFiltersState> {
  PaymentInFiltersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'paymentInFiltersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$paymentInFiltersHash();

  @$internal
  @override
  PaymentInFilters create() => PaymentInFilters();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PaymentInFiltersState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PaymentInFiltersState>(value),
    );
  }
}

String _$paymentInFiltersHash() => r'fd8c086ebf67cf3fac2b9da4c2242cc72ce9afb5';

abstract class _$PaymentInFilters extends $Notifier<PaymentInFiltersState> {
  PaymentInFiltersState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<PaymentInFiltersState, PaymentInFiltersState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PaymentInFiltersState, PaymentInFiltersState>,
              PaymentInFiltersState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(filteredPaymentInRecords)
final filteredPaymentInRecordsProvider = FilteredPaymentInRecordsProvider._();

final class FilteredPaymentInRecordsProvider
    extends
        $FunctionalProvider<
          List<PaymentInModel>,
          List<PaymentInModel>,
          List<PaymentInModel>
        >
    with $Provider<List<PaymentInModel>> {
  FilteredPaymentInRecordsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'filteredPaymentInRecordsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$filteredPaymentInRecordsHash();

  @$internal
  @override
  $ProviderElement<List<PaymentInModel>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<PaymentInModel> create(Ref ref) {
    return filteredPaymentInRecords(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<PaymentInModel> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<PaymentInModel>>(value),
    );
  }
}

String _$filteredPaymentInRecordsHash() =>
    r'73dd29ddf5eb1b65328975b059194a882c6365b7';

@ProviderFor(paginatedPaymentInRecords)
final paginatedPaymentInRecordsProvider = PaginatedPaymentInRecordsProvider._();

final class PaginatedPaymentInRecordsProvider
    extends
        $FunctionalProvider<
          PaginatedPaymentIn,
          PaginatedPaymentIn,
          PaginatedPaymentIn
        >
    with $Provider<PaginatedPaymentIn> {
  PaginatedPaymentInRecordsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'paginatedPaymentInRecordsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$paginatedPaymentInRecordsHash();

  @$internal
  @override
  $ProviderElement<PaginatedPaymentIn> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PaginatedPaymentIn create(Ref ref) {
    return paginatedPaymentInRecords(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PaginatedPaymentIn value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PaginatedPaymentIn>(value),
    );
  }
}

String _$paginatedPaymentInRecordsHash() =>
    r'b26898a0d740bf9407765f5321e603d3ac028e4d';

@ProviderFor(paymentInSummary)
final paymentInSummaryProvider = PaymentInSummaryProvider._();

final class PaymentInSummaryProvider
    extends
        $FunctionalProvider<
          PaymentInSummaryData,
          PaymentInSummaryData,
          PaymentInSummaryData
        >
    with $Provider<PaymentInSummaryData> {
  PaymentInSummaryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'paymentInSummaryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$paymentInSummaryHash();

  @$internal
  @override
  $ProviderElement<PaymentInSummaryData> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PaymentInSummaryData create(Ref ref) {
    return paymentInSummary(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PaymentInSummaryData value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PaymentInSummaryData>(value),
    );
  }
}

String _$paymentInSummaryHash() => r'3619c230b7edce2512d38585d5d7c963be08fded';

@ProviderFor(PaymentInForm)
final paymentInFormProvider = PaymentInFormProvider._();

final class PaymentInFormProvider
    extends $NotifierProvider<PaymentInForm, PaymentInFormState> {
  PaymentInFormProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'paymentInFormProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$paymentInFormHash();

  @$internal
  @override
  PaymentInForm create() => PaymentInForm();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PaymentInFormState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PaymentInFormState>(value),
    );
  }
}

String _$paymentInFormHash() => r'b6c35d4a46f7ee4e9af463fbba3477b5902f602f';

abstract class _$PaymentInForm extends $Notifier<PaymentInFormState> {
  PaymentInFormState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<PaymentInFormState, PaymentInFormState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PaymentInFormState, PaymentInFormState>,
              PaymentInFormState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
