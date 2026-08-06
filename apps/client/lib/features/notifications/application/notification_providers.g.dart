// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(localNotificationPlatformService)
final localNotificationPlatformServiceProvider =
    LocalNotificationPlatformServiceProvider._();

final class LocalNotificationPlatformServiceProvider
    extends
        $FunctionalProvider<
          LocalNotificationPlatformService,
          LocalNotificationPlatformService,
          LocalNotificationPlatformService
        >
    with $Provider<LocalNotificationPlatformService> {
  LocalNotificationPlatformServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'localNotificationPlatformServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$localNotificationPlatformServiceHash();

  @$internal
  @override
  $ProviderElement<LocalNotificationPlatformService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  LocalNotificationPlatformService create(Ref ref) {
    return localNotificationPlatformService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LocalNotificationPlatformService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LocalNotificationPlatformService>(
        value,
      ),
    );
  }
}

String _$localNotificationPlatformServiceHash() =>
    r'e266963c545713d2d3d5b5e761207aa285affecd';

@ProviderFor(notificationPlatformInitializer)
final notificationPlatformInitializerProvider =
    NotificationPlatformInitializerProvider._();

final class NotificationPlatformInitializerProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  NotificationPlatformInitializerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationPlatformInitializerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationPlatformInitializerHash();

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    return notificationPlatformInitializer(ref);
  }
}

String _$notificationPlatformInitializerHash() =>
    r'27866239dbc55fa02c58184066ac3f9b1cb7218b';

@ProviderFor(notificationService)
final notificationServiceProvider = NotificationServiceProvider._();

final class NotificationServiceProvider
    extends
        $FunctionalProvider<
          AsyncValue<svc.NotificationService>,
          svc.NotificationService,
          FutureOr<svc.NotificationService>
        >
    with
        $FutureModifier<svc.NotificationService>,
        $FutureProvider<svc.NotificationService> {
  NotificationServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationServiceHash();

  @$internal
  @override
  $FutureProviderElement<svc.NotificationService> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<svc.NotificationService> create(Ref ref) {
    return notificationService(ref);
  }
}

String _$notificationServiceHash() =>
    r'd58ef8f56956c3f98546eb930c10c2b71c762920';

@ProviderFor(notificationsStream)
final notificationsStreamProvider = NotificationsStreamProvider._();

final class NotificationsStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AppNotification>>,
          List<AppNotification>,
          Stream<List<AppNotification>>
        >
    with
        $FutureModifier<List<AppNotification>>,
        $StreamProvider<List<AppNotification>> {
  NotificationsStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationsStreamProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationsStreamHash();

  @$internal
  @override
  $StreamProviderElement<List<AppNotification>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<AppNotification>> create(Ref ref) {
    return notificationsStream(ref);
  }
}

String _$notificationsStreamHash() =>
    r'a25c2cc681d2c52174edd12536ca2a7fc01fb6a1';

@ProviderFor(notificationUnreadCount)
final notificationUnreadCountProvider = NotificationUnreadCountProvider._();

final class NotificationUnreadCountProvider
    extends $FunctionalProvider<AsyncValue<int>, int, Stream<int>>
    with $FutureModifier<int>, $StreamProvider<int> {
  NotificationUnreadCountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationUnreadCountProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationUnreadCountHash();

  @$internal
  @override
  $StreamProviderElement<int> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<int> create(Ref ref) {
    return notificationUnreadCount(ref);
  }
}

String _$notificationUnreadCountHash() =>
    r'c2fa7c6da71ba1c61e66662ffb8eddf0ac80143a';

@ProviderFor(NotificationFilterController)
final notificationFilterControllerProvider =
    NotificationFilterControllerProvider._();

final class NotificationFilterControllerProvider
    extends
        $AsyncNotifierProvider<
          NotificationFilterController,
          NotificationFilter
        > {
  NotificationFilterControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationFilterControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationFilterControllerHash();

  @$internal
  @override
  NotificationFilterController create() => NotificationFilterController();
}

String _$notificationFilterControllerHash() =>
    r'd789411f240c7dc4c6306f266ee7ea0bc6e4d41e';

abstract class _$NotificationFilterController
    extends $AsyncNotifier<NotificationFilter> {
  FutureOr<NotificationFilter> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<NotificationFilter>, NotificationFilter>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<NotificationFilter>, NotificationFilter>,
              AsyncValue<NotificationFilter>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(NotificationPreferencesController)
final notificationPreferencesControllerProvider =
    NotificationPreferencesControllerProvider._();

final class NotificationPreferencesControllerProvider
    extends
        $AsyncNotifierProvider<
          NotificationPreferencesController,
          NotificationPreferences
        > {
  NotificationPreferencesControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationPreferencesControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() =>
      _$notificationPreferencesControllerHash();

  @$internal
  @override
  NotificationPreferencesController create() =>
      NotificationPreferencesController();
}

String _$notificationPreferencesControllerHash() =>
    r'c9e4e68fbc055072cf8eb71f6f9724370ea9775d';

abstract class _$NotificationPreferencesController
    extends $AsyncNotifier<NotificationPreferences> {
  FutureOr<NotificationPreferences> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<NotificationPreferences>,
              NotificationPreferences
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<NotificationPreferences>,
                NotificationPreferences
              >,
              AsyncValue<NotificationPreferences>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(NotificationPermissionState)
final notificationPermissionStateProvider =
    NotificationPermissionStateProvider._();

final class NotificationPermissionStateProvider
    extends $AsyncNotifierProvider<NotificationPermissionState, bool> {
  NotificationPermissionStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationPermissionStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationPermissionStateHash();

  @$internal
  @override
  NotificationPermissionState create() => NotificationPermissionState();
}

String _$notificationPermissionStateHash() =>
    r'2bd5dc7216dcd7aa07be771a3b33b1caa33ffc12';

abstract class _$NotificationPermissionState extends $AsyncNotifier<bool> {
  FutureOr<bool> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<bool>, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<bool>, bool>,
              AsyncValue<bool>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(NotificationActions)
final notificationActionsProvider = NotificationActionsProvider._();

final class NotificationActionsProvider
    extends $NotifierProvider<NotificationActions, void> {
  NotificationActionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationActionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationActionsHash();

  @$internal
  @override
  NotificationActions create() => NotificationActions();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$notificationActionsHash() =>
    r'1927dbddfdbb92c79e95e5ded5a2adb8af5eb7df';

abstract class _$NotificationActions extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
