// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sale_fa_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(saleFaService)
final saleFaServiceProvider = SaleFaServiceProvider._();

final class SaleFaServiceProvider
    extends
        $FunctionalProvider<
          AsyncValue<SaleFaService>,
          SaleFaService,
          FutureOr<SaleFaService>
        >
    with $FutureModifier<SaleFaService>, $FutureProvider<SaleFaService> {
  SaleFaServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'saleFaServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$saleFaServiceHash();

  @$internal
  @override
  $FutureProviderElement<SaleFaService> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SaleFaService> create(Ref ref) {
    return saleFaService(ref);
  }
}

String _$saleFaServiceHash() => r'993dae72bbae391245c3a6c7cbdb4fa762903a5f';
