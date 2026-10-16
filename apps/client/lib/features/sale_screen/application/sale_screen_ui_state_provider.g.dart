// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sale_screen_ui_state_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Per POS-tab product pane state (search, category filter) across minimize/restore.

@ProviderFor(SaleScreenUiState)
final saleScreenUiStateProvider = SaleScreenUiStateProvider._();

/// Per POS-tab product pane state (search, category filter) across minimize/restore.
final class SaleScreenUiStateProvider
    extends
        $NotifierProvider<
          SaleScreenUiState,
          Map<String, SaleScreenTabUiState>
        > {
  /// Per POS-tab product pane state (search, category filter) across minimize/restore.
  SaleScreenUiStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'saleScreenUiStateProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$saleScreenUiStateHash();

  @$internal
  @override
  SaleScreenUiState create() => SaleScreenUiState();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, SaleScreenTabUiState> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, SaleScreenTabUiState>>(
        value,
      ),
    );
  }
}

String _$saleScreenUiStateHash() => r'3766ab4116f8734a91df4c23f3c84a863de535f5';

/// Per POS-tab product pane state (search, category filter) across minimize/restore.

abstract class _$SaleScreenUiState
    extends $Notifier<Map<String, SaleScreenTabUiState>> {
  Map<String, SaleScreenTabUiState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              Map<String, SaleScreenTabUiState>,
              Map<String, SaleScreenTabUiState>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                Map<String, SaleScreenTabUiState>,
                Map<String, SaleScreenTabUiState>
              >,
              Map<String, SaleScreenTabUiState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
