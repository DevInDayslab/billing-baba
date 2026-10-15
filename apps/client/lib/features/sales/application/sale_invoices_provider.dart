import 'package:billing_baba/core/providers/data_refresh.dart';
import 'package:billing_baba/features/auth/application/auth_provider.dart';
import 'package:billing_baba/features/business/application/business_service.dart';
import 'package:billing_baba/features/export/utils/paginated_fetch.dart';
import 'package:billing_baba/features/inventory/application/inventory_godowns_provider.dart';
import 'package:billing_baba/features/sales/application/sale_paginated_async_helpers.dart';
import 'package:billing_baba/features/sales/application/sales_error_mapper.dart';
import 'package:billing_baba/features/recycle_bin/application/transaction_lifecycle_service.dart';
import 'package:billing_baba/features/sales/application/sales_service.dart';
import 'package:billing_baba/features/sales/models/requests/sales_requests.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_model.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_dropdown_options.dart';
import 'package:billing_baba/features/sales/sales_constants.dart';
import 'package:billing_baba/features/settings/services/whatsapp_auto_notify.dart';
import 'package:billing_baba/shared/widgets/table_filters/table_filters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sale_invoices_provider.g.dart';

const saleInvoicesPageSize = 10;

enum TimeRangeOption {
  allTime,
  today,
  thisWeek,
  thisMonth,
  thisYear,
  custom,
}

extension TimeRangeOptionX on TimeRangeOption {
  String get label => switch (this) {
    TimeRangeOption.allTime => 'All Time',
    TimeRangeOption.today => 'Today',
    TimeRangeOption.thisWeek => 'This Week',
    TimeRangeOption.thisMonth => 'This Month',
    TimeRangeOption.thisYear => 'This Year',
    TimeRangeOption.custom => 'Custom',
  };

  static TimeRangeOption fromLabel(String label) => switch (label) {
    'Today' => TimeRangeOption.today,
    'This Week' => TimeRangeOption.thisWeek,
    'This Month' => TimeRangeOption.thisMonth,
    'This Year' => TimeRangeOption.thisYear,
    'Custom' => TimeRangeOption.custom,
    _ => TimeRangeOption.allTime,
  };
}

class SaleInvoiceFiltersState {
  const SaleInvoiceFiltersState({
    this.timeRangeOption = TimeRangeOption.thisMonth,
    this.customDateRange,
    this.dateColumnFilter,
    this.dueDateColumnFilter,
    this.invoiceNoColumnFilter,
    this.partyNameColumnFilter,
    this.transactionTypeColumnFilter,
    this.paymentTypeColumnFilter,
    this.amountColumnFilter,
    this.loyaltyColumnFilter,
    this.balanceColumnFilter,
    this.selectedFirm = 'All Firms',
    this.selectedUser = 'All Users',
    this.selectedGodown = 'All Godown',
    this.selectedStatus = 'All Status',
    this.currentPage = 1,
  });

  final TimeRangeOption timeRangeOption;
  final DateTimeRange? customDateRange;
  final DateColumnFilter? dateColumnFilter;
  final DateColumnFilter? dueDateColumnFilter;
  final TextColumnFilter? invoiceNoColumnFilter;
  final TextColumnFilter? partyNameColumnFilter;
  final SelectColumnFilter? transactionTypeColumnFilter;
  final SelectColumnFilter? paymentTypeColumnFilter;
  final AmountColumnFilter? amountColumnFilter;
  final AmountColumnFilter? balanceColumnFilter;
  final RangeSliderColumnFilter? loyaltyColumnFilter;
  final String selectedFirm;
  final String selectedUser;
  final String selectedGodown;
  final String selectedStatus;
  final int currentPage;

  String get timeRangeLabel => timeRangeOption.label;

  SaleInvoiceFiltersState copyWith({
    TimeRangeOption? timeRangeOption,
    DateTimeRange? customDateRange,
    bool clearCustomDateRange = false,
    DateColumnFilter? dateColumnFilter,
    bool clearDateColumnFilter = false,
    DateColumnFilter? dueDateColumnFilter,
    bool clearDueDateColumnFilter = false,
    TextColumnFilter? invoiceNoColumnFilter,
    bool clearInvoiceNoColumnFilter = false,
    TextColumnFilter? partyNameColumnFilter,
    bool clearPartyNameColumnFilter = false,
    SelectColumnFilter? transactionTypeColumnFilter,
    bool clearTransactionTypeColumnFilter = false,
    SelectColumnFilter? paymentTypeColumnFilter,
    bool clearPaymentTypeColumnFilter = false,
    AmountColumnFilter? amountColumnFilter,
    bool clearAmountColumnFilter = false,
    AmountColumnFilter? balanceColumnFilter,
    bool clearBalanceColumnFilter = false,
    RangeSliderColumnFilter? loyaltyColumnFilter,
    bool clearLoyaltyColumnFilter = false,
    String? selectedUser,
    String? selectedGodown,
    String? selectedFirm,
    String? selectedStatus,
    int? currentPage,
  }) {
    return SaleInvoiceFiltersState(
      timeRangeOption: timeRangeOption ?? this.timeRangeOption,
      customDateRange: clearCustomDateRange
          ? null
          : (customDateRange ?? this.customDateRange),
      dateColumnFilter: clearDateColumnFilter
          ? null
          : (dateColumnFilter ?? this.dateColumnFilter),
      dueDateColumnFilter: clearDueDateColumnFilter
          ? null
          : (dueDateColumnFilter ?? this.dueDateColumnFilter),
      invoiceNoColumnFilter: clearInvoiceNoColumnFilter
          ? null
          : (invoiceNoColumnFilter ?? this.invoiceNoColumnFilter),
      partyNameColumnFilter: clearPartyNameColumnFilter
          ? null
          : (partyNameColumnFilter ?? this.partyNameColumnFilter),
      transactionTypeColumnFilter: clearTransactionTypeColumnFilter
          ? null
          : (transactionTypeColumnFilter ?? this.transactionTypeColumnFilter),
      paymentTypeColumnFilter: clearPaymentTypeColumnFilter
          ? null
          : (paymentTypeColumnFilter ?? this.paymentTypeColumnFilter),
      amountColumnFilter: clearAmountColumnFilter
          ? null
          : (amountColumnFilter ?? this.amountColumnFilter),
      loyaltyColumnFilter: clearLoyaltyColumnFilter
          ? null
          : (loyaltyColumnFilter ?? this.loyaltyColumnFilter),
      balanceColumnFilter: clearBalanceColumnFilter
          ? null
          : (balanceColumnFilter ?? this.balanceColumnFilter),
      selectedUser: selectedUser ?? this.selectedUser,
      selectedGodown: selectedGodown ?? this.selectedGodown,
      selectedFirm: selectedFirm ?? this.selectedFirm,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

SaleInvoiceStatus? _paymentStatusFromFilterLabel(String label) =>
    switch (label) {
      'Paid' => SaleInvoiceStatus.paid,
      'Unpaid' => SaleInvoiceStatus.unpaid,
      'Partial' => SaleInvoiceStatus.partiallyPaid,
      'Overdue' => SaleInvoiceStatus.overdue,
      'Cancelled' => SaleInvoiceStatus.cancelled,
      _ => null,
    };

String? _documentStatusFromFilterLabel(String label) => switch (label) {
  'Cancelled' => 'cancelled',
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

SalesDocumentListQuery _buildListQuery(
  SaleInvoiceFiltersState filters,
  String searchQuery, {
  int? page,
  int? limit,
}) {
  final dateRange = _resolveTimeRange(
    filters.timeRangeOption,
    filters.customDateRange,
  );

  return SalesDocumentListQuery(
    page: page ?? filters.currentPage,
    limit: limit ?? saleInvoicesPageSize,
    documentType: SalesDocumentType.taxInvoice.apiValue,
    status: _documentStatusFromFilterLabel(filters.selectedStatus),
    from: dateRange?.start.toUtc().toIso8601String(),
    to: dateRange?.end.toUtc().toIso8601String(),
    q: searchQuery.trim().isEmpty ? null : searchQuery.trim(),
  );
}

bool needsSaleInvoiceClientSideFiltering(SaleInvoiceFiltersState filters) {
  return filters.dateColumnFilter != null ||
      filters.dueDateColumnFilter != null ||
      filters.invoiceNoColumnFilter != null ||
      filters.partyNameColumnFilter != null ||
      filters.transactionTypeColumnFilter != null ||
      filters.paymentTypeColumnFilter != null ||
      filters.amountColumnFilter != null ||
      filters.loyaltyColumnFilter != null ||
      filters.balanceColumnFilter != null ||
      filters.selectedStatus != 'All Status' ||
      filters.selectedUser != 'All Users' ||
      filters.selectedGodown != 'All Godown' ||
      filters.selectedFirm != 'All Firms';
}

PaginatedSaleInvoices paginateSaleInvoiceItems(
  List<SaleInvoiceModel> items,
  SaleInvoiceFiltersState filters,
) {
  final totalItems = items.length;
  final totalPages = totalItems == 0
      ? 1
      : (totalItems / saleInvoicesPageSize).ceil();
  final currentPage = filters.currentPage.clamp(1, totalPages);
  final start = (currentPage - 1) * saleInvoicesPageSize;
  final pageItems = items.skip(start).take(saleInvoicesPageSize).toList();

  return PaginatedSaleInvoices(
    items: pageItems,
    currentPage: currentPage,
    totalPages: totalPages,
    totalItems: totalItems,
  );
}

final _saleInvoiceSearchDateFormat = DateFormat('dd/MM/yyyy, HH:mm');
final _saleInvoiceSearchDueDateFormat = DateFormat('dd/MM/yyyy');
final _saleInvoiceSearchCurrencyFormat = NumberFormat.currency(
  locale: 'en_IN',
  symbol: '₹ ',
  decimalDigits: 0,
);

String _saleInvoiceStatusLabel(SaleInvoiceStatus status) => switch (status) {
  SaleInvoiceStatus.paid => 'Paid',
  SaleInvoiceStatus.unpaid => 'Unpaid',
  SaleInvoiceStatus.partiallyPaid => 'Partial',
  SaleInvoiceStatus.overdue => 'Overdue',
  SaleInvoiceStatus.cancelled => 'Cancelled',
};

String _saleInvoiceSearchHaystack(SaleInvoiceModel invoice) {
  return [
    _saleInvoiceSearchDateFormat.format(invoice.date),
    invoice.invoiceNo,
    invoice.partyName,
    invoice.transactionType,
    invoice.paymentType,
    _saleInvoiceSearchCurrencyFormat.format(invoice.amount),
    invoice.amount.toString(),
    _saleInvoiceSearchCurrencyFormat.format(invoice.loyaltyRedeemed),
    invoice.loyaltyRedeemed.toString(),
    _saleInvoiceSearchCurrencyFormat.format(invoice.balance),
    invoice.balance.toString(),
    if (invoice.dueDate != null)
      _saleInvoiceSearchDueDateFormat.format(invoice.dueDate!),
    _saleInvoiceStatusLabel(invoice.status),
    invoice.user,
    invoice.godown,
    invoice.firm,
  ].join(' ').toLowerCase();
}

List<SaleInvoiceModel> applySaleInvoiceClientFilters(
  List<SaleInvoiceModel> invoices,
  SaleInvoiceFiltersState filters, {
  String searchQuery = '',
}) {
  final paymentStatus = _paymentStatusFromFilterLabel(filters.selectedStatus);
  final search = searchQuery.trim().toLowerCase();

  return invoices.where((invoice) {
    if (search.isNotEmpty &&
        !_saleInvoiceSearchHaystack(invoice).contains(search)) {
      return false;
    }
    if (filters.dateColumnFilter != null &&
        !filters.dateColumnFilter!.matches(invoice.date)) {
      return false;
    }
    if (filters.dueDateColumnFilter != null) {
      final dueDate = invoice.dueDate ?? invoice.date;
      if (!filters.dueDateColumnFilter!.matches(dueDate)) {
        return false;
      }
    }
    if (filters.invoiceNoColumnFilter != null &&
        !filters.invoiceNoColumnFilter!.matches(invoice.invoiceNo)) {
      return false;
    }
    if (filters.partyNameColumnFilter != null &&
        !filters.partyNameColumnFilter!.matches(invoice.partyName)) {
      return false;
    }
    if (filters.transactionTypeColumnFilter != null &&
        !filters.transactionTypeColumnFilter!.matches(
          invoice.transactionType,
        )) {
      return false;
    }
    if (filters.paymentTypeColumnFilter != null &&
        !filters.paymentTypeColumnFilter!.matches(invoice.paymentType)) {
      return false;
    }
    if (filters.amountColumnFilter != null &&
        !filters.amountColumnFilter!.matches(invoice.amount)) {
      return false;
    }
    if (filters.loyaltyColumnFilter != null &&
        !filters.loyaltyColumnFilter!.matches(invoice.loyaltyRedeemed)) {
      return false;
    }
    if (filters.balanceColumnFilter != null &&
        !filters.balanceColumnFilter!.matches(invoice.balance)) {
      return false;
    }
    if (paymentStatus != null && invoice.status != paymentStatus) {
      return false;
    }
    if (filters.selectedUser != 'All Users' &&
        invoice.user != filters.selectedUser) {
      return false;
    }
    if (filters.selectedGodown != 'All Godown' &&
        invoice.godown != filters.selectedGodown) {
      return false;
    }
    if (filters.selectedFirm != 'All Firms' &&
        invoice.firm != filters.selectedFirm) {
      return false;
    }
    return true;
  }).toList();
}

List<String> _withAllOption(String allLabel, Iterable<String> values) {
  final unique =
      values
          .map((value) => value.trim())
          .where((value) {
            return value.isNotEmpty && value != allLabel;
          })
          .toSet()
          .toList()
        ..sort();
  return [allLabel, ...unique];
}

@riverpod
List<String> saleInvoiceFirmFilterOptions(Ref ref) {
  final authState = ref.watch(authProvider);
  final businesses = authState.session?.businesses ?? [];
  final names = businesses.map((business) => business.name);
  final currentBusiness = ref.watch(currentBusinessProvider);
  return _withAllOption(
    'All Firms',
    [
      if (currentBusiness != null) currentBusiness.name,
      ...names,
    ],
  );
}

@riverpod
List<String> saleInvoiceUserFilterOptions(Ref ref) {
  final authState = ref.watch(authProvider);
  final authUser = authState.session?.user;
  final invoices = saleInvoiceItemsFromPaginatedAsync(
    ref.watch(saleInvoicesProvider),
  );

  return _withAllOption(
    'All Users',
    [
      if (authUser?.name?.trim().isNotEmpty == true) authUser!.name!,
      if (authUser?.phone.trim().isNotEmpty == true) authUser!.phone,
      ...invoices.map((invoice) => invoice.user),
    ],
  );
}

const _saleInvoiceTransactionTypeOptions = [
  'Sale',
  'Estimate',
  'Sale Order',
  'Delivery Challan',
  'Bill of Supply',
  'Normal Invoice',
  'POS',
  'Credit Note',
];

List<String> _uniqueSortedValues(Iterable<String> values) {
  return values
      .map((value) => value.trim())
      .where((value) => value.isNotEmpty)
      .toSet()
      .toList()
    ..sort();
}

@riverpod
List<String> saleInvoiceTransactionTypeFilterOptions(Ref ref) {
  final invoices = saleInvoiceItemsFromPaginatedAsync(
    ref.watch(saleInvoicesProvider),
  );
  return _uniqueSortedValues([
    ..._saleInvoiceTransactionTypeOptions,
    ...invoices.map((invoice) => invoice.transactionType),
  ]);
}

@riverpod
List<String> saleInvoicePaymentTypeFilterOptions(Ref ref) {
  final invoices = saleInvoiceItemsFromPaginatedAsync(
    ref.watch(saleInvoicesProvider),
  );
  return _uniqueSortedValues([
    ...SaleDropdownOptions.paymentTypes,
    ...invoices.map((invoice) => invoice.paymentType),
  ]);
}

@riverpod
List<String> saleInvoiceGodownFilterOptions(Ref ref) {
  final godownsAsync = ref.watch(inventoryGodownsProvider);
  final invoices = saleInvoiceItemsFromPaginatedAsync(
    ref.watch(saleInvoicesProvider),
  );

  final godownNames = godownsAsync.maybeWhen(
    data: (godowns) => godowns.map((godown) => godown.name),
    orElse: () => const <String>[],
  );

  return _withAllOption(
    'All Godown',
    [
      ...godownNames,
      ...invoices.map((invoice) => invoice.godown),
    ],
  );
}

@riverpod
class SaleInvoiceSearchQuery extends _$SaleInvoiceSearchQuery {
  @override
  String build() => '';

  void setQuery(String value) {
    state = value;
    ref.read(saleInvoiceFiltersProvider.notifier).setPage(1);
  }
}

@riverpod
class SelectedSaleInvoiceId extends _$SelectedSaleInvoiceId {
  @override
  String? build() => null;

  void select(String id) => state = id;

  void clear() => state = null;
}

PaginatedSaleInvoices _allInvoicesPage(List<SaleInvoiceModel> allInvoices) {
  return PaginatedSaleInvoices(
    items: allInvoices,
    currentPage: 1,
    totalPages: 1,
    totalItems: allInvoices.length,
  );
}

@Riverpod(keepAlive: true)
class SaleInvoices extends _$SaleInvoices {
  @override
  Future<PaginatedSaleInvoices> build() async {
    ref.watch(
      saleInvoiceFiltersProvider.select(
        (filters) => (filters.timeRangeOption, filters.customDateRange),
      ),
    );
    final allInvoices = await _fetchAllInvoices();
    return _allInvoicesPage(allInvoices);
  }

  Future<List<SaleInvoiceModel>> _fetchAllInvoices() async {
    final filters = ref.read(saleInvoiceFiltersProvider);
    final service = await ref.read(salesServiceProvider.future);
    final partyNames = await service.fetchPartyNameMap();

    return PaginatedFetch.fetchAll<SaleInvoiceModel>(
      fetchPage: (page) async {
        final result = await service.fetchInvoicesPage(
          _buildListQuery(
            filters,
            '',
            page: page,
            limit: PaginatedFetch.defaultPageSize,
          ),
          partyNames: partyNames,
        );
        return (items: result.items, totalPages: result.totalPages);
      },
    );
  }

  Future<void> refresh() async {
    if (!state.hasValue) {
      state = const AsyncLoading();
    }
    state = await AsyncValue.guard(() async {
      final allInvoices = await _fetchAllInvoices();
      return _allInvoicesPage(allInvoices);
    });
  }

  Future<String?> deleteDraft(String documentId) async {
    final previous = state;
    final current = state.value;
    if (current != null) {
      state = AsyncData(
        PaginatedSaleInvoices(
          items: current.items.where((item) => item.id != documentId).toList(),
          currentPage: current.currentPage,
          totalPages: current.totalPages,
          totalItems: current.totalItems - 1,
        ),
      );
    }

    try {
      final service = await ref.read(salesServiceProvider.future);
      await service.deleteDraft(documentId);
      await refreshAfterSaleMutation(ref);
      return null;
    } catch (error) {
      state = previous;
      return SalesErrorMapper.messageFor(error);
    }
  }

  Future<String?> cancelInvoice(String documentId) async {
    try {
      final service = await ref.read(salesServiceProvider.future);
      await service.cancelSale(documentId);
      await refreshAfterSaleMutation(ref);
      return null;
    } catch (error) {
      return SalesErrorMapper.messageFor(error);
    }
  }

  Future<String?> deleteSale(SaleInvoiceModel invoice) async {
    try {
      if (invoice.isDraft) {
        final service = await ref.read(salesServiceProvider.future);
        await service.deleteDraft(invoice.id);
      } else {
        await ref.read(transactionLifecycleServiceProvider).deleteTransaction(
              entityType: 'sales_document',
              entityId: invoice.id,
            );
      }
      await refreshAfterSaleMutation(ref);
      return null;
    } catch (error) {
      return SalesErrorMapper.messageFor(error);
    }
  }

  Future<String?> deleteInvoice(String documentId) async {
    final current = state.value;
    SaleInvoiceModel? invoice;
    for (final item in current?.items ?? const <SaleInvoiceModel>[]) {
      if (item.id == documentId) {
        invoice = item;
        break;
      }
    }
    if (invoice != null && !invoice.isDraft) {
      try {
        await ref.read(transactionLifecycleServiceProvider).deleteTransaction(
              entityType: 'sales_document',
              entityId: documentId,
            );
        await refreshAfterSaleMutation(ref);
        return null;
      } catch (error) {
        return SalesErrorMapper.messageFor(error);
      }
    }
    return deleteDraft(documentId);
  }

  Future<String?> finalizeInvoice(String documentId) async {
    try {
      final service = await ref.read(salesServiceProvider.future);
      await service.finalizeDraft(documentId);
      await refreshAfterSaleMutation(ref);
      // ignore: unawaited_futures
      WhatsAppAutoNotify.afterSaleFinalize(ref, documentId: documentId);
      return null;
    } catch (error) {
      return SalesErrorMapper.messageFor(error);
    }
  }
}

@riverpod
class SaleInvoiceFilters extends _$SaleInvoiceFilters {
  @override
  SaleInvoiceFiltersState build() {
    final now = DateTime.now();
    return SaleInvoiceFiltersState(
      timeRangeOption: TimeRangeOption.custom,
      customDateRange: DateTimeRange(
        start: DateTime(now.year, now.month),
        end: DateTime(now.year, now.month + 1, 0),
      ),
    );
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

  void setUser(String user) {
    state = state.copyWith(selectedUser: user, currentPage: 1);
  }

  void setGodown(String godown) {
    state = state.copyWith(selectedGodown: godown, currentPage: 1);
  }

  void setFirm(String firm) {
    state = state.copyWith(selectedFirm: firm, currentPage: 1);
  }

  void setStatus(String status) {
    state = state.copyWith(selectedStatus: status, currentPage: 1);
  }

  void setDateColumnFilter(DateColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearDateColumnFilter: true, currentPage: 1)
        : state.copyWith(dateColumnFilter: filter, currentPage: 1);
  }

  void setDueDateColumnFilter(DateColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearDueDateColumnFilter: true, currentPage: 1)
        : state.copyWith(dueDateColumnFilter: filter, currentPage: 1);
  }

  void setInvoiceNoColumnFilter(TextColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearInvoiceNoColumnFilter: true, currentPage: 1)
        : state.copyWith(invoiceNoColumnFilter: filter, currentPage: 1);
  }

  void setPartyNameColumnFilter(TextColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearPartyNameColumnFilter: true, currentPage: 1)
        : state.copyWith(partyNameColumnFilter: filter, currentPage: 1);
  }

  void setTransactionTypeColumnFilter(SelectColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearTransactionTypeColumnFilter: true, currentPage: 1)
        : state.copyWith(transactionTypeColumnFilter: filter, currentPage: 1);
  }

  void setPaymentTypeColumnFilter(SelectColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearPaymentTypeColumnFilter: true, currentPage: 1)
        : state.copyWith(paymentTypeColumnFilter: filter, currentPage: 1);
  }

  void setAmountColumnFilter(AmountColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearAmountColumnFilter: true, currentPage: 1)
        : state.copyWith(amountColumnFilter: filter, currentPage: 1);
  }

  void setLoyaltyColumnFilter(RangeSliderColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearLoyaltyColumnFilter: true, currentPage: 1)
        : state.copyWith(loyaltyColumnFilter: filter, currentPage: 1);
  }

  void setBalanceColumnFilter(AmountColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearBalanceColumnFilter: true, currentPage: 1)
        : state.copyWith(balanceColumnFilter: filter, currentPage: 1);
  }

  void setPage(int page) {
    state = state.copyWith(currentPage: page);
  }
}

@riverpod
List<SaleInvoiceModel> filteredSaleInvoices(Ref ref) {
  final allInvoices = saleInvoiceItemsFromPaginatedAsync(
    ref.watch(saleInvoicesProvider),
  );
  final filters = ref.watch(saleInvoiceFiltersProvider);
  final searchQuery = ref.watch(saleInvoiceSearchQueryProvider);
  return applySaleInvoiceClientFilters(
    allInvoices,
    filters,
    searchQuery: searchQuery,
  );
}

@riverpod
PaginatedSaleInvoices paginatedSaleInvoices(Ref ref) {
  final filtered = ref.watch(filteredSaleInvoicesProvider);
  final filters = ref.watch(saleInvoiceFiltersProvider);
  return paginateSaleInvoiceItems(filtered, filters);
}

@riverpod
SaleInvoiceSummaryData saleInvoiceSummary(Ref ref) {
  final invoices = ref.watch(filteredSaleInvoicesProvider);
  final totalSalesAmount = invoices.fold<double>(
    0,
    (sum, invoice) => sum + invoice.amount,
  );
  final balanceAmount = invoices.fold<double>(
    0,
    (sum, invoice) => sum + invoice.balance,
  );
  final receivedAmount = totalSalesAmount - balanceAmount;
  final loyaltyPointsRewarded = totalSalesAmount / 100;
  final totalDiscountRedeemed = invoices.fold<double>(
    0,
    (sum, invoice) => sum + invoice.loyaltyRedeemed,
  );

  return SaleInvoiceSummaryData(
    totalSalesAmount: totalSalesAmount,
    receivedAmount: receivedAmount,
    balanceAmount: balanceAmount,
    loyaltyPointsRewarded: loyaltyPointsRewarded,
    totalDiscountRedeemed: totalDiscountRedeemed,
  );
}
