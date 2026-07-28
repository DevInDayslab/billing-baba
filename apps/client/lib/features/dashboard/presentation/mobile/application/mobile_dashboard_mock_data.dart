import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/features/dashboard/models/dashboard_model.dart';
import 'package:billing_baba/features/dashboard/models/requests/dashboard_requests.dart';

/// Mock dashboard payload for mobile when API data is unavailable.
abstract final class MobileDashboardMockData {
  static DashboardModel dashboard({
    DashboardPeriod period = DashboardPeriod.thisMonth,
  }) {
    final now = DateTime.now();
    final trendPoints = List.generate(7, (index) {
      final day = now.subtract(Duration(days: 6 - index));
      return DashboardTrendPointModel(
        date: day,
        amount: [12000, 18500, 14200, 22000, 19800, 26500, 24100][index]
            .toDouble(),
      );
    });

    return DashboardModel(
      generatedAt: now,
      period: period,
      overview: const DashboardOverviewModel(
        totalReceivable: 125400,
        receivablePartyCount: 8,
        totalPayable: 48200,
        payablePartyCount: 3,
      ),
      sales: DashboardSalesModel(
        totalAmount: 241000,
        invoiceCount: 42,
        receivedAmount: 198500,
        balanceAmount: 42500,
        trendPoints: trendPoints,
      ),
      purchases: const DashboardPurchasesModel(
        totalAmount: 156800,
        billCount: 18,
        trendPoints: [],
      ),
      finance: const DashboardFinanceModel(
        cashIn: 198500,
        cashOut: 124300,
        expenses: 68400,
      ),
      inventory: const DashboardInventoryModel(
        totalStockValue: 890000,
        lowStockCount: 4,
        negativeStockCount: 0,
        lowStockItems: [],
      ),
      recentTransactions: const [],
      quickReports: defaultReports,
    );
  }

  static const defaultReports = [
    DashboardQuickReportModel(
      key: 'sale_report',
      title: 'Sales',
      route: AppRoutes.reportsSales,
    ),
    DashboardQuickReportModel(
      key: 'purchase_report',
      title: 'Purchases',
      route: AppRoutes.reportsPurchase,
    ),
    DashboardQuickReportModel(
      key: 'balance_sheet',
      title: 'Balance Sheet',
      route: AppRoutes.reports,
    ),
    DashboardQuickReportModel(
      key: 'profit_loss',
      title: 'P&L',
      route: AppRoutes.reports,
    ),
  ];

  static const expenseItems = [
    MobileDashboardExpenseItem(
      id: '1',
      title: 'Office Rent',
      category: 'Rent',
      amount: 15000,
      dateLabel: 'Today',
    ),
    MobileDashboardExpenseItem(
      id: '2',
      title: 'Electricity Bill',
      category: 'Utilities',
      amount: 3200,
      dateLabel: 'Yesterday',
    ),
    MobileDashboardExpenseItem(
      id: '3',
      title: 'Staff Salary',
      category: 'Salary',
      amount: 28000,
      dateLabel: '5 Mar',
    ),
    MobileDashboardExpenseItem(
      id: '4',
      title: 'Transport',
      category: 'Logistics',
      amount: 1850,
      dateLabel: '3 Mar',
    ),
  ];

  /// Computes month-over-month style growth from trend points.
  static double salesGrowthPercent(List<DashboardTrendPointModel> points) {
    if (points.length < 2) return 0;
    final first = points.first.amount;
    final last = points.last.amount;
    if (first <= 0) return last > 0 ? 100 : 0;
    return ((last - first) / first) * 100;
  }
}

class MobileDashboardExpenseItem {
  const MobileDashboardExpenseItem({
    required this.id,
    required this.title,
    required this.category,
    required this.amount,
    required this.dateLabel,
  });

  final String id;
  final String title;
  final String category;
  final double amount;
  final String dateLabel;
}
