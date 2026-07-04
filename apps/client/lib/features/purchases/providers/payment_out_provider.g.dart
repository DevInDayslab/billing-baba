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

String _$paymentOutRecordsHash() => r'0b41139641bf83151c85e4dd5c3ee234be8ed0b7';

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

String _$paymentOutFiltersHash() => r'f22540069388ec2fbc45a09addd88cd7dc783ace';

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
    r'3d89c219c60bcc53956863c54981204881f6cf54';

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

String _$paymentOutSummaryHash() => r'8a69371472d8804fe000928fa1339e81567f9ca7';

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

String _$paymentOutFormHash() => r'35cbef12bf37ed1f9f84eaf0ad3b7bebf36a7309';

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
