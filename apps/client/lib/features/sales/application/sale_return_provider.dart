import 'package:billing_baba/core/utils/debouncer.dart';
import 'package:billing_baba/features/sales/application/sale_invoices_provider.dart';
import 'package:billing_baba/features/sales/application/sales_documents_list_provider.dart';
import 'package:billing_baba/features/sales/application/sales_error_mapper.dart';
import 'package:billing_baba/features/sales/application/sales_service.dart';
import 'package:billing_baba/features/sales/models/requests/sales_requests.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_model.dart';
import 'package:billing_baba/features/sales/sales_constants.dart';
import 'package:billing_baba/shared/widgets/table_filters/table_filters.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sale_return_provider.g.dart';

const saleReturnPageSize = 10;

class SaleReturnFiltersState {
  const SaleReturnFiltersState({
    this.timeRangeOption = TimeRangeOption.thisMonth,
    this.customDateRange,
    this.selectedTransaction = 'Credit Note',
    this.selectedFirm = 'All Firms',
    this.selectedUser = 'All Users',
    this.selectedGodown = 'All Godown',
    this.selectedPayment = 'All Payment',
    this.selectedStatus = 'All Status',
    this.searchQuery = '',
    this.currentPage = 1,
    this.dateColumnFilter,
    this.refNoColumnFilter,
    this.partyNameColumnFilter,
    this.typeColumnFilter,
    this.totalAmountColumnFilter,
    this.receivedPaidColumnFilter,
    this.balanceColumnFilter,
    this.dueDateColumnFilter,
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
  final DateColumnFilter? dateColumnFilter;
  final TextColumnFilter? refNoColumnFilter;
  final TextColumnFilter? partyNameColumnFilter;
  final SelectColumnFilter? typeColumnFilter;
  final AmountColumnFilter? totalAmountColumnFilter;
  final AmountColumnFilter? receivedPaidColumnFilter;
  final AmountColumnFilter? balanceColumnFilter;
  final DateColumnFilter? dueDateColumnFilter;

  String get timeRangeLabel => timeRangeOption.label;

  SaleReturnFiltersState copyWith({
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
    DateColumnFilter? dateColumnFilter,
    bool clearDateColumnFilter = false,
    TextColumnFilter? refNoColumnFilter,
    bool clearRefNoColumnFilter = false,
    TextColumnFilter? partyNameColumnFilter,
    bool clearPartyNameColumnFilter = false,
    SelectColumnFilter? typeColumnFilter,
    bool clearTypeColumnFilter = false,
    AmountColumnFilter? totalAmountColumnFilter,
    bool clearTotalAmountColumnFilter = false,
    AmountColumnFilter? receivedPaidColumnFilter,
    bool clearReceivedPaidColumnFilter = false,
    AmountColumnFilter? balanceColumnFilter,
    bool clearBalanceColumnFilter = false,
    DateColumnFilter? dueDateColumnFilter,
    bool clearDueDateColumnFilter = false,
  }) {
    return SaleReturnFiltersState(
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
      dateColumnFilter: clearDateColumnFilter
          ? null
          : (dateColumnFilter ?? this.dateColumnFilter),
      refNoColumnFilter: clearRefNoColumnFilter
          ? null
          : (refNoColumnFilter ?? this.refNoColumnFilter),
      partyNameColumnFilter: clearPartyNameColumnFilter
          ? null
          : (partyNameColumnFilter ?? this.partyNameColumnFilter),
      typeColumnFilter: clearTypeColumnFilter
          ? null
          : (typeColumnFilter ?? this.typeColumnFilter),
      totalAmountColumnFilter: clearTotalAmountColumnFilter
          ? null
          : (totalAmountColumnFilter ?? this.totalAmountColumnFilter),
      receivedPaidColumnFilter: clearReceivedPaidColumnFilter
          ? null
          : (receivedPaidColumnFilter ?? this.receivedPaidColumnFilter),
      balanceColumnFilter: clearBalanceColumnFilter
          ? null
          : (balanceColumnFilter ?? this.balanceColumnFilter),
      dueDateColumnFilter: clearDueDateColumnFilter
          ? null
          : (dueDateColumnFilter ?? this.dueDateColumnFilter),
    );
  }
}

bool needsSaleReturnClientSideFiltering(SaleReturnFiltersState filters) {
  return filters.dateColumnFilter != null ||
      filters.refNoColumnFilter != null ||
      filters.partyNameColumnFilter != null ||
      filters.typeColumnFilter != null ||
      filters.totalAmountColumnFilter != null ||
      filters.receivedPaidColumnFilter != null ||
      filters.balanceColumnFilter != null ||
      filters.dueDateColumnFilter != null ||
      filters.selectedUser != 'All Users' ||
      filters.selectedFirm != 'All Firms' ||
      filters.selectedGodown != 'All Godown' ||
      filters.selectedPayment != 'All Payment' ||
      filters.selectedStatus != 'All Status';
}

class SaleReturnSummaryData {
  const SaleReturnSummaryData({
    required this.totalAmount,
    required this.balance,
  });

  final double totalAmount;
  final double balance;
}

SaleInvoiceStatus? _statusFromFilterLabel(String label) => switch (label) {
  'Paid' => SaleInvoiceStatus.paid,
  'Unpaid' => SaleInvoiceStatus.unpaid,
  'Partial' => SaleInvoiceStatus.partiallyPaid,
  'Overdue' => SaleInvoiceStatus.overdue,
  'Cancelled' => SaleInvoiceStatus.cancelled,
  _ => null,
};

String? _documentStatusFromFilterLabel(String label) => switch (label) {
  'Cancelled' => 'cancelled',
  'Draft' => 'draft',
  'Finalized' => 'finalized',
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

SalesDocumentListQuery buildSaleReturnListQuery(
  SaleReturnFiltersState filters, {
  int? page,
  int? limit,
}) {
  final dateRange = _resolveTimeRange(
    filters.timeRangeOption,
    filters.customDateRange,
  );

  return SalesDocumentListQuery(
    page: page ?? filters.currentPage,
    limit: limit ?? saleReturnPageSize,
    documentType: SalesDocumentType.salesReturn.apiValue,
    status: _documentStatusFromFilterLabel(filters.selectedStatus),
    from: dateRange?.start.toUtc().toIso8601String(),
    to: dateRange?.end.toUtc().toIso8601String(),
  );
}

PaginatedSaleInvoices paginateSaleReturnItems(
  List<SaleInvoiceModel> items,
  SaleReturnFiltersState filters,
) {
  final totalItems = items.length;
  final totalPages = totalItems == 0
      ? 1
      : (totalItems / saleReturnPageSize).ceil();
  final currentPage = filters.currentPage.clamp(1, totalPages);
  final start = (currentPage - 1) * saleReturnPageSize;
  final pageItems = items.skip(start).take(saleReturnPageSize).toList();

  return PaginatedSaleInvoices(
    items: pageItems,
    currentPage: currentPage,
    totalPages: totalPages,
    totalItems: totalItems,
  );
}

List<SaleInvoiceModel> applySaleReturnClientFilters(
  List<SaleInvoiceModel> returns,
  SaleReturnFiltersState filters,
) {
  final statusFilter = _statusFromFilterLabel(filters.selectedStatus);
  final search = filters.searchQuery.trim().toLowerCase();

  return returns.where((item) {
    if (search.isNotEmpty) {
      final haystack =
          '${item.partyName} ${item.invoiceNo} ${item.transactionType}'
              .toLowerCase();
      if (!haystack.contains(search)) {
        return false;
      }
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
    if (filters.dateColumnFilter != null &&
        !filters.dateColumnFilter!.matches(item.date)) {
      return false;
    }
    if (filters.refNoColumnFilter != null &&
        !filters.refNoColumnFilter!.matches(item.invoiceNo)) {
      return false;
    }
    if (filters.partyNameColumnFilter != null &&
        !filters.partyNameColumnFilter!.matches(item.partyName)) {
      return false;
    }
    if (filters.typeColumnFilter != null &&
        !filters.typeColumnFilter!.matches(item.transactionType)) {
      return false;
    }
    if (filters.totalAmountColumnFilter != null &&
        !filters.totalAmountColumnFilter!.matches(item.amount)) {
      return false;
    }
    final receivedPaid = item.amount - item.balance;
    if (filters.receivedPaidColumnFilter != null &&
        !filters.receivedPaidColumnFilter!.matches(receivedPaid)) {
      return false;
    }
    if (filters.balanceColumnFilter != null &&
        !filters.balanceColumnFilter!.matches(item.balance)) {
      return false;
    }
    if (filters.dueDateColumnFilter != null) {
      final dueDate = item.dueDate ?? item.date;
      if (!filters.dueDateColumnFilter!.matches(dueDate)) {
        return false;
      }
    }
    return true;
  }).toList();
}

@Riverpod(keepAlive: true)
class SaleReturns extends _$SaleReturns {
  @override
  Future<PaginatedSaleInvoices> build() async {
    ref.watch(saleReturnFiltersProvider);
    return _fetchPage();
  }

  Future<PaginatedSaleInvoices> _fetchPage() async {
    final filters = ref.read(saleReturnFiltersProvider);
    final service = await ref.read(salesServiceProvider.future);
    final page = await service.fetchInvoicesPage(buildSaleReturnListQuery(filters));

    return PaginatedSaleInvoices(
      items: applySaleReturnClientFilters(page.items, filters),
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
      final service = await ref.read(salesServiceProvider.future);
      await service.deleteDraft(documentId);
      await refresh();
      ref.invalidate(salesDocumentsListProvider(salesReturnListScope()));
      return null;
    } catch (error) {
      return SalesErrorMapper.messageFor(error);
    }
  }

  Future<String?> finalizeReturn(String documentId, {String? godownId}) async {
    try {
      final service = await ref.read(salesServiceProvider.future);
      await service.finalizeDraft(documentId, godownId: godownId);
      await refresh();
      ref.invalidate(salesDocumentsListProvider(salesReturnListScope()));
      return null;
    } catch (error) {
      return SalesErrorMapper.messageFor(error);
    }
  }
}

@riverpod
class SaleReturnFilters extends _$SaleReturnFilters {
  Debouncer? _searchDebouncer;

  @override
  SaleReturnFiltersState build() {
    ref.onDispose(() => _searchDebouncer?.dispose());
    return const SaleReturnFiltersState();
  }

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
    _searchDebouncer ??= Debouncer();
    _searchDebouncer!.run(() {
      state = state.copyWith(searchQuery: query, currentPage: 1);
    });
  }

  void setPage(int page) {
    state = state.copyWith(currentPage: page);
  }

  void setDateColumnFilter(DateColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearDateColumnFilter: true, currentPage: 1)
        : state.copyWith(dateColumnFilter: filter, currentPage: 1);
  }

  void setRefNoColumnFilter(TextColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearRefNoColumnFilter: true, currentPage: 1)
        : state.copyWith(refNoColumnFilter: filter, currentPage: 1);
  }

  void setPartyNameColumnFilter(TextColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearPartyNameColumnFilter: true, currentPage: 1)
        : state.copyWith(partyNameColumnFilter: filter, currentPage: 1);
  }

  void setTypeColumnFilter(SelectColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearTypeColumnFilter: true, currentPage: 1)
        : state.copyWith(typeColumnFilter: filter, currentPage: 1);
  }

  void setTotalAmountColumnFilter(AmountColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearTotalAmountColumnFilter: true, currentPage: 1)
        : state.copyWith(totalAmountColumnFilter: filter, currentPage: 1);
  }

  void setReceivedPaidColumnFilter(AmountColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearReceivedPaidColumnFilter: true, currentPage: 1)
        : state.copyWith(receivedPaidColumnFilter: filter, currentPage: 1);
  }

  void setBalanceColumnFilter(AmountColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearBalanceColumnFilter: true, currentPage: 1)
        : state.copyWith(balanceColumnFilter: filter, currentPage: 1);
  }

  void setDueDateColumnFilter(DateColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearDueDateColumnFilter: true, currentPage: 1)
        : state.copyWith(dueDateColumnFilter: filter, currentPage: 1);
  }
}

@riverpod
List<SaleInvoiceModel> filteredSaleReturns(Ref ref) {
  final allReturns = ref.watch(saleReturnsProvider).value?.items ?? [];
  final filters = ref.watch(saleReturnFiltersProvider);
  return applySaleReturnClientFilters(allReturns, filters);
}

@riverpod
PaginatedSaleInvoices paginatedSaleReturns(Ref ref) {
  final filtered = ref.watch(filteredSaleReturnsProvider);
  final filters = ref.watch(saleReturnFiltersProvider);
  return paginateSaleReturnItems(filtered, filters);
}

@riverpod
SaleReturnSummaryData saleReturnSummary(Ref ref) {
  final returns = ref.watch(filteredSaleReturnsProvider);

  var totalAmount = 0.0;
  var balance = 0.0;

  for (final item in returns) {
    totalAmount += item.amount;
    balance += item.balance;
  }

  return SaleReturnSummaryData(
    totalAmount: totalAmount,
    balance: balance,
  );
}

@riverpod
Future<void> saleReturnRefresh(Ref ref) async {
  await ref.read(saleReturnsProvider.notifier).refresh();
}

@riverpod
Future<String?> deleteSaleReturnDraft(Ref ref, String documentId) {
  return ref.read(saleReturnsProvider.notifier).deleteDraft(documentId);
}

@riverpod
Future<String?> finalizeSaleReturn(Ref ref, String documentId) {
  return ref.read(saleReturnsProvider.notifier).finalizeReturn(documentId);
}
