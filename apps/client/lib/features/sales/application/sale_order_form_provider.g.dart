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
    r'809714e2356732f25497f039db412846bd91b53b';

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
