import 'package:billing_baba/features/export/utils/paginated_fetch.dart';
import 'package:billing_baba/features/purchases/application/purchase_error_mapper.dart';
import 'package:billing_baba/features/purchases/application/purchase_service.dart';
import 'package:billing_baba/features/purchases/models/purchase_bill_model.dart';
import 'package:billing_baba/features/purchases/models/requests/purchase_requests.dart';
import 'package:billing_baba/features/purchases/purchase_constants.dart';
import 'package:billing_baba/features/sales/providers/sale_invoices_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'purchase_bills_provider.g.dart';

const purchaseBillsPageSize = 10;

enum PurchaseBillNumericFilterOperator {
  equalTo('Equal To'),
  lessThan('Less Than'),
  greaterThan('Greater Than');

  const PurchaseBillNumericFilterOperator(this.label);

  final String label;
}

class PurchaseBillNumericFilter {
  const PurchaseBillNumericFilter({
    required this.operator,
    required this.value,
  });

  final PurchaseBillNumericFilterOperator operator;
  final double value;

  bool matches(double amount) => switch (operator) {
    PurchaseBillNumericFilterOperator.equalTo => amount == value,
    PurchaseBillNumericFilterOperator.lessThan => amount < value,
    PurchaseBillNumericFilterOperator.greaterThan => amount > value,
  };
}

class PurchaseBillFiltersState {
  const PurchaseBillFiltersState({
    this.timeRangeOption = TimeRangeOption.thisMonth,
    this.customDateRange,
    this.selectedFirm = 'All Firms',
    this.selectedUser = 'All Users',
    this.selectedStatus = 'All Status',
    this.currentPage = 1,
    this.columnDateRange,
    this.invoiceNoFilter = '',
    this.selectedParty = 'All Parties',
    this.selectedPaymentTypes = const {},
    this.amountFilter,
    this.balanceFilter,
    this.dueDateRange,
  });

  final TimeRangeOption timeRangeOption;
  final DateTimeRange? customDateRange;
  final String selectedFirm;
  final String selectedUser;
  final String selectedStatus;
  final int currentPage;
  final DateTimeRange? columnDateRange;
  final String invoiceNoFilter;
  final String selectedParty;
  final Set<String> selectedPaymentTypes;
  final PurchaseBillNumericFilter? amountFilter;
  final PurchaseBillNumericFilter? balanceFilter;
  final DateTimeRange? dueDateRange;

  String get timeRangeLabel => timeRangeOption.label;

  bool get hasActiveFilters =>
      timeRangeOption != TimeRangeOption.thisMonth ||
      customDateRange != null ||
      selectedFirm != 'All Firms' ||
      selectedUser != 'All Users' ||
      selectedStatus != 'All Status' ||
      columnDateRange != null ||
      invoiceNoFilter.trim().isNotEmpty ||
      selectedParty != 'All Parties' ||
      selectedPaymentTypes.isNotEmpty ||
      amountFilter != null ||
      balanceFilter != null ||
      dueDateRange != null;

  PurchaseBillFiltersState copyWith({
    TimeRangeOption? timeRangeOption,
    DateTimeRange? customDateRange,
    bool clearCustomDateRange = false,
    String? selectedFirm,
    String? selectedUser,
    String? selectedStatus,
    int? currentPage,
    DateTimeRange? columnDateRange,
    bool clearColumnDateRange = false,
    String? invoiceNoFilter,
    String? selectedParty,
    Set<String>? selectedPaymentTypes,
    bool clearPaymentTypes = false,
    PurchaseBillNumericFilter? amountFilter,
    bool clearAmountFilter = false,
    PurchaseBillNumericFilter? balanceFilter,
    bool clearBalanceFilter = false,
    DateTimeRange? dueDateRange,
    bool clearDueDateRange = false,
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
      columnDateRange: clearColumnDateRange
          ? null
          : (columnDateRange ?? this.columnDateRange),
      invoiceNoFilter: invoiceNoFilter ?? this.invoiceNoFilter,
      selectedParty: selectedParty ?? this.selectedParty,
      selectedPaymentTypes: clearPaymentTypes
          ? const {}
          : (selectedPaymentTypes ?? this.selectedPaymentTypes),
      amountFilter: clearAmountFilter
          ? null
          : (amountFilter ?? this.amountFilter),
      balanceFilter: clearBalanceFilter
          ? null
          : (balanceFilter ?? this.balanceFilter),
      dueDateRange: clearDueDateRange
          ? null
          : (dueDateRange ?? this.dueDateRange),
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

bool _isWithinDateRange(DateTime value, DateTimeRange range) {
  final date = _startOfDay(value);
  final start = _startOfDay(range.start);
  final end = _startOfDay(range.end);
  return !date.isBefore(start) && !date.isAfter(end);
}

PurchaseDocumentListQuery _buildListQuery(PurchaseBillFiltersState filters) {
  final dateRange = _resolveTimeRange(
    filters.timeRangeOption,
    filters.customDateRange,
  );

  return PurchaseDocumentListQuery(
    limit: PaginatedFetch.defaultPageSize,
    documentType: PurchaseDocumentType.purchaseBill.apiValue,
    status: _documentStatusFromFilterLabel(filters.selectedStatus),
    from: dateRange?.start.toUtc().toIso8601String(),
    to: dateRange?.end.toUtc().toIso8601String(),
  );
}

List<PurchaseBillModel> _applyFilters(
  List<PurchaseBillModel> bills,
  PurchaseBillFiltersState filters,
  String globalSearch,
) {
  final paymentStatus = _paymentStatusFromFilterLabel(filters.selectedStatus);
  final globalQuery = globalSearch.trim().toLowerCase();
  final invoiceQuery = filters.invoiceNoFilter.trim().toLowerCase();

  return bills.where((bill) {
    if (globalQuery.isNotEmpty) {
      final matchesGlobal =
          bill.invoiceNo.toLowerCase().contains(globalQuery) ||
          bill.partyName.toLowerCase().contains(globalQuery) ||
          bill.paymentType.toLowerCase().contains(globalQuery);
      if (!matchesGlobal) return false;
    }

    if (invoiceQuery.isNotEmpty &&
        !bill.invoiceNo.toLowerCase().contains(invoiceQuery)) {
      return false;
    }

    if (filters.columnDateRange != null &&
        !_isWithinDateRange(bill.date, filters.columnDateRange!)) {
      return false;
    }

    if (filters.selectedParty != 'All Parties' &&
        bill.partyName != filters.selectedParty) {
      return false;
    }

    if (filters.selectedPaymentTypes.isNotEmpty &&
        !filters.selectedPaymentTypes.contains(bill.paymentType)) {
      return false;
    }

    if (filters.amountFilter != null &&
        !filters.amountFilter!.matches(bill.amount)) {
      return false;
    }

    if (filters.balanceFilter != null &&
        !filters.balanceFilter!.matches(bill.balanceDue)) {
      return false;
    }

    if (filters.dueDateRange != null &&
        !_isWithinDateRange(bill.dueDate, filters.dueDateRange!)) {
      return false;
    }

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

PaginatedPurchaseBills _paginateFilteredBills(
  List<PurchaseBillModel> filtered,
  int currentPage,
) {
  if (filtered.isEmpty) {
    return const PaginatedPurchaseBills(
      items: [],
      currentPage: 1,
      totalPages: 1,
      totalItems: 0,
    );
  }

  final totalItems = filtered.length;
  final totalPages = (totalItems / purchaseBillsPageSize).ceil();
  final page = currentPage.clamp(1, totalPages);
  final start = (page - 1) * purchaseBillsPageSize;
  final end = (start + purchaseBillsPageSize).clamp(0, totalItems);

  return PaginatedPurchaseBills(
    items: filtered.sublist(start, end),
    currentPage: page,
    totalPages: totalPages,
    totalItems: totalItems,
  );
}

@Riverpod(keepAlive: true)
class PurchaseBillSearchQuery extends _$PurchaseBillSearchQuery {
  @override
  String build() => '';

  void setQuery(String value) {
    state = value;
    final filters = ref.read(purchaseBillFiltersProvider);
    if (filters.currentPage != 1) {
      ref.read(purchaseBillFiltersProvider.notifier).setPage(1);
    }
  }
}

PaginatedPurchaseBills _allBillsPage(List<PurchaseBillModel> allBills) {
  return PaginatedPurchaseBills(
    items: allBills,
    currentPage: 1,
    totalPages: 1,
    totalItems: allBills.length,
  );
}

List<PurchaseBillModel> _allBillsFromAsync(
  AsyncValue<PaginatedPurchaseBills> billsAsync,
) {
  return billsAsync.when(
    data: (page) => page.items,
    loading: () => const [],
    error: (_, _) => const [],
  );
}

@Riverpod(keepAlive: true)
class PurchaseBills extends _$PurchaseBills {
  @override
  Future<PaginatedPurchaseBills> build() async {
    ref.watch(
      purchaseBillFiltersProvider.select(
        (filters) => (filters.timeRangeOption, filters.customDateRange),
      ),
    );
    final allBills = await _fetchAllBills();
    return _allBillsPage(allBills);
  }

  Future<List<PurchaseBillModel>> _fetchAllBills() async {
    final filters = ref.read(purchaseBillFiltersProvider);
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
        final pageResult = await service.fetchBillsPage(query);
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
      final allBills = await _fetchAllBills();
      return _allBillsPage(allBills);
    });
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

  Future<String?> cancelBill(String documentId) async {
    try {
      final service = await ref.read(purchaseServiceProvider.future);
      await service.cancelDocument(documentId);
      await refresh();
      return null;
    } catch (error) {
      return PurchaseErrorMapper.messageFor(error);
    }
  }

  Future<({String? error, String? returnId})> convertToReturn(
    String billId,
  ) async {
    try {
      final service = await ref.read(purchaseServiceProvider.future);
      final document = await service.convertBillToReturn(billId);
      await refresh();
      return (error: null, returnId: document.id);
    } catch (error) {
      return (
        error: PurchaseErrorMapper.messageFor(error),
        returnId: null,
      );
    }
  }

  Future<({String? error, String? newId})> duplicateBill(String billId) async {
    try {
      final service = await ref.read(purchaseServiceProvider.future);
      final newId = await service.duplicatePurchaseBill(billId);
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
  }

  void setUser(String user) {
    state = state.copyWith(selectedUser: user, currentPage: 1);
  }

  void setStatus(String status) {
    state = state.copyWith(selectedStatus: status, currentPage: 1);
    if (_documentStatusFromFilterLabel(status) != null) {
      ref.invalidate(purchaseBillsProvider);
    }
  }

  void setColumnDateRange(DateTimeRange range) {
    state = state.copyWith(columnDateRange: range, currentPage: 1);
  }

  void clearColumnDateRange() {
    state = state.copyWith(clearColumnDateRange: true, currentPage: 1);
  }

  void setInvoiceNo(String value) {
    state = state.copyWith(invoiceNoFilter: value, currentPage: 1);
  }

  void setParty(String party) {
    state = state.copyWith(selectedParty: party, currentPage: 1);
  }

  void togglePaymentType(String paymentType) {
    final updated = Set<String>.from(state.selectedPaymentTypes);
    if (updated.contains(paymentType)) {
      updated.remove(paymentType);
    } else {
      updated.add(paymentType);
    }
    state = state.copyWith(selectedPaymentTypes: updated, currentPage: 1);
  }

  void clearPaymentTypes() {
    state = state.copyWith(clearPaymentTypes: true, currentPage: 1);
  }

  void applyAmountFilter(PurchaseBillNumericFilter filter) {
    state = state.copyWith(amountFilter: filter, currentPage: 1);
  }

  void clearAmountFilter() {
    state = state.copyWith(clearAmountFilter: true, currentPage: 1);
  }

  void applyBalanceFilter(PurchaseBillNumericFilter filter) {
    state = state.copyWith(balanceFilter: filter, currentPage: 1);
  }

  void clearBalanceFilter() {
    state = state.copyWith(clearBalanceFilter: true, currentPage: 1);
  }

  void setDueDateRange(DateTimeRange range) {
    state = state.copyWith(dueDateRange: range, currentPage: 1);
  }

  void clearDueDateRange() {
    state = state.copyWith(clearDueDateRange: true, currentPage: 1);
  }

  void setPage(int page) {
    state = state.copyWith(currentPage: page);
  }

  void clearAllFilters() {
    state = const PurchaseBillFiltersState();
    ref.read(purchaseBillSearchQueryProvider.notifier).setQuery('');
    ref.invalidate(purchaseBillsProvider);
  }
}

@riverpod
List<PurchaseBillModel> filteredPurchaseBills(Ref ref) {
  final allBills = _allBillsFromAsync(ref.watch(purchaseBillsProvider));
  final filters = ref.watch(purchaseBillFiltersProvider);
  final search = ref.watch(purchaseBillSearchQueryProvider);
  return _applyFilters(allBills, filters, search);
}

@riverpod
PaginatedPurchaseBills paginatedPurchaseBills(Ref ref) {
  final filtered = ref.watch(filteredPurchaseBillsProvider);
  final filters = ref.watch(purchaseBillFiltersProvider);
  return _paginateFilteredBills(filtered, filters.currentPage);
}

@riverpod
List<String> purchaseBillPartyOptions(Ref ref) {
  final allBills = _allBillsFromAsync(ref.watch(purchaseBillsProvider));
  final parties = allBills.map((bill) => bill.partyName).toSet().toList()
    ..sort();
  return ['All Parties', ...parties];
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

/// One-shot success message shown on the purchase bills list after save.
final purchaseBillSaveSuccessMessageProvider =
    NotifierProvider<PurchaseBillSaveSuccessMessage, String?>(
      PurchaseBillSaveSuccessMessage.new,
    );

class PurchaseBillSaveSuccessMessage extends Notifier<String?> {
  @override
  String? build() => null;

  void setMessage(String? value) => state = value;
}
