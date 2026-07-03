import 'package:billing_baba/features/sales/application/sales_service.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_model.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sale_invoices_provider.g.dart';

const saleInvoicesPageSize = 10;

enum TimeRangeOption {
  allTime,
  today,
  thisWeek,
  thisMonth,
  thisYear,
  custom,
}

extension TimeRangeOptionX on TimeRangeOption {
  String get label => switch (this) {
    TimeRangeOption.allTime => 'All Time',
    TimeRangeOption.today => 'Today',
    TimeRangeOption.thisWeek => 'This Week',
    TimeRangeOption.thisMonth => 'This Month',
    TimeRangeOption.thisYear => 'This Year',
    TimeRangeOption.custom => 'Custom',
  };

  static TimeRangeOption fromLabel(String label) => switch (label) {
    'Today' => TimeRangeOption.today,
    'This Week' => TimeRangeOption.thisWeek,
    'This Month' => TimeRangeOption.thisMonth,
    'This Year' => TimeRangeOption.thisYear,
    'Custom' => TimeRangeOption.custom,
    _ => TimeRangeOption.allTime,
  };
}

class SaleInvoiceFiltersState {
  const SaleInvoiceFiltersState({
    this.timeRangeOption = TimeRangeOption.allTime,
    this.customDateRange,
    this.selectedUser = 'All Users',
    this.selectedGodown = 'All Godown',
    this.selectedStatus = 'All Status',
    this.currentPage = 1,
  });

  final TimeRangeOption timeRangeOption;
  final DateTimeRange? customDateRange;
  final String selectedUser;
  final String selectedGodown;
  final String selectedStatus;
  final int currentPage;

  String get timeRangeLabel => timeRangeOption.label;

  SaleInvoiceFiltersState copyWith({
    TimeRangeOption? timeRangeOption,
    DateTimeRange? customDateRange,
    bool clearCustomDateRange = false,
    String? selectedUser,
    String? selectedGodown,
    String? selectedStatus,
    int? currentPage,
  }) {
    return SaleInvoiceFiltersState(
      timeRangeOption: timeRangeOption ?? this.timeRangeOption,
      customDateRange: clearCustomDateRange
          ? null
          : (customDateRange ?? this.customDateRange),
      selectedUser: selectedUser ?? this.selectedUser,
      selectedGodown: selectedGodown ?? this.selectedGodown,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

class SaleInvoiceSummaryData {
  const SaleInvoiceSummaryData({
    required this.totalSalesAmount,
    required this.receivedAmount,
    required this.balanceAmount,
  });

  final double totalSalesAmount;
  final double receivedAmount;
  final double balanceAmount;
}

class PaginatedSaleInvoices {
  const PaginatedSaleInvoices({
    required this.items,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
  });

  final List<SaleInvoiceModel> items;
  final int currentPage;
  final int totalPages;
  final int totalItems;
}

SaleInvoiceStatus? _statusFromFilterLabel(String label) => switch (label) {
  'Paid' => SaleInvoiceStatus.paid,
  'Unpaid' => SaleInvoiceStatus.unpaid,
  'Partial' => SaleInvoiceStatus.partiallyPaid,
  'Overdue' => SaleInvoiceStatus.overdue,
  'Cancelled' => SaleInvoiceStatus.cancelled,
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

@Riverpod(keepAlive: true)
class SaleInvoices extends _$SaleInvoices {
  @override
  Future<List<SaleInvoiceModel>> build() async {
    final service = await ref.watch(salesServiceProvider.future);
    return service.fetchInvoices();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final service = await ref.read(salesServiceProvider.future);
      return service.fetchInvoices();
    });
  }
}

@riverpod
class SaleInvoiceFilters extends _$SaleInvoiceFilters {
  @override
  SaleInvoiceFiltersState build() => const SaleInvoiceFiltersState();

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

  void setStatus(String status) {
    state = state.copyWith(selectedStatus: status, currentPage: 1);
  }

  void setPage(int page) {
    state = state.copyWith(currentPage: page);
  }
}

@riverpod
List<SaleInvoiceModel> filteredSaleInvoices(Ref ref) {
  final invoicesAsync = ref.watch(saleInvoicesProvider);
  final invoices = invoicesAsync.value ?? const <SaleInvoiceModel>[];
  final filters = ref.watch(saleInvoiceFiltersProvider);

  final dateRange = _resolveTimeRange(
    filters.timeRangeOption,
    filters.customDateRange,
  );
  final statusFilter = _statusFromFilterLabel(filters.selectedStatus);

  return invoices.where((invoice) {
    if (statusFilter != null && invoice.status != statusFilter) {
      return false;
    }
    if (filters.selectedUser != 'All Users' &&
        invoice.user != filters.selectedUser) {
      return false;
    }
    if (filters.selectedGodown != 'All Godown' &&
        invoice.godown != filters.selectedGodown) {
      return false;
    }
    if (dateRange != null &&
        !_isWithinRange(invoice.date, dateRange.start, dateRange.end)) {
      return false;
    }
    return true;
  }).toList();
}

@riverpod
PaginatedSaleInvoices paginatedSaleInvoices(Ref ref) {
  final filtered = ref.watch(filteredSaleInvoicesProvider);
  final filters = ref.watch(saleInvoiceFiltersProvider);

  final totalItems = filtered.length;
  final totalPages = totalItems == 0
      ? 1
      : (totalItems / saleInvoicesPageSize).ceil();
  final currentPage = filters.currentPage.clamp(1, totalPages);
  final startIndex = (currentPage - 1) * saleInvoicesPageSize;
  final endIndex = (startIndex + saleInvoicesPageSize).clamp(0, totalItems);

  return PaginatedSaleInvoices(
    items: filtered.sublist(startIndex, endIndex),
    currentPage: currentPage,
    totalPages: totalPages,
    totalItems: totalItems,
  );
}

@riverpod
class SaleInvoiceSummary extends _$SaleInvoiceSummary {
  @override
  SaleInvoiceSummaryData build() {
    final invoices = ref.watch(filteredSaleInvoicesProvider);
    final totalSalesAmount = invoices.fold<double>(
      0,
      (sum, invoice) => sum + invoice.amount,
    );
    final balanceAmount = invoices.fold<double>(
      0,
      (sum, invoice) => sum + invoice.balance,
    );
    final receivedAmount = totalSalesAmount - balanceAmount;

    return SaleInvoiceSummaryData(
      totalSalesAmount: totalSalesAmount,
      receivedAmount: receivedAmount,
      balanceAmount: balanceAmount,
    );
  }
}
