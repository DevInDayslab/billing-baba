import 'package:billing_baba/features/sales/application/job_work_service.dart';
import 'package:billing_baba/features/sales/application/sales_error_mapper.dart';
import 'package:billing_baba/features/sales/models/job_work_out_form_model.dart';
import 'package:billing_baba/features/sales/models/requests/job_work_requests.dart';
import 'package:billing_baba/shared/widgets/table_filters/table_filters.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'job_work_orders_provider.g.dart';

const jobWorkOrdersPageSize = 20;

class JobWorkOutFiltersState {
  const JobWorkOutFiltersState({
    this.dateColumnFilter,
    this.partyNameColumnFilter,
    this.jobIdColumnFilter,
    this.deliveryDateColumnFilter,
    this.selectedStatus = 'All Status',
  });

  final DateColumnFilter? dateColumnFilter;
  final TextColumnFilter? partyNameColumnFilter;
  final TextColumnFilter? jobIdColumnFilter;
  final DateColumnFilter? deliveryDateColumnFilter;
  final String selectedStatus;

  bool get hasColumnFilters =>
      FilterUtils.isFilterActive(FilterType.date, dateColumnFilter) ||
      FilterUtils.isFilterActive(FilterType.text, partyNameColumnFilter) ||
      FilterUtils.isFilterActive(FilterType.text, jobIdColumnFilter) ||
      FilterUtils.isFilterActive(FilterType.date, deliveryDateColumnFilter);

  JobWorkOutFiltersState copyWith({
    DateColumnFilter? dateColumnFilter,
    bool clearDateColumnFilter = false,
    TextColumnFilter? partyNameColumnFilter,
    bool clearPartyNameColumnFilter = false,
    TextColumnFilter? jobIdColumnFilter,
    bool clearJobIdColumnFilter = false,
    DateColumnFilter? deliveryDateColumnFilter,
    bool clearDeliveryDateColumnFilter = false,
    String? selectedStatus,
  }) {
    return JobWorkOutFiltersState(
      dateColumnFilter: clearDateColumnFilter
          ? null
          : (dateColumnFilter ?? this.dateColumnFilter),
      partyNameColumnFilter: clearPartyNameColumnFilter
          ? null
          : (partyNameColumnFilter ?? this.partyNameColumnFilter),
      jobIdColumnFilter: clearJobIdColumnFilter
          ? null
          : (jobIdColumnFilter ?? this.jobIdColumnFilter),
      deliveryDateColumnFilter: clearDeliveryDateColumnFilter
          ? null
          : (deliveryDateColumnFilter ?? this.deliveryDateColumnFilter),
      selectedStatus: selectedStatus ?? this.selectedStatus,
    );
  }
}

JobWorkOutStatus? _jobWorkStatusFromFilterLabel(String label) =>
    switch (label) {
      'Open' => JobWorkOutStatus.open,
      'Closed' => JobWorkOutStatus.closed,
      'Cancelled' => JobWorkOutStatus.cancelled,
      _ => null,
    };

List<JobWorkOrderListItem> applyJobWorkOutClientFilters(
  List<JobWorkOrderListItem> items,
  JobWorkOutFiltersState filters,
  String searchQuery,
) {
  final query = searchQuery.trim().toLowerCase();
  final status = _jobWorkStatusFromFilterLabel(filters.selectedStatus);

  return items.where((item) {
    if (status != null && item.status != status) {
      return false;
    }
    final invoiceDate = item.invoiceDate;
    if (filters.dateColumnFilter != null &&
        invoiceDate != null &&
        !filters.dateColumnFilter!.matches(invoiceDate)) {
      return false;
    }
    if (filters.partyNameColumnFilter != null &&
        !filters.partyNameColumnFilter!.matches(item.party)) {
      return false;
    }
    if (filters.jobIdColumnFilter != null &&
        !filters.jobIdColumnFilter!.matches(item.jobId)) {
      return false;
    }
    final deliveryDate = item.deliveryDate;
    if (filters.deliveryDateColumnFilter != null &&
        deliveryDate != null &&
        !filters.deliveryDateColumnFilter!.matches(deliveryDate)) {
      return false;
    }
    if (query.isNotEmpty) {
      final haystack = [
        item.party,
        item.jobId,
        item.convertedInvoiceNumber ?? '',
      ].join(' ').toLowerCase();
      if (!haystack.contains(query)) {
        return false;
      }
    }
    return true;
  }).toList();
}

@Riverpod(keepAlive: true)
class JobWorkOutSearchQuery extends _$JobWorkOutSearchQuery {
  @override
  String build() => '';

  void setQuery(String value) => state = value;
}

@Riverpod(keepAlive: true)
class JobWorkOutFilters extends _$JobWorkOutFilters {
  @override
  JobWorkOutFiltersState build() => const JobWorkOutFiltersState();

  void setDateColumnFilter(DateColumnFilter? filter) {
    state = state.copyWith(
      dateColumnFilter: filter,
      clearDateColumnFilter: filter == null,
    );
  }

  void setPartyNameColumnFilter(TextColumnFilter? filter) {
    state = state.copyWith(
      partyNameColumnFilter: filter,
      clearPartyNameColumnFilter: filter == null,
    );
  }

  void setJobIdColumnFilter(TextColumnFilter? filter) {
    state = state.copyWith(
      jobIdColumnFilter: filter,
      clearJobIdColumnFilter: filter == null,
    );
  }

  void setDeliveryDateColumnFilter(DateColumnFilter? filter) {
    state = state.copyWith(
      deliveryDateColumnFilter: filter,
      clearDeliveryDateColumnFilter: filter == null,
    );
  }

  void setStatus(String status) {
    state = state.copyWith(selectedStatus: status);
  }
}

@riverpod
List<JobWorkOrderListItem> filteredJobWorkOrders(Ref ref) {
  final items = ref.watch(jobWorkOrdersListProvider).value?.items ?? const [];
  final filters = ref.watch(jobWorkOutFiltersProvider);
  final searchQuery = ref.watch(jobWorkOutSearchQueryProvider);
  return applyJobWorkOutClientFilters(items, filters, searchQuery);
}

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
