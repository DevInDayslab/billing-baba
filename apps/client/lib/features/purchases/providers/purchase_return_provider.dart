import 'package:billing_baba/features/purchases/models/debit_note_form_model.dart';
import 'package:billing_baba/features/purchases/models/purchase_bill_model.dart';
import 'package:billing_baba/features/purchases/models/purchase_return_model.dart';
import 'package:billing_baba/features/purchases/providers/debit_note_form_provider.dart';
import 'package:billing_baba/features/sales/providers/sale_invoices_provider.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'purchase_return_provider.g.dart';

const purchaseReturnPageSize = 10;

class PurchaseReturnFiltersState {
  const PurchaseReturnFiltersState({
    this.timeRangeOption = TimeRangeOption.thisMonth,
    this.customDateRange,
    this.selectedTransaction = 'Debit Note',
    this.selectedFirm = 'All Firms',
    this.selectedUser = 'All Users',
    this.selectedGodown = 'All Godown',
    this.selectedPayment = 'All Payment',
    this.selectedStatus = 'All Status',
    this.searchQuery = '',
    this.currentPage = 1,
  });

  final TimeRangeOption timeRangeOption;
  final DateTimeRange? customDateRange;
  final String selectedTransaction;
  final String selectedFirm;
  final String selectedUser;
  final String selectedGodown;
  final String selectedPayment;
  final String selectedStatus;
  final String searchQuery;
  final int currentPage;

  String get timeRangeLabel => timeRangeOption.label;

  PurchaseReturnFiltersState copyWith({
    TimeRangeOption? timeRangeOption,
    DateTimeRange? customDateRange,
    bool clearCustomDateRange = false,
    String? selectedTransaction,
    String? selectedFirm,
    String? selectedUser,
    String? selectedGodown,
    String? selectedPayment,
    String? selectedStatus,
    String? searchQuery,
    int? currentPage,
  }) {
    return PurchaseReturnFiltersState(
      timeRangeOption: timeRangeOption ?? this.timeRangeOption,
      customDateRange: clearCustomDateRange
          ? null
          : (customDateRange ?? this.customDateRange),
      selectedTransaction: selectedTransaction ?? this.selectedTransaction,
      selectedFirm: selectedFirm ?? this.selectedFirm,
      selectedUser: selectedUser ?? this.selectedUser,
      selectedGodown: selectedGodown ?? this.selectedGodown,
      selectedPayment: selectedPayment ?? this.selectedPayment,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      searchQuery: searchQuery ?? this.searchQuery,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

class PaginatedPurchaseReturns {
  const PaginatedPurchaseReturns({
    required this.items,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
  });

  final List<PurchaseReturnModel> items;
  final int currentPage;
  final int totalPages;
  final int totalItems;
}

class PurchaseReturnSummaryData {
  const PurchaseReturnSummaryData({
    required this.totalAmount,
    required this.balance,
  });

  final double totalAmount;
  final double balance;
}

List<PurchaseReturnModel> _mockPurchaseReturns() {
  return [
    PurchaseReturnModel(
      id: '1',
      debitNoteNo: '1',
      date: DateTime(2026, 7, 2, 19, 11),
      partyName: 'KK INDUSTRIES',
      categoryName: '',
      type: 'Debit Note',
      status: PurchaseBillStatus.unpaid,
      total: 50,
      receivedPaid: 0,
      balance: 50,
      dueDate: DateTime(2026, 7, 2),
      paymentType: 'Cash',
    ),
  ];
}

PurchaseReturnModel _fromSavedDebitNote(SavedDebitNote note) {
  final date = note.returnDate ?? note.savedAt;
  final time = note.returnTime;
  final dateTime = time != null
      ? DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        )
      : date;

  return PurchaseReturnModel(
    id: note.id,
    debitNoteNo: note.returnNo,
    date: dateTime,
    partyName: note.party,
    categoryName: '',
    type: 'Debit Note',
    status: note.status,
    total: note.total,
    receivedPaid: note.paymentAmount,
    balance: note.balance,
    dueDate: date.add(const Duration(days: 15)),
    paymentType: note.paymentType,
    godown: note.godown,
  );
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
class PurchaseReturns extends _$PurchaseReturns {
  @override
  List<PurchaseReturnModel> build() => _mockPurchaseReturns();
}

@riverpod
class PurchaseReturnFilters extends _$PurchaseReturnFilters {
  @override
  PurchaseReturnFiltersState build() => const PurchaseReturnFiltersState();

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

  void setTransaction(String transaction) {
    state = state.copyWith(selectedTransaction: transaction, currentPage: 1);
  }

  void setFirm(String firm) {
    state = state.copyWith(selectedFirm: firm, currentPage: 1);
  }

  void setUser(String user) {
    state = state.copyWith(selectedUser: user, currentPage: 1);
  }

  void setGodown(String godown) {
    state = state.copyWith(selectedGodown: godown, currentPage: 1);
  }

  void setPayment(String payment) {
    state = state.copyWith(selectedPayment: payment, currentPage: 1);
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
List<PurchaseReturnModel> allPurchaseReturns(Ref ref) {
  final mock = ref.watch(purchaseReturnsProvider);
  final saved = ref
      .watch(savedDebitNotesProvider)
      .map(_fromSavedDebitNote)
      .toList();
  return [...saved, ...mock];
}

@riverpod
List<PurchaseReturnModel> filteredPurchaseReturns(Ref ref) {
  final returns = ref.watch(allPurchaseReturnsProvider);
  final filters = ref.watch(purchaseReturnFiltersProvider);

  final dateRange = _resolveTimeRange(
    filters.timeRangeOption,
    filters.customDateRange,
  );
  final statusFilter = _statusFromFilterLabel(filters.selectedStatus);
  final query = filters.searchQuery.trim().toLowerCase();

  return returns.where((item) {
    if (statusFilter != null && item.status != statusFilter) {
      return false;
    }
    if (filters.selectedUser != 'All Users' &&
        item.user != filters.selectedUser) {
      return false;
    }
    if (filters.selectedFirm != 'All Firms' &&
        item.firm != filters.selectedFirm) {
      return false;
    }
    if (filters.selectedGodown != 'All Godown' &&
        item.godown != filters.selectedGodown) {
      return false;
    }
    if (filters.selectedPayment != 'All Payment' &&
        item.paymentType != filters.selectedPayment) {
      return false;
    }
    if (dateRange != null &&
        !_isWithinRange(item.date, dateRange.start, dateRange.end)) {
      return false;
    }
    if (query.isNotEmpty) {
      final matchesParty = item.partyName.toLowerCase().contains(query);
      final matchesRef = item.debitNoteNo.toLowerCase().contains(query);
      final matchesCategory = item.categoryName.toLowerCase().contains(query);
      if (!matchesParty && !matchesRef && !matchesCategory) {
        return false;
      }
    }
    return true;
  }).toList();
}

@riverpod
PaginatedPurchaseReturns paginatedPurchaseReturns(Ref ref) {
  final filtered = ref.watch(filteredPurchaseReturnsProvider);
  final filters = ref.watch(purchaseReturnFiltersProvider);

  final totalItems = filtered.length;
  final totalPages = totalItems == 0
      ? 1
      : (totalItems / purchaseReturnPageSize).ceil();
  final currentPage = filters.currentPage.clamp(1, totalPages);
  final startIndex = (currentPage - 1) * purchaseReturnPageSize;
  final endIndex = (startIndex + purchaseReturnPageSize).clamp(0, totalItems);

  return PaginatedPurchaseReturns(
    items: filtered.sublist(startIndex, endIndex),
    currentPage: currentPage,
    totalPages: totalPages,
    totalItems: totalItems,
  );
}

@riverpod
PurchaseReturnSummaryData purchaseReturnSummary(Ref ref) {
  final returns = ref.watch(filteredPurchaseReturnsProvider);

  var totalAmount = 0.0;
  var balance = 0.0;

  for (final item in returns) {
    totalAmount += item.total;
    balance += item.balance;
  }

  return PurchaseReturnSummaryData(
    totalAmount: totalAmount,
    balance: balance,
  );
}
