import 'package:billing_baba/features/dashboard/data/dashboard_remote_data_source.dart';
import 'package:billing_baba/features/dashboard/models/dto/dashboard_dto.dart';
import 'package:billing_baba/features/dashboard/models/requests/dashboard_requests.dart';

class DashboardRepository {
  DashboardRepository({required this._remote});

  final DashboardRemoteDataSource _remote;

  Future<DashboardDto> getDashboard(DashboardQuery query) =>
      _remote.getDashboard(query);
}
