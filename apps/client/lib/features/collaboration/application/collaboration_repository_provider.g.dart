// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'collaboration_repository_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

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
    r'3da25dafe8b2820b01acdef335a30062fe2a7523';

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
