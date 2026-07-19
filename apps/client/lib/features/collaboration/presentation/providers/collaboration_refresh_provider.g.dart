// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'collaboration_refresh_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CollaborationRefresh)
final collaborationRefreshProvider = CollaborationRefreshProvider._();

final class CollaborationRefreshProvider
    extends $NotifierProvider<CollaborationRefresh, bool> {
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
    r'2d5d051566fed224457c04183f7a02c81686630f';

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
