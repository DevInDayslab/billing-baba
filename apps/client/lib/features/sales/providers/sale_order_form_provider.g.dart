// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sale_order_form_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SaleOrderFormNotifier)
final saleOrderFormProvider = SaleOrderFormNotifierFamily._();

final class SaleOrderFormNotifierProvider
    extends $NotifierProvider<SaleOrderFormNotifier, SaleOrderFormState> {
  SaleOrderFormNotifierProvider._({
    required SaleOrderFormNotifierFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'saleOrderFormProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$saleOrderFormNotifierHash();

  @override
  String toString() {
    return r'saleOrderFormProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  SaleOrderFormNotifier create() => SaleOrderFormNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SaleOrderFormState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SaleOrderFormState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is SaleOrderFormNotifierProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$saleOrderFormNotifierHash() =>
    r'b77a639be43e02115ab4b56cda1e2ac377aa8de9';

final class SaleOrderFormNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
          SaleOrderFormNotifier,
          SaleOrderFormState,
          SaleOrderFormState,
          SaleOrderFormState,
          String
        > {
  SaleOrderFormNotifierFamily._()
    : super(
        retry: null,
        name: r'saleOrderFormProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SaleOrderFormNotifierProvider call({String sessionKey = 'default'}) =>
      SaleOrderFormNotifierProvider._(argument: sessionKey, from: this);

  @override
  String toString() => r'saleOrderFormProvider';
}

abstract class _$SaleOrderFormNotifier extends $Notifier<SaleOrderFormState> {
  late final _$args = ref.$arg as String;
  String get sessionKey => _$args;

  SaleOrderFormState build({String sessionKey = 'default'});
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<SaleOrderFormState, SaleOrderFormState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SaleOrderFormState, SaleOrderFormState>,
              SaleOrderFormState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(sessionKey: _$args));
  }
}

@ProviderFor(saleOrderGrandTotal)
final saleOrderGrandTotalProvider = SaleOrderGrandTotalFamily._();

final class SaleOrderGrandTotalProvider
    extends $FunctionalProvider<double, double, double>
    with $Provider<double> {
  SaleOrderGrandTotalProvider._({
    required SaleOrderGrandTotalFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'saleOrderGrandTotalProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$saleOrderGrandTotalHash();

  @override
  String toString() {
    return r'saleOrderGrandTotalProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<double> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  double create(Ref ref) {
    final argument = this.argument as String;
    return saleOrderGrandTotal(ref, sessionKey: argument);
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
    return other is SaleOrderGrandTotalProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$saleOrderGrandTotalHash() =>
    r'7181867151a937bd04338549240dd2369aef1679';

final class SaleOrderGrandTotalFamily extends $Family
    with $FunctionalFamilyOverride<double, String> {
  SaleOrderGrandTotalFamily._()
    : super(
        retry: null,
        name: r'saleOrderGrandTotalProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SaleOrderGrandTotalProvider call({String sessionKey = 'default'}) =>
      SaleOrderGrandTotalProvider._(argument: sessionKey, from: this);

  @override
  String toString() => r'saleOrderGrandTotalProvider';
}

@ProviderFor(saleOrderTotalTax)
final saleOrderTotalTaxProvider = SaleOrderTotalTaxFamily._();

final class SaleOrderTotalTaxProvider
    extends $FunctionalProvider<double, double, double>
    with $Provider<double> {
  SaleOrderTotalTaxProvider._({
    required SaleOrderTotalTaxFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'saleOrderTotalTaxProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$saleOrderTotalTaxHash();

  @override
  String toString() {
    return r'saleOrderTotalTaxProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<double> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  double create(Ref ref) {
    final argument = this.argument as String;
    return saleOrderTotalTax(ref, sessionKey: argument);
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
    return other is SaleOrderTotalTaxProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$saleOrderTotalTaxHash() => r'6d355cbc3303600fb56b6fcb205c566ab97b6426';

final class SaleOrderTotalTaxFamily extends $Family
    with $FunctionalFamilyOverride<double, String> {
  SaleOrderTotalTaxFamily._()
    : super(
        retry: null,
        name: r'saleOrderTotalTaxProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SaleOrderTotalTaxProvider call({String sessionKey = 'default'}) =>
      SaleOrderTotalTaxProvider._(argument: sessionKey, from: this);

  @override
  String toString() => r'saleOrderTotalTaxProvider';
}
