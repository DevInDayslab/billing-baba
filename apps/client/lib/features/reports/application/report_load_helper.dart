import 'package:billing_baba/features/reports/application/report_filters_provider.dart';
import 'package:billing_baba/features/reports/models/requests/report_requests.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Filter fields that should refetch the report (pagination alone uses [goToPage]).
typedef ReportListReloadKey = ({
  ReportPeriod period,
  DateTimeRange? customDateRange,
  DateTime? selectedDate,
  String? godownId,
  String? partyId,
  String? itemId,
  String? categoryId,
  String? paymentMode,
  String? documentType,
  String? partyGroup,
  String? bankName,
  String? taxRate,
  String? loanAccount,
  String? status,
  String? partyType,
  bool inStockOnly,
  String? format,
  String searchQuery,
  int pageSize,
});

ReportListReloadKey reportListReloadKey(ReportFiltersState filters) {
  return (
    period: filters.period,
    customDateRange: filters.customDateRange,
    selectedDate: filters.selectedDate,
    godownId: filters.godownId,
    partyId: filters.partyId,
    itemId: filters.itemId,
    categoryId: filters.categoryId,
    paymentMode: filters.paymentMode,
    documentType: filters.documentType,
    partyGroup: filters.partyGroup,
    bankName: filters.bankName,
    taxRate: filters.taxRate,
    loanAccount: filters.loanAccount,
    status: filters.status,
    partyType: filters.partyType,
    inStockOnly: filters.inStockOnly,
    format: filters.format,
    searchQuery: filters.searchQuery,
    pageSize: filters.pageSize,
  );
}

void watchReportListReload(Ref ref) {
  ref.watch(reportFiltersProvider.select(reportListReloadKey));
}

/// Runs a report fetch and clears the table loading flag when complete.
Future<T> runReportLoad<T>(Ref ref, Future<T> Function() load) async {
  try {
    return await load();
  } finally {
    ref.read(reportFiltersProvider.notifier).clearTableLoading();
  }
}

/// Refetch without wiping the current table on manual refresh or page change.
Future<void> guardedReportRefresh<T>(
  AsyncValue<T> current,
  void Function(AsyncValue<T> value) setState,
  Future<T> Function() load,
) async {
  if (!current.hasValue) {
    setState(const AsyncLoading());
  }
  setState(await AsyncValue.guard(load));
}

/// Whether the report table should show a reload overlay.
bool reportIsTableReloading(AsyncValue<dynamic> value, bool isTableLoading) {
  return value.isReloading || value.isRefreshing || isTableLoading;
}
