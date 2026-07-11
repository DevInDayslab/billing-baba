import 'package:billing_baba/features/auth/providers/auth_provider.dart';
import 'package:billing_baba/features/business/application/business_service.dart';
import 'package:billing_baba/features/export/utils/paginated_fetch.dart';
import 'package:billing_baba/features/inventory/providers/inventory_godowns_provider.dart';
import 'package:billing_baba/features/sales/application/sales_error_mapper.dart';
import 'package:billing_baba/features/sales/application/sales_service.dart';
import 'package:billing_baba/features/sales/models/requests/sales_requests.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_model.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_column_amount_filter.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_column_date_filter.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_column_text_filter.dart';
import 'package:billing_baba/features/sales/providers/sale_invoices_provider.dart';
import 'package:billing_baba/features/sales/sales_constants.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'estimate_quotation_provider.g.dart';

const estimateQuotationsPageSize = 10;

class EstimateQuotationFiltersState {
  const EstimateQuotationFiltersState({
    this.timeRangeOption = TimeRangeOption.thisMonth,
    this.customDateRange,
    this.dateColumnFilter,
    this.referenceNoColumnFilter,
    this.partyNameColumnFilter,
    this.amountColumnFilter,
    this.selectedFirm = 'All Firms',
    this.selectedUser = 'All Users',
    this.selectedGodown = 'All Godown',
    this.selectedStatus = 'All Status',
    this.currentPage = 1,
  });

  final TimeRangeOption timeRangeOption;
  final DateTimeRange? customDateRange;
  final DateColumnFilter? dateColumnFilter;
  final TextColumnFilter? referenceNoColumnFilter;
  final TextColumnFilter? partyNameColumnFilter;
  final AmountColumnFilter? amountColumnFilter;
  final String selectedFirm;
  final String selectedUser;
  final String selectedGodown;
  final String selectedStatus;
  final int currentPage;

  String get timeRangeLabel => timeRangeOption.label;

  EstimateQuotationFiltersState copyWith({
    TimeRangeOption? timeRangeOption,
    DateTimeRange? customDateRange,
    bool clearCustomDateRange = false,
    DateColumnFilter? dateColumnFilter,
    bool clearDateColumnFilter = false,
    TextColumnFilter? referenceNoColumnFilter,
    bool clearReferenceNoColumnFilter = false,
    TextColumnFilter? partyNameColumnFilter,
    bool clearPartyNameColumnFilter = false,
    AmountColumnFilter? amountColumnFilter,
    bool clearAmountColumnFilter = false,
    String? selectedUser,
    String? selectedGodown,
    String? selectedFirm,
    String? selectedStatus,
    int? currentPage,
  }) {
    return EstimateQuotationFiltersState(
      timeRangeOption: timeRangeOption ?? this.timeRangeOption,
      customDateRange: clearCustomDateRange
          ? null
          : (customDateRange ?? this.customDateRange),
      dateColumnFilter: clearDateColumnFilter
          ? null
          : (dateColumnFilter ?? this.dateColumnFilter),
      referenceNoColumnFilter: clearReferenceNoColumnFilter
          ? null
          : (referenceNoColumnFilter ?? this.referenceNoColumnFilter),
      partyNameColumnFilter: clearPartyNameColumnFilter
          ? null
          : (partyNameColumnFilter ?? this.partyNameColumnFilter),
      amountColumnFilter: clearAmountColumnFilter
          ? null
          : (amountColumnFilter ?? this.amountColumnFilter),
      selectedUser: selectedUser ?? this.selectedUser,
      selectedGodown: selectedGodown ?? this.selectedGodown,
      selectedFirm: selectedFirm ?? this.selectedFirm,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

class EstimateQuotationSummaryData {
  const EstimateQuotationSummaryData({
    required this.totalQuotationsAmount,
    required this.convertedAmount,
    required this.openAmount,
  });

  final double totalQuotationsAmount;
  final double convertedAmount;
  final double openAmount;
}

SalesDocumentStatus? _estimateStatusFromFilterLabel(String label) =>
    switch (label) {
      'Open' => SalesDocumentStatus.finalized,
      'Converted' => SalesDocumentStatus.converted,
      'Cancelled' => SalesDocumentStatus.cancelled,
      'Draft' => SalesDocumentStatus.draft,
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

SalesDocumentListQuery _buildEstimateListQuery(
  EstimateQuotationFiltersState filters,
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
    limit: limit ?? estimateQuotationsPageSize,
    documentType: SalesDocumentType.estimate.apiValue,
    status: _estimateStatusFromFilterLabel(filters.selectedStatus)?.apiValue,
    from: dateRange?.start.toUtc().toIso8601String(),
    to: dateRange?.end.toUtc().toIso8601String(),
    q: searchQuery.trim().isEmpty ? null : searchQuery.trim(),
  );
}

bool needsEstimateClientSideFiltering(EstimateQuotationFiltersState filters) {
  return filters.dateColumnFilter != null ||
      filters.referenceNoColumnFilter != null ||
      filters.partyNameColumnFilter != null ||
      filters.amountColumnFilter != null ||
      filters.selectedStatus != 'All Status' ||
      filters.selectedUser != 'All Users' ||
      filters.selectedGodown != 'All Godown' ||
      filters.selectedFirm != 'All Firms';
}

List<SaleInvoiceModel> _filterEstimateSeries(List<SaleInvoiceModel> items) {
  return items
      .where(
        (item) => item.documentSeries == SalesConstants.estimateSeries,
      )
      .toList();
}

PaginatedSaleInvoices paginateEstimateItems(
  List<SaleInvoiceModel> items,
  EstimateQuotationFiltersState filters,
) {
  final totalItems = items.length;
  final totalPages = totalItems == 0
      ? 1
      : (totalItems / estimateQuotationsPageSize).ceil();
  final currentPage = filters.currentPage.clamp(1, totalPages);
  final start = (currentPage - 1) * estimateQuotationsPageSize;
  final pageItems = items.skip(start).take(estimateQuotationsPageSize).toList();

  return PaginatedSaleInvoices(
    items: pageItems,
    currentPage: currentPage,
    totalPages: totalPages,
    totalItems: totalItems,
  );
}

List<SaleInvoiceModel> applyEstimateClientFilters(
  List<SaleInvoiceModel> estimates,
  EstimateQuotationFiltersState filters,
) {
  final documentStatus = _estimateStatusFromFilterLabel(filters.selectedStatus);

  return estimates.where((estimate) {
    if (filters.dateColumnFilter != null &&
        !filters.dateColumnFilter!.matches(estimate.date)) {
      return false;
    }
    if (filters.referenceNoColumnFilter != null &&
        !filters.referenceNoColumnFilter!.matches(estimate.invoiceNo)) {
      return false;
    }
    if (filters.partyNameColumnFilter != null &&
        !filters.partyNameColumnFilter!.matches(estimate.partyName)) {
      return false;
    }
    if (filters.amountColumnFilter != null &&
        !filters.amountColumnFilter!.matches(estimate.amount)) {
      return false;
    }
    if (documentStatus != null &&
        estimate.documentStatus != documentStatus) {
      return false;
    }
    if (filters.selectedUser != 'All Users' &&
        estimate.user != filters.selectedUser) {
      return false;
    }
    if (filters.selectedGodown != 'All Godown' &&
        estimate.godown != filters.selectedGodown) {
      return false;
    }
    if (filters.selectedFirm != 'All Firms' &&
        estimate.firm != filters.selectedFirm) {
      return false;
    }
    return true;
  }).toList();
}

double estimateBalanceFor(SaleInvoiceModel estimate) {
  return switch (estimate.documentStatus) {
    SalesDocumentStatus.finalized => estimate.amount,
    SalesDocumentStatus.draft => estimate.amount,
    _ => 0,
  };
}

List<String> _withAllOption(String allLabel, Iterable<String> values) {
  final unique = values.map((value) => value.trim()).where((value) {
    return value.isNotEmpty && value != allLabel;
  }).toSet().toList()
    ..sort();
  return [allLabel, ...unique];
}

@riverpod
List<String> estimateFirmFilterOptions(Ref ref) {
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
List<String> estimateUserFilterOptions(Ref ref) {
  final authState = ref.watch(authProvider);
  final authUser = authState.session?.user;
  final estimates = ref.watch(estimateQuotationsProvider).value?.items ?? [];

  return _withAllOption(
    'All Users',
    [
      if (authUser?.name?.trim().isNotEmpty == true) authUser!.name!,
      if (authUser?.phone.trim().isNotEmpty == true) authUser!.phone,
      ...estimates.map((estimate) => estimate.user),
    ],
  );
}

@riverpod
List<String> estimateGodownFilterOptions(Ref ref) {
  final godownsAsync = ref.watch(inventoryGodownsProvider);
  final estimates = ref.watch(estimateQuotationsProvider).value?.items ?? [];

  final godownNames = godownsAsync.maybeWhen(
    data: (godowns) => godowns.map((godown) => godown.name),
    orElse: () => const <String>[],
  );

  return _withAllOption(
    'All Godown',
    [
      ...godownNames,
      ...estimates.map((estimate) => estimate.godown),
    ],
  );
}

@riverpod
class EstimateQuotationSearchQuery extends _$EstimateQuotationSearchQuery {
  @override
  String build() => '';

  void setQuery(String value) => state = value;
}

@riverpod
class SelectedEstimateQuotationId extends _$SelectedEstimateQuotationId {
  @override
  String? build() => null;

  void select(String id) => state = id;

  void clear() => state = null;
}

@Riverpod(keepAlive: true)
class EstimateQuotations extends _$EstimateQuotations {
  @override
  Future<PaginatedSaleInvoices> build() async {
    ref.watch(estimateQuotationFiltersProvider);
    ref.watch(estimateQuotationSearchQueryProvider);
    return _fetchPage();
  }

  Future<PaginatedSaleInvoices> _fetchPage() async {
    final filters = ref.read(estimateQuotationFiltersProvider);
    final search = ref.read(estimateQuotationSearchQueryProvider);
    final service = await ref.read(salesServiceProvider.future);

    if (needsEstimateClientSideFiltering(filters)) {
      final allItems = await PaginatedFetch.fetchAll<SaleInvoiceModel>(
        fetchPage: (page) async {
          final result = await service.fetchInvoicesPage(
            _buildEstimateListQuery(
              filters,
              search,
              page: page,
              limit: PaginatedFetch.defaultPageSize,
            ),
          );
          return (
            items: _filterEstimateSeries(result.items),
            totalPages: result.totalPages,
          );
        },
      );

      final filteredItems = applyEstimateClientFilters(allItems, filters);
      return paginateEstimateItems(filteredItems, filters);
    }

    final page = await service.fetchInvoicesPage(
      _buildEstimateListQuery(filters, search),
    );

    final seriesFiltered = _filterEstimateSeries(page.items);
    return PaginatedSaleInvoices(
      items: seriesFiltered,
      currentPage: page.currentPage,
      totalPages: page.totalPages,
      totalItems: seriesFiltered.length,
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetchPage);
  }

  Future<String?> deleteEstimate(String documentId) async {
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
      await refresh();
      return null;
    } catch (error) {
      state = previous;
      return SalesErrorMapper.messageFor(error);
    }
  }

  Future<String?> cancelEstimate(String documentId) async {
    try {
      final service = await ref.read(salesServiceProvider.future);
      await service.cancelSale(documentId);
      await refresh();
      return null;
    } catch (error) {
      return SalesErrorMapper.messageFor(error);
    }
  }

  Future<String?> finalizeEstimate(String documentId) async {
    try {
      final service = await ref.read(salesServiceProvider.future);
      await service.finalizeDraft(documentId);
      await refresh();
      return null;
    } catch (error) {
      return SalesErrorMapper.messageFor(error);
    }
  }

  Future<String?> convertEstimate(
    String documentId, {
    required String targetType,
  }) async {
    try {
      final service = await ref.read(salesServiceProvider.future);
      await service.convertDocument(
        documentId,
        targetType: targetType,
      );
      await refresh();
      return null;
    } catch (error) {
      return SalesErrorMapper.messageFor(error);
    }
  }
}

@riverpod
class EstimateQuotationFilters extends _$EstimateQuotationFilters {
  @override
  EstimateQuotationFiltersState build() {
    return const EstimateQuotationFiltersState(
      timeRangeOption: TimeRangeOption.thisMonth,
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

  void setReferenceNoColumnFilter(TextColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearReferenceNoColumnFilter: true, currentPage: 1)
        : state.copyWith(referenceNoColumnFilter: filter, currentPage: 1);
  }

  void setPartyNameColumnFilter(TextColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearPartyNameColumnFilter: true, currentPage: 1)
        : state.copyWith(partyNameColumnFilter: filter, currentPage: 1);
  }

  void setAmountColumnFilter(AmountColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearAmountColumnFilter: true, currentPage: 1)
        : state.copyWith(amountColumnFilter: filter, currentPage: 1);
  }

  void setPage(int page) {
    state = state.copyWith(currentPage: page);
  }
}

@riverpod
PaginatedSaleInvoices paginatedEstimateQuotations(Ref ref) {
  final estimatesAsync = ref.watch(estimateQuotationsProvider);
  return estimatesAsync.maybeWhen(
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
EstimateQuotationSummaryData estimateQuotationSummary(Ref ref) {
  final page = ref.watch(paginatedEstimateQuotationsProvider);
  final estimates = page.items;

  var totalAmount = 0.0;
  var convertedAmount = 0.0;
  var openAmount = 0.0;

  for (final estimate in estimates) {
    totalAmount += estimate.amount;
    if (estimate.documentStatus == SalesDocumentStatus.converted) {
      convertedAmount += estimate.amount;
    } else if (estimate.documentStatus == SalesDocumentStatus.finalized) {
      openAmount += estimate.amount;
    }
  }

  return EstimateQuotationSummaryData(
    totalQuotationsAmount: totalAmount,
    convertedAmount: convertedAmount,
    openAmount: openAmount,
  );
}
