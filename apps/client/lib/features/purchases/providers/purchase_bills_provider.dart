import 'package:billing_baba/features/purchases/models/purchase_bill_model.dart';
import 'package:billing_baba/features/sales/providers/sale_invoices_provider.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'purchase_bills_provider.g.dart';

const purchaseBillsPageSize = 10;

class PurchaseBillFiltersState {
  const PurchaseBillFiltersState({
    this.timeRangeOption = TimeRangeOption.thisMonth,
    this.customDateRange,
    this.selectedFirm = 'All Firms',
    this.selectedUser = 'All Users',
    this.selectedStatus = 'All Status',
    this.currentPage = 1,
  });

  final TimeRangeOption timeRangeOption;
  final DateTimeRange? customDateRange;
  final String selectedFirm;
  final String selectedUser;
  final String selectedStatus;
  final int currentPage;

  String get timeRangeLabel => timeRangeOption.label;

  PurchaseBillFiltersState copyWith({
    TimeRangeOption? timeRangeOption,
    DateTimeRange? customDateRange,
    bool clearCustomDateRange = false,
    String? selectedFirm,
    String? selectedUser,
    String? selectedStatus,
    int? currentPage,
  }) {
    return PurchaseBillFiltersState(
      timeRangeOption: timeRangeOption ?? this.timeRangeOption,
      customDateRange: clearCustomDateRange
          ? null
          : (customDateRange ?? this.customDateRange),
      selectedFirm: selectedFirm ?? this.selectedFirm,
      selectedUser: selectedUser ?? this.selectedUser,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

class PurchaseBillSummaryData {
  const PurchaseBillSummaryData({
    required this.paidAmount,
    required this.unpaidAmount,
    required this.overdueAmount,
    required this.totalAmount,
  });

  final double paidAmount;
  final double unpaidAmount;
  final double overdueAmount;
  final double totalAmount;
}

class PaginatedPurchaseBills {
  const PaginatedPurchaseBills({
    required this.items,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
  });

  final List<PurchaseBillModel> items;
  final int currentPage;
  final int totalPages;
  final int totalItems;
}

List<PurchaseBillModel> _mockPurchaseBills() {
  const parties = [
    'KK INDUSTRIES',
    'Sharma Traders',
    'Patel Electronics',
    'Gupta General Store',
    'Mehta Hardware',
    'Singh & Sons',
    'Kumar Agencies',
    'Reddy Mart',
    'Joshi Distributors',
    'Verma Enterprises',
  ];

  const paymentTypes = ['Cash', 'Credit', 'UPI', 'Cheque'];

  PurchaseBillModel buildBill({
    required int id,
    required DateTime date,
    required PurchaseBillStatus status,
    int partyIndex = 0,
    double? amount,
    double? balanceDue,
    DateTime? dueDate,
  }) {
    final billAmount = amount ?? (5000 + (id * 750) % 25000).toDouble();
    final balance =
        balanceDue ??
        switch (status) {
          PurchaseBillStatus.paid => 0.0,
          PurchaseBillStatus.cancelled => 0.0,
          PurchaseBillStatus.unpaid => billAmount,
          PurchaseBillStatus.overdue => billAmount,
          PurchaseBillStatus.partiallyPaid =>
            (billAmount * 0.2).roundToDouble(),
        };

    return PurchaseBillModel(
      id: '$id',
      invoiceNo: 'PB-${1000 + id}',
      date: date,
      partyName: parties[partyIndex % parties.length],
      paymentType: paymentTypes[id % paymentTypes.length],
      status: status,
      amount: billAmount,
      balanceDue: balance,
      dueDate: dueDate ?? date.add(const Duration(days: 15)),
      user: id % 3 == 0 ? 'Admin' : 'Staff',
      firm: id % 2 == 0 ? 'Main Firm' : 'Branch Firm',
    );
  }

  return [
    buildBill(
      id: 1,
      date: DateTime(2026, 7, 2, 18, 23),
      status: PurchaseBillStatus.partiallyPaid,
      partyIndex: 0,
      amount: 25000,
      balanceDue: 5000,
      dueDate: DateTime(2026, 7, 2),
    ),
    buildBill(
      id: 2,
      date: DateTime(2026, 7, 5),
      status: PurchaseBillStatus.paid,
      partyIndex: 1,
    ),
    buildBill(
      id: 3,
      date: DateTime(2026, 7, 8),
      status: PurchaseBillStatus.unpaid,
      partyIndex: 2,
    ),
    buildBill(
      id: 4,
      date: DateTime(2026, 6, 20),
      status: PurchaseBillStatus.overdue,
      partyIndex: 3,
    ),
    buildBill(
      id: 5,
      date: DateTime(2026, 7, 12),
      status: PurchaseBillStatus.partiallyPaid,
      partyIndex: 4,
    ),
    buildBill(
      id: 6,
      date: DateTime(2026, 7, 15),
      status: PurchaseBillStatus.paid,
      partyIndex: 5,
    ),
    buildBill(
      id: 7,
      date: DateTime(2026, 7, 18),
      status: PurchaseBillStatus.unpaid,
      partyIndex: 6,
    ),
    buildBill(
      id: 8,
      date: DateTime(2026, 7, 22),
      status: PurchaseBillStatus.cancelled,
      partyIndex: 7,
    ),
    buildBill(
      id: 9,
      date: DateTime(2026, 7, 25),
      status: PurchaseBillStatus.paid,
      partyIndex: 8,
    ),
    buildBill(
      id: 10,
      date: DateTime(2026, 7, 28),
      status: PurchaseBillStatus.partiallyPaid,
      partyIndex: 9,
    ),
  ];
}

PurchaseBillStatus? _statusFromFilterLabel(String label) => switch (label) {
  'Paid' => PurchaseBillStatus.paid,
  'Unpaid' => PurchaseBillStatus.unpaid,
  'Partial' => PurchaseBillStatus.partiallyPaid,
  'Overdue' => PurchaseBillStatus.overdue,
  'Cancelled' => PurchaseBillStatus.cancelled,
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
class PurchaseBills extends _$PurchaseBills {
  @override
  List<PurchaseBillModel> build() => _mockPurchaseBills();

  void addBill(PurchaseBillModel bill) {
    state = [bill, ...state];
  }
}

@riverpod
class PurchaseBillFilters extends _$PurchaseBillFilters {
  @override
  PurchaseBillFiltersState build() => const PurchaseBillFiltersState();

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

  void setPage(int page) {
    state = state.copyWith(currentPage: page);
  }
}

@riverpod
List<PurchaseBillModel> filteredPurchaseBills(Ref ref) {
  final bills = ref.watch(purchaseBillsProvider);
  final filters = ref.watch(purchaseBillFiltersProvider);

  final dateRange = _resolveTimeRange(
    filters.timeRangeOption,
    filters.customDateRange,
  );
  final statusFilter = _statusFromFilterLabel(filters.selectedStatus);

  return bills.where((bill) {
    if (statusFilter != null && bill.status != statusFilter) {
      return false;
    }
    if (filters.selectedUser != 'All Users' &&
        bill.user != filters.selectedUser) {
      return false;
    }
    if (filters.selectedFirm != 'All Firms' &&
        bill.firm != filters.selectedFirm) {
      return false;
    }
    if (dateRange != null &&
        !_isWithinRange(bill.date, dateRange.start, dateRange.end)) {
      return false;
    }
    return true;
  }).toList();
}

@riverpod
PaginatedPurchaseBills paginatedPurchaseBills(Ref ref) {
  final filtered = ref.watch(filteredPurchaseBillsProvider);
  final filters = ref.watch(purchaseBillFiltersProvider);

  final totalItems = filtered.length;
  final totalPages = totalItems == 0
      ? 1
      : (totalItems / purchaseBillsPageSize).ceil();
  final currentPage = filters.currentPage.clamp(1, totalPages);
  final startIndex = (currentPage - 1) * purchaseBillsPageSize;
  final endIndex = (startIndex + purchaseBillsPageSize).clamp(0, totalItems);

  return PaginatedPurchaseBills(
    items: filtered.sublist(startIndex, endIndex),
    currentPage: currentPage,
    totalPages: totalPages,
    totalItems: totalItems,
  );
}

@riverpod
PurchaseBillSummaryData purchaseBillSummary(Ref ref) {
  final bills = ref.watch(filteredPurchaseBillsProvider);

  var paidAmount = 0.0;
  var unpaidAmount = 0.0;
  var overdueAmount = 0.0;
  var totalAmount = 0.0;

  for (final bill in bills) {
    totalAmount += bill.amount;
    paidAmount += bill.paidAmount;
    if (bill.status == PurchaseBillStatus.overdue) {
      overdueAmount += bill.balanceDue;
    } else if (bill.status == PurchaseBillStatus.unpaid ||
        bill.status == PurchaseBillStatus.partiallyPaid) {
      unpaidAmount += bill.balanceDue;
    }
  }

  return PurchaseBillSummaryData(
    paidAmount: paidAmount,
    unpaidAmount: unpaidAmount,
    overdueAmount: overdueAmount,
    totalAmount: totalAmount,
  );
}
