// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_sales_list_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PosSalesList)
final posSalesListProvider = PosSalesListProvider._();

final class PosSalesListProvider
    extends $NotifierProvider<PosSalesList, List<PosSale>> {
  PosSalesListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'posSalesListProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$posSalesListHash();

  @$internal
  @override
  PosSalesList create() => PosSalesList();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<PosSale> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<PosSale>>(value),
    );
  }
}

String _$posSalesListHash() => r'e5f678901234567890abcdef0123456789012345';

abstract class _$PosSalesList extends $Notifier<List<PosSale>> {
  List<PosSale> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<List<PosSale>, List<PosSale>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<PosSale>, List<PosSale>>,
              List<PosSale>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
