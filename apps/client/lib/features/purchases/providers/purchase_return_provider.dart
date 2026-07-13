import 'package:billing_baba/features/export/utils/paginated_fetch.dart';
import 'package:billing_baba/features/purchases/application/purchase_error_mapper.dart';
import 'package:billing_baba/features/purchases/application/purchase_list_filter_utils.dart';
import 'package:billing_baba/features/purchases/application/purchase_service.dart';
import 'package:billing_baba/features/purchases/models/purchase_bill_model.dart';
import 'package:billing_baba/features/purchases/models/purchase_return_model.dart';
import 'package:billing_baba/features/purchases/models/requests/purchase_requests.dart';
import 'package:billing_baba/features/purchases/presentation/widgets/shared/purchase_shared_column_filters.dart';
import 'package:billing_baba/features/purchases/purchase_constants.dart';
import 'package:billing_baba/features/sales/providers/sale_invoices_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'purchase_return_provider.g.dart';

const purchaseReturnPageSize = 10;

/// One-shot success message shown on the purchase return list after save.
final purchaseReturnSaveSuccessMessageProvider =
    NotifierProvider<PurchaseReturnSaveSuccessMessage, String?>(
      PurchaseReturnSaveSuccessMessage.new,
    );

class PurchaseReturnSaveSuccessMessage extends Notifier<String?> {
  @override
  String? build() => null;

  void setMessage(String? value) => state = value;
}

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
    this.columnFilters = const PurchaseColumnFilterFields(),
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
  final PurchaseColumnFilterFields columnFilters;

  String get timeRangeLabel => timeRangeOption.label;

  bool get hasActiveFilters =>
      timeRangeOption != TimeRangeOption.thisMonth ||
      customDateRange != null ||
      selectedFirm != 'All Firms' ||
      selectedUser != 'All Users' ||
      selectedGodown != 'All Godown' ||
      selectedPayment != 'All Payment' ||
      selectedStatus != 'All Status' ||
      searchQuery.trim().isNotEmpty ||
      columnFilters.hasColumnFilters;

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
    PurchaseColumnFilterFields? columnFilters,
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
      columnFilters: columnFilters ?? this.columnFilters,
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
    limit: PaginatedFetch.defaultPageSize,
    documentType: PurchaseDocumentType.purchaseReturn.apiValue,
    status: _documentStatusFromFilterLabel(filters.selectedStatus),
    from: dateRange?.start.toUtc().toIso8601String(),
    to: dateRange?.end.toUtc().toIso8601String(),
  );
}

List<PurchaseReturnModel> _applyFilters(
  List<PurchaseReturnModel> returns,
  PurchaseReturnFiltersState filters,
) {
  final statusFilter = _statusFromFilterLabel(filters.selectedStatus);
  final columns = filters.columnFilters;
  final globalQuery = filters.searchQuery.trim().toLowerCase();

  return returns.where((item) {
    if (globalQuery.isNotEmpty &&
        !purchaseFilterMatchesGlobalSearch(globalQuery, [
          item.debitNoteNo,
          item.partyName,
          item.categoryName,
          item.type,
          item.paymentType,
        ])) {
      return false;
    }

    if (columns.columnDateRange != null &&
        !purchaseFilterIsWithinDateRange(item.date, columns.columnDateRange!)) {
      return false;
    }

    if (!purchaseFilterMatchesText(columns.documentNoFilter, item.debitNoteNo)) {
      return false;
    }

    if (!purchaseFilterMatchesParty(columns.selectedParty, item.partyName)) {
      return false;
    }

    if (!purchaseFilterMatchesOption(
      columns.selectedCategory,
      'All Categories',
      item.categoryName,
    )) {
      return false;
    }

    if (!purchaseFilterMatchesOption(
      columns.selectedType,
      'All Types',
      item.type,
    )) {
      return false;
    }

    if (!purchaseFilterMatchesNumericFilter(item.total, columns.amountFilter)) {
      return false;
    }

    if (!purchaseFilterMatchesNumericFilter(
      item.receivedPaid,
      columns.receivedPaidFilter,
    )) {
      return false;
    }

    if (!purchaseFilterMatchesNumericFilter(
      item.balance,
      columns.balanceFilter,
    )) {
      return false;
    }

    if (columns.dueDateRange != null &&
        !purchaseFilterIsWithinDateRange(item.dueDate, columns.dueDateRange!)) {
      return false;
    }

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

PaginatedPurchaseReturns _paginateFilteredReturns(
  List<PurchaseReturnModel> filtered,
  int currentPage,
) {
  final slice = purchaseFilterPaginate(
    filtered,
    currentPage,
    purchaseReturnPageSize,
  );
  return PaginatedPurchaseReturns(
    items: slice.items,
    currentPage: slice.currentPage,
    totalPages: slice.totalPages,
    totalItems: slice.totalItems,
  );
}

PaginatedPurchaseReturns _allReturnsPage(List<PurchaseReturnModel> allReturns) {
  return PaginatedPurchaseReturns(
    items: allReturns,
    currentPage: 1,
    totalPages: 1,
    totalItems: allReturns.length,
  );
}

List<PurchaseReturnModel> _allReturnsFromAsync(
  AsyncValue<PaginatedPurchaseReturns> returnsAsync,
) {
  return returnsAsync.when(
    data: (page) => page.items,
    loading: () => const [],
    error: (_, _) => const [],
  );
}

@Riverpod(keepAlive: true)
class PurchaseReturns extends _$PurchaseReturns {
  @override
  Future<PaginatedPurchaseReturns> build() async {
    ref.watch(
      purchaseReturnFiltersProvider.select(
        (filters) => (filters.timeRangeOption, filters.customDateRange),
      ),
    );
    final allReturns = await _fetchAllReturns();
    return _allReturnsPage(allReturns);
  }

  Future<List<PurchaseReturnModel>> _fetchAllReturns() async {
    final filters = ref.read(purchaseReturnFiltersProvider);
    final service = await ref.read(purchaseServiceProvider.future);

    return PaginatedFetch.fetchAll(
      fetchPage: (page) async {
        final baseQuery = _buildListQuery(filters);
        final query = PurchaseDocumentListQuery(
          page: page,
          limit: baseQuery.limit,
          documentType: baseQuery.documentType,
          status: baseQuery.status,
          from: baseQuery.from,
          to: baseQuery.to,
          sort: baseQuery.sort,
          order: baseQuery.order,
        );
        final pageResult = await service.fetchReturnsPage(query);
        return (
          items: pageResult.items,
          totalPages: pageResult.totalPages,
        );
      },
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final allReturns = await _fetchAllReturns();
      return _allReturnsPage(allReturns);
    });
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

  Future<String?> cancelReturn(String documentId) async {
    try {
      final service = await ref.read(purchaseServiceProvider.future);
      await service.cancelDocument(documentId);
      await refresh();
      return null;
    } catch (error) {
      return PurchaseErrorMapper.messageFor(error);
    }
  }

  Future<({String? error, String? newId})> duplicateReturn(String returnId) async {
    try {
      final service = await ref.read(purchaseServiceProvider.future);
      final newId = await service.duplicatePurchaseReturn(returnId);
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
    if (_documentStatusFromFilterLabel(status) != null) {
      ref.invalidate(purchaseReturnsProvider);
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query, currentPage: 1);
  }

  void setColumnDateRange(DateTimeRange range) {
    state = state.copyWith(
      columnFilters: state.columnFilters.copyWith(columnDateRange: range),
      currentPage: 1,
    );
  }

  void clearColumnDateRange() {
    state = state.copyWith(
      columnFilters: state.columnFilters.copyWith(clearColumnDateRange: true),
      currentPage: 1,
    );
  }

  void setDocumentNoFilter(String value) {
    state = state.copyWith(
      columnFilters: state.columnFilters.copyWith(documentNoFilter: value),
      currentPage: 1,
    );
  }

  void setParty(String party) {
    state = state.copyWith(
      columnFilters: state.columnFilters.copyWith(selectedParty: party),
      currentPage: 1,
    );
  }

  void setCategory(String category) {
    state = state.copyWith(
      columnFilters: state.columnFilters.copyWith(selectedCategory: category),
      currentPage: 1,
    );
  }

  void setType(String type) {
    state = state.copyWith(
      columnFilters: state.columnFilters.copyWith(selectedType: type),
      currentPage: 1,
    );
  }

  void applyAmountFilter(PurchaseNumericFilter filter) {
    state = state.copyWith(
      columnFilters: state.columnFilters.copyWith(amountFilter: filter),
      currentPage: 1,
    );
  }

  void clearAmountFilter() {
    state = state.copyWith(
      columnFilters: state.columnFilters.copyWith(clearAmountFilter: true),
      currentPage: 1,
    );
  }

  void applyReceivedPaidFilter(PurchaseNumericFilter filter) {
    state = state.copyWith(
      columnFilters: state.columnFilters.copyWith(receivedPaidFilter: filter),
      currentPage: 1,
    );
  }

  void clearReceivedPaidFilter() {
    state = state.copyWith(
      columnFilters: state.columnFilters.copyWith(clearReceivedPaidFilter: true),
      currentPage: 1,
    );
  }

  void applyBalanceFilter(PurchaseNumericFilter filter) {
    state = state.copyWith(
      columnFilters: state.columnFilters.copyWith(balanceFilter: filter),
      currentPage: 1,
    );
  }

  void clearBalanceFilter() {
    state = state.copyWith(
      columnFilters: state.columnFilters.copyWith(clearBalanceFilter: true),
      currentPage: 1,
    );
  }

  void togglePaymentType(String paymentType) {}

  void clearPaymentTypes() {}

  void setDueDateRange(DateTimeRange range) {
    state = state.copyWith(
      columnFilters: state.columnFilters.copyWith(dueDateRange: range),
      currentPage: 1,
    );
  }

  void clearDueDateRange() {
    state = state.copyWith(
      columnFilters: state.columnFilters.copyWith(clearDueDateRange: true),
      currentPage: 1,
    );
  }

  void setPage(int page) {
    state = state.copyWith(currentPage: page);
  }

  void clearAllFilters() {
    state = const PurchaseReturnFiltersState();
    ref.invalidate(purchaseReturnsProvider);
  }
}

@riverpod
List<PurchaseReturnModel> filteredPurchaseReturns(Ref ref) {
  final allReturns = _allReturnsFromAsync(ref.watch(purchaseReturnsProvider));
  final filters = ref.watch(purchaseReturnFiltersProvider);
  return _applyFilters(allReturns, filters);
}

@riverpod
PaginatedPurchaseReturns paginatedPurchaseReturns(Ref ref) {
  final filtered = ref.watch(filteredPurchaseReturnsProvider);
  final filters = ref.watch(purchaseReturnFiltersProvider);
  return _paginateFilteredReturns(filtered, filters.currentPage);
}

@riverpod
List<String> purchaseReturnPartyOptions(Ref ref) {
  final allReturns = _allReturnsFromAsync(ref.watch(purchaseReturnsProvider));
  return purchasePartyOptionsFromNames(
    allReturns.map((item) => item.partyName),
  );
}

@riverpod
List<String> purchaseReturnCategoryOptions(Ref ref) {
  final allReturns = _allReturnsFromAsync(ref.watch(purchaseReturnsProvider));
  final categories = allReturns.map((item) => item.categoryName).toSet().toList()
    ..sort();
  return ['All Categories', ...categories];
}

@riverpod
List<String> purchaseReturnTypeOptions(Ref ref) {
  final allReturns = _allReturnsFromAsync(ref.watch(purchaseReturnsProvider));
  final types = allReturns.map((item) => item.type).toSet().toList()..sort();
  return ['All Types', ...types];
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
