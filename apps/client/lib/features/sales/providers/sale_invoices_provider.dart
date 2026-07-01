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

List<SaleInvoiceModel> _mockSaleInvoices() {
  const parties = [
    'Sharma Traders',
    'Patel Electronics',
    'Gupta General Store',
    'Mehta Hardware',
    'Singh & Sons',
    'Kumar Agencies',
    'Reddy Mart',
    'Joshi Distributors',
    'Verma Enterprises',
    'Agarwal Textiles',
    'Bansal Pharma',
    'Chopra Foods',
    'Desai Motors',
    'Fernandes Exports',
    'Iyer Stationery',
  ];

  const paymentTypes = ['Cash', 'Credit', 'UPI', 'Cheque'];

  SaleInvoiceModel buildInvoice({
    required int id,
    required DateTime date,
    required SaleInvoiceStatus status,
    int partyIndex = 0,
  }) {
    final amount = 3000 + (id * 750) % 25000;
    return SaleInvoiceModel(
      id: '$id',
      invoiceNo: 'SI-${1000 + id}',
      date: date,
      partyName: parties[partyIndex % parties.length],
      transactionType: 'Sale',
      paymentType: paymentTypes[id % paymentTypes.length],
      status: status,
      amount: amount.toDouble(),
      balance: switch (status) {
        SaleInvoiceStatus.paid => 0.0,
        SaleInvoiceStatus.cancelled => 0.0,
        SaleInvoiceStatus.unpaid => amount.toDouble(),
        SaleInvoiceStatus.overdue => amount.toDouble(),
        SaleInvoiceStatus.partiallyPaid => (amount * 0.4).roundToDouble(),
      },
      user: id % 3 == 0 ? 'Admin' : 'Staff',
      godown: id % 4 == 0 ? 'Main Location' : 'Warehouse B',
    );
  }

  final baseInvoices = List.generate(35, (index) {
    final id = index + 1;
    final monthCycle = [3, 4, 5, 6, 7];
    final month = monthCycle[index % monthCycle.length];
    final day = (index % 28) + 1;
    const statuses = SaleInvoiceStatus.values;

    return buildInvoice(
      id: id,
      date: DateTime(2026, month, day),
      status: statuses[index % statuses.length],
      partyIndex: index,
    );
  });

  final mayJuneInvoices = <SaleInvoiceModel>[
    buildInvoice(
      id: 36,
      date: DateTime(2026, 5, 3),
      status: SaleInvoiceStatus.paid,
    ),
    buildInvoice(
      id: 37,
      date: DateTime(2026, 5, 8),
      status: SaleInvoiceStatus.unpaid,
      partyIndex: 1,
    ),
    buildInvoice(
      id: 38,
      date: DateTime(2026, 5, 14),
      status: SaleInvoiceStatus.overdue,
      partyIndex: 2,
    ),
    buildInvoice(
      id: 39,
      date: DateTime(2026, 5, 19),
      status: SaleInvoiceStatus.partiallyPaid,
      partyIndex: 3,
    ),
    buildInvoice(
      id: 40,
      date: DateTime(2026, 5, 24),
      status: SaleInvoiceStatus.cancelled,
      partyIndex: 4,
    ),
    buildInvoice(
      id: 41,
      date: DateTime(2026, 5, 29),
      status: SaleInvoiceStatus.paid,
      partyIndex: 5,
    ),
    buildInvoice(
      id: 42,
      date: DateTime(2026, 6, 2),
      status: SaleInvoiceStatus.unpaid,
      partyIndex: 6,
    ),
    buildInvoice(
      id: 43,
      date: DateTime(2026, 6, 11),
      status: SaleInvoiceStatus.partiallyPaid,
      partyIndex: 7,
    ),
    buildInvoice(
      id: 44,
      date: DateTime(2026, 6, 18),
      status: SaleInvoiceStatus.overdue,
      partyIndex: 8,
    ),
    buildInvoice(
      id: 45,
      date: DateTime(2026, 6, 27),
      status: SaleInvoiceStatus.paid,
      partyIndex: 9,
    ),
  ];

  return [...baseInvoices, ...mayJuneInvoices];
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

@riverpod
class SaleInvoices extends _$SaleInvoices {
  @override
  List<SaleInvoiceModel> build() => _mockSaleInvoices();

  void addInvoice(SaleInvoiceModel invoice) {
    state = [invoice, ...state];
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
  final invoices = ref.watch(saleInvoicesProvider);
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
