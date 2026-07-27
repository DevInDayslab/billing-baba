// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sales_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(salesService)
final salesServiceProvider = SalesServiceProvider._();

final class SalesServiceProvider
    extends
        $FunctionalProvider<
          AsyncValue<SalesService>,
          SalesService,
          FutureOr<SalesService>
        >
    with $FutureModifier<SalesService>, $FutureProvider<SalesService> {
  SalesServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'salesServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$salesServiceHash();

  @$internal
  @override
  $FutureProviderElement<SalesService> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SalesService> create(Ref ref) {
    return salesService(ref);
  }
}

String _$salesServiceHash() => r'7b65016e72cedff749baf3159cd9bf5a6cf2f51f';
