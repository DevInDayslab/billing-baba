// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_status_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SyncStatusNotifier)
final syncStatusProvider = SyncStatusNotifierProvider._();

final class SyncStatusNotifierProvider
    extends $AsyncNotifierProvider<SyncStatusNotifier, SyncStatus> {
  SyncStatusNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'syncStatusProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$syncStatusNotifierHash();

  @$internal
  @override
  SyncStatusNotifier create() => SyncStatusNotifier();
}

String _$syncStatusNotifierHash() =>
    r'ee9b43ec631af55ef24322b24913ad35cbc8c3e8';

abstract class _$SyncStatusNotifier extends $AsyncNotifier<SyncStatus> {
  FutureOr<SyncStatus> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<SyncStatus>, SyncStatus>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<SyncStatus>, SyncStatus>,
              AsyncValue<SyncStatus>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
