import 'dart:convert';

import 'package:billing_baba/core/constants/storage_keys.dart';
import 'package:billing_baba/core/services/storage_service.dart';
import 'package:billing_baba/features/dashboard/models/dto/dashboard_dto.dart';
import 'package:billing_baba/features/dashboard/models/requests/dashboard_requests.dart';

/// Persists dashboard API payloads per business + period for offline display.
class DashboardSnapshotCache {
  DashboardSnapshotCache(this._storage);

  final StorageService _storage;

  String _cacheKey(String businessId, DashboardPeriod period) =>
      '$businessId|${period.apiValue}';

  Future<void> save({
    required String businessId,
    required DashboardPeriod period,
    required Map<String, dynamic> payload,
  }) async {
    if (businessId.isEmpty) return;

    final all = _readAll();
    all[_cacheKey(businessId, period)] = {
      'saved_at': DateTime.now().toUtc().toIso8601String(),
      'data': payload,
    };
    await _storage.write(StorageKeys.dashboardSnapshots, jsonEncode(all));
  }

  ({DashboardDto dto, DateTime savedAt})? read({
    required String businessId,
    required DashboardPeriod period,
  }) {
    if (businessId.isEmpty) return null;

    final entry = _readAll()[_cacheKey(businessId, period)];
    if (entry is! Map<String, dynamic>) return null;

    final data = entry['data'];
    final savedAtRaw = entry['saved_at']?.toString();
    if (data is! Map<String, dynamic> ||
        savedAtRaw == null ||
        savedAtRaw.isEmpty) {
      return null;
    }

    final savedAt = DateTime.tryParse(savedAtRaw)?.toLocal();
    if (savedAt == null) return null;

    return (dto: DashboardDto.fromJson(data), savedAt: savedAt);
  }

  Map<String, dynamic> _readAll() {
    final raw = _storage.read(StorageKeys.dashboardSnapshots);
    if (raw == null || raw.isEmpty) return {};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return {};
      return decoded;
    } on Object {
      return {};
    }
  }
}
