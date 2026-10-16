import 'package:billing_baba/features/dashboard/application/local_business_metrics_service.dart';
import 'package:billing_baba/features/dashboard/models/dashboard_model.dart';
import 'package:billing_baba/features/dashboard/models/requests/dashboard_requests.dart';
import 'package:billing_baba/features/dashboard/utils/dashboard_trend_series.dart';
import 'package:billing_baba/features/inventory/models/item_model.dart';

/// Merges API dashboard payloads with local Drift metrics when the server is empty.
abstract final class DashboardModelMerger {
  static DashboardModel merge({
    required DashboardModel remote,
    required DashboardOverviewModel localOverview,
    required LocalPeriodMetrics localPeriod,
    required List<InventoryItem> inventoryItems,
    required LocalBusinessMetricsService metrics,
    required DashboardQuery query,
    required List<DashboardTrendPointModel> localSalesTrend,
    required List<DashboardTrendPointModel> localPurchasesTrend,
  }) {
    final lowStockCount = metrics.countLowStockItems(inventoryItems);
    final lowStockItems = metrics.lowStockPreview(inventoryItems);

    return DashboardModel(
      generatedAt: remote.generatedAt,
      period: remote.period,
      overview: _mergeOverview(remote.overview, localOverview),
      sales: _mergeSales(
        remote.sales,
        localPeriod,
        query: query,
        localTrend: localSalesTrend,
      ),
      purchases: _mergePurchases(
        remote.purchases,
        localPeriod,
        query: query,
        localTrend: localPurchasesTrend,
      ),
      finance: _mergeFinance(remote.finance, localPeriod),
      inventory: _mergeInventory(
        remote.inventory,
        lowStockCount: lowStockCount,
        lowStockItems: lowStockItems,
      ),
      recentTransactions: remote.recentTransactions,
      quickReports: remote.quickReports,
    );
  }

  static DashboardOverviewModel _mergeOverview(
    DashboardOverviewModel remote,
    DashboardOverviewModel local,
  ) {
    return DashboardOverviewModel(
      totalReceivable: _preferLocalAmount(
        remote.totalReceivable,
        local.totalReceivable,
      ),
      receivablePartyCount: _preferLocalCount(
        remote.receivablePartyCount,
        local.receivablePartyCount,
      ),
      totalPayable: _preferLocalAmount(remote.totalPayable, local.totalPayable),
      payablePartyCount: _preferLocalCount(
        remote.payablePartyCount,
        local.payablePartyCount,
      ),
    );
  }

  static DashboardSalesModel _mergeSales(
    DashboardSalesModel remote,
    LocalPeriodMetrics local, {
    required DashboardQuery query,
    required List<DashboardTrendPointModel> localTrend,
  }) {
    final merged = remote.totalAmount != 0 || local.salesTotal == 0
        ? remote
        : DashboardSalesModel(
            totalAmount: local.salesTotal,
            invoiceCount: local.salesCount,
            receivedAmount: remote.receivedAmount,
            balanceAmount: remote.balanceAmount,
            trendPoints: remote.trendPoints,
          );

    final sparse = DashboardTrendSeries.combineSparseTrendSources(
      [remote.trendPoints, localTrend],
      query.period,
    );
    final trendPoints = DashboardTrendSeries.normalizeDashboardTrend(
      sparse,
      query,
    );

    return DashboardSalesModel(
      totalAmount: merged.totalAmount,
      invoiceCount: merged.invoiceCount,
      receivedAmount: merged.receivedAmount,
      balanceAmount: merged.balanceAmount,
      trendPoints: trendPoints,
    );
  }

  static DashboardPurchasesModel _mergePurchases(
    DashboardPurchasesModel remote,
    LocalPeriodMetrics local, {
    required DashboardQuery query,
    required List<DashboardTrendPointModel> localTrend,
  }) {
    final merged = remote.totalAmount != 0 || local.purchaseTotal == 0
        ? remote
        : DashboardPurchasesModel(
            totalAmount: local.purchaseTotal,
            billCount: local.purchaseCount,
            trendPoints: remote.trendPoints,
          );

    final sparse = DashboardTrendSeries.combineSparseTrendSources(
      [remote.trendPoints, localTrend],
      query.period,
    );
    final trendPoints = DashboardTrendSeries.normalizeDashboardTrend(
      sparse,
      query,
    );

    return DashboardPurchasesModel(
      totalAmount: merged.totalAmount,
      billCount: merged.billCount,
      trendPoints: trendPoints,
    );
  }

  static DashboardFinanceModel _mergeFinance(
    DashboardFinanceModel remote,
    LocalPeriodMetrics local,
  ) {
    if (remote.expenses != 0 || local.expensesTotal == 0) return remote;
    return DashboardFinanceModel(
      cashIn: remote.cashIn,
      cashOut: remote.cashOut,
      expenses: local.expensesTotal,
      bankBalance: remote.bankBalance,
    );
  }

  static DashboardInventoryModel _mergeInventory(
    DashboardInventoryModel remote, {
    required int lowStockCount,
    required List<DashboardLowStockItemModel> lowStockItems,
  }) {
    if (remote.lowStockCount != 0 || lowStockCount == 0) return remote;
    return DashboardInventoryModel(
      totalStockValue: remote.totalStockValue,
      lowStockCount: lowStockCount,
      negativeStockCount: remote.negativeStockCount,
      lowStockItems: lowStockItems,
    );
  }

  static double _preferLocalAmount(double remote, double local) {
    if (remote == 0 && local != 0) return local;
    return local > remote ? local : remote;
  }

  static int _preferLocalCount(int remote, int local) {
    if (remote == 0 && local != 0) return local;
    return local > remote ? local : remote;
  }
}
