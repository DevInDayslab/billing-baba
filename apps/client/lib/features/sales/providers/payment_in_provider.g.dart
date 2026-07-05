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
    extends $AsyncNotifierProvider<PaymentInRecords, PaginatedPaymentIn> {
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

String _$paymentInRecordsHash() => r'f55165f2e69c7096a3b312431b0f6d52063f0459';

abstract class _$PaymentInRecords extends $AsyncNotifier<PaginatedPaymentIn> {
  FutureOr<PaginatedPaymentIn> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<PaginatedPaymentIn>, PaginatedPaymentIn>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<PaginatedPaymentIn>, PaginatedPaymentIn>,
              AsyncValue<PaginatedPaymentIn>,
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

String _$paymentInFiltersHash() => r'b34804a1ab12d3ad28444e5e06d317371e014a3b';

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
    r'0016f0987c5c453bdfe6f4d3d2c4d7f1bc759be1';

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

String _$paymentInSummaryHash() => r'e1064a4ae0b8768cb8cb2ad2c4acbd14001dc0f4';

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

String _$paymentInFormHash() => r'f1c4c2f33981b30e1f1c4209b6017931c7b09383';

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
