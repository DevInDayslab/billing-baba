// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sale_document_form_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SaleDocumentFormNotifier)
final saleDocumentFormProvider = SaleDocumentFormNotifierFamily._();

final class SaleDocumentFormNotifierProvider
    extends $NotifierProvider<SaleDocumentFormNotifier, SaleDocumentFormState> {
  SaleDocumentFormNotifierProvider._({
    required SaleDocumentFormNotifierFamily super.from,
    required SaleDocumentType super.argument,
  }) : super(
         retry: null,
         name: r'saleDocumentFormProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$saleDocumentFormNotifierHash();

  @override
  String toString() {
    return r'saleDocumentFormProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  SaleDocumentFormNotifier create() => SaleDocumentFormNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SaleDocumentFormState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SaleDocumentFormState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is SaleDocumentFormNotifierProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$saleDocumentFormNotifierHash() =>
    r'74f4d91601b0889a65809e40f07b87c227fce9aa';

final class SaleDocumentFormNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
          SaleDocumentFormNotifier,
          SaleDocumentFormState,
          SaleDocumentFormState,
          SaleDocumentFormState,
          SaleDocumentType
        > {
  SaleDocumentFormNotifierFamily._()
    : super(
        retry: null,
        name: r'saleDocumentFormProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SaleDocumentFormNotifierProvider call(SaleDocumentType documentType) =>
      SaleDocumentFormNotifierProvider._(argument: documentType, from: this);

  @override
  String toString() => r'saleDocumentFormProvider';
}

abstract class _$SaleDocumentFormNotifier
    extends $Notifier<SaleDocumentFormState> {
  late final _$args = ref.$arg as SaleDocumentType;
  SaleDocumentType get documentType => _$args;

  SaleDocumentFormState build(SaleDocumentType documentType);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<SaleDocumentFormState, SaleDocumentFormState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SaleDocumentFormState, SaleDocumentFormState>,
              SaleDocumentFormState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

@ProviderFor(saleDocumentTotalTax)
final saleDocumentTotalTaxProvider = SaleDocumentTotalTaxFamily._();

final class SaleDocumentTotalTaxProvider
    extends $FunctionalProvider<double, double, double>
    with $Provider<double> {
  SaleDocumentTotalTaxProvider._({
    required SaleDocumentTotalTaxFamily super.from,
    required SaleDocumentType super.argument,
  }) : super(
         retry: null,
         name: r'saleDocumentTotalTaxProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$saleDocumentTotalTaxHash();

  @override
  String toString() {
    return r'saleDocumentTotalTaxProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<double> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  double create(Ref ref) {
    final argument = this.argument as SaleDocumentType;
    return saleDocumentTotalTax(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(double value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<double>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is SaleDocumentTotalTaxProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$saleDocumentTotalTaxHash() =>
    r'fcab33b73fb7ac0cd737c0c54b0e523b6b978714';

final class SaleDocumentTotalTaxFamily extends $Family
    with $FunctionalFamilyOverride<double, SaleDocumentType> {
  SaleDocumentTotalTaxFamily._()
    : super(
        retry: null,
        name: r'saleDocumentTotalTaxProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SaleDocumentTotalTaxProvider call(SaleDocumentType documentType) =>
      SaleDocumentTotalTaxProvider._(argument: documentType, from: this);

  @override
  String toString() => r'saleDocumentTotalTaxProvider';
}

@ProviderFor(saleDocumentGrandTotal)
final saleDocumentGrandTotalProvider = SaleDocumentGrandTotalFamily._();

final class SaleDocumentGrandTotalProvider
    extends $FunctionalProvider<double, double, double>
    with $Provider<double> {
  SaleDocumentGrandTotalProvider._({
    required SaleDocumentGrandTotalFamily super.from,
    required SaleDocumentType super.argument,
  }) : super(
         retry: null,
         name: r'saleDocumentGrandTotalProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$saleDocumentGrandTotalHash();

  @override
  String toString() {
    return r'saleDocumentGrandTotalProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<double> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  double create(Ref ref) {
    final argument = this.argument as SaleDocumentType;
    return saleDocumentGrandTotal(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(double value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<double>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is SaleDocumentGrandTotalProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$saleDocumentGrandTotalHash() =>
    r'7d1c4f1e1c70fad37a4a5c58a04ca7b8e2ad98b0';

final class SaleDocumentGrandTotalFamily extends $Family
    with $FunctionalFamilyOverride<double, SaleDocumentType> {
  SaleDocumentGrandTotalFamily._()
    : super(
        retry: null,
        name: r'saleDocumentGrandTotalProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SaleDocumentGrandTotalProvider call(SaleDocumentType documentType) =>
      SaleDocumentGrandTotalProvider._(argument: documentType, from: this);

  @override
  String toString() => r'saleDocumentGrandTotalProvider';
}
