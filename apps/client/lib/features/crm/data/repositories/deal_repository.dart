import 'dart:convert';

import 'package:billing_baba/features/crm/data/sources/deal_local_source.dart';
import 'package:billing_baba/features/crm/data/sources/deal_remote_source.dart';
import 'package:billing_baba/features/crm/domain/models/deal.dart';
import 'package:billing_baba/features/crm/domain/services/deal_service_types.dart';

class DealRepository {
  DealRepository({
    required this._local,
    required this._remote,
  });

  final DealLocalSource _local;
  final DealRemoteSource _remote;

  DealRemoteSource get remote => _remote;

  DealLocalSource get local => _local;

  String? readBusinessId() => _local.readBusinessId();

  Stream<List<Deal>> watchDeals(String businessId) =>
      _local.watchDeals(businessId);

  Future<List<Deal>> getDeals(String businessId) => _local.getDeals(businessId);

  Future<Deal?> getDealById(String businessId, String dealId) =>
      _local.getDealById(businessId, dealId);

  Future<Deal> saveDeal(Deal deal, {required String operation}) async {
    try {
      await _local.upsertDeal(deal);
      await _enqueue(
        businessId: deal.businessId,
        entityType: 'deal',
        entityId: deal.id,
        operation: operation,
        payload: deal.toJson(),
        createdAt: deal.updatedAt.toUtc().toIso8601String(),
      );
      return deal;
    } on Object catch (error) {
      throw DealValidationException('Failed to save deal locally: $error');
    }
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
