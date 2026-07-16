import 'package:billing_baba/features/sales/application/sales_error_mapper.dart';
import 'package:billing_baba/features/sales/application/sales_service.dart';
import 'package:billing_baba/features/sales/models/requests/sales_requests.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_model.dart';
import 'package:billing_baba/features/sales/presentation/widgets/shared/sales_order_summary_cards.dart';
import 'package:billing_baba/features/sales/providers/estimate_quotation_provider.dart';
import 'package:billing_baba/features/sales/providers/sale_invoices_provider.dart';
import 'package:billing_baba/features/sales/providers/sale_return_provider.dart';
import 'package:billing_baba/features/sales/sales_constants.dart';
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
    this.selectedStatus = 'All Status',
    this.currentPage = 1,
  });

  final TimeRangeOption timeRangeOption;
  final DateTimeRange? customDateRange;
  final String selectedStatus;
  final int currentPage;

  String get timeRangeLabel => timeRangeOption.label;

  SalesDocumentFiltersState copyWith({
    TimeRangeOption? timeRangeOption,
    DateTimeRange? customDateRange,
    bool clearCustomDateRange = false,
    String? selectedStatus,
    int? currentPage,
  }) {
    return SalesDocumentFiltersState(
      timeRangeOption: timeRangeOption ?? this.timeRangeOption,
      customDateRange: clearCustomDateRange
          ? null
          : (customDateRange ?? this.customDateRange),
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

SalesDocumentListQuery _buildListQuery(
  SalesDocumentListScope scope,
  SalesDocumentFiltersState filters,
  String searchQuery,
) {
  final dateRange = _resolveTimeRange(
    filters.timeRangeOption,
    filters.customDateRange,
  );

  return SalesDocumentListQuery(
    page: filters.currentPage,
    limit: salesDocumentsPageSize,
    documentType: scope.documentType.apiValue,
    status: _documentStatusFromFilterLabel(filters.selectedStatus),
    from: dateRange?.start.toUtc().toIso8601String(),
    to: dateRange?.end.toUtc().toIso8601String(),
    q: searchQuery.trim().isEmpty ? null : searchQuery.trim(),
  );
}

List<SaleInvoiceModel> _applySeriesFilter(
  List<SaleInvoiceModel> items,
  SalesDocumentListScope scope,
) {
  if (scope.documentSeries == null) return items;
  return items
      .where((item) => item.documentSeries == scope.documentSeries)
      .toList();
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
    ref.invalidate(salesDocumentsListProvider(scope));
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
    ref.invalidate(salesDocumentsListProvider(scope));
  }

  void setStatus(String status) {
    state = state.copyWith(selectedStatus: status, currentPage: 1);
    ref.invalidate(salesDocumentsListProvider(scope));
  }

  void setPage(int page) {
    state = state.copyWith(currentPage: page);
    ref.invalidate(salesDocumentsListProvider(scope));
  }
}

@Riverpod(keepAlive: true)
class SalesDocumentsList extends _$SalesDocumentsList {
  @override
  Future<PaginatedSaleInvoices> build(SalesDocumentListScope scope) async {
    ref.watch(salesDocumentFiltersProvider(scope));
    ref.watch(salesDocumentSearchQueryProvider(scope));
    return _fetchPage(scope);
  }

  Future<PaginatedSaleInvoices> _fetchPage(SalesDocumentListScope scope) async {
    final filters = ref.read(salesDocumentFiltersProvider(scope));
    final search = ref.read(salesDocumentSearchQueryProvider(scope));
    final service = await ref.read(salesServiceProvider.future);
    final page = await service.fetchInvoicesPage(
      _buildListQuery(scope, filters, search),
    );

    final filteredItems = _applySeriesFilter(page.items, scope);
    return PaginatedSaleInvoices(
      items: filteredItems,
      currentPage: page.currentPage,
      totalPages: page.totalPages,
      totalItems: page.totalItems,
      summary: page.summary,
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchPage(scope));
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
PaginatedSaleInvoices paginatedSalesDocuments(
  Ref ref,
  SalesDocumentListScope scope,
) {
  final documentsAsync = ref.watch(salesDocumentsListProvider(scope));
  return documentsAsync.maybeWhen(
    data: (page) => page,
    orElse: () => const PaginatedSaleInvoices(
      items: [],
      currentPage: 1,
      totalPages: 1,
      totalItems: 0,
    ),
  );
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

@Riverpod(keepAlive: true)
Future<SalesOrderSummaryData> salesOrderStatusSummary(Ref ref) async {
  ref.watch(salesDocumentsListProvider(saleOrderListScope()));
  final service = await ref.read(salesServiceProvider.future);
  final items = await service.fetchDocumentsByType(
    SalesDocumentType.saleOrder,
    limit: 500,
  );
  return summarizeSaleOrders(items);
}

SalesDocumentListScope salesReturnListScope() => const SalesDocumentListScope(
  documentType: SalesDocumentType.salesReturn,
);
