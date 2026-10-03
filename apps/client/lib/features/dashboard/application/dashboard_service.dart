import 'package:billing_baba/core/network/api_error_parser.dart';
import 'package:billing_baba/core/providers/api_client_provider.dart';
import 'package:billing_baba/core/providers/storage_service_provider.dart';
import 'package:billing_baba/features/business/application/business_service.dart';
import 'package:billing_baba/features/dashboard/application/dashboard_error_mapper.dart';
import 'package:billing_baba/features/dashboard/data/dashboard_local_data_source.dart';
import 'package:billing_baba/features/dashboard/data/dashboard_remote_data_source.dart';
import 'package:billing_baba/features/dashboard/data/dashboard_repository.dart';
import 'package:billing_baba/features/dashboard/models/dashboard_view_state.dart';
import 'package:billing_baba/features/dashboard/models/mappers/dashboard_mapper.dart';
import 'package:billing_baba/features/dashboard/models/requests/dashboard_requests.dart';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

export 'dashboard_error_mapper.dart' show DashboardException;

part 'dashboard_service.g.dart';

@Riverpod(keepAlive: true)
Future<DashboardService> dashboardService(Ref ref) async {
  final api = await ref.watch(apiClientProvider.future);
  final storage = await ref.watch(storageServiceProvider.future);
  return DashboardService(
    repository: DashboardRepository(
      remote: DashboardRemoteDataSource(api.dio),
      local: DashboardLocalDataSource(storage),
      readBusinessId: () => ref.read(currentBusinessProvider)?.id ?? '',
    ),
  );
}

class DashboardService {
  DashboardService({required this._repository});

  final DashboardRepository _repository;

  DashboardViewState? readCachedViewState(DashboardQuery query) {
    final cached = _repository.readCachedDashboard(query);
    if (cached == null) return null;
    return DashboardViewState(
      dashboard: DashboardMapper.toModel(cached.dto),
      snapshotSavedAt: cached.savedAt,
    );
  }

  Future<DashboardViewState> fetchDashboard(DashboardQuery query) async {
    try {
      final result = await _repository.fetchDashboard(query);
      return DashboardViewState(
        dashboard: DashboardMapper.toModel(result.dto),
        snapshotSavedAt: DateTime.now(),
      );
    } on DioException catch (error) {
      final cached = _repository.readCachedDashboard(query);
      if (cached != null && ApiErrorParser.isOffline(error)) {
        return DashboardViewState(
          dashboard: DashboardMapper.toModel(cached.dto),
          isCachedSnapshot: true,
          snapshotSavedAt: cached.savedAt,
        );
      }
      throw mapDashboardError(error);
    }
  }
}
