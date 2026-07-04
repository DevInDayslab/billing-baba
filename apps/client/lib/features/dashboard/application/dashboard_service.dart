import 'package:billing_baba/core/providers/api_client_provider.dart';
import 'package:billing_baba/features/dashboard/application/dashboard_error_mapper.dart';
import 'package:billing_baba/features/dashboard/data/dashboard_remote_data_source.dart';
import 'package:billing_baba/features/dashboard/data/dashboard_repository.dart';
import 'package:billing_baba/features/dashboard/models/dashboard_model.dart';
import 'package:billing_baba/features/dashboard/models/mappers/dashboard_mapper.dart';
import 'package:billing_baba/features/dashboard/models/requests/dashboard_requests.dart';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

export 'dashboard_error_mapper.dart' show DashboardException;

part 'dashboard_service.g.dart';

@Riverpod(keepAlive: true)
Future<DashboardService> dashboardService(Ref ref) async {
  final api = await ref.watch(apiClientProvider.future);
  return DashboardService(
    repository: DashboardRepository(
      remote: DashboardRemoteDataSource(api.dio),
    ),
  );
}

class DashboardService {
  DashboardService({required this._repository});

  final DashboardRepository _repository;

  Future<DashboardModel> fetchDashboard(DashboardQuery query) async {
    try {
      final dto = await _repository.getDashboard(query);
      return DashboardMapper.toModel(dto);
    } on DioException catch (error) {
      throw mapDashboardError(error);
    }
  }
}
