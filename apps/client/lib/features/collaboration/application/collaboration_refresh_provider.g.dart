// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'collaboration_refresh_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Backwards-compatible alias for [SyncShareRefresh].

@ProviderFor(CollaborationRefresh)
final collaborationRefreshProvider = CollaborationRefreshProvider._();

/// Backwards-compatible alias for [SyncShareRefresh].
final class CollaborationRefreshProvider
    extends $NotifierProvider<CollaborationRefresh, bool> {
  /// Backwards-compatible alias for [SyncShareRefresh].
  CollaborationRefreshProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'collaborationRefreshProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$collaborationRefreshHash();

  @$internal
  @override
  CollaborationRefresh create() => CollaborationRefresh();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$collaborationRefreshHash() =>
    r'6dbb185102e0cdc9270e7b9fe9525a327e595dd1';

/// Backwards-compatible alias for [SyncShareRefresh].

abstract class _$CollaborationRefresh extends $Notifier<bool> {
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
