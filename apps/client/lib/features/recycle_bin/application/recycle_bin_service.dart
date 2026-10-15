import 'package:billing_baba/core/database/app_database_provider.dart';
import 'package:billing_baba/core/providers/api_client_provider.dart';
import 'package:billing_baba/features/recycle_bin/data/recycle_bin_local_data_source.dart';
import 'package:billing_baba/features/recycle_bin/data/recycle_bin_remote_data_source.dart';
import 'package:billing_baba/features/recycle_bin/models/recycle_bin_item.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final recycleBinServiceProvider = FutureProvider<RecycleBinService>((ref) async {
  final api = await ref.watch(apiClientProvider.future);
  return RecycleBinService(
    remote: RecycleBinRemoteDataSource(api.dio),
    local: RecycleBinLocalDataSource(ref.watch(appDatabaseProvider)),
  );
});

class RecycleBinService {
  RecycleBinService({
    required RecycleBinRemoteDataSource remote,
    required RecycleBinLocalDataSource local,
  })  : _remote = remote,
        _local = local;

  final RecycleBinRemoteDataSource _remote;
  final RecycleBinLocalDataSource _local;

  Future<List<RecycleBinItem>> list({
    required String businessId,
    bool preferRemote = true,
  }) async {
    if (preferRemote) {
      try {
        final result = await _remote.list(limit: 100);
        if (result.items.isNotEmpty) return result.items;
      } catch (_) {
        // Fall back to local union when offline or API unavailable.
      }
    }
    return _local.listDeleted(businessId: businessId);
  }

  Future<void> restore({
    required String entityType,
    required String entityId,
  }) {
    return _remote.restore(entityType: entityType, entityId: entityId);
  }

  Future<void> purge({
    required String entityType,
    required String entityId,
  }) {
    return _remote.purge(entityType: entityType, entityId: entityId);
  }
}
