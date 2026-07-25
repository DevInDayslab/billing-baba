// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sale_line_item_column_visibility_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Persisted visibility for optional columns on the Add Sale line-items grid.

@ProviderFor(SaleLineItemColumnVisibilityState)
final saleLineItemColumnVisibilityStateProvider =
    SaleLineItemColumnVisibilityStateProvider._();

/// Persisted visibility for optional columns on the Add Sale line-items grid.
final class SaleLineItemColumnVisibilityStateProvider
    extends
        $NotifierProvider<
          SaleLineItemColumnVisibilityState,
          SaleLineItemColumnVisibility
        > {
  /// Persisted visibility for optional columns on the Add Sale line-items grid.
  SaleLineItemColumnVisibilityStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'saleLineItemColumnVisibilityStateProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() =>
      _$saleLineItemColumnVisibilityStateHash();

  @$internal
  @override
  SaleLineItemColumnVisibilityState create() =>
      SaleLineItemColumnVisibilityState();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SaleLineItemColumnVisibility value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SaleLineItemColumnVisibility>(value),
    );
  }
}

String _$saleLineItemColumnVisibilityStateHash() =>
    r'd7db92799d1c469b1138490097cf06d0dd32c61a';

/// Persisted visibility for optional columns on the Add Sale line-items grid.

abstract class _$SaleLineItemColumnVisibilityState
    extends $Notifier<SaleLineItemColumnVisibility> {
  SaleLineItemColumnVisibility build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<SaleLineItemColumnVisibility, SaleLineItemColumnVisibility>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                SaleLineItemColumnVisibility,
                SaleLineItemColumnVisibility
              >,
              SaleLineItemColumnVisibility,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
