import 'dart:convert';

import 'package:billing_baba/features/crm/data/sources/lead_local_source.dart';
import 'package:billing_baba/features/crm/data/sources/lead_remote_source.dart';
import 'package:billing_baba/features/crm/domain/models/lead.dart';
import 'package:billing_baba/features/crm/domain/models/lead_activity.dart';

class LeadRepository {
  LeadRepository({
    required this._local,
    required this._remote,
  });

  final LeadLocalSource _local;
  final LeadRemoteSource _remote;

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
  ) => _local.watchActivities(businessId, leadId);

  Future<Lead> saveLead(Lead lead, {required String operation}) async {
    await _local.upsertLead(lead);
    await _enqueue(
      businessId: lead.businessId,
      entityType: 'lead',
      entityId: lead.id,
      operation: operation,
      payload: lead.toJson(),
      createdAt: lead.updatedAt.toUtc().toIso8601String(),
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
      createdAt: activity.updatedAt.toUtc().toIso8601String(),
    );
    return activity;
  }

  Future<void> _enqueue({
    required String businessId,
    required String entityType,
    required String entityId,
    required String operation,
    required Map<String, dynamic> payload,
    required String createdAt,
  }) async {
    await _local.enqueueSyncOperation(
      businessId: businessId,
      entityType: entityType,
      entityId: entityId,
      operation: operation,
      payload: jsonEncode(payload),
      createdAt: createdAt,
    );
  }
}
