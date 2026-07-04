import 'package:billing_baba/features/dashboard/models/dashboard_model.dart';
import 'package:billing_baba/features/dashboard/models/dto/dashboard_dto.dart';

abstract final class DashboardMapper {
  static double _money(String? value) => double.tryParse(value ?? '') ?? 0;

  static DateTime _date(String value) =>
      DateTime.tryParse(value) ?? DateTime.fromMillisecondsSinceEpoch(0);

  static DashboardTransactionType _transactionType(String value) =>
      switch (value) {
        'purchase' => DashboardTransactionType.purchase,
        'payment' => DashboardTransactionType.payment,
        'expense' => DashboardTransactionType.expense,
        _ => DashboardTransactionType.sale,
      };

  static List<DashboardTrendPointModel> _trendPoints(DashboardTrendDto dto) {
    return dto.points
        .map(
          (point) => DashboardTrendPointModel(
            date: _date(point.date),
            amount: _money(point.amount),
          ),
        )
        .toList();
  }

  static DashboardModel toModel(DashboardDto dto) {
    return DashboardModel(
      generatedAt: _date(dto.generatedAt),
      period: dto.period.periodEnum,
      overview: DashboardOverviewModel(
        totalReceivable: _money(dto.overview.totalReceivable),
        receivablePartyCount: dto.overview.receivablePartyCount,
        totalPayable: _money(dto.overview.totalPayable),
        payablePartyCount: dto.overview.payablePartyCount,
      ),
      sales: DashboardSalesModel(
        totalAmount: _money(dto.sales.totalAmount),
        invoiceCount: dto.sales.invoiceCount,
        receivedAmount: _money(dto.sales.receivedAmount),
        balanceAmount: _money(dto.sales.balanceAmount),
        trendPoints: _trendPoints(dto.charts.salesTrend),
      ),
      purchases: DashboardPurchasesModel(
        totalAmount: _money(dto.purchases.totalAmount),
        billCount: dto.purchases.billCount,
        trendPoints: _trendPoints(dto.charts.purchasesTrend),
      ),
      finance: DashboardFinanceModel(
        cashIn: _money(dto.finance.cashIn),
        cashOut: _money(dto.finance.cashOut),
        expenses: _money(dto.finance.expenses),
      ),
      inventory: DashboardInventoryModel(
        totalStockValue: _money(dto.inventory.totalStockValue),
        lowStockCount: dto.inventory.lowStockCount,
        negativeStockCount: dto.inventory.negativeStockCount,
        lowStockItems: dto.inventory.lowStockItems
            .map(
              (item) => DashboardLowStockItemModel(
                itemId: item.itemId,
                itemName: item.itemName,
                quantity: _money(item.quantity),
                reorderLevel: _money(item.reorderLevel),
              ),
            )
            .toList(),
      ),
      recentTransactions: dto.recentTransactions
          .map(
            (row) => DashboardRecentTransactionModel(
              id: row.id,
              type: _transactionType(row.type),
              referenceNumber: row.referenceNumber ?? '',
              partyName: row.partyName ?? '',
              amount: _money(row.amount),
              date: _date(row.date),
            ),
          )
          .toList(),
      quickReports: dto.quickReports
          .map(
            (report) => DashboardQuickReportModel(
              key: report.key,
              title: report.title,
              route: report.route,
            ),
          )
          .toList(),
    );
  }
}
