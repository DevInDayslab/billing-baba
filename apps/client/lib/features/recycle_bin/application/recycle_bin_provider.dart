import 'package:billing_baba/features/business/application/business_service.dart';
import 'package:billing_baba/features/recycle_bin/application/recycle_bin_service.dart';
import 'package:billing_baba/features/recycle_bin/models/recycle_bin_item.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final recycleBinListProvider =
    AsyncNotifierProvider<RecycleBinListNotifier, List<RecycleBinItem>>(
  RecycleBinListNotifier.new,
);

class RecycleBinListNotifier extends AsyncNotifier<List<RecycleBinItem>> {
  @override
  Future<List<RecycleBinItem>> build() async {
    final businessId = ref.watch(currentBusinessProvider)?.id;
    if (businessId == null) return [];
    final service = await ref.watch(recycleBinServiceProvider.future);
    return service.list(businessId: businessId);
  }

  Future<String?> restore(RecycleBinItem item) async {
    try {
      final service = await ref.read(recycleBinServiceProvider.future);
      await service.restore(
        entityType: item.entityType,
        entityId: item.entityId,
      );
      ref.invalidateSelf();
      return null;
    } catch (error) {
      return error.toString();
    }
  }

  Future<String?> purge(RecycleBinItem item) async {
    try {
      final service = await ref.read(recycleBinServiceProvider.future);
      await service.purge(
        entityType: item.entityType,
        entityId: item.entityId,
      );
      ref.invalidateSelf();
      return null;
    } catch (error) {
      return error.toString();
    }
  }
}
