import 'package:billing_baba/core/providers/data_refresh.dart';
import 'package:billing_baba/features/auth/application/auth_provider.dart';
import 'package:billing_baba/features/business/application/business_service.dart';
import 'package:billing_baba/features/export/utils/paginated_fetch.dart';
import 'package:billing_baba/features/inventory/application/inventory_godowns_provider.dart';
import 'package:billing_baba/features/sales/application/sales_error_mapper.dart';
import 'package:billing_baba/features/sales/application/sales_service.dart';
import 'package:billing_baba/features/sales/models/requests/sales_requests.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_model.dart';
import 'package:billing_baba/features/sales/application/sale_invoices_provider.dart';
import 'package:billing_baba/features/sales/sales_constants.dart';
import 'package:billing_baba/shared/widgets/table_filters/table_filters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'delivery_challan_provider.g.dart';

const deliveryChallansPageSize = 10;

class DeliveryChallanFiltersState {
  const DeliveryChallanFiltersState({
    this.timeRangeOption = TimeRangeOption.thisMonth,
    this.customDateRange,
    this.dateColumnFilter,
    this.challanNoColumnFilter,
    this.partyNameColumnFilter,
    this.dueDateColumnFilter,
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
  final TextColumnFilter? challanNoColumnFilter;
  final TextColumnFilter? partyNameColumnFilter;
  final DateColumnFilter? dueDateColumnFilter;
  final AmountColumnFilter? amountColumnFilter;
  final String selectedFirm;
  final String selectedUser;
  final String selectedGodown;
  final String selectedStatus;
  final int currentPage;

  String get timeRangeLabel => timeRangeOption.label;

  DeliveryChallanFiltersState copyWith({
    TimeRangeOption? timeRangeOption,
    DateTimeRange? customDateRange,
    bool clearCustomDateRange = false,
    DateColumnFilter? dateColumnFilter,
    bool clearDateColumnFilter = false,
    TextColumnFilter? challanNoColumnFilter,
    bool clearChallanNoColumnFilter = false,
    TextColumnFilter? partyNameColumnFilter,
    bool clearPartyNameColumnFilter = false,
    DateColumnFilter? dueDateColumnFilter,
    bool clearDueDateColumnFilter = false,
    AmountColumnFilter? amountColumnFilter,
    bool clearAmountColumnFilter = false,
    String? selectedUser,
    String? selectedGodown,
    String? selectedFirm,
    String? selectedStatus,
    int? currentPage,
  }) {
    return DeliveryChallanFiltersState(
      timeRangeOption: timeRangeOption ?? this.timeRangeOption,
      customDateRange: clearCustomDateRange
          ? null
          : (customDateRange ?? this.customDateRange),
      dateColumnFilter: clearDateColumnFilter
          ? null
          : (dateColumnFilter ?? this.dateColumnFilter),
      challanNoColumnFilter: clearChallanNoColumnFilter
          ? null
          : (challanNoColumnFilter ?? this.challanNoColumnFilter),
      partyNameColumnFilter: clearPartyNameColumnFilter
          ? null
          : (partyNameColumnFilter ?? this.partyNameColumnFilter),
      dueDateColumnFilter: clearDueDateColumnFilter
          ? null
          : (dueDateColumnFilter ?? this.dueDateColumnFilter),
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

class DeliveryChallanSummaryData {
  const DeliveryChallanSummaryData({
    required this.totalAmount,
    required this.convertedAmount,
    required this.openAmount,
  });

  final double totalAmount;
  final double convertedAmount;
  final double openAmount;
}

SalesDocumentStatus? _challanStatusFromFilterLabel(String label) =>
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

SalesDocumentListQuery buildChallanListQuery(
  DeliveryChallanFiltersState filters,
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
    limit: limit ?? deliveryChallansPageSize,
    documentType: SalesDocumentType.deliveryChallan.apiValue,
    status: _challanStatusFromFilterLabel(filters.selectedStatus)?.apiValue,
    from: dateRange?.start.toUtc().toIso8601String(),
    to: dateRange?.end.toUtc().toIso8601String(),
    q: searchQuery.trim().isEmpty ? null : searchQuery.trim(),
  );
}

bool needsChallanClientSideFiltering(DeliveryChallanFiltersState filters) {
  return filters.dateColumnFilter != null ||
      filters.challanNoColumnFilter != null ||
      filters.partyNameColumnFilter != null ||
      filters.dueDateColumnFilter != null ||
      filters.amountColumnFilter != null ||
      filters.selectedStatus != 'All Status' ||
      filters.selectedUser != 'All Users' ||
      filters.selectedGodown != 'All Godown' ||
      filters.selectedFirm != 'All Firms';
}

List<SaleInvoiceModel> filterChallanSeries(List<SaleInvoiceModel> items) {
  return items
      .where(
        (item) => item.documentSeries == SalesConstants.challanSeries,
      )
      .toList();
}

PaginatedSaleInvoices paginateChallanItems(
  List<SaleInvoiceModel> items,
  DeliveryChallanFiltersState filters,
) {
  final totalItems = items.length;
  final totalPages = totalItems == 0
      ? 1
      : (totalItems / deliveryChallansPageSize).ceil();
  final currentPage = filters.currentPage.clamp(1, totalPages);
  final start = (currentPage - 1) * deliveryChallansPageSize;
  final pageItems = items.skip(start).take(deliveryChallansPageSize).toList();

  return PaginatedSaleInvoices(
    items: pageItems,
    currentPage: currentPage,
    totalPages: totalPages,
    totalItems: totalItems,
  );
}

List<SaleInvoiceModel> applyChallanClientFilters(
  List<SaleInvoiceModel> challans,
  DeliveryChallanFiltersState filters,
) {
  final documentStatus = _challanStatusFromFilterLabel(filters.selectedStatus);

  return challans.where((challan) {
    if (filters.dateColumnFilter != null &&
        !filters.dateColumnFilter!.matches(challan.date)) {
      return false;
    }
    if (filters.challanNoColumnFilter != null &&
        !filters.challanNoColumnFilter!.matches(challan.invoiceNo)) {
      return false;
    }
    if (filters.partyNameColumnFilter != null &&
        !filters.partyNameColumnFilter!.matches(challan.partyName)) {
      return false;
    }
    if (filters.dueDateColumnFilter != null &&
        challan.dueDate != null &&
        !filters.dueDateColumnFilter!.matches(challan.dueDate!)) {
      return false;
    }
    if (filters.amountColumnFilter != null &&
        !filters.amountColumnFilter!.matches(challan.amount)) {
      return false;
    }
    if (documentStatus != null && challan.documentStatus != documentStatus) {
      return false;
    }
    if (filters.selectedUser != 'All Users' &&
        challan.user != filters.selectedUser) {
      return false;
    }
    if (filters.selectedGodown != 'All Godown' &&
        challan.godown != filters.selectedGodown) {
      return false;
    }
    if (filters.selectedFirm != 'All Firms' &&
        challan.firm != filters.selectedFirm) {
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
List<String> deliveryChallanFirmFilterOptions(Ref ref) {
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
List<String> deliveryChallanUserFilterOptions(Ref ref) {
  final authState = ref.watch(authProvider);
  final authUser = authState.session?.user;
  final challans = ref.watch(deliveryChallansProvider).value?.items ?? [];

  return _withAllOption(
    'All Users',
    [
      if (authUser?.name?.trim().isNotEmpty == true) authUser!.name!,
      if (authUser?.phone.trim().isNotEmpty == true) authUser!.phone,
      ...challans.map((challan) => challan.user),
    ],
  );
}

@riverpod
List<String> deliveryChallanGodownFilterOptions(Ref ref) {
  final godownsAsync = ref.watch(inventoryGodownsProvider);
  final challans = ref.watch(deliveryChallansProvider).value?.items ?? [];

  final godownNames = godownsAsync.maybeWhen(
    data: (godowns) => godowns.map((godown) => godown.name),
    orElse: () => const <String>[],
  );

  return _withAllOption(
    'All Godown',
    [
      ...godownNames,
      ...challans.map((challan) => challan.godown),
    ],
  );
}

@riverpod
class DeliveryChallanSearchQuery extends _$DeliveryChallanSearchQuery {
  @override
  String build() => '';

  void setQuery(String value) => state = value;
}

@riverpod
class SelectedDeliveryChallanIds extends _$SelectedDeliveryChallanIds {
  @override
  Set<String> build() => {};

  void toggle(String id) {
    final next = Set<String>.from(state);
    if (next.contains(id)) {
      next.remove(id);
    } else {
      next.add(id);
    }
    state = next;
  }

  void clear() => state = {};
}

@Riverpod(keepAlive: true)
class DeliveryChallans extends _$DeliveryChallans {
  @override
  Future<PaginatedSaleInvoices> build() async {
    ref.watch(deliveryChallanFiltersProvider);
    ref.watch(deliveryChallanSearchQueryProvider);
    return _fetchPage();
  }

  Future<PaginatedSaleInvoices> _fetchPage() async {
    final filters = ref.read(deliveryChallanFiltersProvider);
    final search = ref.read(deliveryChallanSearchQueryProvider);
    final service = await ref.read(salesServiceProvider.future);

    if (needsChallanClientSideFiltering(filters)) {
      final allItems = await PaginatedFetch.fetchAll<SaleInvoiceModel>(
        fetchPage: (page) async {
          final result = await service.fetchInvoicesPage(
            buildChallanListQuery(
              filters,
              search,
              page: page,
              limit: PaginatedFetch.defaultPageSize,
            ),
          );
          return (
            items: filterChallanSeries(result.items),
            totalPages: result.totalPages,
          );
        },
      );

      final filteredItems = applyChallanClientFilters(allItems, filters);
      return paginateChallanItems(filteredItems, filters);
    }

    final page = await service.fetchInvoicesPage(
      buildChallanListQuery(filters, search),
    );

    final seriesFiltered = filterChallanSeries(page.items);
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

  Future<String?> deleteChallan(String documentId) async {
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

  Future<String?> cancelChallan(String documentId) async {
    try {
      final service = await ref.read(salesServiceProvider.future);
      await service.cancelSale(documentId);
      await refresh();
      return null;
    } catch (error) {
      return SalesErrorMapper.messageFor(error);
    }
  }

  Future<String?> finalizeChallan(String documentId) async {
    try {
      final service = await ref.read(salesServiceProvider.future);
      final document = await service.finalizeDraft(documentId);
      await refresh();
      await refreshAfterSaleMutation(
        ref,
        context: (
          partyId: document.partyId,
          itemIds: document.lines
              .map((line) => line.itemId)
              .whereType<String>()
              .where((id) => id.isNotEmpty),
        ),
      );
      return null;
    } catch (error) {
      return SalesErrorMapper.messageFor(error);
    }
  }

  Future<String?> convertChallan(
    String documentId, {
    required String targetType,
  }) async {
    try {
      final service = await ref.read(salesServiceProvider.future);
      final document = await service.convertDocument(
        documentId,
        targetType: targetType,
      );
      await refresh();
      await refreshAfterSaleMutation(
        ref,
        context: (
          partyId: document.partyId,
          itemIds: document.lines
              .map((line) => line.itemId)
              .whereType<String>()
              .where((id) => id.isNotEmpty),
        ),
      );
      return null;
    } catch (error) {
      return SalesErrorMapper.messageFor(error);
    }
  }

  Future<String?> bulkConvertToSale(Set<String> documentIds) async {
    if (documentIds.isEmpty) {
      return 'Select at least one delivery challan';
    }

    for (final documentId in documentIds) {
      final error = await convertChallan(
        documentId,
        targetType: 'tax_invoice',
      );
      if (error != null) return error;
    }
    return null;
  }
}

@riverpod
class DeliveryChallanFilters extends _$DeliveryChallanFilters {
  @override
  DeliveryChallanFiltersState build() {
    return const DeliveryChallanFiltersState();
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

  void setChallanNoColumnFilter(TextColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearChallanNoColumnFilter: true, currentPage: 1)
        : state.copyWith(challanNoColumnFilter: filter, currentPage: 1);
  }

  void setPartyNameColumnFilter(TextColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearPartyNameColumnFilter: true, currentPage: 1)
        : state.copyWith(partyNameColumnFilter: filter, currentPage: 1);
  }

  void setDueDateColumnFilter(DateColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearDueDateColumnFilter: true, currentPage: 1)
        : state.copyWith(dueDateColumnFilter: filter, currentPage: 1);
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
List<SaleInvoiceModel> filteredDeliveryChallans(Ref ref) {
  final allChallans = ref.watch(deliveryChallansProvider).value?.items ?? [];
  final filters = ref.watch(deliveryChallanFiltersProvider);
  return applyChallanClientFilters(allChallans, filters);
}

@riverpod
PaginatedSaleInvoices paginatedDeliveryChallans(Ref ref) {
  final filtered = ref.watch(filteredDeliveryChallansProvider);
  final filters = ref.watch(deliveryChallanFiltersProvider);
  return paginateChallanItems(filtered, filters);
}

@riverpod
DeliveryChallanSummaryData deliveryChallanSummary(Ref ref) {
  final challans = ref.watch(filteredDeliveryChallansProvider);

  var totalAmount = 0.0;
  var convertedAmount = 0.0;
  var openAmount = 0.0;

  for (final challan in challans) {
    totalAmount += challan.amount;
    if (challan.documentStatus == SalesDocumentStatus.converted) {
      convertedAmount += challan.amount;
    } else if (challan.documentStatus == SalesDocumentStatus.finalized) {
      openAmount += challan.amount;
    }
  }

  return DeliveryChallanSummaryData(
    totalAmount: totalAmount,
    convertedAmount: convertedAmount,
    openAmount: openAmount,
  );
}
