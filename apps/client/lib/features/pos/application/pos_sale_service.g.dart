// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_sale_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(posSaleService)
final posSaleServiceProvider = PosSaleServiceProvider._();

final class PosSaleServiceProvider
    extends
        $FunctionalProvider<
          AsyncValue<PosSaleService>,
          PosSaleService,
          FutureOr<PosSaleService>
        >
    with $FutureModifier<PosSaleService>, $FutureProvider<PosSaleService> {
  PosSaleServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'posSaleServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$posSaleServiceHash();

  @$internal
  @override
  $FutureProviderElement<PosSaleService> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<PosSaleService> create(Ref ref) {
    return posSaleService(ref);
  }
}

String _$posSaleServiceHash() => r'0735faae2699303a9b8bf9c74aa52fd4f80612f0';
