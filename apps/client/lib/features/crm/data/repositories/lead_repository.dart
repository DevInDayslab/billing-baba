import 'package:billing_baba/core/sync/models/sync_queue_enums.dart';
import 'package:billing_baba/core/sync/queue/sync_queue.dart';
import 'package:billing_baba/features/crm/data/sources/lead_local_source.dart';
import 'package:billing_baba/features/crm/data/sources/lead_remote_source.dart';
import 'package:billing_baba/features/crm/domain/models/lead.dart';
import 'package:billing_baba/features/crm/domain/models/lead_activity.dart';

class LeadRepository {
  LeadRepository({
    required LeadLocalSource local,
    required LeadRemoteSource remote,
    required SyncQueue syncQueue,
  })  : _local = local,
        _remote = remote,
        _syncQueue = syncQueue;

  final LeadLocalSource _local;
  final LeadRemoteSource _remote;
  final SyncQueue _syncQueue;

  LeadRemoteSource get remote => _remote;

  LeadLocalSource get local => _local;

  String? readBusinessId() => _local.readBusinessId();

  Stream<List<Lead>> watchLeads(String businessId) =>
      _local.watchLeads(businessId);

  Future<List<Lead>> getLeads(String businessId) => _local.getLeads(businessId);

  Future<Lead?> getLeadById(String businessId, String leadId) =>
      _local.getLeadById(businessId, leadId);

  Stream<List<LeadActivity>> watchActivities(
    String businessId,
    String leadId,
  ) =>
      _local.watchActivities(businessId, leadId);

  Future<Lead> saveLead(Lead lead, {required String operation}) async {
    await _local.upsertLead(lead);
    await _enqueue(
      businessId: lead.businessId,
      entityType: 'lead',
      entityId: lead.id,
      operation: operation,
      payload: lead.toJson(),
    );
    return lead;
  }

  Future<LeadActivity> saveActivity(
    LeadActivity activity, {
    required String operation,
  }) async {
    await _local.upsertActivity(activity);
    await _enqueue(
      businessId: activity.businessId,
      entityType: 'lead_activity',
      entityId: activity.id,
      operation: operation,
      payload: activity.toJson(),
    );
    return activity;
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
