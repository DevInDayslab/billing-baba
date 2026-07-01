// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'storage_service_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(storageService)
final storageServiceProvider = StorageServiceProvider._();

final class StorageServiceProvider
    extends
        $FunctionalProvider<
          AsyncValue<StorageService>,
          StorageService,
          FutureOr<StorageService>
        >
    with $FutureModifier<StorageService>, $FutureProvider<StorageService> {
  StorageServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'storageServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$storageServiceHash();

  @$internal
  @override
  $FutureProviderElement<StorageService> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<StorageService> create(Ref ref) {
    return storageService(ref);
  }
}

String _$storageServiceHash() => r'8a71bebf8aecd1cde9ff27e5af912f834824a3b1';
