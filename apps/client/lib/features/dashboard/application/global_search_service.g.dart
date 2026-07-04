// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'global_search_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(globalSearchService)
final globalSearchServiceProvider = GlobalSearchServiceProvider._();

final class GlobalSearchServiceProvider
    extends
        $FunctionalProvider<
          AsyncValue<GlobalSearchService>,
          GlobalSearchService,
          FutureOr<GlobalSearchService>
        >
    with
        $FutureModifier<GlobalSearchService>,
        $FutureProvider<GlobalSearchService> {
  GlobalSearchServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'globalSearchServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$globalSearchServiceHash();

  @$internal
  @override
  $FutureProviderElement<GlobalSearchService> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<GlobalSearchService> create(Ref ref) {
    return globalSearchService(ref);
  }
}

String _$globalSearchServiceHash() =>
    r'517f5e53a55e946abe84b33c4806049b04928cc4';
