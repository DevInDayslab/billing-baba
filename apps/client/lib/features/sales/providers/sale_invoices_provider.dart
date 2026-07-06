import 'package:billing_baba/features/sales/application/sales_error_mapper.dart';
import 'package:billing_baba/features/sales/application/sales_service.dart';
import 'package:billing_baba/features/sales/models/requests/sales_requests.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_model.dart';
import 'package:billing_baba/features/sales/sales_constants.dart';
import 'package:flutter/material.dart';
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
    this.timeRangeOption = TimeRangeOption.allTime,
    this.customDateRange,
    this.selectedUser = 'All Users',
    this.selectedGodown = 'All Godown',
    this.selectedStatus = 'All Status',
    this.currentPage = 1,
  });

  final TimeRangeOption timeRangeOption;
  final DateTimeRange? customDateRange;
  final String selectedUser;
  final String selectedGodown;
  final String selectedStatus;
  final int currentPage;

  String get timeRangeLabel => timeRangeOption.label;

  SaleInvoiceFiltersState copyWith({
    TimeRangeOption? timeRangeOption,
    DateTimeRange? customDateRange,
    bool clearCustomDateRange = false,
    String? selectedUser,
    String? selectedGodown,
    String? selectedStatus,
    int? currentPage,
  }) {
    return SaleInvoiceFiltersState(
      timeRangeOption: timeRangeOption ?? this.timeRangeOption,
      customDateRange: clearCustomDateRange
          ? null
          : (customDateRange ?? this.customDateRange),
      selectedUser: selectedUser ?? this.selectedUser,
      selectedGodown: selectedGodown ?? this.selectedGodown,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

SaleInvoiceStatus? _paymentStatusFromFilterLabel(String label) => switch (label) {
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
  String searchQuery,
) {
  final dateRange = _resolveTimeRange(
    filters.timeRangeOption,
    filters.customDateRange,
  );

  return SalesDocumentListQuery(
    page: filters.currentPage,
    limit: saleInvoicesPageSize,
    documentType: SalesDocumentType.taxInvoice.apiValue,
    status: _documentStatusFromFilterLabel(filters.selectedStatus),
    from: dateRange?.start.toUtc().toIso8601String(),
    to: dateRange?.end.toUtc().toIso8601String(),
    q: searchQuery.trim().isEmpty ? null : searchQuery.trim(),
  );
}

List<SaleInvoiceModel> _applyClientFilters(
  List<SaleInvoiceModel> invoices,
  SaleInvoiceFiltersState filters,
) {
  final paymentStatus = _paymentStatusFromFilterLabel(filters.selectedStatus);

  return invoices.where((invoice) {
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
    return true;
  }).toList();
}

@Riverpod(keepAlive: true)
class SaleInvoiceSearchQuery extends _$SaleInvoiceSearchQuery {
  @override
  String build() => '';

  void setQuery(String value) => state = value;
}

@Riverpod(keepAlive: true)
class SaleInvoices extends _$SaleInvoices {
  @override
  Future<PaginatedSaleInvoices> build() async {
    ref.watch(saleInvoiceFiltersProvider);
    ref.watch(saleInvoiceSearchQueryProvider);
    return _fetchPage();
  }

  Future<PaginatedSaleInvoices> _fetchPage() async {
    final filters = ref.read(saleInvoiceFiltersProvider);
    final search = ref.read(saleInvoiceSearchQueryProvider);
    final service = await ref.read(salesServiceProvider.future);
    final page = await service.fetchInvoicesPage(
      _buildListQuery(filters, search),
    );

    final filteredItems = _applyClientFilters(page.items, filters);
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
          summary: current.summary,
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

  Future<String?> deleteSale(SaleInvoiceModel invoice) async {
    try {
      final service = await ref.read(salesServiceProvider.future);
      if (invoice.isDraft) {
        await service.deleteDraft(invoice.id);
      } else {
        await service.cancelSale(invoice.id);
      }
      await refresh();
      return null;
    } catch (error) {
      return SalesErrorMapper.messageFor(error);
    }
  }

  Future<String?> finalizeInvoice(String documentId) async {
    try {
      final service = await ref.read(salesServiceProvider.future);
      await service.finalizeDraft(documentId);
      await refresh();
      return null;
    } catch (error) {
      return SalesErrorMapper.messageFor(error);
    }
  }
}

@Riverpod(keepAlive: true)
class SaleInvoiceFilters extends _$SaleInvoiceFilters {
  @override
  SaleInvoiceFiltersState build() => const SaleInvoiceFiltersState();

  void setTimeRange(String label) {
    state = state.copyWith(
      timeRangeOption: TimeRangeOptionX.fromLabel(label),
      currentPage: 1,
    );
    ref.invalidate(saleInvoicesProvider);
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
    ref.invalidate(saleInvoicesProvider);
  }

  void setUser(String user) {
    state = state.copyWith(selectedUser: user, currentPage: 1);
    ref.invalidate(saleInvoicesProvider);
  }

  void setGodown(String godown) {
    state = state.copyWith(selectedGodown: godown, currentPage: 1);
    ref.invalidate(saleInvoicesProvider);
  }

  void setStatus(String status) {
    state = state.copyWith(selectedStatus: status, currentPage: 1);
    ref.invalidate(saleInvoicesProvider);
  }

  void setPage(int page) {
    state = state.copyWith(currentPage: page);
    ref.invalidate(saleInvoicesProvider);
  }
}

@riverpod
PaginatedSaleInvoices paginatedSaleInvoices(Ref ref) {
  final invoicesAsync = ref.watch(saleInvoicesProvider);
  return invoicesAsync.maybeWhen(
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
SaleInvoiceSummaryData saleInvoiceSummary(Ref ref) {
  final page = ref.watch(paginatedSaleInvoicesProvider);
  final summary = page.summary;
  if (summary != null) {
    return summary;
  }

  return const SaleInvoiceSummaryData(
    totalSalesAmount: 0,
    receivedAmount: 0,
    balanceAmount: 0,
  );
}
