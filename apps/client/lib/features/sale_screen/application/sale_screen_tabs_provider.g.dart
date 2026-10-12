// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sale_screen_tabs_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SaleScreenTabs)
final saleScreenTabsProvider = SaleScreenTabsProvider._();

final class SaleScreenTabsProvider
    extends $NotifierProvider<SaleScreenTabs, SaleScreenTabsState> {
  SaleScreenTabsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'saleScreenTabsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$saleScreenTabsHash();

  @$internal
  @override
  SaleScreenTabs create() => SaleScreenTabs();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SaleScreenTabsState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SaleScreenTabsState>(value),
    );
  }
}

String _$saleScreenTabsHash() => r'32ddf69d0209cf66efe6c86050031018a02758f1';

abstract class _$SaleScreenTabs extends $Notifier<SaleScreenTabsState> {
  SaleScreenTabsState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<SaleScreenTabsState, SaleScreenTabsState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SaleScreenTabsState, SaleScreenTabsState>,
              SaleScreenTabsState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
