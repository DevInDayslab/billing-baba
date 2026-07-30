// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_share_refresh_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Coordinates Sync & Share refresh requests with de-duplication.
///
/// UI and lifecycle hooks should call [refresh] or [refreshAfterMutation] only.

@ProviderFor(SyncShareRefresh)
final syncShareRefreshProvider = SyncShareRefreshProvider._();

/// Coordinates Sync & Share refresh requests with de-duplication.
///
/// UI and lifecycle hooks should call [refresh] or [refreshAfterMutation] only.
final class SyncShareRefreshProvider
    extends $NotifierProvider<SyncShareRefresh, bool> {
  /// Coordinates Sync & Share refresh requests with de-duplication.
  ///
  /// UI and lifecycle hooks should call [refresh] or [refreshAfterMutation] only.
  SyncShareRefreshProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'syncShareRefreshProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$syncShareRefreshHash();

  @$internal
  @override
  SyncShareRefresh create() => SyncShareRefresh();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$syncShareRefreshHash() => r'7049f9cc2b239bfcb43237bccf6f52abac514a1b';

/// Coordinates Sync & Share refresh requests with de-duplication.
///
/// UI and lifecycle hooks should call [refresh] or [refreshAfterMutation] only.

abstract class _$SyncShareRefresh extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
