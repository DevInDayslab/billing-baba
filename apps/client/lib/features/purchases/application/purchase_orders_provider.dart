import 'package:billing_baba/core/providers/data_refresh.dart';
import 'package:billing_baba/features/export/utils/paginated_fetch.dart';
import 'package:billing_baba/features/purchases/application/purchase_bills_provider.dart';
import 'package:billing_baba/features/purchases/application/purchase_error_mapper.dart';
import 'package:billing_baba/features/purchases/application/purchase_list_filter_utils.dart';
import 'package:billing_baba/features/purchases/application/purchase_service.dart';
import 'package:billing_baba/features/purchases/models/purchase_order_model.dart';
import 'package:billing_baba/features/purchases/models/requests/purchase_requests.dart';
import 'package:billing_baba/features/purchases/presentation/desktop/widgets/shared/purchase_shared_column_filters.dart';
import 'package:billing_baba/features/purchases/purchase_constants.dart';
import 'package:billing_baba/features/sales/application/sale_invoices_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'purchase_orders_provider.g.dart';

const purchaseOrdersPageSize = 10;

/// One-shot success message shown on the purchase order list after save.
final purchaseOrderSaveSuccessMessageProvider =
    NotifierProvider<PurchaseOrderSaveSuccessMessage, String?>(
      PurchaseOrderSaveSuccessMessage.new,
    );

class PurchaseOrderSaveSuccessMessage extends Notifier<String?> {
  @override
  String? build() => null;

  void setMessage(String? value) => state = value;
}

class PurchaseOrderFiltersState {
  const PurchaseOrderFiltersState({
    this.timeRangeOption = TimeRangeOption.thisMonth,
    this.customDateRange,
    this.selectedFirm = 'All Firms',
    this.selectedUser = 'All Users',
    this.selectedStatus = 'All Status',
    this.searchQuery = '',
    this.currentPage = 1,
    this.columnFilters = const PurchaseColumnFilterFields(),
  });

  final TimeRangeOption timeRangeOption;
  final DateTimeRange? customDateRange;
  final String selectedFirm;
  final String selectedUser;
  final String selectedStatus;
  final String searchQuery;
  final int currentPage;
  final PurchaseColumnFilterFields columnFilters;

  String get timeRangeLabel => timeRangeOption.label;

  bool get hasActiveFilters =>
      timeRangeOption != TimeRangeOption.thisMonth ||
      customDateRange != null ||
      selectedFirm != 'All Firms' ||
      selectedUser != 'All Users' ||
      selectedStatus != 'All Status' ||
      searchQuery.trim().isNotEmpty ||
      columnFilters.hasColumnFilters;

  PurchaseOrderFiltersState copyWith({
    TimeRangeOption? timeRangeOption,
    DateTimeRange? customDateRange,
    bool clearCustomDateRange = false,
    String? selectedFirm,
    String? selectedUser,
    String? selectedStatus,
    String? searchQuery,
    int? currentPage,
    PurchaseColumnFilterFields? columnFilters,
  }) {
    return PurchaseOrderFiltersState(
      timeRangeOption: timeRangeOption ?? this.timeRangeOption,
      customDateRange: clearCustomDateRange
          ? null
          : (customDateRange ?? this.customDateRange),
      selectedFirm: selectedFirm ?? this.selectedFirm,
      selectedUser: selectedUser ?? this.selectedUser,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      searchQuery: searchQuery ?? this.searchQuery,
      currentPage: currentPage ?? this.currentPage,
      columnFilters: columnFilters ?? this.columnFilters,
    );
  }
}

PurchaseOrderStatus? _statusFromFilterLabel(String label) => switch (label) {
  'Open' => PurchaseOrderStatus.open,
  'Order Completed' => PurchaseOrderStatus.orderCompleted,
  'Partially Received' => PurchaseOrderStatus.partiallyReceived,
  'Cancelled' => PurchaseOrderStatus.cancelled,
  _ => null,
};

String? _documentStatusFromFilterLabel(String label) => switch (label) {
  'Cancelled' => 'cancelled',
  'Open' => 'draft',
  'Order Completed' => 'finalized',
  _ => null,
};

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

PurchaseDocumentListQuery _buildListQuery(PurchaseOrderFiltersState filters) {
  final dateRange = _resolveTimeRange(
    filters.timeRangeOption,
    filters.customDateRange,
  );

  return PurchaseDocumentListQuery(
    limit: PaginatedFetch.defaultPageSize,
    documentType: PurchaseDocumentType.purchaseOrder.apiValue,
    status: _documentStatusFromFilterLabel(filters.selectedStatus),
    from: dateRange?.start.toUtc().toIso8601String(),
    to: dateRange?.end.toUtc().toIso8601String(),
  );
}

List<PurchaseOrderModel> _applyFilters(
  List<PurchaseOrderModel> orders,
  PurchaseOrderFiltersState filters,
) {
  final statusFilter = _statusFromFilterLabel(filters.selectedStatus);
  final columns = filters.columnFilters;
  final globalQuery = filters.searchQuery.trim().toLowerCase();

  return orders.where((order) {
    if (globalQuery.isNotEmpty &&
        !purchaseFilterMatchesGlobalSearch(globalQuery, [
          order.orderNo,
          order.partyName,
          order.type,
        ])) {
      return false;
    }

    if (!purchaseFilterMatchesText(columns.documentNoFilter, order.orderNo)) {
      return false;
    }

    if (columns.columnDateRange != null &&
        !purchaseFilterIsWithinDateRange(
          order.date,
          columns.columnDateRange!,
        )) {
      return false;
    }

    if (!purchaseFilterMatchesParty(columns.selectedParty, order.partyName)) {
      return false;
    }

    if (columns.dueDateRange != null &&
        !purchaseFilterIsWithinDateRange(
          order.dueDate,
          columns.dueDateRange!,
        )) {
      return false;
    }

    if (!purchaseFilterMatchesNumericFilter(
      order.amount,
      columns.amountFilter,
    )) {
      return false;
    }

    if (!purchaseFilterMatchesNumericFilter(
      order.balanceDue,
      columns.balanceFilter,
    )) {
      return false;
    }

    if (!purchaseFilterMatchesOption(
      columns.selectedType,
      'All Types',
      order.type,
    )) {
      return false;
    }

    if (statusFilter != null && order.status != statusFilter) {
      return false;
    }

    if (filters.selectedUser != 'All Users' &&
        order.user != filters.selectedUser) {
      return false;
    }
    if (filters.selectedFirm != 'All Firms' &&
        order.firm != filters.selectedFirm) {
      return false;
    }

    return true;
  }).toList();
}

PaginatedPurchaseOrders _paginateFilteredOrders(
  List<PurchaseOrderModel> filtered,
  int currentPage,
) {
  final slice = purchaseFilterPaginate(
    filtered,
    currentPage,
    purchaseOrdersPageSize,
  );
  return PaginatedPurchaseOrders(
    items: slice.items,
    currentPage: slice.currentPage,
    totalPages: slice.totalPages,
    totalItems: slice.totalItems,
  );
}

PaginatedPurchaseOrders _allOrdersPage(List<PurchaseOrderModel> allOrders) {
  return PaginatedPurchaseOrders(
    items: allOrders,
    currentPage: 1,
    totalPages: 1,
    totalItems: allOrders.length,
  );
}

List<PurchaseOrderModel> _allOrdersFromAsync(
  AsyncValue<PaginatedPurchaseOrders> ordersAsync,
) {
  return ordersAsync.when(
    data: (page) => page.items,
    loading: () => const [],
    error: (_, _) => const [],
  );
}

@Riverpod(keepAlive: true)
class PurchaseOrders extends _$PurchaseOrders {
  @override
  Future<PaginatedPurchaseOrders> build() async {
    ref.watch(
      purchaseOrderFiltersProvider.select(
        (filters) => (filters.timeRangeOption, filters.customDateRange),
      ),
    );
    ref.watch(
      purchaseOrderFiltersProvider.select(
        (filters) => _documentStatusFromFilterLabel(filters.selectedStatus),
      ),
    );
    final allOrders = await _fetchAllOrders();
    return _allOrdersPage(allOrders);
  }

  Future<List<PurchaseOrderModel>> _fetchAllOrders() async {
    final filters = ref.read(purchaseOrderFiltersProvider);
    final service = await ref.read(purchaseServiceProvider.future);

    return PaginatedFetch.fetchAll(
      fetchPage: (page) async {
        final baseQuery = _buildListQuery(filters);
        final query = PurchaseDocumentListQuery(
          page: page,
          limit: baseQuery.limit,
          documentType: baseQuery.documentType,
          status: baseQuery.status,
          from: baseQuery.from,
          to: baseQuery.to,
          sort: baseQuery.sort,
          order: baseQuery.order,
        );
        final pageResult = await service.fetchOrdersPage(query);
        return (
          items: pageResult.items,
          totalPages: pageResult.totalPages,
        );
      },
    );
  }

  Future<void> refresh() async {
    if (!state.hasValue) {
      state = const AsyncLoading();
    }
    state = await AsyncValue.guard(() async {
      final allOrders = await _fetchAllOrders();
      return _allOrdersPage(allOrders);
    });
  }

  Future<String?> deleteDraft(String documentId) async {
    try {
      final service = await ref.read(purchaseServiceProvider.future);
      await service.deleteDraft(documentId);
      await refresh();
      return null;
    } catch (error) {
      return PurchaseErrorMapper.messageFor(error);
    }
  }

  Future<String?> finalizeOrder(String documentId, {String? godownId}) async {
    try {
      final service = await ref.read(purchaseServiceProvider.future);
      await service.finalizeDraft(documentId, godownId: godownId);
      await refresh();
      await refreshAfterPurchaseMutation(ref);
      return null;
    } catch (error) {
      return PurchaseErrorMapper.messageFor(error);
    }
  }

  Future<String?> convertToBill(String orderId) async {
    try {
      final service = await ref.read(purchaseServiceProvider.future);
      await service.convertPurchaseOrder(orderId);
      await refresh();
      ref.invalidate(purchaseBillsProvider);
      await ref.read(purchaseBillsProvider.notifier).refresh();
      await refreshAfterPurchaseMutation(ref);
      return null;
    } catch (error) {
      return PurchaseErrorMapper.messageFor(error);
    }
  }

  Future<({String? error, String? billId})> convertToBillWithId(
    String orderId,
  ) async {
    try {
      final service = await ref.read(purchaseServiceProvider.future);
      final document = await service.convertPurchaseOrder(orderId);
      await refresh();
      ref.invalidate(purchaseBillsProvider);
      await ref.read(purchaseBillsProvider.notifier).refresh();
      await refreshAfterPurchaseMutation(ref);
      return (error: null, billId: document.id);
    } catch (error) {
      return (
        error: PurchaseErrorMapper.messageFor(error),
        billId: null,
      );
    }
  }

  Future<String?> cancelOrder(String documentId) async {
    try {
      final service = await ref.read(purchaseServiceProvider.future);
      await service.cancelDocument(documentId);
      await refresh();
      return null;
    } catch (error) {
      return PurchaseErrorMapper.messageFor(error);
    }
  }

  Future<({String? error, String? newId})> duplicateOrder(
    String orderId,
  ) async {
    try {
      final service = await ref.read(purchaseServiceProvider.future);
      final newId = await service.duplicatePurchaseOrder(orderId);
      await refresh();
      return (error: null, newId: newId);
    } catch (error) {
      return (
        error: PurchaseErrorMapper.messageFor(error),
        newId: null,
      );
    }
  }
}

@riverpod
class PurchaseOrderFilters extends _$PurchaseOrderFilters {
  @override
  PurchaseOrderFiltersState build() => const PurchaseOrderFiltersState();

  void setTimeRange(String label) {
    state = state.copyWith(
      timeRangeOption: TimeRangeOptionX.fromLabel(label),
      currentPage: 1,
    );
    ref.invalidate(purchaseOrdersProvider);
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
    ref.invalidate(purchaseOrdersProvider);
  }

  void setFirm(String firm) {
    state = state.copyWith(selectedFirm: firm, currentPage: 1);
  }

  void setUser(String user) {
    state = state.copyWith(selectedUser: user, currentPage: 1);
  }

  void setStatus(String status) {
    state = state.copyWith(selectedStatus: status, currentPage: 1);
    if (_documentStatusFromFilterLabel(status) != null) {
      ref.invalidate(purchaseOrdersProvider);
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query, currentPage: 1);
  }

  void setColumnDateRange(DateTimeRange range) {
    state = state.copyWith(
      columnFilters: state.columnFilters.copyWith(columnDateRange: range),
      currentPage: 1,
    );
  }

  void clearColumnDateRange() {
    state = state.copyWith(
      columnFilters: state.columnFilters.copyWith(clearColumnDateRange: true),
      currentPage: 1,
    );
  }

  void setDocumentNoFilter(String value) {
    state = state.copyWith(
      columnFilters: state.columnFilters.copyWith(documentNoFilter: value),
      currentPage: 1,
    );
  }

  void setParty(String party) {
    state = state.copyWith(
      columnFilters: state.columnFilters.copyWith(selectedParty: party),
      currentPage: 1,
    );
  }

  void setType(String type) {
    state = state.copyWith(
      columnFilters: state.columnFilters.copyWith(selectedType: type),
      currentPage: 1,
    );
  }

  void applyAmountFilter(PurchaseNumericFilter filter) {
    state = state.copyWith(
      columnFilters: state.columnFilters.copyWith(amountFilter: filter),
      currentPage: 1,
    );
  }

  void clearAmountFilter() {
    state = state.copyWith(
      columnFilters: state.columnFilters.copyWith(clearAmountFilter: true),
      currentPage: 1,
    );
  }

  void applyBalanceFilter(PurchaseNumericFilter filter) {
    state = state.copyWith(
      columnFilters: state.columnFilters.copyWith(balanceFilter: filter),
      currentPage: 1,
    );
  }

  void clearBalanceFilter() {
    state = state.copyWith(
      columnFilters: state.columnFilters.copyWith(clearBalanceFilter: true),
      currentPage: 1,
    );
  }

  void togglePaymentType(String paymentType) {}

  void clearPaymentTypes() {}

  void setDueDateRange(DateTimeRange range) {
    state = state.copyWith(
      columnFilters: state.columnFilters.copyWith(dueDateRange: range),
      currentPage: 1,
    );
  }

  void clearDueDateRange() {
    state = state.copyWith(
      columnFilters: state.columnFilters.copyWith(clearDueDateRange: true),
      currentPage: 1,
    );
  }

  void setPage(int page) {
    state = state.copyWith(currentPage: page);
  }

  void clearAllFilters() {
    state = const PurchaseOrderFiltersState();
    ref.invalidate(purchaseOrdersProvider);
  }
}

@riverpod
List<PurchaseOrderModel> filteredPurchaseOrders(Ref ref) {
  final allOrders = _allOrdersFromAsync(ref.watch(purchaseOrdersProvider));
  final filters = ref.watch(purchaseOrderFiltersProvider);
  return _applyFilters(allOrders, filters);
}

@riverpod
PaginatedPurchaseOrders paginatedPurchaseOrders(Ref ref) {
  final filtered = ref.watch(filteredPurchaseOrdersProvider);
  final filters = ref.watch(purchaseOrderFiltersProvider);
  return _paginateFilteredOrders(filtered, filters.currentPage);
}

@riverpod
List<String> purchaseOrderPartyOptions(Ref ref) {
  final allOrders = _allOrdersFromAsync(ref.watch(purchaseOrdersProvider));
  return purchasePartyOptionsFromNames(
    allOrders.map((order) => order.partyName),
  );
}

@riverpod
List<String> purchaseOrderTypeOptions(Ref ref) {
  final allOrders = _allOrdersFromAsync(ref.watch(purchaseOrdersProvider));
  final types = allOrders.map((order) => order.type).toSet().toList()..sort();
  return ['All Types', ...types];
}

class PurchaseOrderSummaryData {
  const PurchaseOrderSummaryData({
    required this.openAmount,
    required this.partiallyReceivedAmount,
    required this.completedAmount,
    required this.totalAmount,
  });

  final double openAmount;
  final double partiallyReceivedAmount;
  final double completedAmount;
  final double totalAmount;
}

@riverpod
PurchaseOrderSummaryData purchaseOrderSummary(Ref ref) {
  final orders = ref.watch(filteredPurchaseOrdersProvider);

  var openAmount = 0.0;
  var partiallyReceivedAmount = 0.0;
  var completedAmount = 0.0;
  var totalAmount = 0.0;

  for (final order in orders) {
    totalAmount += order.amount;
    switch (order.status) {
      case PurchaseOrderStatus.open:
        openAmount += order.amount;
      case PurchaseOrderStatus.partiallyReceived:
        partiallyReceivedAmount += order.amount;
      case PurchaseOrderStatus.orderCompleted:
        completedAmount += order.amount;
      case PurchaseOrderStatus.cancelled:
        break;
    }
  }

  return PurchaseOrderSummaryData(
    openAmount: openAmount,
    partiallyReceivedAmount: partiallyReceivedAmount,
    completedAmount: completedAmount,
    totalAmount: totalAmount,
  );
}
