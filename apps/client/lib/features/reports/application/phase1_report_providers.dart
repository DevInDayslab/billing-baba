import 'package:billing_baba/features/reports/application/report_filters_provider.dart';
import 'package:billing_baba/features/reports/application/report_load_helper.dart';
import 'package:billing_baba/features/reports/application/report_refresh_provider.dart';
import 'package:billing_baba/features/reports/application/reports_service.dart';
import 'package:billing_baba/features/reports/models/requests/report_requests.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'phase1_report_providers.g.dart';

ReportQuery _currentQuery(Ref ref) {
  return ref.read(reportFiltersProvider).toQuery();
}

@Riverpod(keepAlive: true)
class SaleReport extends _$SaleReport {
  @override
  Future<SaleReportData> build() async {
    watchReportListReload(ref);
    ref.watch(reportDataEpochProvider);
    return runReportLoad(ref, _load);
  }

  Future<void> refresh() async {
    await guardedReportRefresh(state, (value) => state = value, _load);
  }

  Future<void> goToPage(int page) async {
    ref.read(reportFiltersProvider.notifier).setPage(page);
    await guardedReportRefresh(state, (value) => state = value, _load);
  }

  Future<SaleReportData> _load() async {
    final service = await ref.read(reportsServiceProvider.future);
    return service.fetchSaleReport(_currentQuery(ref));
  }
}

@Riverpod(keepAlive: true)
class PurchaseReport extends _$PurchaseReport {
  @override
  Future<PurchaseReportData> build() async {
    watchReportListReload(ref);
    ref.watch(reportDataEpochProvider);
    return runReportLoad(ref, _load);
  }

  Future<void> refresh() async {
    await guardedReportRefresh(state, (value) => state = value, _load);
  }

  Future<void> goToPage(int page) async {
    ref.read(reportFiltersProvider.notifier).setPage(page);
    await guardedReportRefresh(state, (value) => state = value, _load);
  }

  Future<PurchaseReportData> _load() async {
    final service = await ref.read(reportsServiceProvider.future);
    return service.fetchPurchaseReport(_currentQuery(ref));
  }
}

@Riverpod(keepAlive: true)
class StockSummaryReport extends _$StockSummaryReport {
  @override
  Future<StockSummaryReportData> build() async {
    watchReportListReload(ref);
    ref.watch(reportDataEpochProvider);
    return runReportLoad(ref, _load);
  }

  Future<void> refresh() async {
    await guardedReportRefresh(state, (value) => state = value, _load);
  }

  Future<void> goToPage(int page) async {
    ref.read(reportFiltersProvider.notifier).setPage(page);
    await guardedReportRefresh(state, (value) => state = value, _load);
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
    watchReportListReload(ref);
    ref.watch(reportDataEpochProvider);
    return runReportLoad(ref, _load);
  }

  Future<void> refresh() async {
    await guardedReportRefresh(state, (value) => state = value, _load);
  }

  Future<void> goToPage(int page) async {
    ref.read(reportFiltersProvider.notifier).setPage(page);
    await guardedReportRefresh(state, (value) => state = value, _load);
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
    watchReportListReload(ref);
    ref.watch(reportDataEpochProvider);
    return runReportLoad(ref, _load);
  }

  Future<void> refresh() async {
    await guardedReportRefresh(state, (value) => state = value, _load);
  }

  Future<void> goToPage(int page) async {
    ref.read(reportFiltersProvider.notifier).setPage(page);
    await guardedReportRefresh(state, (value) => state = value, _load);
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
    watchReportListReload(ref);
    final partyId = ref.watch(
      reportFiltersProvider.select((state) => state.partyId),
    );
    if (partyId == null) return null;
    return runReportLoad(ref, _load);
  }

  Future<void> refresh() async {
    await guardedReportRefresh(state, (value) => state = value, _load);
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
    watchReportListReload(ref);
    ref.watch(reportDataEpochProvider);
    return runReportLoad(ref, _load);
  }

  Future<void> refresh() async {
    await guardedReportRefresh(state, (value) => state = value, _load);
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
    watchReportListReload(ref);
    ref.watch(reportDataEpochProvider);
    return runReportLoad(ref, _load);
  }

  Future<void> refresh() async {
    await guardedReportRefresh(state, (value) => state = value, _load);
  }

  Future<void> goToPage(int page) async {
    ref.read(reportFiltersProvider.notifier).setPage(page);
    await guardedReportRefresh(state, (value) => state = value, _load);
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
    watchReportListReload(ref);
    ref.watch(reportDataEpochProvider);
    return runReportLoad(ref, _load);
  }

  Future<void> refresh() async {
    await guardedReportRefresh(state, (value) => state = value, _load);
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
    watchReportListReload(ref);
    ref.watch(reportDataEpochProvider);
    return runReportLoad(ref, _load);
  }

  Future<void> refresh() async {
    await guardedReportRefresh(state, (value) => state = value, _load);
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
    watchReportListReload(ref);
    ref.watch(reportDataEpochProvider);
    return runReportLoad(ref, _load);
  }

  Future<void> refresh() async {
    await guardedReportRefresh(state, (value) => state = value, _load);
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
    watchReportListReload(ref);
    ref.watch(reportDataEpochProvider);
    return runReportLoad(ref, _load);
  }

  Future<void> refresh() async {
    await guardedReportRefresh(state, (value) => state = value, _load);
  }

  Future<Gstr3bReportData> _load() async {
    final service = await ref.read(reportsServiceProvider.future);
    return service.fetchGstr3b(_currentQuery(ref));
  }
}

@riverpod
class TrialBalanceReport extends _$TrialBalanceReport {
  @override
  Future<TrialBalanceReportData> build() async {
    watchReportListReload(ref);
    ref.watch(reportDataEpochProvider);
    return runReportLoad(ref, _load);
  }

  Future<void> refresh() async {
    await guardedReportRefresh(state, (value) => state = value, _load);
  }

  Future<TrialBalanceReportData> _load() async {
    final service = await ref.read(reportsServiceProvider.future);
    return service.fetchTrialBalance(_currentQuery(ref));
  }
}

@riverpod
class BalanceSheetReport extends _$BalanceSheetReport {
  @override
  Future<BalanceSheetReportData> build() async {
    watchReportListReload(ref);
    ref.watch(reportDataEpochProvider);
    return runReportLoad(ref, _load);
  }

  Future<void> refresh() async {
    await guardedReportRefresh(state, (value) => state = value, _load);
  }

  Future<BalanceSheetReportData> _load() async {
    final service = await ref.read(reportsServiceProvider.future);
    return service.fetchBalanceSheet(_currentQuery(ref));
  }
}
