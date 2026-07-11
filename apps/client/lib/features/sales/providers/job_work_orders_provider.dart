import 'package:billing_baba/features/sales/application/job_work_service.dart';
import 'package:billing_baba/features/sales/application/sales_error_mapper.dart';
import 'package:billing_baba/features/sales/models/requests/job_work_requests.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'job_work_orders_provider.g.dart';

const jobWorkOrdersPageSize = 20;

@Riverpod(keepAlive: true)
class JobWorkOrdersList extends _$JobWorkOrdersList {
  @override
  Future<PaginatedJobWorkOrders> build() async {
    return _fetchPage();
  }

  Future<PaginatedJobWorkOrders> _fetchPage() async {
    final service = await ref.read(jobWorkServiceProvider.future);
    return service.fetchOrdersPage(
      const JobWorkOrderListQuery(),
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetchPage);
  }

  Future<String?> closeOrder(String orderId) async {
    try {
      final service = await ref.read(jobWorkServiceProvider.future);
      await service.closeOrder(orderId);
      await refresh();
      return null;
    } catch (error) {
      return SalesErrorMapper.messageFor(error);
    }
  }

  Future<String?> deleteOrder(String orderId) async {
    final previous = state;
    final current = state.value;
    if (current != null) {
      state = AsyncData(
        PaginatedJobWorkOrders(
          items: current.items.where((item) => item.id != orderId).toList(),
          currentPage: current.currentPage,
          totalPages: current.totalPages,
          totalItems: current.totalItems - 1,
        ),
      );
    }

    try {
      final service = await ref.read(jobWorkServiceProvider.future);
      await service.deleteOrder(orderId);
      await refresh();
      return null;
    } catch (error) {
      state = previous;
      return SalesErrorMapper.messageFor(error);
    }
  }
}
