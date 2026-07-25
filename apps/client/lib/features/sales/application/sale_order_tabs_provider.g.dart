// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sale_order_tabs_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SaleOrderTabs)
final saleOrderTabsProvider = SaleOrderTabsFamily._();

final class SaleOrderTabsProvider
    extends $NotifierProvider<SaleOrderTabs, SaleOrderTabsState> {
  SaleOrderTabsProvider._({
    required SaleOrderTabsFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'saleOrderTabsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$saleOrderTabsHash();

  @override
  String toString() {
    return r'saleOrderTabsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  SaleOrderTabs create() => SaleOrderTabs();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SaleOrderTabsState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SaleOrderTabsState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is SaleOrderTabsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$saleOrderTabsHash() => r'2d9ccafd48cbf3d5d8af23551097ea69e71a6ec9';

final class SaleOrderTabsFamily extends $Family
    with
        $ClassFamilyOverride<
          SaleOrderTabs,
          SaleOrderTabsState,
          SaleOrderTabsState,
          SaleOrderTabsState,
          String?
        > {
  SaleOrderTabsFamily._()
    : super(
        retry: null,
        name: r'saleOrderTabsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SaleOrderTabsProvider call({String? initialDocumentId}) =>
      SaleOrderTabsProvider._(argument: initialDocumentId, from: this);

  @override
  String toString() => r'saleOrderTabsProvider';
}

abstract class _$SaleOrderTabs extends $Notifier<SaleOrderTabsState> {
  late final _$args = ref.$arg as String?;
  String? get initialDocumentId => _$args;

  SaleOrderTabsState build({String? initialDocumentId});
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<SaleOrderTabsState, SaleOrderTabsState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SaleOrderTabsState, SaleOrderTabsState>,
              SaleOrderTabsState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(initialDocumentId: _$args));
  }
}
