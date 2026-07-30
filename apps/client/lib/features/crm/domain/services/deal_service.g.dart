// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deal_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(dealService)
final dealServiceProvider = DealServiceProvider._();

final class DealServiceProvider
    extends
        $FunctionalProvider<
          AsyncValue<DealService>,
          DealService,
          FutureOr<DealService>
        >
    with $FutureModifier<DealService>, $FutureProvider<DealService> {
  DealServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dealServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dealServiceHash();

  @$internal
  @override
  $FutureProviderElement<DealService> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<DealService> create(Ref ref) {
    return dealService(ref);
  }
}

String _$dealServiceHash() => r'e0c8a6575964a5975670869ceb917909a2388123';
