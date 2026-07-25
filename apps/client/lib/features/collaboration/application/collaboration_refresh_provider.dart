import 'package:billing_baba/features/collaboration/application/sync_share_refresh_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'collaboration_refresh_provider.g.dart';

/// Backwards-compatible alias for [SyncShareRefresh].
@Riverpod(keepAlive: true)
class CollaborationRefresh extends _$CollaborationRefresh {
  @override
  bool build() => ref.watch(syncShareRefreshProvider);

  Future<void> refreshAll({bool showLoading = false}) {
    return ref.read(syncShareRefreshProvider.notifier).refresh(manual: true);
  }
}
