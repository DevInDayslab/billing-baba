import 'package:billing_baba/features/sales/data/job_work_remote_data_source.dart';
import 'package:billing_baba/features/sales/models/dto/job_work_order_dto.dart';
import 'package:billing_baba/features/sales/models/requests/job_work_requests.dart';

class JobWorkRepository {
  JobWorkRepository({required this._remote});

  final JobWorkRemoteDataSource _remote;

  Future<PaginatedJobWorkOrdersDto> listOrders(JobWorkOrderListQuery query) =>
      _remote.listOrders(query);

  Future<JobWorkOrderDto> getOrder(String id) => _remote.getOrder(id);

  Future<JobWorkOrderDto> createOrder(CreateJobWorkOrderRequest request) =>
      _remote.createOrder(request);

  Future<JobWorkOrderDto> updateOrder(
    String id,
    UpdateJobWorkOrderRequest request,
  ) => _remote.updateOrder(id, request);

  Future<void> deleteOrder(String id) => _remote.deleteOrder(id);
}
