import 'package:billing_baba/features/collaboration/application/collaboration_repository_provider.dart';
import 'package:billing_baba/features/collaboration/domain/models/sync_status.dart';
import 'package:billing_baba/features/collaboration/presentation/providers/collaboration_init_provider.dart';
import 'package:billing_baba/features/collaboration/presentation/providers/company_access_provider.dart';
import 'package:billing_baba/features/collaboration/presentation/providers/devices_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sync_status_provider.g.dart';

@Riverpod(keepAlive: true)
class SyncStatusNotifier extends _$SyncStatusNotifier {
  @override
  Future<SyncStatus> build() async {
    ref.watch(collaborationInitProvider);
    final service = ref.watch(collaborationServiceProvider);
    return service.fetchSyncStatus();
  }

  Future<void> reload({bool showLoading = true}) async {
    if (showLoading) {
      state = const AsyncLoading();
    }
    state = await AsyncValue.guard(() async {
      final service = ref.read(collaborationServiceProvider);
      return service.fetchSyncStatus();
    });
  }

  Future<void> refreshSync() async {
    final current = state.asData?.value;
    if (current != null) {
      state = AsyncData(
        current.copyWith(
          state: CollaborationSyncState.syncing,
          isSyncing: true,
        ),
      );
    }

    state = await AsyncValue.guard(() async {
      final service = ref.read(collaborationServiceProvider);
      return service.refresh();
    });

    ref.invalidate(companyAccessProvider);
    ref.invalidate(devicesProvider);
  }

  Future<void> enableSync() async {
    final service = ref.read(collaborationServiceProvider);
    await service.enableSync();
    await reload(showLoading: false);
    ref.invalidate(devicesProvider);
    ref.invalidate(companyAccessProvider);
  }

  Future<void> disableSync() async {
    final service = ref.read(collaborationServiceProvider);
    await service.disableSync();
    await reload(showLoading: false);
    ref.invalidate(devicesProvider);
  }

  Future<void> logoutSync() async {
    final service = ref.read(collaborationServiceProvider);
    await service.logoutSync();
    await reload(showLoading: false);
    ref.invalidate(devicesProvider);
  }
}
