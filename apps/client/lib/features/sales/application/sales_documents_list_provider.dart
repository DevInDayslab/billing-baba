import 'package:billing_baba/core/providers/data_refresh.dart';
import 'package:billing_baba/features/export/utils/paginated_fetch.dart';
import 'package:billing_baba/features/sales/application/estimate_quotation_provider.dart';
import 'package:billing_baba/features/sales/application/sale_invoices_provider.dart';
import 'package:billing_baba/features/sales/application/sale_orders_provider.dart';
import 'package:billing_baba/features/sales/application/sale_return_provider.dart';
import 'package:billing_baba/features/sales/application/sale_paginated_async_helpers.dart';
import 'package:billing_baba/features/sales/application/sales_error_mapper.dart';
import 'package:billing_baba/features/sales/application/sales_service.dart';
import 'package:billing_baba/features/sales/models/requests/sales_requests.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_model.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/shared/sales_order_summary_cards.dart';
import 'package:billing_baba/features/sales/sales_constants.dart';
import 'package:billing_baba/features/settings/services/whatsapp_auto_notify.dart';
import 'package:billing_baba/shared/widgets/table_filters/table_filters.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sales_documents_list_provider.g.dart';

const salesDocumentsPageSize = 10;

class SalesDocumentListScope {
  const SalesDocumentListScope({
    required this.documentType,
    this.documentSeries,
  });

  final SalesDocumentType documentType;
  final String? documentSeries;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is SalesDocumentListScope &&
            documentType == other.documentType &&
            documentSeries == other.documentSeries;
  }

  @override
  int get hashCode => Object.hash(documentType, documentSeries);
}

class SalesDocumentFiltersState {
  const SalesDocumentFiltersState({
    this.timeRangeOption = TimeRangeOption.allTime,
    this.customDateRange,
    this.dateColumnFilter,
    this.documentNoColumnFilter,
    this.partyNameColumnFilter,
    this.amountColumnFilter,
    this.selectedStatus = 'All Status',
    this.currentPage = 1,
  });

  final TimeRangeOption timeRangeOption;
  final DateTimeRange? customDateRange;
  final DateColumnFilter? dateColumnFilter;
  final TextColumnFilter? documentNoColumnFilter;
  final TextColumnFilter? partyNameColumnFilter;
  final AmountColumnFilter? amountColumnFilter;
  final String selectedStatus;
  final int currentPage;

  String get timeRangeLabel => timeRangeOption.label;

  bool get hasColumnFilters =>
      FilterUtils.isFilterActive(FilterType.date, dateColumnFilter) ||
      FilterUtils.isFilterActive(FilterType.text, documentNoColumnFilter) ||
      FilterUtils.isFilterActive(FilterType.text, partyNameColumnFilter) ||
      FilterUtils.isFilterActive(FilterType.number, amountColumnFilter);

  SalesDocumentFiltersState copyWith({
    TimeRangeOption? timeRangeOption,
    DateTimeRange? customDateRange,
    bool clearCustomDateRange = false,
    DateColumnFilter? dateColumnFilter,
    bool clearDateColumnFilter = false,
    TextColumnFilter? documentNoColumnFilter,
    bool clearDocumentNoColumnFilter = false,
    TextColumnFilter? partyNameColumnFilter,
    bool clearPartyNameColumnFilter = false,
    AmountColumnFilter? amountColumnFilter,
    bool clearAmountColumnFilter = false,
    String? selectedStatus,
    int? currentPage,
  }) {
    return SalesDocumentFiltersState(
      timeRangeOption: timeRangeOption ?? this.timeRangeOption,
      customDateRange: clearCustomDateRange
          ? null
          : (customDateRange ?? this.customDateRange),
      dateColumnFilter: clearDateColumnFilter
          ? null
          : (dateColumnFilter ?? this.dateColumnFilter),
      documentNoColumnFilter: clearDocumentNoColumnFilter
          ? null
          : (documentNoColumnFilter ?? this.documentNoColumnFilter),
      partyNameColumnFilter: clearPartyNameColumnFilter
          ? null
          : (partyNameColumnFilter ?? this.partyNameColumnFilter),
      amountColumnFilter: clearAmountColumnFilter
          ? null
          : (amountColumnFilter ?? this.amountColumnFilter),
      selectedStatus: selectedStatus ?? this.selectedStatus,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

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

SalesDocumentListQuery _buildFetchAllQuery(
  SalesDocumentListScope scope,
  SalesDocumentFiltersState filters,
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
    limit: limit ?? salesDocumentsPageSize,
    documentType: scope.documentType.apiValue,
    documentSeries: scope.documentSeries,
    status: _documentStatusFromFilterLabel(filters.selectedStatus),
    from: dateRange?.start.toUtc().toIso8601String(),
    to: dateRange?.end.toUtc().toIso8601String(),
    q: searchQuery.trim().isEmpty ? null : searchQuery.trim(),
  );
}

bool needsSalesDocumentClientSideFiltering(SalesDocumentFiltersState filters) {
  return filters.hasColumnFilters;
}

PaginatedSaleInvoices paginateSalesDocuments(
  List<SaleInvoiceModel> items,
  int currentPage,
) {
  final totalItems = items.length;
  final totalPages = totalItems == 0
      ? 1
      : (totalItems / salesDocumentsPageSize).ceil();
  final page = currentPage.clamp(1, totalPages);
  final start = (page - 1) * salesDocumentsPageSize;
  final pageItems = items.skip(start).take(salesDocumentsPageSize).toList();

  return PaginatedSaleInvoices(
    items: pageItems,
    currentPage: page,
    totalPages: totalPages,
    totalItems: totalItems,
  );
}

List<SaleInvoiceModel> _applySalesDocumentClientFilters(
  List<SaleInvoiceModel> items,
  SalesDocumentFiltersState filters,
) {
  return items.where((item) {
    if (filters.dateColumnFilter != null &&
        !filters.dateColumnFilter!.matches(item.date)) {
      return false;
    }
    if (filters.documentNoColumnFilter != null &&
        !filters.documentNoColumnFilter!.matches(item.invoiceNo)) {
      return false;
    }
    if (filters.partyNameColumnFilter != null &&
        !filters.partyNameColumnFilter!.matches(item.partyName)) {
      return false;
    }
    if (filters.amountColumnFilter != null &&
        !filters.amountColumnFilter!.matches(item.amount)) {
      return false;
    }
    return true;
  }).toList();
}

@Riverpod(keepAlive: true)
class SalesDocumentSearchQuery extends _$SalesDocumentSearchQuery {
  @override
  String build(SalesDocumentListScope scope) => '';

  void setQuery(String value) => state = value;
}

@Riverpod(keepAlive: true)
class SalesDocumentFilters extends _$SalesDocumentFilters {
  @override
  SalesDocumentFiltersState build(SalesDocumentListScope scope) =>
      const SalesDocumentFiltersState();

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

  void setStatus(String status) {
    state = state.copyWith(selectedStatus: status, currentPage: 1);
  }

  void setDateColumnFilter(DateColumnFilter? filter) {
    state = state.copyWith(
      dateColumnFilter: filter,
      clearDateColumnFilter: filter == null,
      currentPage: 1,
    );
  }

  void setDocumentNoColumnFilter(TextColumnFilter? filter) {
    state = state.copyWith(
      documentNoColumnFilter: filter,
      clearDocumentNoColumnFilter: filter == null,
      currentPage: 1,
    );
  }

  void setPartyNameColumnFilter(TextColumnFilter? filter) {
    state = state.copyWith(
      partyNameColumnFilter: filter,
      clearPartyNameColumnFilter: filter == null,
      currentPage: 1,
    );
  }

  void setAmountColumnFilter(AmountColumnFilter? filter) {
    state = state.copyWith(
      amountColumnFilter: filter,
      clearAmountColumnFilter: filter == null,
      currentPage: 1,
    );
  }

  void setPage(int page) {
    state = state.copyWith(currentPage: page);
  }
}

@Riverpod(keepAlive: true)
class SalesDocumentsList extends _$SalesDocumentsList {
  @override
  Future<PaginatedSaleInvoices> build(SalesDocumentListScope scope) async {
    ref.watch(salesDocumentFiltersProvider(scope));
    ref.watch(salesDocumentSearchQueryProvider(scope));
    return _fetchPage();
  }

  Future<PaginatedSaleInvoices> _fetchPage() async {
    final filters = ref.read(salesDocumentFiltersProvider(scope));
    final search = ref.read(salesDocumentSearchQueryProvider(scope));
    final service = await ref.read(salesServiceProvider.future);
    final partyNames = await service.fetchPartyNameMap();

    if (needsSalesDocumentClientSideFiltering(filters)) {
      final allItems = await PaginatedFetch.fetchAll<SaleInvoiceModel>(
        fetchPage: (page) async {
          final result = await service.fetchInvoicesPage(
            _buildFetchAllQuery(
              scope,
              filters,
              search,
              page: page,
              limit: PaginatedFetch.defaultPageSize,
            ),
            partyNames: partyNames,
          );
          return (items: result.items, totalPages: result.totalPages);
        },
      );
      final filtered = _applySalesDocumentClientFilters(allItems, filters);
      return paginateSalesDocuments(filtered, filters.currentPage);
    }

    final page = await service.fetchInvoicesPage(
      _buildFetchAllQuery(scope, filters, search),
      partyNames: partyNames,
    );
    final filtered = _applySalesDocumentClientFilters(page.items, filters);
    return PaginatedSaleInvoices(
      items: filtered,
      currentPage: page.currentPage,
      totalPages: page.totalPages,
      totalItems: page.totalItems,
      summary: page.summary,
    );
  }

  Future<void> refresh() async {
    if (!state.hasValue) {
      state = const AsyncLoading();
    }
    state = await AsyncValue.guard(_fetchPage);
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
      await refresh();
      return null;
    } catch (error) {
      state = previous;
      return SalesErrorMapper.messageFor(error);
    }
  }

  Future<String?> finalizeDocument(
    String documentId, {
    String? godownId,
  }) async {
    try {
      final service = await ref.read(salesServiceProvider.future);
      await service.finalizeDraft(documentId, godownId: godownId);
      await refresh();
      _invalidateRelatedLists(ref);
      await refreshAfterSaleMutation(ref);
      final isSaleInvoice =
          scope.documentType == SalesDocumentType.taxInvoice ||
          scope.documentType == SalesDocumentType.billOfSupply ||
          scope.documentType == SalesDocumentType.normalInvoice ||
          scope.documentType == SalesDocumentType.pos;
      if (isSaleInvoice) {
        // ignore: unawaited_futures
        WhatsAppAutoNotify.afterSaleFinalize(ref, documentId: documentId);
      }
      return null;
    } catch (error) {
      return SalesErrorMapper.messageFor(error);
    }
  }

  Future<String?> cancelDocument(String documentId) async {
    try {
      final service = await ref.read(salesServiceProvider.future);
      await service.cancelSale(documentId);
      await refresh();
      _invalidateRelatedLists(ref);
      await refreshAfterSaleMutation(ref);
      return null;
    } catch (error) {
      return SalesErrorMapper.messageFor(error);
    }
  }

  Future<String?> convertDocument(
    String documentId, {
    required String targetType,
    bool applyGst = false,
  }) async {
    try {
      final service = await ref.read(salesServiceProvider.future);
      await service.convertDocument(
        documentId,
        targetType: targetType,
        applyGst: applyGst,
      );
      await refresh();
      _invalidateRelatedLists(ref, targetType: targetType);
      return null;
    } catch (error) {
      return SalesErrorMapper.messageFor(error);
    }
  }
}

void _invalidateRelatedLists(
  Ref ref, {
  String? targetType,
}) {
  ref.invalidate(salesDocumentsListProvider(saleOrderListScope()));
  ref.invalidate(salesDocumentsListProvider(deliveryChallanListScope()));
  ref.invalidate(salesDocumentsListProvider(salesReturnListScope()));
  ref.invalidate(saleReturnsProvider);
  ref.invalidate(salesDocumentsListProvider(estimateListScope()));
  ref.invalidate(salesDocumentsListProvider(proformaListScope()));
  ref.invalidate(saleInvoicesProvider);
  ref.invalidate(estimateQuotationsProvider);

  if (targetType == 'tax_invoice') {
    ref.invalidate(saleInvoicesProvider);
  }
}

@riverpod
List<SaleInvoiceModel> filteredSalesDocuments(
  Ref ref,
  SalesDocumentListScope scope,
) {
  return saleInvoiceItemsFromPaginatedAsync(
    ref.watch(salesDocumentsListProvider(scope)),
  );
}

@riverpod
PaginatedSaleInvoices paginatedSalesDocuments(
  Ref ref,
  SalesDocumentListScope scope,
) {
  return paginatedSaleInvoicesFromAsync(
    ref.watch(salesDocumentsListProvider(scope)),
  );
}

@Riverpod(keepAlive: true)
Future<SalesOrderSummaryData> salesOrderStatusSummary(Ref ref) async {
  final items = ref.watch(filteredSaleOrdersProvider);
  return summarizeSaleOrders(items);
}

SalesDocumentListScope estimateListScope() => const SalesDocumentListScope(
  documentType: SalesDocumentType.estimate,
  documentSeries: SalesConstants.estimateSeries,
);

SalesDocumentListScope proformaListScope() => const SalesDocumentListScope(
  documentType: SalesDocumentType.estimate,
  documentSeries: SalesConstants.proformaSeries,
);

SalesDocumentListScope saleOrderListScope() => const SalesDocumentListScope(
  documentType: SalesDocumentType.saleOrder,
);

SalesDocumentListScope deliveryChallanListScope() =>
    const SalesDocumentListScope(
      documentType: SalesDocumentType.deliveryChallan,
    );

SalesDocumentListScope salesReturnListScope() => const SalesDocumentListScope(
  documentType: SalesDocumentType.salesReturn,
);
