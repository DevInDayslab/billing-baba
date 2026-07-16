import 'package:billing_baba/core/utils/debouncer.dart';
import 'package:billing_baba/features/sales/application/sales_error_mapper.dart';
import 'package:billing_baba/features/sales/application/sales_service.dart';
import 'package:billing_baba/features/sales/models/requests/sales_requests.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_model.dart';
import 'package:billing_baba/features/sales/providers/sale_invoices_provider.dart';
import 'package:billing_baba/features/sales/providers/sales_documents_list_provider.dart';
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

SalesDocumentListQuery _buildListQuery(SaleReturnFiltersState filters) {
  final dateRange = _resolveTimeRange(
    filters.timeRangeOption,
    filters.customDateRange,
  );

  return SalesDocumentListQuery(
    page: filters.currentPage,
    limit: saleReturnPageSize,
    documentType: SalesDocumentType.salesReturn.apiValue,
    status: _documentStatusFromFilterLabel(filters.selectedStatus),
    from: dateRange?.start.toUtc().toIso8601String(),
    to: dateRange?.end.toUtc().toIso8601String(),
    q: filters.searchQuery.trim().isEmpty ? null : filters.searchQuery.trim(),
  );
}

List<SaleInvoiceModel> _applyClientFilters(
  List<SaleInvoiceModel> returns,
  SaleReturnFiltersState filters,
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
    final page = await service.fetchInvoicesPage(_buildListQuery(filters));

    return PaginatedSaleInvoices(
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
    ref.invalidate(saleReturnsProvider);
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
    ref.invalidate(saleReturnsProvider);
  }

  void setTransaction(String transaction) {
    state = state.copyWith(selectedTransaction: transaction, currentPage: 1);
    ref.invalidate(saleReturnsProvider);
  }

  void setFirm(String firm) {
    state = state.copyWith(selectedFirm: firm, currentPage: 1);
    ref.invalidate(saleReturnsProvider);
  }

  void setUser(String user) {
    state = state.copyWith(selectedUser: user, currentPage: 1);
    ref.invalidate(saleReturnsProvider);
  }

  void setGodown(String godown) {
    state = state.copyWith(selectedGodown: godown, currentPage: 1);
    ref.invalidate(saleReturnsProvider);
  }

  void setPayment(String payment) {
    state = state.copyWith(selectedPayment: payment, currentPage: 1);
    ref.invalidate(saleReturnsProvider);
  }

  void setStatus(String status) {
    state = state.copyWith(selectedStatus: status, currentPage: 1);
    ref.invalidate(saleReturnsProvider);
  }

  void setSearchQuery(String query) {
    _searchDebouncer ??= Debouncer();
    _searchDebouncer!.run(() {
      state = state.copyWith(searchQuery: query, currentPage: 1);
      ref.invalidate(saleReturnsProvider);
    });
  }

  void setPage(int page) {
    state = state.copyWith(currentPage: page);
    ref.invalidate(saleReturnsProvider);
  }

  void setDateColumnFilter(DateColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearDateColumnFilter: true, currentPage: 1)
        : state.copyWith(dateColumnFilter: filter, currentPage: 1);
    ref.invalidate(saleReturnsProvider);
  }

  void setRefNoColumnFilter(TextColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearRefNoColumnFilter: true, currentPage: 1)
        : state.copyWith(refNoColumnFilter: filter, currentPage: 1);
    ref.invalidate(saleReturnsProvider);
  }

  void setPartyNameColumnFilter(TextColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearPartyNameColumnFilter: true, currentPage: 1)
        : state.copyWith(partyNameColumnFilter: filter, currentPage: 1);
    ref.invalidate(saleReturnsProvider);
  }

  void setTypeColumnFilter(SelectColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearTypeColumnFilter: true, currentPage: 1)
        : state.copyWith(typeColumnFilter: filter, currentPage: 1);
    ref.invalidate(saleReturnsProvider);
  }

  void setTotalAmountColumnFilter(AmountColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearTotalAmountColumnFilter: true, currentPage: 1)
        : state.copyWith(totalAmountColumnFilter: filter, currentPage: 1);
    ref.invalidate(saleReturnsProvider);
  }

  void setReceivedPaidColumnFilter(AmountColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearReceivedPaidColumnFilter: true, currentPage: 1)
        : state.copyWith(receivedPaidColumnFilter: filter, currentPage: 1);
    ref.invalidate(saleReturnsProvider);
  }

  void setBalanceColumnFilter(AmountColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearBalanceColumnFilter: true, currentPage: 1)
        : state.copyWith(balanceColumnFilter: filter, currentPage: 1);
    ref.invalidate(saleReturnsProvider);
  }

  void setDueDateColumnFilter(DateColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearDueDateColumnFilter: true, currentPage: 1)
        : state.copyWith(dueDateColumnFilter: filter, currentPage: 1);
    ref.invalidate(saleReturnsProvider);
  }
}

@riverpod
PaginatedSaleInvoices paginatedSaleReturns(Ref ref) {
  final returnsAsync = ref.watch(saleReturnsProvider);
  return returnsAsync.maybeWhen(
    data: (page) => page,
    orElse: () => const PaginatedSaleInvoices(
      items: [],
      currentPage: 1,
      totalPages: 1,
      totalItems: 0,
    ),
  );
}

@riverpod
SaleReturnSummaryData saleReturnSummary(Ref ref) {
  final page = ref.watch(paginatedSaleReturnsProvider);
  final returns = page.items;

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
