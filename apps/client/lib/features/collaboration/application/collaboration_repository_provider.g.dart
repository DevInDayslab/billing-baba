// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'collaboration_repository_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(collaborationCache)
final collaborationCacheProvider = CollaborationCacheProvider._();

final class CollaborationCacheProvider
    extends
        $FunctionalProvider<
          CollaborationCache,
          CollaborationCache,
          CollaborationCache
        >
    with $Provider<CollaborationCache> {
  CollaborationCacheProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'collaborationCacheProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$collaborationCacheHash();

  @$internal
  @override
  $ProviderElement<CollaborationCache> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CollaborationCache create(Ref ref) {
    return collaborationCache(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CollaborationCache value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CollaborationCache>(value),
    );
  }
}

String _$collaborationCacheHash() =>
    r'6bf4c63103789d26adb822628bde2df9a209aa89';

@ProviderFor(collaborationRepository)
final collaborationRepositoryProvider = CollaborationRepositoryProvider._();

final class CollaborationRepositoryProvider
    extends
        $FunctionalProvider<
          CollaborationRepository,
          CollaborationRepository,
          CollaborationRepository
        >
    with $Provider<CollaborationRepository> {
  CollaborationRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'collaborationRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$collaborationRepositoryHash();

  @$internal
  @override
  $ProviderElement<CollaborationRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CollaborationRepository create(Ref ref) {
    return collaborationRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CollaborationRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CollaborationRepository>(value),
    );
  }
}

String _$collaborationRepositoryHash() =>
    r'06321ef8fadedbb54f1291b9fd60d7f4e278cdb3';

@ProviderFor(collaborationService)
final collaborationServiceProvider = CollaborationServiceProvider._();

final class CollaborationServiceProvider
    extends
        $FunctionalProvider<
          CollaborationService,
          CollaborationService,
          CollaborationService
        >
    with $Provider<CollaborationService> {
  CollaborationServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'collaborationServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$collaborationServiceHash();

  @$internal
  @override
  $ProviderElement<CollaborationService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CollaborationService create(Ref ref) {
    return collaborationService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CollaborationService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CollaborationService>(value),
    );
  }
}

String _$collaborationServiceHash() =>
    r'48df4456eea205212cde896ad40af138ea32cf66';
