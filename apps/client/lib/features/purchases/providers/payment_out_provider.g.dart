// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_out_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PaymentOutSearchQuery)
final paymentOutSearchQueryProvider = PaymentOutSearchQueryProvider._();

final class PaymentOutSearchQueryProvider
    extends $NotifierProvider<PaymentOutSearchQuery, String> {
  PaymentOutSearchQueryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'paymentOutSearchQueryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$paymentOutSearchQueryHash();

  @$internal
  @override
  PaymentOutSearchQuery create() => PaymentOutSearchQuery();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$paymentOutSearchQueryHash() =>
    r'cbba87c31c7c3d2c3a102f9151693a06971c242e';

abstract class _$PaymentOutSearchQuery extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String, String>,
              String,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(PaymentOutRecords)
final paymentOutRecordsProvider = PaymentOutRecordsProvider._();

final class PaymentOutRecordsProvider
    extends $AsyncNotifierProvider<PaymentOutRecords, PaginatedPaymentOut> {
  PaymentOutRecordsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'paymentOutRecordsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$paymentOutRecordsHash();

  @$internal
  @override
  PaymentOutRecords create() => PaymentOutRecords();
}

String _$paymentOutRecordsHash() => r'39f8e246fe2b2ee1190f719529ba9cad72d9e562';

abstract class _$PaymentOutRecords extends $AsyncNotifier<PaginatedPaymentOut> {
  FutureOr<PaginatedPaymentOut> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<PaginatedPaymentOut>, PaginatedPaymentOut>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<PaginatedPaymentOut>, PaginatedPaymentOut>,
              AsyncValue<PaginatedPaymentOut>,
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

String _$paymentOutFiltersHash() => r'9a564e7c98e0e4c01780a04fb50bacf947a8ae42';

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
    r'1fc79855d4440c543336651a9345b10eb5fd1029';

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
    r'41e6a7b6dc913e91a4f68bfaeb02e1aefabd1dd9';

@ProviderFor(paymentOutPartyOptions)
final paymentOutPartyOptionsProvider = PaymentOutPartyOptionsProvider._();

final class PaymentOutPartyOptionsProvider
    extends $FunctionalProvider<List<String>, List<String>, List<String>>
    with $Provider<List<String>> {
  PaymentOutPartyOptionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'paymentOutPartyOptionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$paymentOutPartyOptionsHash();

  @$internal
  @override
  $ProviderElement<List<String>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<String> create(Ref ref) {
    return paymentOutPartyOptions(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<String>>(value),
    );
  }
}

String _$paymentOutPartyOptionsHash() =>
    r'73a23e4fbe8f71c8d429b82a51f32ad3b5f52a77';

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

String _$paymentOutFormHash() => r'fc9fd1bb4b4b8dc549f3ed562a345587212d7156';

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
