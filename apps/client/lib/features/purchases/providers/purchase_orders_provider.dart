import 'package:billing_baba/core/utils/debouncer.dart';
import 'package:billing_baba/features/purchases/application/purchase_error_mapper.dart';
import 'package:billing_baba/features/purchases/application/purchase_service.dart';
import 'package:billing_baba/features/purchases/models/purchase_order_model.dart';
import 'package:billing_baba/features/purchases/models/requests/purchase_requests.dart';
import 'package:billing_baba/features/purchases/providers/purchase_bills_provider.dart';
import 'package:billing_baba/features/purchases/purchase_constants.dart';
import 'package:billing_baba/features/sales/providers/sale_invoices_provider.dart';
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
  });

  final TimeRangeOption timeRangeOption;
  final DateTimeRange? customDateRange;
  final String selectedFirm;
  final String selectedUser;
  final String selectedStatus;
  final String searchQuery;
  final int currentPage;

  String get timeRangeLabel => timeRangeOption.label;

  PurchaseOrderFiltersState copyWith({
    TimeRangeOption? timeRangeOption,
    DateTimeRange? customDateRange,
    bool clearCustomDateRange = false,
    String? selectedFirm,
    String? selectedUser,
    String? selectedStatus,
    String? searchQuery,
    int? currentPage,
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
    page: filters.currentPage,
    limit: purchaseOrdersPageSize,
    documentType: PurchaseDocumentType.purchaseOrder.apiValue,
    status: _documentStatusFromFilterLabel(filters.selectedStatus),
    from: dateRange?.start.toUtc().toIso8601String(),
    to: dateRange?.end.toUtc().toIso8601String(),
    q: filters.searchQuery.trim().isEmpty ? null : filters.searchQuery.trim(),
  );
}

List<PurchaseOrderModel> _applyClientFilters(
  List<PurchaseOrderModel> orders,
  PurchaseOrderFiltersState filters,
) {
  final statusFilter = _statusFromFilterLabel(filters.selectedStatus);

  return orders.where((order) {
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

@Riverpod(keepAlive: true)
class PurchaseOrders extends _$PurchaseOrders {
  @override
  Future<PaginatedPurchaseOrders> build() async {
    ref.watch(purchaseOrderFiltersProvider);
    return _fetchPage();
  }

  Future<PaginatedPurchaseOrders> _fetchPage() async {
    final filters = ref.read(purchaseOrderFiltersProvider);
    final service = await ref.read(purchaseServiceProvider.future);
    final page = await service.fetchOrdersPage(_buildListQuery(filters));

    return PaginatedPurchaseOrders(
      items: _applyClientFilters(page.items, filters),
      currentPage: page.currentPage,
      totalPages: page.totalPages,
      totalItems: page.totalItems,
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetchPage);
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

  Future<({String? error, String? newId})> duplicateOrder(String orderId) async {
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
  Debouncer? _searchDebouncer;

  @override
  PurchaseOrderFiltersState build() {
    ref.onDispose(() => _searchDebouncer?.dispose());
    return const PurchaseOrderFiltersState();
  }

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
    ref.invalidate(purchaseOrdersProvider);
  }

  void setUser(String user) {
    state = state.copyWith(selectedUser: user, currentPage: 1);
    ref.invalidate(purchaseOrdersProvider);
  }

  void setStatus(String status) {
    state = state.copyWith(selectedStatus: status, currentPage: 1);
    ref.invalidate(purchaseOrdersProvider);
  }

  void setSearchQuery(String query) {
    _searchDebouncer ??= Debouncer();
    _searchDebouncer!.run(() {
      state = state.copyWith(searchQuery: query, currentPage: 1);
      ref.invalidate(purchaseOrdersProvider);
    });
  }

  void setPage(int page) {
    state = state.copyWith(currentPage: page);
    ref.invalidate(purchaseOrdersProvider);
  }
}

@riverpod
PaginatedPurchaseOrders paginatedPurchaseOrders(Ref ref) {
  final ordersAsync = ref.watch(purchaseOrdersProvider);
  return ordersAsync.maybeWhen(
    data: (page) => page,
    orElse: () => const PaginatedPurchaseOrders(
      items: [],
      currentPage: 1,
      totalPages: 1,
      totalItems: 0,
    ),
  );
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
  final page = ref.watch(paginatedPurchaseOrdersProvider);
  final orders = page.items;

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
