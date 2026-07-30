// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notifications_remote_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(notificationsRemote)
final notificationsRemoteProvider = NotificationsRemoteProvider._();

final class NotificationsRemoteProvider
    extends
        $FunctionalProvider<
          AsyncValue<NotificationsRemoteDataSource>,
          NotificationsRemoteDataSource,
          FutureOr<NotificationsRemoteDataSource>
        >
    with
        $FutureModifier<NotificationsRemoteDataSource>,
        $FutureProvider<NotificationsRemoteDataSource> {
  NotificationsRemoteProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationsRemoteProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationsRemoteHash();

  @$internal
  @override
  $FutureProviderElement<NotificationsRemoteDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<NotificationsRemoteDataSource> create(Ref ref) {
    return notificationsRemote(ref);
  }
}

String _$notificationsRemoteHash() =>
    r'163faa7fbf5639d3236cd2a3151d27a7b6d3fb46';

@ProviderFor(notificationsRepository)
final notificationsRepositoryProvider = NotificationsRepositoryProvider._();

final class NotificationsRepositoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<NotificationsRepository>,
          NotificationsRepository,
          FutureOr<NotificationsRepository>
        >
    with
        $FutureModifier<NotificationsRepository>,
        $FutureProvider<NotificationsRepository> {
  NotificationsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationsRepositoryHash();

  @$internal
  @override
  $FutureProviderElement<NotificationsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<NotificationsRepository> create(Ref ref) {
    return notificationsRepository(ref);
  }
}

String _$notificationsRepositoryHash() =>
    r'7958b42e4589bc4a2f0fb3644d41c8de4e7dc123';
