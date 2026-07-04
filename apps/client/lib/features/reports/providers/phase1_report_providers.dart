import 'package:billing_baba/features/reports/application/reports_service.dart';
import 'package:billing_baba/features/reports/models/requests/report_requests.dart';
import 'package:billing_baba/features/reports/providers/report_filters_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'phase1_report_providers.g.dart';

ReportQuery _currentQuery(Ref ref) =>
    ref.watch(reportFiltersProvider).toQuery();

@riverpod
class SaleReport extends _$SaleReport {
  @override
  Future<SaleReportData> build() async {
    ref.watch(reportFiltersProvider);
    return _load();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<void> goToPage(int page) async {
    ref.read(reportFiltersProvider.notifier).setPage(page);
    ref.invalidateSelf();
    await future;
  }

  Future<SaleReportData> _load() async {
    final service = await ref.read(reportsServiceProvider.future);
    return service.fetchSaleReport(_currentQuery(ref));
  }
}

@riverpod
class PurchaseReport extends _$PurchaseReport {
  @override
  Future<PurchaseReportData> build() async {
    ref.watch(reportFiltersProvider);
    return _load();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<void> goToPage(int page) async {
    ref.read(reportFiltersProvider.notifier).setPage(page);
    ref.invalidateSelf();
    await future;
  }

  Future<PurchaseReportData> _load() async {
    final service = await ref.read(reportsServiceProvider.future);
    return service.fetchPurchaseReport(_currentQuery(ref));
  }
}

@riverpod
class StockSummaryReport extends _$StockSummaryReport {
  @override
  Future<StockSummaryReportData> build() async {
    ref.watch(reportFiltersProvider);
    return _load();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<void> goToPage(int page) async {
    ref.read(reportFiltersProvider.notifier).setPage(page);
    ref.invalidateSelf();
    await future;
  }

  Future<StockSummaryReportData> _load() async {
    final service = await ref.read(reportsServiceProvider.future);
    return service.fetchStockSummary(_currentQuery(ref));
  }
}

@riverpod
class LowStockReport extends _$LowStockReport {
  @override
  Future<LowStockReportData> build() async {
    ref.watch(reportFiltersProvider);
    return _load();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<void> goToPage(int page) async {
    ref.read(reportFiltersProvider.notifier).setPage(page);
    ref.invalidateSelf();
    await future;
  }

  Future<LowStockReportData> _load() async {
    final service = await ref.read(reportsServiceProvider.future);
    return service.fetchLowStock(_currentQuery(ref));
  }
}

@riverpod
class PartyOutstandingReport extends _$PartyOutstandingReport {
  @override
  Future<PartyOutstandingReportData> build() async {
    ref.watch(reportFiltersProvider);
    return _load();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<void> goToPage(int page) async {
    ref.read(reportFiltersProvider.notifier).setPage(page);
    ref.invalidateSelf();
    await future;
  }

  Future<PartyOutstandingReportData> _load() async {
    final service = await ref.read(reportsServiceProvider.future);
    return service.fetchPartyOutstanding(_currentQuery(ref));
  }
}

@riverpod
class PartyStatementReport extends _$PartyStatementReport {
  @override
  Future<PartyStatementReportData?> build() async {
    final filters = ref.watch(reportFiltersProvider);
    if (filters.partyId == null) return null;
    return _load();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<PartyStatementReportData?> _load() async {
    final filters = ref.read(reportFiltersProvider);
    if (filters.partyId == null) return null;
    final service = await ref.read(reportsServiceProvider.future);
    return service.fetchPartyStatement(filters.toQuery());
  }
}

@riverpod
class DayBookReport extends _$DayBookReport {
  @override
  Future<DayBookReportData> build() async {
    ref.watch(reportFiltersProvider);
    return _load();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<DayBookReportData> _load() async {
    final service = await ref.read(reportsServiceProvider.future);
    return service.fetchDayBook(_currentQuery(ref));
  }
}

@riverpod
class AllTransactionsReport extends _$AllTransactionsReport {
  @override
  Future<AllTransactionsReportData> build() async {
    ref.watch(reportFiltersProvider);
    return _load();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<void> goToPage(int page) async {
    ref.read(reportFiltersProvider.notifier).setPage(page);
    ref.invalidateSelf();
    await future;
  }

  Future<AllTransactionsReportData> _load() async {
    final service = await ref.read(reportsServiceProvider.future);
    return service.fetchAllTransactions(_currentQuery(ref));
  }
}

@riverpod
class ProfitLossReport extends _$ProfitLossReport {
  @override
  Future<ProfitLossReportData> build() async {
    ref.watch(reportFiltersProvider);
    return _load();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<ProfitLossReportData> _load() async {
    final service = await ref.read(reportsServiceProvider.future);
    return service.fetchProfitLoss(_currentQuery(ref));
  }
}

@riverpod
class Gstr1Report extends _$Gstr1Report {
  @override
  Future<GstrReportData> build() async {
    ref.watch(reportFiltersProvider);
    return _load();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<GstrReportData> _load() async {
    final service = await ref.read(reportsServiceProvider.future);
    return service.fetchGstr1(_currentQuery(ref));
  }
}

@riverpod
class Gstr2Report extends _$Gstr2Report {
  @override
  Future<GstrReportData> build() async {
    ref.watch(reportFiltersProvider);
    return _load();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<GstrReportData> _load() async {
    final service = await ref.read(reportsServiceProvider.future);
    return service.fetchGstr2(_currentQuery(ref));
  }
}

@riverpod
class Gstr3bReport extends _$Gstr3bReport {
  @override
  Future<Gstr3bReportData> build() async {
    ref.watch(reportFiltersProvider);
    return _load();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<Gstr3bReportData> _load() async {
    final service = await ref.read(reportsServiceProvider.future);
    return service.fetchGstr3b(_currentQuery(ref));
  }
}
