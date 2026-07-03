import 'package:billing_baba/features/purchases/models/purchase_order_model.dart';
import 'package:billing_baba/features/sales/providers/sale_invoices_provider.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'purchase_orders_provider.g.dart';

const purchaseOrdersPageSize = 10;

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

class PaginatedPurchaseOrders {
  const PaginatedPurchaseOrders({
    required this.items,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
  });

  final List<PurchaseOrderModel> items;
  final int currentPage;
  final int totalPages;
  final int totalItems;
}

List<PurchaseOrderModel> _mockPurchaseOrders() {
  return [
    PurchaseOrderModel(
      id: '1',
      orderNo: '2',
      date: DateTime(2025, 7, 2, 19, 9),
      partyName: 'KK INDUSTRIES',
      status: PurchaseOrderStatus.orderCompleted,
      amount: 22162.80,
      balanceDue: 22162.80,
      dueDate: DateTime(2025, 7, 2),
    ),
    PurchaseOrderModel(
      id: '2',
      orderNo: '1',
      date: DateTime(2025, 6, 28, 14, 30),
      partyName: 'Sharma Traders',
      status: PurchaseOrderStatus.open,
      amount: 15500,
      balanceDue: 15500,
      dueDate: DateTime(2025, 7, 15),
    ),
    PurchaseOrderModel(
      id: '3',
      orderNo: '3',
      date: DateTime(2025, 7, 5, 10, 0),
      partyName: 'Patel Electronics',
      status: PurchaseOrderStatus.partiallyReceived,
      amount: 8900,
      balanceDue: 4500,
      dueDate: DateTime(2025, 7, 20),
    ),
    PurchaseOrderModel(
      id: '4',
      orderNo: '4',
      date: DateTime(2025, 6, 15, 16, 45),
      partyName: 'Gupta General Store',
      status: PurchaseOrderStatus.cancelled,
      amount: 3200,
      balanceDue: 0,
      dueDate: DateTime(2025, 6, 30),
    ),
  ];
}

PurchaseOrderStatus? _statusFromFilterLabel(String label) => switch (label) {
  'Open' => PurchaseOrderStatus.open,
  'Order Completed' => PurchaseOrderStatus.orderCompleted,
  'Partially Received' => PurchaseOrderStatus.partiallyReceived,
  'Cancelled' => PurchaseOrderStatus.cancelled,
  _ => null,
};

DateTime _startOfDay(DateTime date) =>
    DateTime(date.year, date.month, date.day);

DateTime _endOfDay(DateTime date) =>
    DateTime(date.year, date.month, date.day, 23, 59, 59, 999);

bool _isWithinRange(DateTime date, DateTime start, DateTime end) {
  final normalized = _startOfDay(date);
  return !normalized.isBefore(_startOfDay(start)) &&
      !normalized.isAfter(_startOfDay(end));
}

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

@riverpod
class PurchaseOrders extends _$PurchaseOrders {
  @override
  List<PurchaseOrderModel> build() => _mockPurchaseOrders();

  void addOrder(PurchaseOrderModel order) {
    state = [order, ...state];
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

  void setFirm(String firm) {
    state = state.copyWith(selectedFirm: firm, currentPage: 1);
  }

  void setUser(String user) {
    state = state.copyWith(selectedUser: user, currentPage: 1);
  }

  void setStatus(String status) {
    state = state.copyWith(selectedStatus: status, currentPage: 1);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query, currentPage: 1);
  }

  void setPage(int page) {
    state = state.copyWith(currentPage: page);
  }
}

@riverpod
List<PurchaseOrderModel> filteredPurchaseOrders(Ref ref) {
  final orders = ref.watch(purchaseOrdersProvider);
  final filters = ref.watch(purchaseOrderFiltersProvider);

  final dateRange = _resolveTimeRange(
    filters.timeRangeOption,
    filters.customDateRange,
  );
  final statusFilter = _statusFromFilterLabel(filters.selectedStatus);
  final query = filters.searchQuery.trim().toLowerCase();

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
    if (dateRange != null &&
        !_isWithinRange(order.date, dateRange.start, dateRange.end)) {
      return false;
    }
    if (query.isNotEmpty) {
      final matchesParty = order.partyName.toLowerCase().contains(query);
      final matchesNo = order.orderNo.toLowerCase().contains(query);
      if (!matchesParty && !matchesNo) return false;
    }
    return true;
  }).toList();
}

@riverpod
PaginatedPurchaseOrders paginatedPurchaseOrders(Ref ref) {
  final filtered = ref.watch(filteredPurchaseOrdersProvider);
  final filters = ref.watch(purchaseOrderFiltersProvider);

  final totalItems = filtered.length;
  final totalPages = totalItems == 0
      ? 1
      : (totalItems / purchaseOrdersPageSize).ceil();
  final currentPage = filters.currentPage.clamp(1, totalPages);
  final startIndex = (currentPage - 1) * purchaseOrdersPageSize;
  final endIndex = (startIndex + purchaseOrdersPageSize).clamp(0, totalItems);

  return PaginatedPurchaseOrders(
    items: filtered.sublist(startIndex, endIndex),
    currentPage: currentPage,
    totalPages: totalPages,
    totalItems: totalItems,
  );
}
