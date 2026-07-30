import 'package:billing_baba/features/dashboard/data/dashboard_local_data_source.dart';
import 'package:billing_baba/features/dashboard/data/dashboard_remote_data_source.dart';
import 'package:billing_baba/features/dashboard/models/dto/dashboard_dto.dart';
import 'package:billing_baba/features/dashboard/models/requests/dashboard_requests.dart';

class DashboardRepository {
  DashboardRepository({
    required this._remote,
    required this._local,
    required this._readBusinessId,
  });

  final DashboardRemoteDataSource _remote;
  final DashboardLocalDataSource _local;
  final String Function() _readBusinessId;

  Future<DashboardFetchResult> fetchDashboard(DashboardQuery query) async {
    final result = await _remote.getDashboard(query);
    final businessId = _readBusinessId();
    if (businessId.isNotEmpty) {
      await _local.saveSnapshot(
        businessId: businessId,
        period: query.period,
        payload: result.rawPayload,
      );
    }
    return result;
  }

  ({DashboardDto dto, DateTime savedAt})? readCachedDashboard(
    DashboardQuery query,
  ) {
    final businessId = _readBusinessId();
    if (businessId.isEmpty) return null;
    return _local.readSnapshot(businessId: businessId, period: query.period);
  }
}
