import 'package:billing_baba/core/utils/debouncer.dart';
import 'package:billing_baba/features/purchases/application/purchase_error_mapper.dart';
import 'package:billing_baba/features/purchases/application/purchase_fa_service.dart';
import 'package:billing_baba/features/purchases/models/purchase_fa_model.dart';
import 'package:billing_baba/features/purchases/models/requests/purchase_fa_requests.dart';
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
    this.currentPage = 1,
  });

  final TimeRangeOption timeRangeOption;
  final DateTimeRange? customDateRange;
  final String selectedFirm;
  final String selectedUser;
  final String selectedStatus;
  final int currentPage;

  String get timeRangeLabel => timeRangeOption.label;

  PurchaseFaFiltersState copyWith({
    TimeRangeOption? timeRangeOption,
    DateTimeRange? customDateRange,
    bool clearCustomDateRange = false,
    String? selectedFirm,
    String? selectedUser,
    String? selectedStatus,
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

String? _statusFromFilterLabel(String label) => switch (label) {
  'Paid' => 'paid',
  'Unpaid' => 'unpaid',
  'Partially Paid' => 'partially_paid',
  'Partial' => 'partially_paid',
  'Overdue' => 'overdue',
  'Cancelled' => 'cancelled',
  _ => null,
};

PurchaseFaStatus? _paymentStatusFromFilterLabel(String label) =>
    switch (label) {
      'Paid' => PurchaseFaStatus.paid,
      'Unpaid' => PurchaseFaStatus.unpaid,
      'Partially Paid' => PurchaseFaStatus.partiallyPaid,
      'Partial' => PurchaseFaStatus.partiallyPaid,
      'Overdue' => PurchaseFaStatus.overdue,
      'Cancelled' => PurchaseFaStatus.cancelled,
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

PurchaseFaListQuery _buildListQuery(
  PurchaseFaFiltersState filters,
  String searchQuery,
) {
  final dateRange = _resolveTimeRange(
    filters.timeRangeOption,
    filters.customDateRange,
  );

  return PurchaseFaListQuery(
    page: filters.currentPage,
    limit: purchaseFaPageSize,
    status: _statusFromFilterLabel(filters.selectedStatus),
    from: dateRange?.start.toUtc().toIso8601String().split('T').first,
    to: dateRange?.end.toUtc().toIso8601String().split('T').first,
    q: searchQuery.trim().isEmpty ? null : searchQuery.trim(),
  );
}

List<PurchaseFaModel> _applyClientFilters(
  List<PurchaseFaModel> records,
  PurchaseFaFiltersState filters,
) {
  final paymentStatus = _paymentStatusFromFilterLabel(filters.selectedStatus);

  return records.where((record) {
    if (paymentStatus != null && record.status != paymentStatus) {
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
    return true;
  }).toList();
}

@riverpod
class PurchaseFaSearchQuery extends _$PurchaseFaSearchQuery {
  Debouncer? _debouncer;

  @override
  String build() {
    ref.onDispose(() => _debouncer?.dispose());
    return '';
  }

  void setQuery(String value) {
    _debouncer ??= Debouncer();
    _debouncer!.run(() => state = value);
  }
}

@Riverpod(keepAlive: true)
class PurchaseFa extends _$PurchaseFa {
  @override
  Future<PaginatedPurchaseFaRecords> build() async {
    ref.watch(purchaseFaFiltersProvider);
    ref.watch(purchaseFaSearchQueryProvider);
    return _fetchPage();
  }

  Future<PaginatedPurchaseFaRecords> _fetchPage() async {
    final filters = ref.read(purchaseFaFiltersProvider);
    final search = ref.read(purchaseFaSearchQueryProvider);
    final service = await ref.read(purchaseFaServiceProvider.future);
    final page = await service.fetchBatchesPage(
      _buildListQuery(filters, search),
    );

    final filteredItems = _applyClientFilters(page.items, filters);
    return PaginatedPurchaseFaRecords(
      items: filteredItems,
      currentPage: page.currentPage,
      totalPages: page.totalPages,
      totalItems: page.totalItems,
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetchPage);
  }

  Future<String?> deleteBatch(String batchId) async {
    final previous = state;
    final current = state.value;
    if (current != null) {
      state = AsyncData(
        PaginatedPurchaseFaRecords(
          items: current.items.where((item) => item.batchId != batchId).toList(),
          currentPage: current.currentPage,
          totalPages: current.totalPages,
          totalItems: current.totalItems - 1,
        ),
      );
    }

    try {
      final service = await ref.read(purchaseFaServiceProvider.future);
      await service.deleteBatch(batchId);
      await refresh();
      return null;
    } catch (error) {
      state = previous;
      return PurchaseErrorMapper.messageFor(error);
    }
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
    ref.invalidate(purchaseFaProvider);
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
    ref.invalidate(purchaseFaProvider);
  }

  void setFirm(String firm) {
    state = state.copyWith(selectedFirm: firm, currentPage: 1);
    ref.invalidate(purchaseFaProvider);
  }

  void setUser(String user) {
    state = state.copyWith(selectedUser: user, currentPage: 1);
    ref.invalidate(purchaseFaProvider);
  }

  void setStatus(String status) {
    state = state.copyWith(selectedStatus: status, currentPage: 1);
    ref.invalidate(purchaseFaProvider);
  }

  void setPage(int page) {
    state = state.copyWith(currentPage: page);
    ref.invalidate(purchaseFaProvider);
  }
}

@riverpod
PaginatedPurchaseFaRecords paginatedPurchaseFaRecords(Ref ref) {
  final faAsync = ref.watch(purchaseFaProvider);
  return faAsync.maybeWhen(
    data: (page) => page,
    orElse: () => const PaginatedPurchaseFaRecords(
      items: [],
      currentPage: 1,
      totalPages: 1,
      totalItems: 0,
    ),
  );
}
