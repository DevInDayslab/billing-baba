import 'package:billing_baba/core/sync/models/sync_job.dart';
import 'package:billing_baba/core/sync/queue/sync_queue.dart';
import 'package:billing_baba/features/crm/data/sources/deal_local_source.dart';
import 'package:billing_baba/features/crm/data/sources/deal_remote_source.dart';
import 'package:billing_baba/features/crm/domain/models/deal.dart';

class DealRepository {
  DealRepository({
    required this._local,
    required this._remote,
    required this._syncQueue,
  });

  final DealLocalSource _local;
  final DealRemoteSource _remote;
  final SyncQueue _syncQueue;

  DealRemoteSource get remote => _remote;

  DealLocalSource get local => _local;

  String? readBusinessId() => _local.readBusinessId();

  Stream<List<Deal>> watchDeals(String businessId) =>
      _local.watchDeals(businessId);

  Future<List<Deal>> getDeals(String businessId) => _local.getDeals(businessId);

  Future<Deal?> getDealById(String businessId, String dealId) =>
      _local.getDealById(businessId, dealId);

  Future<Deal> saveDeal(Deal deal, {required String operation}) async {
    await _local.upsertDeal(deal);
    await _enqueue(
      businessId: deal.businessId,
      entityType: 'deals',
      entityId: deal.id,
      operation: operation,
      payload: deal.toJson(),
    );
    return deal;
  }

  Future<void> _enqueue({
    required String businessId,
    required String entityType,
    required String entityId,
    required String operation,
    required Map<String, dynamic> payload,
  }) {
    return _syncQueue.enqueueRowMutation(
      businessId: businessId,
      entityType: entityType,
      entityId: entityId,
      operation: SyncQueueOperation.fromWire(operation),
      payload: payload,
    );
  }
}
