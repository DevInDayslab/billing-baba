// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sale_screen_minimized_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// True after the user minimizes POS; cleared when the sale screen is closed.

@ProviderFor(SaleScreenMinimized)
final saleScreenMinimizedProvider = SaleScreenMinimizedProvider._();

/// True after the user minimizes POS; cleared when the sale screen is closed.
final class SaleScreenMinimizedProvider
    extends $NotifierProvider<SaleScreenMinimized, bool> {
  /// True after the user minimizes POS; cleared when the sale screen is closed.
  SaleScreenMinimizedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'saleScreenMinimizedProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$saleScreenMinimizedHash();

  @$internal
  @override
  SaleScreenMinimized create() => SaleScreenMinimized();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$saleScreenMinimizedHash() =>
    r'a978b4e2e9ac43f26d5c4f6e575a6837832b4fa5';

/// True after the user minimizes POS; cleared when the sale screen is closed.

abstract class _$SaleScreenMinimized extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
