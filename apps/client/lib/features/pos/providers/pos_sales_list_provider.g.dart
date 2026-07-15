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
    extends $AsyncNotifierProvider<PosSalesList, List<PosSale>> {
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
}

String _$posSalesListHash() => r'6a140709b66b86bdb0851cedb50b03fd58b69df0';

abstract class _$PosSalesList extends $AsyncNotifier<List<PosSale>> {
  FutureOr<List<PosSale>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<PosSale>>, List<PosSale>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<PosSale>>, List<PosSale>>,
              AsyncValue<List<PosSale>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
