import 'dart:async';

import 'package:billing_baba/core/database/app_database_provider.dart';
import 'package:billing_baba/core/providers/api_client_provider.dart';
import 'package:billing_baba/core/providers/storage_service_provider.dart';
import 'package:billing_baba/features/crm/data/repositories/deal_repository.dart';
import 'package:billing_baba/features/crm/data/sources/deal_local_source.dart';
import 'package:billing_baba/features/crm/data/sources/deal_remote_source.dart';
import 'package:billing_baba/features/crm/domain/models/deal.dart';
import 'package:billing_baba/features/crm/domain/services/deal_service_types.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

part 'deal_service.g.dart';

const _uuid = Uuid();

@Riverpod(keepAlive: true)
Future<DealService> dealService(Ref ref) async {
  final db = ref.watch(appDatabaseProvider);
  final storage = await ref.watch(storageServiceProvider.future);
  final api = await ref.watch(apiClientProvider.future);
  final repository = DealRepository(
    local: DealLocalSource(db, storage),
    remote: DealRemoteSource(api.dio),
  );
  return DealService(repository);
}

class DealService {
  DealService(this._repository);

  final DealRepository _repository;

  /// Returns the current business ID without throwing.
  /// Returns null if no business is selected.
  String? readBusinessId() => _repository.readBusinessId();

  String _requireBusinessId() {
    final businessId = _repository.readBusinessId();
    if (businessId == null || businessId.isEmpty) {
      throw const DealBusinessNotSelectedException();
    }
    return businessId;
  }

  Stream<List<Deal>> watchDeals({
    DealQueryFilters filters = const DealQueryFilters(),
  }) {
    final businessId = _requireBusinessId();
    return _repository
        .watchDeals(businessId)
        .map((deals) => filterDeals(deals, filters));
  }

  Future<List<Deal>> loadDeals({
    DealQueryFilters filters = const DealQueryFilters(),
  }) async {
    final businessId = _requireBusinessId();
    final deals = await _repository.getDeals(businessId);
    return filterDeals(deals, filters);
  }

  Future<void> syncFromRemote() async {
    final businessId = _requireBusinessId();
    try {
      final remoteDeals = await _repository.remote.listDeals(limit: 100);
      for (final deal in remoteDeals) {
        if (deal.businessId == businessId) {
          await _repository.local.upsertDeal(deal);
        }
      }
    } on Object {
      // Silent fallback to local Drift data
    }
  }

  List<Deal> filterDeals(List<Deal> deals, DealQueryFilters filters) {
    final query = filters.searchQuery.trim().toLowerCase();
    return deals.where((deal) {
      if (filters.accountName != null &&
          deal.accountName != filters.accountName) {
        return false;
      }
      if (filters.assignedTo != null &&
          deal.assignedTo != filters.assignedTo) {
        return false;
      }
      if (filters.stage != null && deal.stage != filters.stage) {
        return false;
      }
      if (filters.dateFrom != null &&
          deal.createdAt.isBefore(_startOfDay(filters.dateFrom!))) {
        return false;
      }
      if (filters.dateTo != null &&
          deal.createdAt.isAfter(_endOfDay(filters.dateTo!))) {
        return false;
      }
      if (query.isEmpty) return true;
      return deal.name.toLowerCase().contains(query) ||
          (deal.accountName?.toLowerCase().contains(query) ?? false) ||
          (deal.assignedTo?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  Map<DealStage, List<Deal>> groupByStage(List<Deal> deals) {
    final grouped = <DealStage, List<Deal>>{
      for (final stage in DealStageX.pipelineStages) stage: [],
    };
    for (final deal in deals) {
      grouped.putIfAbsent(deal.stage, () => []).add(deal);
    }
    return grouped;
  }

  Future<Deal> addDeal(AddDealServiceInput input) async {
    _validateAddInput(input);
    final businessId = _requireBusinessId();
    final now = DateTime.now().toUtc();

    final deal = Deal(
      id: _uuid.v4(),
      businessId: businessId,
      name: input.name.trim(),
      stage: input.stage,
      accountName: _nullableTrim(input.accountName),
      assignedTo: _nullableTrim(input.assignedTo),
      amount: input.amount,
      expectedCloseDate: input.expectedCloseDate,
      description: _nullableTrim(input.description),
      updatedAt: now,
      createdAt: now,
    );

    return _repository.saveDeal(deal, operation: 'create');
  }

  Future<Deal> updateDeal(Deal deal) async {
    final businessId = _requireBusinessId();
    if (deal.businessId != businessId) {
      throw const DealValidationException(
        'Deal does not belong to this business',
      );
    }
    final updated = deal.copyWith(
      updatedAt: DateTime.now().toUtc(),
      syncStatus: 'pending',
    );
    return _repository.saveDeal(updated, operation: 'update');
  }

  Future<Deal> moveDealToStage(Deal deal, DealStage newStage) async {
    if (deal.stage == newStage) return deal;
    return updateDeal(deal.copyWith(stage: newStage));
  }

  Future<void> deleteDeal(String dealId) async {
    final businessId = _requireBusinessId();
    final existing = await _repository.getDealById(businessId, dealId);
    if (existing == null) return;

    final now = DateTime.now().toUtc();
    final deleted = existing.copyWith(
      isDeleted: true,
      deletedAt: now,
      updatedAt: now,
      syncStatus: 'pending',
    );
    await _repository.saveDeal(deleted, operation: 'delete');
  }

  void _validateAddInput(AddDealServiceInput input) {
    if (input.name.trim().isEmpty) {
      throw const DealValidationException('Deal name is required');
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
