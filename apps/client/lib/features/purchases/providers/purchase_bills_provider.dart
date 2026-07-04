import 'package:billing_baba/core/utils/debouncer.dart';
import 'package:billing_baba/features/purchases/application/purchase_error_mapper.dart';
import 'package:billing_baba/features/purchases/application/purchase_service.dart';
import 'package:billing_baba/features/purchases/models/purchase_bill_model.dart';
import 'package:billing_baba/features/purchases/models/requests/purchase_requests.dart';
import 'package:billing_baba/features/purchases/purchase_constants.dart';
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

PurchaseBillStatus? _paymentStatusFromFilterLabel(String label) =>
    switch (label) {
      'Paid' => PurchaseBillStatus.paid,
      'Unpaid' => PurchaseBillStatus.unpaid,
      'Partial' => PurchaseBillStatus.partiallyPaid,
      'Overdue' => PurchaseBillStatus.overdue,
      'Cancelled' => PurchaseBillStatus.cancelled,
      _ => null,
    };

String? _documentStatusFromFilterLabel(String label) => switch (label) {
  'Cancelled' => 'cancelled',
  'Draft' => 'draft',
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

PurchaseDocumentListQuery _buildListQuery(
  PurchaseBillFiltersState filters,
  String searchQuery,
) {
  final dateRange = _resolveTimeRange(
    filters.timeRangeOption,
    filters.customDateRange,
  );

  return PurchaseDocumentListQuery(
    page: filters.currentPage,
    limit: purchaseBillsPageSize,
    documentType: PurchaseDocumentType.purchaseBill.apiValue,
    status: _documentStatusFromFilterLabel(filters.selectedStatus),
    from: dateRange?.start.toUtc().toIso8601String(),
    to: dateRange?.end.toUtc().toIso8601String(),
    q: searchQuery.trim().isEmpty ? null : searchQuery.trim(),
  );
}

List<PurchaseBillModel> _applyClientFilters(
  List<PurchaseBillModel> bills,
  PurchaseBillFiltersState filters,
) {
  final paymentStatus = _paymentStatusFromFilterLabel(filters.selectedStatus);

  return bills.where((bill) {
    if (paymentStatus != null && bill.status != paymentStatus) {
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
    return true;
  }).toList();
}

@riverpod
class PurchaseBillSearchQuery extends _$PurchaseBillSearchQuery {
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
class PurchaseBills extends _$PurchaseBills {
  @override
  Future<PaginatedPurchaseBills> build() async {
    ref.watch(purchaseBillFiltersProvider);
    ref.watch(purchaseBillSearchQueryProvider);
    return _fetchPage();
  }

  Future<PaginatedPurchaseBills> _fetchPage() async {
    final filters = ref.read(purchaseBillFiltersProvider);
    final search = ref.read(purchaseBillSearchQueryProvider);
    final service = await ref.read(purchaseServiceProvider.future);
    final page = await service.fetchBillsPage(
      _buildListQuery(filters, search),
    );

    final filteredItems = _applyClientFilters(page.items, filters);
    return PaginatedPurchaseBills(
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

  Future<String?> deleteDraft(String documentId) async {
    final previous = state;
    final current = state.value;
    if (current != null) {
      state = AsyncData(
        PaginatedPurchaseBills(
          items: current.items.where((item) => item.id != documentId).toList(),
          currentPage: current.currentPage,
          totalPages: current.totalPages,
          totalItems: current.totalItems - 1,
        ),
      );
    }

    try {
      final service = await ref.read(purchaseServiceProvider.future);
      await service.deleteDraft(documentId);
      await refresh();
      return null;
    } catch (error) {
      state = previous;
      return PurchaseErrorMapper.messageFor(error);
    }
  }

  Future<String?> finalizeBill(String documentId, {String? godownId}) async {
    try {
      final service = await ref.read(purchaseServiceProvider.future);
      await service.finalizeDraft(documentId, godownId: godownId);
      await refresh();
      return null;
    } catch (error) {
      return PurchaseErrorMapper.messageFor(error);
    }
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
    ref.invalidate(purchaseBillsProvider);
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
    ref.invalidate(purchaseBillsProvider);
  }

  void setFirm(String firm) {
    state = state.copyWith(selectedFirm: firm, currentPage: 1);
    ref.invalidate(purchaseBillsProvider);
  }

  void setUser(String user) {
    state = state.copyWith(selectedUser: user, currentPage: 1);
    ref.invalidate(purchaseBillsProvider);
  }

  void setStatus(String status) {
    state = state.copyWith(selectedStatus: status, currentPage: 1);
    ref.invalidate(purchaseBillsProvider);
  }

  void setPage(int page) {
    state = state.copyWith(currentPage: page);
    ref.invalidate(purchaseBillsProvider);
  }
}

@riverpod
PaginatedPurchaseBills paginatedPurchaseBills(Ref ref) {
  final billsAsync = ref.watch(purchaseBillsProvider);
  return billsAsync.maybeWhen(
    data: (page) => page,
    orElse: () => const PaginatedPurchaseBills(
      items: [],
      currentPage: 1,
      totalPages: 1,
      totalItems: 0,
    ),
  );
}

@riverpod
PurchaseBillSummaryData purchaseBillSummary(Ref ref) {
  final page = ref.watch(paginatedPurchaseBillsProvider);
  final bills = page.items;

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
