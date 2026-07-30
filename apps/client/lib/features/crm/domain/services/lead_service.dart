import 'dart:async';

import 'package:billing_baba/core/database/app_database_provider.dart';
import 'package:billing_baba/core/providers/api_client_provider.dart';
import 'package:billing_baba/core/providers/storage_service_provider.dart';
import 'package:billing_baba/core/sync/providers/sync_providers.dart';
import 'package:billing_baba/features/crm/data/repositories/lead_repository.dart';
import 'package:billing_baba/features/crm/data/sources/lead_local_source.dart';
import 'package:billing_baba/features/crm/data/sources/lead_remote_source.dart';
import 'package:billing_baba/features/crm/domain/models/lead.dart';
import 'package:billing_baba/features/crm/domain/services/lead_service_types.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

part 'lead_service.g.dart';

const _uuid = Uuid();

@Riverpod(keepAlive: true)
Future<LeadService> leadService(Ref ref) async {
  final db = ref.watch(appDatabaseProvider);
  final storage = await ref.watch(storageServiceProvider.future);
  final api = await ref.watch(apiClientProvider.future);
  final repository = LeadRepository(
    local: LeadLocalSource(db, storage),
    remote: LeadRemoteSource(api.dio),
    syncQueue: ref.watch(syncQueueProvider),
  );
  return LeadService(repository);
}

class LeadService {
  LeadService(this._repository);

  final LeadRepository _repository;

  /// Returns the current business ID without throwing.
  /// Returns null if no business is selected.
  String? readBusinessId() => _repository.readBusinessId();

  String _requireBusinessId() {
    final businessId = _repository.readBusinessId();
    if (businessId == null || businessId.isEmpty) {
      throw const LeadBusinessNotSelectedException();
    }
    return businessId;
  }

  Stream<List<Lead>> watchLeads({
    LeadQueryFilters filters = const LeadQueryFilters(),
  }) {
    final businessId = _requireBusinessId();
    return _repository
        .watchLeads(businessId)
        .map(
          (leads) => filterLeads(leads, filters),
        );
  }

  Future<List<Lead>> loadLeads({
    LeadQueryFilters filters = const LeadQueryFilters(),
  }) async {
    final businessId = _requireBusinessId();
    final leads = await _repository.getLeads(businessId);
    return filterLeads(leads, filters);
  }

  Stream<LeadWithActivities?> watchLeadDetail(String leadId) {
    final businessId = _requireBusinessId();
    final refreshTrigger = Stream<void>.multi((controller) {
      final leadSub = _repository
          .watchLeads(businessId)
          .listen(
            (_) => controller.add(null),
            onError: controller.addError,
          );
      final activitySub = _repository
          .watchActivities(businessId, leadId)
          .listen(
            (_) => controller.add(null),
            onError: controller.addError,
          );
      controller.onCancel = () async {
        await leadSub.cancel();
        await activitySub.cancel();
      };
    });

    return refreshTrigger.asyncMap((_) async {
      final lead = await _repository.getLeadById(businessId, leadId);
      if (lead == null) return null;
      final activities = await _repository
          .watchActivities(businessId, leadId)
          .first;
      return LeadWithActivities(lead: lead, activities: activities);
    });
  }

  Future<LeadWithActivities?> getLeadDetail(String leadId) async {
    final businessId = _requireBusinessId();
    final lead = await _repository.getLeadById(businessId, leadId);
    if (lead == null) return null;
    final activities = await _repository
        .watchActivities(businessId, leadId)
        .first;
    return LeadWithActivities(lead: lead, activities: activities);
  }

  /// Pulls leads from the API and upserts into local Drift DB.
  /// Silent on network failure — local data is shown as fallback.
  Future<void> syncFromRemote() async {
    final businessId = _requireBusinessId();
    try {
      final remoteLeads = await _repository.remote.listLeads();
      for (final lead in remoteLeads) {
        if (lead.businessId == businessId) {
          await _repository.local.upsertLead(lead);
        }
      }
    } on Object {
      // Network failure — silently fall back to local data
    }
  }

  List<Lead> filterLeads(List<Lead> leads, LeadQueryFilters filters) {
    final query = filters.searchQuery.trim().toLowerCase();
    return leads.where((lead) {
      if (filters.status != null && lead.status != filters.status) {
        return false;
      }
      if (filters.leadSource != null && lead.leadSource != filters.leadSource) {
        return false;
      }
      if (filters.dateFrom != null &&
          lead.createdAt.isBefore(_startOfDay(filters.dateFrom!))) {
        return false;
      }
      if (filters.dateTo != null &&
          lead.createdAt.isAfter(_endOfDay(filters.dateTo!))) {
        return false;
      }
      if (query.isEmpty) return true;
      return lead.name.toLowerCase().contains(query) ||
          (lead.company?.toLowerCase().contains(query) ?? false) ||
          (lead.email?.toLowerCase().contains(query) ?? false) ||
          (lead.phone?.contains(query) ?? false);
    }).toList();
  }

  Future<Lead> addLead(AddLeadInput input) async {
    _validateAddInput(input);
    final businessId = _requireBusinessId();
    final now = DateTime.now().toUtc();

    final lead = Lead(
      id: _uuid.v4(),
      businessId: businessId,
      name: input.name.trim(),
      company: _nullableTrim(input.company),
      phone: input.phone.trim(),
      email: _nullableTrim(input.email),
      leadSource: input.leadSource,
      status: input.status,
      assignedTo: _nullableTrim(input.assignedTo),
      notes: _nullableTrim(input.notes),
      updatedAt: now,
      createdAt: now,
    );

    return _repository.saveLead(lead, operation: 'create');
  }

  Future<Lead> updateLead(Lead lead) async {
    final businessId = _requireBusinessId();
    if (lead.businessId != businessId) {
      throw const LeadValidationException(
        'Lead does not belong to this business',
      );
    }
    final updated = lead.copyWith(
      updatedAt: DateTime.now().toUtc(),
      syncStatus: 'pending',
    );
    return _repository.saveLead(updated, operation: 'update');
  }

  Future<void> deleteLead(String leadId) async {
    final businessId = _requireBusinessId();
    final existing = await _repository.getLeadById(businessId, leadId);
    if (existing == null) return;

    final now = DateTime.now().toUtc();
    final deleted = existing.copyWith(
      isDeleted: true,
      deletedAt: now,
      updatedAt: now,
      syncStatus: 'pending',
    );
    await _repository.saveLead(deleted, operation: 'delete');
  }

  void _validateAddInput(AddLeadInput input) {
    if (input.name.trim().isEmpty) {
      throw const LeadValidationException('Lead name is required');
    }
    if (input.phone.trim().isEmpty) {
      throw const LeadValidationException('Phone number is required');
    }
  }

  static String? _nullableTrim(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
  }

  static DateTime _startOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  static DateTime _endOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
}
