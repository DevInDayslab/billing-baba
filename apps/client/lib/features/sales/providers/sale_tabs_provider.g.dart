// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sale_tabs_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SaleTabs)
final saleTabsProvider = SaleTabsFamily._();

final class SaleTabsProvider
    extends $NotifierProvider<SaleTabs, SaleTabsState> {
  SaleTabsProvider._({
    required SaleTabsFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'saleTabsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$saleTabsHash();

  @override
  String toString() {
    return r'saleTabsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  SaleTabs create() => SaleTabs();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SaleTabsState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SaleTabsState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is SaleTabsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$saleTabsHash() => r'80e4992238d842da95a9b9fa618313a941161ab6';

final class SaleTabsFamily extends $Family
    with
        $ClassFamilyOverride<
          SaleTabs,
          SaleTabsState,
          SaleTabsState,
          SaleTabsState,
          String?
        > {
  SaleTabsFamily._()
    : super(
        retry: null,
        name: r'saleTabsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SaleTabsProvider call({String? initialDocumentId}) =>
      SaleTabsProvider._(argument: initialDocumentId, from: this);

  @override
  String toString() => r'saleTabsProvider';
}

abstract class _$SaleTabs extends $Notifier<SaleTabsState> {
  late final _$args = ref.$arg as String?;
  String? get initialDocumentId => _$args;

  SaleTabsState build({String? initialDocumentId});
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<SaleTabsState, SaleTabsState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SaleTabsState, SaleTabsState>,
              SaleTabsState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(initialDocumentId: _$args));
  }
}
