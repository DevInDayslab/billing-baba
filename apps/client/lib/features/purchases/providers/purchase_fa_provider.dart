import 'package:billing_baba/features/purchases/models/purchase_fa_model.dart';
import 'package:billing_baba/features/sales/providers/sale_invoices_provider.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'purchase_fa_provider.g.dart';

const purchaseFaPageSize = 10;

class PurchaseFaFiltersState {
  const PurchaseFaFiltersState({
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

  PurchaseFaFiltersState copyWith({
    TimeRangeOption? timeRangeOption,
    DateTimeRange? customDateRange,
    bool clearCustomDateRange = false,
    String? selectedFirm,
    String? selectedUser,
    String? selectedStatus,
    String? searchQuery,
    int? currentPage,
  }) {
    return PurchaseFaFiltersState(
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

class PaginatedPurchaseFaRecords {
  const PaginatedPurchaseFaRecords({
    required this.items,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
  });

  final List<PurchaseFaModel> items;
  final int currentPage;
  final int totalPages;
  final int totalItems;
}

DateTime _endOfDay(DateTime date) =>
    DateTime(date.year, date.month, date.day, 23, 59, 59);

bool _isWithinRange(DateTime date, DateTime start, DateTime end) {
  return !date.isBefore(start) && !date.isAfter(end);
}

PurchaseFaStatus? _statusFromFilterLabel(String label) {
  return switch (label) {
    'Paid' => PurchaseFaStatus.paid,
    'Unpaid' => PurchaseFaStatus.unpaid,
    'Partially Paid' => PurchaseFaStatus.partiallyPaid,
    'Overdue' => PurchaseFaStatus.overdue,
    'Cancelled' => PurchaseFaStatus.cancelled,
    _ => null,
  };
}

DateTimeRange? _resolveTimeRange(
  TimeRangeOption option,
  DateTimeRange? custom,
) {
  final now = DateTime.now();
  return switch (option) {
    TimeRangeOption.allTime => null,
    TimeRangeOption.today => DateTimeRange(
      start: DateTime(now.year, now.month, now.day),
      end: _endOfDay(now),
    ),
    TimeRangeOption.thisWeek => DateTimeRange(
      start: DateTime(now.year, now.month, now.day - now.weekday + 1),
      end: _endOfDay(now),
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
class PurchaseFaRecords extends _$PurchaseFaRecords {
  @override
  List<PurchaseFaModel> build() => [];

  void addRecord(PurchaseFaModel record) {
    state = [record, ...state];
  }
}

@riverpod
class PurchaseFaFilters extends _$PurchaseFaFilters {
  @override
  PurchaseFaFiltersState build() => const PurchaseFaFiltersState();

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
List<PurchaseFaModel> filteredPurchaseFaRecords(Ref ref) {
  final records = ref.watch(purchaseFaRecordsProvider);
  final filters = ref.watch(purchaseFaFiltersProvider);

  final dateRange = _resolveTimeRange(
    filters.timeRangeOption,
    filters.customDateRange,
  );
  final statusFilter = _statusFromFilterLabel(filters.selectedStatus);
  final query = filters.searchQuery.trim().toLowerCase();

  return records.where((record) {
    if (statusFilter != null && record.status != statusFilter) {
      return false;
    }
    if (filters.selectedUser != 'All Users' &&
        record.user != filters.selectedUser) {
      return false;
    }
    if (filters.selectedFirm != 'All Firms' &&
        record.firm != filters.selectedFirm) {
      return false;
    }
    if (dateRange != null &&
        !_isWithinRange(record.date, dateRange.start, dateRange.end)) {
      return false;
    }
    if (query.isNotEmpty) {
      final matchesParty = record.partyName.toLowerCase().contains(query);
      final matchesNo = record.invoiceNo.toLowerCase().contains(query);
      if (!matchesParty && !matchesNo) return false;
    }
    return true;
  }).toList();
}

@riverpod
PaginatedPurchaseFaRecords paginatedPurchaseFaRecords(Ref ref) {
  final filtered = ref.watch(filteredPurchaseFaRecordsProvider);
  final filters = ref.watch(purchaseFaFiltersProvider);

  final totalItems = filtered.length;
  final totalPages = totalItems == 0
      ? 1
      : (totalItems / purchaseFaPageSize).ceil();
  final currentPage = filters.currentPage.clamp(1, totalPages);
  final startIndex = (currentPage - 1) * purchaseFaPageSize;
  final endIndex = (startIndex + purchaseFaPageSize).clamp(0, totalItems);

  return PaginatedPurchaseFaRecords(
    items: filtered.sublist(startIndex, endIndex),
    currentPage: currentPage,
    totalPages: totalPages,
    totalItems: totalItems,
  );
}
