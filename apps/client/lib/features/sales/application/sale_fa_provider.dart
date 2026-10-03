import 'package:billing_baba/core/providers/data_refresh.dart';
import 'package:billing_baba/features/auth/application/auth_provider.dart';
import 'package:billing_baba/features/business/application/business_service.dart';
import 'package:billing_baba/features/export/utils/paginated_fetch.dart';
import 'package:billing_baba/features/inventory/application/inventory_godowns_provider.dart';
import 'package:billing_baba/features/sales/application/sale_fa_service.dart';
import 'package:billing_baba/features/sales/application/sale_invoices_provider.dart';
import 'package:billing_baba/features/sales/application/sales_error_mapper.dart';
import 'package:billing_baba/features/sales/models/requests/sale_fa_requests.dart';
import 'package:billing_baba/features/sales/models/sale_fa_model.dart';
import 'package:billing_baba/shared/utils/debouncer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sale_fa_provider.g.dart';

const saleFaPageSize = 10;

class SaleFaFiltersState {
  const SaleFaFiltersState({
    this.timeRangeOption = TimeRangeOption.thisMonth,
    this.customDateRange,
    this.selectedFirm = 'All Firms',
    this.selectedUser = 'All Users',
    this.selectedGodown = 'All Godown',
    this.selectedStatus = 'All Status',
    this.currentPage = 1,
  });

  final TimeRangeOption timeRangeOption;
  final DateTimeRange? customDateRange;
  final String selectedFirm;
  final String selectedUser;
  final String selectedGodown;
  final String selectedStatus;
  final int currentPage;

  String get timeRangeLabel => timeRangeOption.label;

  SaleFaFiltersState copyWith({
    TimeRangeOption? timeRangeOption,
    DateTimeRange? customDateRange,
    bool clearCustomDateRange = false,
    String? selectedFirm,
    String? selectedUser,
    String? selectedGodown,
    String? selectedStatus,
    int? currentPage,
  }) {
    return SaleFaFiltersState(
      timeRangeOption: timeRangeOption ?? this.timeRangeOption,
      customDateRange: clearCustomDateRange
          ? null
          : (customDateRange ?? this.customDateRange),
      selectedFirm: selectedFirm ?? this.selectedFirm,
      selectedUser: selectedUser ?? this.selectedUser,
      selectedGodown: selectedGodown ?? this.selectedGodown,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

class PaginatedSaleFaRecords {
  const PaginatedSaleFaRecords({
    required this.items,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
  });

  final List<SaleFaModel> items;
  final int currentPage;
  final int totalPages;
  final int totalItems;
}

class SaleFaSummaryData {
  const SaleFaSummaryData({
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

String? _statusFromFilterLabel(String label) => switch (label) {
  'Paid' => 'paid',
  'Unpaid' => 'unpaid',
  'Partially Paid' => 'partially_paid',
  'Partial' => 'partially_paid',
  'Overdue' => 'overdue',
  'Cancelled' => 'cancelled',
  _ => null,
};

SaleFaStatus? _paymentStatusFromFilterLabel(String label) => switch (label) {
  'Paid' => SaleFaStatus.paid,
  'Unpaid' => SaleFaStatus.unpaid,
  'Partially Paid' => SaleFaStatus.partiallyPaid,
  'Partial' => SaleFaStatus.partiallyPaid,
  'Overdue' => SaleFaStatus.overdue,
  'Cancelled' => SaleFaStatus.cancelled,
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

SaleFaListQuery _buildListQuery(
  SaleFaFiltersState filters,
  String searchQuery,
) {
  final dateRange = _resolveTimeRange(
    filters.timeRangeOption,
    filters.customDateRange,
  );

  return SaleFaListQuery(
    page: filters.currentPage,
    limit: saleFaPageSize,
    status: _statusFromFilterLabel(filters.selectedStatus),
    from: dateRange?.start.toUtc().toIso8601String().split('T').first,
    to: dateRange?.end.toUtc().toIso8601String().split('T').first,
    q: searchQuery.trim().isEmpty ? null : searchQuery.trim(),
  );
}

List<SaleFaModel> _applyClientFilters(
  List<SaleFaModel> records,
  SaleFaFiltersState filters,
) {
  final paymentStatus = _paymentStatusFromFilterLabel(filters.selectedStatus);

  return records.where((record) {
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
    return true;
  }).toList();
}

PaginatedSaleFaRecords _paginateSaleFaRecords(
  List<SaleFaModel> records,
  int currentPage,
) {
  if (records.isEmpty) {
    return const PaginatedSaleFaRecords(
      items: [],
      currentPage: 1,
      totalPages: 1,
      totalItems: 0,
    );
  }

  final totalItems = records.length;
  final totalPages = (totalItems / saleFaPageSize).ceil();
  final page = currentPage.clamp(1, totalPages);
  final start = (page - 1) * saleFaPageSize;
  final end = (start + saleFaPageSize).clamp(0, totalItems);

  return PaginatedSaleFaRecords(
    items: records.sublist(start, end),
    currentPage: page,
    totalPages: totalPages,
    totalItems: totalItems,
  );
}

PaginatedSaleFaRecords _allSaleFaPage(List<SaleFaModel> records) {
  return PaginatedSaleFaRecords(
    items: records,
    currentPage: 1,
    totalPages: 1,
    totalItems: records.length,
  );
}

List<SaleFaModel> _allSaleFaFromAsync(
  AsyncValue<PaginatedSaleFaRecords> faAsync,
) {
  return faAsync.when(
    data: (page) => page.items,
    loading: () => const [],
    error: (_, _) => const [],
  );
}

@riverpod
class SaleFaSearchQuery extends _$SaleFaSearchQuery {
  Debouncer? _debouncer;

  @override
  String build() {
    ref.onDispose(() => _debouncer?.dispose());
    return '';
  }

  void setQuery(String value) {
    _debouncer ??= Debouncer();
    _debouncer!.run(() => state = value);
  }
}

@Riverpod(keepAlive: true)
class SaleFa extends _$SaleFa {
  @override
  Future<PaginatedSaleFaRecords> build() async {
    ref.watch(
      saleFaFiltersProvider.select(
        (filters) => (filters.timeRangeOption, filters.customDateRange),
      ),
    );
    ref.watch(saleFaSearchQueryProvider);
    final allRecords = await _fetchAllRecords();
    return _allSaleFaPage(allRecords);
  }

  Future<List<SaleFaModel>> _fetchAllRecords() async {
    final filters = ref.read(saleFaFiltersProvider);
    final search = ref.read(saleFaSearchQueryProvider);
    final service = await ref.read(saleFaServiceProvider.future);

    return PaginatedFetch.fetchAll<SaleFaModel>(
      fetchPage: (page) async {
        final baseQuery = _buildListQuery(filters, search);
        final pageResult = await service.fetchBatchesPage(
          SaleFaListQuery(
            page: page,
            limit: PaginatedFetch.defaultPageSize,
            q: baseQuery.q,
            partyId: baseQuery.partyId,
            status: baseQuery.status,
            from: baseQuery.from,
            to: baseQuery.to,
            sort: baseQuery.sort,
            order: baseQuery.order,
          ),
        );
        return (items: pageResult.items, totalPages: pageResult.totalPages);
      },
    );
  }

  Future<void> refresh() async {
    if (!state.hasValue) {
      state = const AsyncLoading();
    }
    state = await AsyncValue.guard(() async {
      final allRecords = await _fetchAllRecords();
      return _allSaleFaPage(allRecords);
    });
  }

  Future<String?> deleteBatch(String batchId) async {
    final previous = state;
    final current = state.value;
    final partyId = current?.items
        .where((item) => item.batchId == batchId)
        .map((item) => item.partyId)
        .firstOrNull;

    if (current != null) {
      state = AsyncData(
        PaginatedSaleFaRecords(
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
      final service = await ref.read(saleFaServiceProvider.future);
      await service.deleteBatch(batchId);
      refreshAfterSaleFaMutation(
        ref,
        context: (partyId: partyId, itemIds: const []),
      );
      return null;
    } catch (error) {
      state = previous;
      return SalesErrorMapper.messageFor(error);
    }
  }
}

@riverpod
class SaleFaFilters extends _$SaleFaFilters {
  @override
  SaleFaFiltersState build() => const SaleFaFiltersState();

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

  void setFirm(String firm) {
    state = state.copyWith(selectedFirm: firm, currentPage: 1);
  }

  void setUser(String user) {
    state = state.copyWith(selectedUser: user, currentPage: 1);
  }

  void setGodown(String godown) {
    state = state.copyWith(selectedGodown: godown, currentPage: 1);
  }

  void setStatus(String status) {
    state = state.copyWith(selectedStatus: status, currentPage: 1);
  }

  void setPage(int page) {
    state = state.copyWith(currentPage: page);
  }
}

@riverpod
List<SaleFaModel> filteredSaleFaRecords(Ref ref) {
  final allRecords = _allSaleFaFromAsync(ref.watch(saleFaProvider));
  final filters = ref.watch(saleFaFiltersProvider);
  return _applyClientFilters(allRecords, filters);
}

@riverpod
PaginatedSaleFaRecords paginatedSaleFaRecords(Ref ref) {
  final filtered = ref.watch(filteredSaleFaRecordsProvider);
  final filters = ref.watch(saleFaFiltersProvider);
  return _paginateSaleFaRecords(filtered, filters.currentPage);
}

@riverpod
SaleFaSummaryData saleFaSummary(Ref ref) {
  final records = ref.watch(filteredSaleFaRecordsProvider);

  var paidAmount = 0.0;
  var unpaidAmount = 0.0;
  var overdueAmount = 0.0;
  var totalAmount = 0.0;

  for (final record in records) {
    totalAmount += record.amount;
    paidAmount += record.paidAmount;
    if (record.status == SaleFaStatus.overdue) {
      overdueAmount += record.balanceDue;
    } else if (record.status == SaleFaStatus.unpaid ||
        record.status == SaleFaStatus.partiallyPaid) {
      unpaidAmount += record.balanceDue;
    }
  }

  return SaleFaSummaryData(
    paidAmount: paidAmount,
    unpaidAmount: unpaidAmount,
    overdueAmount: overdueAmount,
    totalAmount: totalAmount,
  );
}

@riverpod
List<String> saleFaFirmFilterOptions(Ref ref) {
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
List<String> saleFaUserFilterOptions(Ref ref) {
  final authState = ref.watch(authProvider);
  final authUser = authState.session?.user;
  final records = _allSaleFaFromAsync(ref.watch(saleFaProvider));

  return _withAllOption(
    'All Users',
    [
      if (authUser?.name?.trim().isNotEmpty == true) authUser!.name!,
      if (authUser?.phone.trim().isNotEmpty == true) authUser!.phone,
      ...records.map((record) => record.user),
    ],
  );
}

@riverpod
List<String> saleFaGodownFilterOptions(Ref ref) {
  final godownsAsync = ref.watch(inventoryGodownsProvider);

  final godownNames = godownsAsync.maybeWhen(
    data: (godowns) => godowns.map((godown) => godown.name),
    orElse: () => const <String>[],
  );

  return _withAllOption('All Godown', godownNames);
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
