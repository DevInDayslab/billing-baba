// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_return_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(posReturnService)
final posReturnServiceProvider = PosReturnServiceProvider._();

final class PosReturnServiceProvider
    extends
        $FunctionalProvider<
          AsyncValue<PosReturnService>,
          PosReturnService,
          FutureOr<PosReturnService>
        >
    with $FutureModifier<PosReturnService>, $FutureProvider<PosReturnService> {
  PosReturnServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'posReturnServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$posReturnServiceHash();

  @$internal
  @override
  $FutureProviderElement<PosReturnService> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<PosReturnService> create(Ref ref) {
    return posReturnService(ref);
  }
}

String _$posReturnServiceHash() => r'e0a5a99a044b97e2d5ce2c890f06923fa65069ce';
