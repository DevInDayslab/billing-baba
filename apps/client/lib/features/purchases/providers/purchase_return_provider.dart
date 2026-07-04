import 'package:billing_baba/features/purchases/application/purchase_error_mapper.dart';
import 'package:billing_baba/features/purchases/application/purchase_service.dart';
import 'package:billing_baba/features/purchases/models/purchase_bill_model.dart';
import 'package:billing_baba/features/purchases/models/purchase_return_model.dart';
import 'package:billing_baba/features/purchases/models/requests/purchase_requests.dart';
import 'package:billing_baba/features/purchases/purchase_constants.dart';
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

class PurchaseReturnSummaryData {
  const PurchaseReturnSummaryData({
    required this.totalAmount,
    required this.balance,
  });

  final double totalAmount;
  final double balance;
}

PurchaseBillStatus? _statusFromFilterLabel(String label) => switch (label) {
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

PurchaseDocumentListQuery _buildListQuery(PurchaseReturnFiltersState filters) {
  final dateRange = _resolveTimeRange(
    filters.timeRangeOption,
    filters.customDateRange,
  );

  return PurchaseDocumentListQuery(
    page: filters.currentPage,
    limit: purchaseReturnPageSize,
    documentType: PurchaseDocumentType.purchaseReturn.apiValue,
    status: _documentStatusFromFilterLabel(filters.selectedStatus),
    from: dateRange?.start.toUtc().toIso8601String(),
    to: dateRange?.end.toUtc().toIso8601String(),
    q: filters.searchQuery.trim().isEmpty ? null : filters.searchQuery.trim(),
  );
}

List<PurchaseReturnModel> _applyClientFilters(
  List<PurchaseReturnModel> returns,
  PurchaseReturnFiltersState filters,
) {
  final statusFilter = _statusFromFilterLabel(filters.selectedStatus);

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
    return true;
  }).toList();
}

@Riverpod(keepAlive: true)
class PurchaseReturns extends _$PurchaseReturns {
  @override
  Future<PaginatedPurchaseReturns> build() async {
    ref.watch(purchaseReturnFiltersProvider);
    return _fetchPage();
  }

  Future<PaginatedPurchaseReturns> _fetchPage() async {
    final filters = ref.read(purchaseReturnFiltersProvider);
    final service = await ref.read(purchaseServiceProvider.future);
    final page = await service.fetchReturnsPage(_buildListQuery(filters));

    return PaginatedPurchaseReturns(
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

  Future<String?> finalizeReturn(String documentId, {String? godownId}) async {
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
class PurchaseReturnFilters extends _$PurchaseReturnFilters {
  @override
  PurchaseReturnFiltersState build() => const PurchaseReturnFiltersState();

  void setTimeRange(String label) {
    state = state.copyWith(
      timeRangeOption: TimeRangeOptionX.fromLabel(label),
      currentPage: 1,
    );
    ref.invalidate(purchaseReturnsProvider);
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
    ref.invalidate(purchaseReturnsProvider);
  }

  void setTransaction(String transaction) {
    state = state.copyWith(selectedTransaction: transaction, currentPage: 1);
    ref.invalidate(purchaseReturnsProvider);
  }

  void setFirm(String firm) {
    state = state.copyWith(selectedFirm: firm, currentPage: 1);
    ref.invalidate(purchaseReturnsProvider);
  }

  void setUser(String user) {
    state = state.copyWith(selectedUser: user, currentPage: 1);
    ref.invalidate(purchaseReturnsProvider);
  }

  void setGodown(String godown) {
    state = state.copyWith(selectedGodown: godown, currentPage: 1);
    ref.invalidate(purchaseReturnsProvider);
  }

  void setPayment(String payment) {
    state = state.copyWith(selectedPayment: payment, currentPage: 1);
    ref.invalidate(purchaseReturnsProvider);
  }

  void setStatus(String status) {
    state = state.copyWith(selectedStatus: status, currentPage: 1);
    ref.invalidate(purchaseReturnsProvider);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query, currentPage: 1);
    ref.invalidate(purchaseReturnsProvider);
  }

  void setPage(int page) {
    state = state.copyWith(currentPage: page);
    ref.invalidate(purchaseReturnsProvider);
  }
}

@riverpod
PaginatedPurchaseReturns paginatedPurchaseReturns(Ref ref) {
  final returnsAsync = ref.watch(purchaseReturnsProvider);
  return returnsAsync.maybeWhen(
    data: (page) => page,
    orElse: () => const PaginatedPurchaseReturns(
      items: [],
      currentPage: 1,
      totalPages: 1,
      totalItems: 0,
    ),
  );
}

@riverpod
PurchaseReturnSummaryData purchaseReturnSummary(Ref ref) {
  final page = ref.watch(paginatedPurchaseReturnsProvider);
  final returns = page.items;

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
