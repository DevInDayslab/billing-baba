import 'package:billing_baba/core/services/storage_service.dart';
import 'package:billing_baba/features/dashboard/data/dashboard_snapshot_cache.dart';
import 'package:billing_baba/features/dashboard/models/dto/dashboard_dto.dart';
import 'package:billing_baba/features/dashboard/models/requests/dashboard_requests.dart';

class DashboardLocalDataSource {
  DashboardLocalDataSource(StorageService storage)
      : _cache = DashboardSnapshotCache(storage);

  final DashboardSnapshotCache _cache;

  Future<void> saveSnapshot({
    required String businessId,
    required DashboardPeriod period,
    required Map<String, dynamic> payload,
  }) {
    return _cache.save(
      businessId: businessId,
      period: period,
      payload: payload,
    );
  }

  ({DashboardDto dto, DateTime savedAt})? readSnapshot({
    required String businessId,
    required DashboardPeriod period,
  }) {
    return _cache.read(businessId: businessId, period: period);
  }
}
