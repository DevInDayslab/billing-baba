import 'package:billing_baba/features/export/utils/paginated_fetch.dart';
import 'package:billing_baba/features/purchases/application/purchase_error_mapper.dart';
import 'package:billing_baba/features/purchases/application/purchase_fa_service.dart';
import 'package:billing_baba/features/purchases/application/purchase_list_filter_utils.dart';
import 'package:billing_baba/features/purchases/models/purchase_fa_model.dart';
import 'package:billing_baba/features/purchases/models/requests/purchase_fa_requests.dart';
import 'package:billing_baba/features/purchases/presentation/desktop/widgets/shared/purchase_shared_column_filters.dart';
import 'package:billing_baba/features/sales/application/sale_invoices_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'purchase_fa_provider.g.dart';

const purchaseFaPageSize = 10;

/// One-shot success message shown on the purchase FA list after save.
final purchaseFaSaveSuccessMessageProvider =
    NotifierProvider<PurchaseFaSaveSuccessMessage, String?>(
      PurchaseFaSaveSuccessMessage.new,
    );

class PurchaseFaSaveSuccessMessage extends Notifier<String?> {
  @override
  String? build() => null;

  void setMessage(String? value) => state = value;
}

class PurchaseFaFiltersState {
  const PurchaseFaFiltersState({
    this.timeRangeOption = TimeRangeOption.thisMonth,
    this.customDateRange,
    this.selectedFirm = 'All Firms',
    this.selectedGodown = 'All Godown',
    this.selectedUser = 'All Users',
    this.selectedStatus = 'All Status',
    this.currentPage = 1,
    this.columnFilters = const PurchaseColumnFilterFields(),
  });

  final TimeRangeOption timeRangeOption;
  final DateTimeRange? customDateRange;
  final String selectedFirm;
  final String selectedGodown;
  final String selectedUser;
  final String selectedStatus;
  final int currentPage;
  final PurchaseColumnFilterFields columnFilters;

  String get timeRangeLabel => timeRangeOption.label;

  bool get hasActiveFilters =>
      timeRangeOption != TimeRangeOption.thisMonth ||
      customDateRange != null ||
      selectedFirm != 'All Firms' ||
      selectedGodown != 'All Godown' ||
      selectedUser != 'All Users' ||
      selectedStatus != 'All Status' ||
      columnFilters.hasColumnFilters;

  PurchaseFaFiltersState copyWith({
    TimeRangeOption? timeRangeOption,
    DateTimeRange? customDateRange,
    bool clearCustomDateRange = false,
    String? selectedFirm,
    String? selectedGodown,
    String? selectedUser,
    String? selectedStatus,
    int? currentPage,
    PurchaseColumnFilterFields? columnFilters,
  }) {
    return PurchaseFaFiltersState(
      timeRangeOption: timeRangeOption ?? this.timeRangeOption,
      customDateRange: clearCustomDateRange
          ? null
          : (customDateRange ?? this.customDateRange),
      selectedFirm: selectedFirm ?? this.selectedFirm,
      selectedGodown: selectedGodown ?? this.selectedGodown,
      selectedUser: selectedUser ?? this.selectedUser,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      currentPage: currentPage ?? this.currentPage,
      columnFilters: columnFilters ?? this.columnFilters,
    );
  }
}

class PaginatedPurchaseFaRecords {
  const PaginatedPurchaseFaRecords({
    required this.items,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
  });

  final List<PurchaseFaModel> items;
  final int currentPage;
  final int totalPages;
  final int totalItems;
}

PurchaseFaStatus? _paymentStatusFromFilterLabel(String label) =>
    switch (label) {
      'Paid' => PurchaseFaStatus.paid,
      'Unpaid' => PurchaseFaStatus.unpaid,
      'Partially Paid' => PurchaseFaStatus.partiallyPaid,
      'Partial' => PurchaseFaStatus.partiallyPaid,
      'Overdue' => PurchaseFaStatus.overdue,
      'Cancelled' => PurchaseFaStatus.cancelled,
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

PurchaseFaListQuery _buildListQuery(PurchaseFaFiltersState filters) {
  final dateRange = _resolveTimeRange(
    filters.timeRangeOption,
    filters.customDateRange,
  );

  return PurchaseFaListQuery(
    limit: PaginatedFetch.defaultPageSize,
    status: _documentStatusFromFilterLabel(filters.selectedStatus),
    from: dateRange?.start.toUtc().toIso8601String().split('T').first,
    to: dateRange?.end.toUtc().toIso8601String().split('T').first,
  );
}

List<PurchaseFaModel> _applyFilters(
  List<PurchaseFaModel> records,
  PurchaseFaFiltersState filters,
  String globalSearch,
) {
  final paymentStatus = _paymentStatusFromFilterLabel(filters.selectedStatus);
  final columns = filters.columnFilters;

  return records.where((record) {
    if (!purchaseFilterMatchesGlobalSearch(globalSearch, [
      record.invoiceNo,
      record.partyName,
      record.paymentType,
    ])) {
      return false;
    }

    if (!purchaseFilterMatchesText(
      columns.documentNoFilter,
      record.invoiceNo,
    )) {
      return false;
    }

    if (columns.columnDateRange != null &&
        !purchaseFilterIsWithinDateRange(
          record.date,
          columns.columnDateRange!,
        )) {
      return false;
    }

    if (!purchaseFilterMatchesParty(columns.selectedParty, record.partyName)) {
      return false;
    }

    if (!purchaseFilterMatchesPaymentTypes(
      columns.selectedPaymentTypes,
      record.paymentType,
    )) {
      return false;
    }

    if (!purchaseFilterMatchesNumericFilter(
      record.amount,
      columns.amountFilter,
    )) {
      return false;
    }

    if (!purchaseFilterMatchesNumericFilter(
      record.balanceDue,
      columns.balanceFilter,
    )) {
      return false;
    }

    if (columns.dueDateRange != null &&
        !purchaseFilterIsWithinDateRange(
          record.dueDate,
          columns.dueDateRange!,
        )) {
      return false;
    }

    if (paymentStatus != null && record.status != paymentStatus) {
      return false;
    }

    if (filters.selectedUser != 'All Users' &&
        record.user != filters.selectedUser) {
      return false;
    }
    if (filters.selectedFirm != 'All Firms' &&
        record.firm != filters.selectedFirm) {
      return false;
    }
    if (filters.selectedGodown != 'All Godown' &&
        record.godown != filters.selectedGodown) {
      return false;
    }

    return true;
  }).toList();
}

PaginatedPurchaseFaRecords _paginateFilteredRecords(
  List<PurchaseFaModel> filtered,
  int currentPage,
) {
  final slice = purchaseFilterPaginate(
    filtered,
    currentPage,
    purchaseFaPageSize,
  );
  return PaginatedPurchaseFaRecords(
    items: slice.items,
    currentPage: slice.currentPage,
    totalPages: slice.totalPages,
    totalItems: slice.totalItems,
  );
}

PaginatedPurchaseFaRecords _allRecordsPage(List<PurchaseFaModel> allRecords) {
  return PaginatedPurchaseFaRecords(
    items: allRecords,
    currentPage: 1,
    totalPages: 1,
    totalItems: allRecords.length,
  );
}

List<PurchaseFaModel> _allRecordsFromAsync(
  AsyncValue<PaginatedPurchaseFaRecords> recordsAsync,
) {
  return recordsAsync.when(
    data: (page) => page.items,
    loading: () => const [],
    error: (_, _) => const [],
  );
}

@Riverpod(keepAlive: true)
class PurchaseFaSearchQuery extends _$PurchaseFaSearchQuery {
  @override
  String build() => '';

  void setQuery(String value) {
    state = value;
    final filters = ref.read(purchaseFaFiltersProvider);
    if (filters.currentPage != 1) {
      ref.read(purchaseFaFiltersProvider.notifier).setPage(1);
    }
  }
}

@Riverpod(keepAlive: true)
class PurchaseFa extends _$PurchaseFa {
  @override
  Future<PaginatedPurchaseFaRecords> build() async {
    ref.watch(
      purchaseFaFiltersProvider.select(
        (filters) => (filters.timeRangeOption, filters.customDateRange),
      ),
    );
    ref.watch(
      purchaseFaFiltersProvider.select(
        (filters) => _documentStatusFromFilterLabel(filters.selectedStatus),
      ),
    );
    final allRecords = await _fetchAllRecords();
    return _allRecordsPage(allRecords);
  }

  Future<List<PurchaseFaModel>> _fetchAllRecords() async {
    final filters = ref.read(purchaseFaFiltersProvider);
    final service = await ref.read(purchaseFaServiceProvider.future);

    return PaginatedFetch.fetchAll(
      fetchPage: (page) async {
        final baseQuery = _buildListQuery(filters);
        final query = PurchaseFaListQuery(
          page: page,
          limit: baseQuery.limit,
          status: baseQuery.status,
          from: baseQuery.from,
          to: baseQuery.to,
        );
        final pageResult = await service.fetchBatchesPage(query);
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
      final allRecords = await _fetchAllRecords();
      return _allRecordsPage(allRecords);
    });
  }

  Future<String?> deleteBatch(String batchId) async {
    final previous = state;
    final current = state.value;
    if (current != null) {
      state = AsyncData(
        PaginatedPurchaseFaRecords(
          items: current.items
              .where((item) => item.batchId != batchId)
              .toList(),
          currentPage: current.currentPage,
          totalPages: current.totalPages,
          totalItems: current.totalItems - 1,
        ),
      );
    }

    try {
      final service = await ref.read(purchaseFaServiceProvider.future);
      await service.deleteBatch(batchId);
      await refresh();
      return null;
    } catch (error) {
      state = previous;
      return PurchaseErrorMapper.messageFor(error);
    }
  }

  Future<({String? error, String? newId})> duplicateRecord(
    String batchId,
  ) async {
    try {
      final service = await ref.read(purchaseFaServiceProvider.future);
      final newId = await service.duplicateBatch(batchId);
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
class PurchaseFaFilters extends _$PurchaseFaFilters {
  @override
  PurchaseFaFiltersState build() => const PurchaseFaFiltersState();

  void setTimeRange(String label) {
    state = state.copyWith(
      timeRangeOption: TimeRangeOptionX.fromLabel(label),
      currentPage: 1,
    );
    ref.invalidate(purchaseFaProvider);
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
    ref.invalidate(purchaseFaProvider);
  }

  void setFirm(String firm) {
    state = state.copyWith(selectedFirm: firm, currentPage: 1);
  }

  void setGodown(String godown) {
    state = state.copyWith(selectedGodown: godown, currentPage: 1);
  }

  void setUser(String user) {
    state = state.copyWith(selectedUser: user, currentPage: 1);
  }

  void setStatus(String status) {
    state = state.copyWith(selectedStatus: status, currentPage: 1);
    if (_documentStatusFromFilterLabel(status) != null) {
      ref.invalidate(purchaseFaProvider);
    }
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

  void togglePaymentType(String paymentType) {
    final updated = Set<String>.from(state.columnFilters.selectedPaymentTypes);
    if (updated.contains(paymentType)) {
      updated.remove(paymentType);
    } else {
      updated.add(paymentType);
    }
    state = state.copyWith(
      columnFilters: state.columnFilters.copyWith(
        selectedPaymentTypes: updated,
      ),
      currentPage: 1,
    );
  }

  void clearPaymentTypes() {
    state = state.copyWith(
      columnFilters: state.columnFilters.copyWith(clearPaymentTypes: true),
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
    state = const PurchaseFaFiltersState();
    ref.read(purchaseFaSearchQueryProvider.notifier).setQuery('');
    ref.invalidate(purchaseFaProvider);
  }
}

@riverpod
List<PurchaseFaModel> filteredPurchaseFaRecords(Ref ref) {
  final allRecords = _allRecordsFromAsync(ref.watch(purchaseFaProvider));
  final filters = ref.watch(purchaseFaFiltersProvider);
  final search = ref.watch(purchaseFaSearchQueryProvider);
  return _applyFilters(allRecords, filters, search);
}

@riverpod
PaginatedPurchaseFaRecords paginatedPurchaseFaRecords(Ref ref) {
  final filtered = ref.watch(filteredPurchaseFaRecordsProvider);
  final filters = ref.watch(purchaseFaFiltersProvider);
  return _paginateFilteredRecords(filtered, filters.currentPage);
}

@riverpod
List<String> purchaseFaPartyOptions(Ref ref) {
  final allRecords = _allRecordsFromAsync(ref.watch(purchaseFaProvider));
  return purchasePartyOptionsFromNames(
    allRecords.map((record) => record.partyName),
  );
}

class PurchaseFaSummaryData {
  const PurchaseFaSummaryData({
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

@riverpod
PurchaseFaSummaryData purchaseFaSummary(Ref ref) {
  final records = ref.watch(filteredPurchaseFaRecordsProvider);

  var paidAmount = 0.0;
  var unpaidAmount = 0.0;
  var overdueAmount = 0.0;
  var totalAmount = 0.0;

  for (final record in records) {
    totalAmount += record.amount;
    paidAmount += record.paidAmount;
    if (record.status == PurchaseFaStatus.overdue) {
      overdueAmount += record.balanceDue;
    } else if (record.status == PurchaseFaStatus.unpaid ||
        record.status == PurchaseFaStatus.partiallyPaid) {
      unpaidAmount += record.balanceDue;
    }
  }

  return PurchaseFaSummaryData(
    paidAmount: paidAmount,
    unpaidAmount: unpaidAmount,
    overdueAmount: overdueAmount,
    totalAmount: totalAmount,
  );
}
