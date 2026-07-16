import 'package:billing_baba/features/auth/providers/auth_provider.dart';
import 'package:billing_baba/features/business/application/business_service.dart';
import 'package:billing_baba/features/export/utils/paginated_fetch.dart';
import 'package:billing_baba/features/inventory/providers/inventory_godowns_provider.dart';
import 'package:billing_baba/features/sales/application/sales_error_mapper.dart';
import 'package:billing_baba/features/sales/application/sales_service.dart';
import 'package:billing_baba/features/sales/models/requests/sales_requests.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_model.dart';
import 'package:billing_baba/features/sales/providers/sale_invoices_provider.dart';
import 'package:billing_baba/features/sales/sales_constants.dart';
import 'package:billing_baba/shared/widgets/table_filters/table_filters.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sale_orders_provider.g.dart';

const saleOrdersPageSize = 10;

class SaleOrderFiltersState {
  const SaleOrderFiltersState({
    this.timeRangeOption = TimeRangeOption.thisMonth,
    this.customDateRange,
    this.dateColumnFilter,
    this.orderNoColumnFilter,
    this.partyNameColumnFilter,
    this.amountColumnFilter,
    this.dueDateColumnFilter,
    this.selectedFirm = 'All Firms',
    this.selectedUser = 'All Users',
    this.selectedGodown = 'All Godown',
    this.selectedStatus = 'All Status',
    this.currentPage = 1,
  });

  final TimeRangeOption timeRangeOption;
  final DateTimeRange? customDateRange;
  final DateColumnFilter? dateColumnFilter;
  final TextColumnFilter? orderNoColumnFilter;
  final TextColumnFilter? partyNameColumnFilter;
  final AmountColumnFilter? amountColumnFilter;
  final DateColumnFilter? dueDateColumnFilter;
  final String selectedFirm;
  final String selectedUser;
  final String selectedGodown;
  final String selectedStatus;
  final int currentPage;

  String get timeRangeLabel => timeRangeOption.label;

  SaleOrderFiltersState copyWith({
    TimeRangeOption? timeRangeOption,
    DateTimeRange? customDateRange,
    bool clearCustomDateRange = false,
    DateColumnFilter? dateColumnFilter,
    bool clearDateColumnFilter = false,
    TextColumnFilter? orderNoColumnFilter,
    bool clearOrderNoColumnFilter = false,
    TextColumnFilter? partyNameColumnFilter,
    bool clearPartyNameColumnFilter = false,
    AmountColumnFilter? amountColumnFilter,
    bool clearAmountColumnFilter = false,
    DateColumnFilter? dueDateColumnFilter,
    bool clearDueDateColumnFilter = false,
    String? selectedUser,
    String? selectedGodown,
    String? selectedFirm,
    String? selectedStatus,
    int? currentPage,
  }) {
    return SaleOrderFiltersState(
      timeRangeOption: timeRangeOption ?? this.timeRangeOption,
      customDateRange: clearCustomDateRange
          ? null
          : (customDateRange ?? this.customDateRange),
      dateColumnFilter: clearDateColumnFilter
          ? null
          : (dateColumnFilter ?? this.dateColumnFilter),
      orderNoColumnFilter: clearOrderNoColumnFilter
          ? null
          : (orderNoColumnFilter ?? this.orderNoColumnFilter),
      partyNameColumnFilter: clearPartyNameColumnFilter
          ? null
          : (partyNameColumnFilter ?? this.partyNameColumnFilter),
      amountColumnFilter: clearAmountColumnFilter
          ? null
          : (amountColumnFilter ?? this.amountColumnFilter),
      dueDateColumnFilter: clearDueDateColumnFilter
          ? null
          : (dueDateColumnFilter ?? this.dueDateColumnFilter),
      selectedUser: selectedUser ?? this.selectedUser,
      selectedGodown: selectedGodown ?? this.selectedGodown,
      selectedFirm: selectedFirm ?? this.selectedFirm,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

enum SaleOrderDisplayStatus {
  draft,
  open,
  overdue,
  completed,
  cancelled,
}

SaleOrderDisplayStatus saleOrderDisplayStatus(SaleInvoiceModel order) {
  if (order.documentStatus == SalesDocumentStatus.cancelled) {
    return SaleOrderDisplayStatus.cancelled;
  }
  if (order.documentStatus == SalesDocumentStatus.draft) {
    return SaleOrderDisplayStatus.draft;
  }
  if (order.documentStatus == SalesDocumentStatus.converted) {
    return SaleOrderDisplayStatus.completed;
  }
  final dueDate = order.dueDate ?? order.date;
  final today = DateTime.now();
  final dueDay = DateTime(dueDate.year, dueDate.month, dueDate.day);
  final todayDay = DateTime(today.year, today.month, today.day);
  if (dueDay.isBefore(todayDay)) {
    return SaleOrderDisplayStatus.overdue;
  }
  return SaleOrderDisplayStatus.open;
}

bool _matchesSaleOrderStatusFilter(
  SaleInvoiceModel order,
  String statusLabel,
) {
  if (statusLabel == 'All Status') return true;
  final displayStatus = saleOrderDisplayStatus(order);
  return switch (statusLabel) {
    'Order Overdue' => displayStatus == SaleOrderDisplayStatus.overdue,
    'Order Completed' => displayStatus == SaleOrderDisplayStatus.completed,
    'Open' => displayStatus == SaleOrderDisplayStatus.open,
    'Draft' => displayStatus == SaleOrderDisplayStatus.draft,
    'Cancelled' => displayStatus == SaleOrderDisplayStatus.cancelled,
    _ => true,
  };
}

double saleOrderBalanceFor(SaleInvoiceModel order) {
  return switch (order.documentStatus) {
    SalesDocumentStatus.finalized => order.amount,
    SalesDocumentStatus.draft => order.amount,
    _ => 0,
  };
}

DateTime _startOfDay(DateTime date) =>
    DateTime(date.year, date.month, date.day);

DateTime _endOfDay(DateTime date) =>
    DateTime(date.year, date.month, date.day, 23, 59, 59, 999);

DateTimeRange? _resolveTimeRange(
  TimeRangeOption option,
  DateTimeRange? custom,
) {
  final now = DateTime.now();
  final today = _startOfDay(now);

  return switch (option) {
    TimeRangeOption.allTime => null,
    TimeRangeOption.today => DateTimeRange(start: today, end: _endOfDay(today)),
    TimeRangeOption.thisWeek => DateTimeRange(
      start: today.subtract(Duration(days: today.weekday % 7)),
      end: _endOfDay(
        today.add(Duration(days: 6 - (today.weekday % 7))),
      ),
    ),
    TimeRangeOption.thisMonth => DateTimeRange(
      start: DateTime(now.year, now.month),
      end: _endOfDay(DateTime(now.year, now.month + 1, 0)),
    ),
    TimeRangeOption.thisYear => DateTimeRange(
      start: DateTime(now.year),
      end: _endOfDay(DateTime(now.year, 12, 31)),
    ),
    TimeRangeOption.custom => custom,
  };
}

SalesDocumentListQuery _buildSaleOrderListQuery(
  SaleOrderFiltersState filters,
  String searchQuery, {
  int? page,
  int? limit,
}) {
  final dateRange = _resolveTimeRange(
    filters.timeRangeOption,
    filters.customDateRange,
  );

  return SalesDocumentListQuery(
    page: page ?? filters.currentPage,
    limit: limit ?? saleOrdersPageSize,
    documentType: SalesDocumentType.saleOrder.apiValue,
    from: dateRange?.start.toUtc().toIso8601String(),
    to: dateRange?.end.toUtc().toIso8601String(),
    q: searchQuery.trim().isEmpty ? null : searchQuery.trim(),
  );
}

bool needsSaleOrderClientSideFiltering(SaleOrderFiltersState filters) {
  return filters.dateColumnFilter != null ||
      filters.orderNoColumnFilter != null ||
      filters.partyNameColumnFilter != null ||
      filters.amountColumnFilter != null ||
      filters.dueDateColumnFilter != null ||
      filters.selectedStatus != 'All Status' ||
      filters.selectedUser != 'All Users' ||
      filters.selectedGodown != 'All Godown' ||
      filters.selectedFirm != 'All Firms';
}

PaginatedSaleInvoices paginateSaleOrderItems(
  List<SaleInvoiceModel> items,
  SaleOrderFiltersState filters,
) {
  final totalItems = items.length;
  final totalPages = totalItems == 0
      ? 1
      : (totalItems / saleOrdersPageSize).ceil();
  final currentPage = filters.currentPage.clamp(1, totalPages);
  final start = (currentPage - 1) * saleOrdersPageSize;
  final pageItems = items.skip(start).take(saleOrdersPageSize).toList();

  return PaginatedSaleInvoices(
    items: pageItems,
    currentPage: currentPage,
    totalPages: totalPages,
    totalItems: totalItems,
  );
}

List<SaleInvoiceModel> applySaleOrderClientFilters(
  List<SaleInvoiceModel> orders,
  SaleOrderFiltersState filters,
) {
  return orders.where((order) {
    if (filters.dateColumnFilter != null &&
        !filters.dateColumnFilter!.matches(order.date)) {
      return false;
    }
    if (filters.orderNoColumnFilter != null &&
        !filters.orderNoColumnFilter!.matches(order.invoiceNo)) {
      return false;
    }
    if (filters.partyNameColumnFilter != null &&
        !filters.partyNameColumnFilter!.matches(order.partyName)) {
      return false;
    }
    if (filters.amountColumnFilter != null &&
        !filters.amountColumnFilter!.matches(order.amount)) {
      return false;
    }
    final dueDate = order.dueDate ?? order.date;
    if (filters.dueDateColumnFilter != null &&
        !filters.dueDateColumnFilter!.matches(dueDate)) {
      return false;
    }
    if (!_matchesSaleOrderStatusFilter(order, filters.selectedStatus)) {
      return false;
    }
    if (filters.selectedUser != 'All Users' &&
        order.user != filters.selectedUser) {
      return false;
    }
    if (filters.selectedGodown != 'All Godown' &&
        order.godown != filters.selectedGodown) {
      return false;
    }
    if (filters.selectedFirm != 'All Firms' &&
        order.firm != filters.selectedFirm) {
      return false;
    }
    return true;
  }).toList();
}

List<String> _withAllOption(String allLabel, Iterable<String> values) {
  final unique =
      values
          .map((value) => value.trim())
          .where((value) {
            return value.isNotEmpty && value != allLabel;
          })
          .toSet()
          .toList()
        ..sort();
  return [allLabel, ...unique];
}

@riverpod
List<String> saleOrderFirmFilterOptions(Ref ref) {
  final authState = ref.watch(authProvider);
  final businesses = authState.session?.businesses ?? [];
  final names = businesses.map((business) => business.name);
  final currentBusiness = ref.watch(currentBusinessProvider);
  return _withAllOption(
    'All Firms',
    [
      if (currentBusiness != null) currentBusiness.name,
      ...names,
    ],
  );
}

@riverpod
List<String> saleOrderUserFilterOptions(Ref ref) {
  final authState = ref.watch(authProvider);
  final authUser = authState.session?.user;
  final orders = ref.watch(saleOrdersProvider).value?.items ?? [];

  return _withAllOption(
    'All Users',
    [
      if (authUser?.name?.trim().isNotEmpty == true) authUser!.name!,
      if (authUser?.phone.trim().isNotEmpty == true) authUser!.phone,
      ...orders.map((order) => order.user),
    ],
  );
}

@riverpod
List<String> saleOrderGodownFilterOptions(Ref ref) {
  final godownsAsync = ref.watch(inventoryGodownsProvider);
  final orders = ref.watch(saleOrdersProvider).value?.items ?? [];

  final godownNames = godownsAsync.maybeWhen(
    data: (godowns) => godowns.map((godown) => godown.name),
    orElse: () => const <String>[],
  );

  return _withAllOption(
    'All Godown',
    [
      ...godownNames,
      ...orders.map((order) => order.godown),
    ],
  );
}

@riverpod
class SaleOrderSearchQuery extends _$SaleOrderSearchQuery {
  @override
  String build() => '';

  void setQuery(String value) => state = value;
}

@riverpod
class SelectedSaleOrderId extends _$SelectedSaleOrderId {
  @override
  String? build() => null;

  void select(String id) => state = id;

  void clear() => state = null;
}

@riverpod
class BulkSelectedSaleOrderIds extends _$BulkSelectedSaleOrderIds {
  @override
  Set<String> build() => {};

  void toggle(String id) {
    final next = Set<String>.from(state);
    if (next.contains(id)) {
      next.remove(id);
    } else {
      next.add(id);
    }
    state = next;
  }

  void selectAll(Iterable<String> ids) => state = ids.toSet();

  void clear() => state = {};
}

@Riverpod(keepAlive: true)
class SaleOrders extends _$SaleOrders {
  @override
  Future<PaginatedSaleInvoices> build() async {
    ref.watch(saleOrderFiltersProvider);
    ref.watch(saleOrderSearchQueryProvider);
    return _fetchPage();
  }

  Future<PaginatedSaleInvoices> _fetchPage() async {
    final filters = ref.read(saleOrderFiltersProvider);
    final search = ref.read(saleOrderSearchQueryProvider);
    final service = await ref.read(salesServiceProvider.future);

    if (needsSaleOrderClientSideFiltering(filters)) {
      final allItems = await PaginatedFetch.fetchAll<SaleInvoiceModel>(
        fetchPage: (page) async {
          final result = await service.fetchInvoicesPage(
            _buildSaleOrderListQuery(
              filters,
              search,
              page: page,
              limit: PaginatedFetch.defaultPageSize,
            ),
          );
          return (
            items: result.items,
            totalPages: result.totalPages,
          );
        },
      );

      final filteredItems = applySaleOrderClientFilters(allItems, filters);
      return paginateSaleOrderItems(filteredItems, filters);
    }

    final page = await service.fetchInvoicesPage(
      _buildSaleOrderListQuery(filters, search),
    );

    return page;
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetchPage);
  }

  Future<String?> deleteOrder(String documentId) async {
    final previous = state;
    final current = state.value;
    if (current != null) {
      state = AsyncData(
        PaginatedSaleInvoices(
          items: current.items.where((item) => item.id != documentId).toList(),
          currentPage: current.currentPage,
          totalPages: current.totalPages,
          totalItems: current.totalItems - 1,
        ),
      );
    }

    try {
      final service = await ref.read(salesServiceProvider.future);
      await service.deleteDraft(documentId);
      await refresh();
      return null;
    } catch (error) {
      state = previous;
      return SalesErrorMapper.messageFor(error);
    }
  }

  Future<String?> cancelOrder(String documentId) async {
    try {
      final service = await ref.read(salesServiceProvider.future);
      await service.cancelSale(documentId);
      await refresh();
      return null;
    } catch (error) {
      return SalesErrorMapper.messageFor(error);
    }
  }

  Future<String?> convertOrder(
    String documentId, {
    required String targetType,
  }) async {
    try {
      final service = await ref.read(salesServiceProvider.future);
      await service.convertDocument(
        documentId,
        targetType: targetType,
      );
      await refresh();
      return null;
    } catch (error) {
      return SalesErrorMapper.messageFor(error);
    }
  }

  Future<String?> bulkConvertToSale(Iterable<String> documentIds) async {
    final ids = documentIds.toList();
    if (ids.isEmpty) return 'Select at least one order';

    try {
      final service = await ref.read(salesServiceProvider.future);
      for (final id in ids) {
        await service.convertDocument(id, targetType: 'tax_invoice');
      }
      ref.read(bulkSelectedSaleOrderIdsProvider.notifier).clear();
      await refresh();
      return null;
    } catch (error) {
      return SalesErrorMapper.messageFor(error);
    }
  }
}

@riverpod
class SaleOrderFilters extends _$SaleOrderFilters {
  @override
  SaleOrderFiltersState build() {
    return const SaleOrderFiltersState();
  }

  void setTimeRange(String label) {
    state = state.copyWith(
      timeRangeOption: TimeRangeOptionX.fromLabel(label),
      currentPage: 1,
    );
  }

  void setCustomDateRange(
    DateTimeRange range, {
    bool autoSwitchToCustom = false,
  }) {
    state = state.copyWith(
      timeRangeOption: autoSwitchToCustom
          ? TimeRangeOption.custom
          : state.timeRangeOption,
      customDateRange: range,
      currentPage: 1,
    );
  }

  void setUser(String user) {
    state = state.copyWith(selectedUser: user, currentPage: 1);
  }

  void setGodown(String godown) {
    state = state.copyWith(selectedGodown: godown, currentPage: 1);
  }

  void setFirm(String firm) {
    state = state.copyWith(selectedFirm: firm, currentPage: 1);
  }

  void setStatus(String status) {
    state = state.copyWith(selectedStatus: status, currentPage: 1);
  }

  void setDateColumnFilter(DateColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearDateColumnFilter: true, currentPage: 1)
        : state.copyWith(dateColumnFilter: filter, currentPage: 1);
  }

  void setOrderNoColumnFilter(TextColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearOrderNoColumnFilter: true, currentPage: 1)
        : state.copyWith(orderNoColumnFilter: filter, currentPage: 1);
  }

  void setPartyNameColumnFilter(TextColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearPartyNameColumnFilter: true, currentPage: 1)
        : state.copyWith(partyNameColumnFilter: filter, currentPage: 1);
  }

  void setAmountColumnFilter(AmountColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearAmountColumnFilter: true, currentPage: 1)
        : state.copyWith(amountColumnFilter: filter, currentPage: 1);
  }

  void setDueDateColumnFilter(DateColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearDueDateColumnFilter: true, currentPage: 1)
        : state.copyWith(dueDateColumnFilter: filter, currentPage: 1);
  }

  void setPage(int page) {
    state = state.copyWith(currentPage: page);
  }
}

@riverpod
PaginatedSaleInvoices paginatedSaleOrders(Ref ref) {
  final ordersAsync = ref.watch(saleOrdersProvider);
  return ordersAsync.maybeWhen(
    data: (page) => page,
    orElse: () => const PaginatedSaleInvoices(
      items: [],
      currentPage: 1,
      totalPages: 1,
      totalItems: 0,
    ),
  );
}
