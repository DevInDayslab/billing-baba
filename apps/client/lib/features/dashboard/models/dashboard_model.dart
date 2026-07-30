import 'package:billing_baba/features/dashboard/models/requests/dashboard_requests.dart';

class DashboardOverviewModel {
  const DashboardOverviewModel({
    required this.totalReceivable,
    required this.receivablePartyCount,
    required this.totalPayable,
    required this.payablePartyCount,
  });

  final double totalReceivable;
  final int receivablePartyCount;
  final double totalPayable;
  final int payablePartyCount;
}

class DashboardSalesModel {
  const DashboardSalesModel({
    required this.totalAmount,
    required this.invoiceCount,
    required this.receivedAmount,
    required this.balanceAmount,
    required this.trendPoints,
  });

  final double totalAmount;
  final int invoiceCount;
  final double receivedAmount;
  final double balanceAmount;
  final List<DashboardTrendPointModel> trendPoints;
}

class DashboardPurchasesModel {
  const DashboardPurchasesModel({
    required this.totalAmount,
    required this.billCount,
    required this.trendPoints,
  });

  final double totalAmount;
  final int billCount;
  final List<DashboardTrendPointModel> trendPoints;
}

class DashboardFinanceModel {
  const DashboardFinanceModel({
    required this.cashIn,
    required this.cashOut,
    required this.expenses,
  });

  final double cashIn;
  final double cashOut;
  final double expenses;
}

class DashboardLowStockItemModel {
  const DashboardLowStockItemModel({
    required this.itemId,
    required this.itemName,
    required this.quantity,
    required this.reorderLevel,
  });

  final String itemId;
  final String itemName;
  final double quantity;
  final double reorderLevel;

  bool get isNegative => quantity < 0;
}

class DashboardInventoryModel {
  const DashboardInventoryModel({
    required this.totalStockValue,
    required this.lowStockCount,
    required this.negativeStockCount,
    required this.lowStockItems,
  });

  final double totalStockValue;
  final int lowStockCount;
  final int negativeStockCount;
  final List<DashboardLowStockItemModel> lowStockItems;
}

class DashboardTrendPointModel {
  const DashboardTrendPointModel({required this.date, required this.amount});

  final DateTime date;
  final double amount;
}

enum DashboardTransactionType {
  sale,
  purchase,
  paymentIn,
  paymentOut,
  expense,
  saleReturn,
  purchaseReturn,
  opening,
}

class DashboardRecentTransactionModel {
  const DashboardRecentTransactionModel({
    required this.id,
    required this.type,
    required this.referenceNumber,
    required this.partyName,
    required this.amount,
    required this.date,
    this.referenceId,
    this.referenceType,
    this.direction,
  });

  final String id;
  final DashboardTransactionType type;
  final String? referenceId;
  final String? referenceType;
  final String referenceNumber;
  final String partyName;
  final double amount;
  final DateTime date;
  final String? direction;
}

class DashboardQuickReportModel {
  const DashboardQuickReportModel({
    required this.key,
    required this.title,
    required this.route,
  });

  final String key;
  final String title;
  final String route;
}

class DashboardModel {
  const DashboardModel({
    required this.generatedAt,
    required this.period,
    required this.overview,
    required this.sales,
    required this.purchases,
    required this.finance,
    required this.inventory,
    required this.recentTransactions,
    required this.quickReports,
  });

  final DateTime generatedAt;
  final DashboardPeriod period;
  final DashboardOverviewModel overview;
  final DashboardSalesModel sales;
  final DashboardPurchasesModel purchases;
  final DashboardFinanceModel finance;
  final DashboardInventoryModel inventory;
  final List<DashboardRecentTransactionModel> recentTransactions;
  final List<DashboardQuickReportModel> quickReports;
}
