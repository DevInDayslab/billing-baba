import 'package:billing_baba/features/purchases/application/purchase_error_mapper.dart';
import 'package:billing_baba/features/purchases/application/purchase_service.dart';
import 'package:billing_baba/features/purchases/models/requests/purchase_requests.dart';
import 'package:billing_baba/features/purchases/purchase_constants.dart';
import 'package:billing_baba/features/sales/application/sale_invoices_provider.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'purchase_documents_list_provider.g.dart';

const purchaseDocumentsPageSize = 10;

class PurchaseDocumentListScope {
  const PurchaseDocumentListScope({required this.documentType});

  final PurchaseDocumentType documentType;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is PurchaseDocumentListScope &&
            documentType == other.documentType;
  }

  @override
  int get hashCode => documentType.hashCode;
}

class PurchaseDocumentFiltersState {
  const PurchaseDocumentFiltersState({
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

  PurchaseDocumentFiltersState copyWith({
    TimeRangeOption? timeRangeOption,
    DateTimeRange? customDateRange,
    bool clearCustomDateRange = false,
    String? selectedStatus,
    int? currentPage,
  }) {
    return PurchaseDocumentFiltersState(
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
  'Open' => 'draft',
  'Completed' => 'finalized',
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

PurchaseDocumentListQuery _buildListQuery(
  PurchaseDocumentListScope scope,
  PurchaseDocumentFiltersState filters,
  String searchQuery,
) {
  final dateRange = _resolveTimeRange(
    filters.timeRangeOption,
    filters.customDateRange,
  );

  return PurchaseDocumentListQuery(
    page: filters.currentPage,
    limit: purchaseDocumentsPageSize,
    documentType: scope.documentType.apiValue,
    status: _documentStatusFromFilterLabel(filters.selectedStatus),
    from: dateRange?.start.toUtc().toIso8601String(),
    to: dateRange?.end.toUtc().toIso8601String(),
    q: searchQuery.trim().isEmpty ? null : searchQuery.trim(),
  );
}

@riverpod
class PurchaseDocumentSearchQuery extends _$PurchaseDocumentSearchQuery {
  @override
  String build(PurchaseDocumentListScope scope) => '';

  void setQuery(String value) => state = value;
}

@riverpod
class PurchaseDocumentFilters extends _$PurchaseDocumentFilters {
  @override
  PurchaseDocumentFiltersState build(PurchaseDocumentListScope scope) =>
      const PurchaseDocumentFiltersState();

  void setTimeRange(String label) {
    state = state.copyWith(
      timeRangeOption: TimeRangeOptionX.fromLabel(label),
      currentPage: 1,
    );
    ref.invalidate(purchaseDocumentsListProvider(scope));
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
    ref.invalidate(purchaseDocumentsListProvider(scope));
  }

  void setStatus(String status) {
    state = state.copyWith(selectedStatus: status, currentPage: 1);
    ref.invalidate(purchaseDocumentsListProvider(scope));
  }

  void setPage(int page) {
    state = state.copyWith(currentPage: page);
    ref.invalidate(purchaseDocumentsListProvider(scope));
  }
}

@Riverpod(keepAlive: true)
class PurchaseDocumentsList extends _$PurchaseDocumentsList {
  @override
  Future<PaginatedPurchaseDocuments> build(
    PurchaseDocumentListScope scope,
  ) async {
    ref.watch(purchaseDocumentFiltersProvider(scope));
    ref.watch(purchaseDocumentSearchQueryProvider(scope));
    return _fetchPage(scope);
  }

  Future<PaginatedPurchaseDocuments> _fetchPage(
    PurchaseDocumentListScope scope,
  ) async {
    final filters = ref.read(purchaseDocumentFiltersProvider(scope));
    final search = ref.read(purchaseDocumentSearchQueryProvider(scope));
    final service = await ref.read(purchaseServiceProvider.future);
    return service.fetchDocumentsPage(
      _buildListQuery(scope, filters, search),
    );
  }

  Future<void> refresh() async {
    if (!state.hasValue) {
      state = const AsyncLoading();
    }
    state = await AsyncValue.guard(() => _fetchPage(scope));
  }

  Future<String?> deleteDraft(String documentId) async {
    try {
      final service = await ref.read(purchaseServiceProvider.future);
      await service.deleteDraft(documentId);
      await refresh();
      return null;
    } catch (error) {
      return PurchaseErrorMapper.messageFor(error);
    }
  }

  Future<String?> finalizeDocument(
    String documentId, {
    String? godownId,
  }) async {
    try {
      final service = await ref.read(purchaseServiceProvider.future);
      await service.finalizeDraft(documentId, godownId: godownId);
      await refresh();
      return null;
    } catch (error) {
      return PurchaseErrorMapper.messageFor(error);
    }
  }

  Future<String?> convertOrder(String orderId) async {
    try {
      final service = await ref.read(purchaseServiceProvider.future);
      await service.convertPurchaseOrder(orderId);
      await refresh();
      return null;
    } catch (error) {
      return PurchaseErrorMapper.messageFor(error);
    }
  }
}

PurchaseDocumentListScope purchaseBillListScope() =>
    const PurchaseDocumentListScope(
      documentType: PurchaseDocumentType.purchaseBill,
    );

PurchaseDocumentListScope purchaseOrderListScope() =>
    const PurchaseDocumentListScope(
      documentType: PurchaseDocumentType.purchaseOrder,
    );

PurchaseDocumentListScope purchaseReturnListScope() =>
    const PurchaseDocumentListScope(
      documentType: PurchaseDocumentType.purchaseReturn,
    );
