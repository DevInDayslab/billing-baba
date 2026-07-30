import 'package:billing_baba/features/dashboard/models/requests/dashboard_requests.dart';

class DashboardDto {
  const DashboardDto({
    required this.generatedAt,
    required this.period,
    required this.overview,
    required this.sales,
    required this.purchases,
    required this.finance,
    required this.inventory,
    required this.charts,
    required this.alerts,
    required this.recentTransactions,
    required this.quickReports,
  });

  factory DashboardDto.fromJson(Map<String, dynamic> json) {
    return DashboardDto(
      generatedAt: json['generated_at'] as String? ?? '',
      period: DashboardPeriodDto.fromJson(
        (json['period'] as Map<String, dynamic>?) ?? {},
      ),
      overview: DashboardOverviewDto.fromJson(
        (json['overview'] as Map<String, dynamic>?) ?? {},
      ),
      sales: DashboardSalesDto.fromJson(
        (json['sales'] as Map<String, dynamic>?) ?? {},
      ),
      purchases: DashboardPurchasesDto.fromJson(
        (json['purchases'] as Map<String, dynamic>?) ?? {},
      ),
      finance: DashboardFinanceDto.fromJson(
        (json['finance'] as Map<String, dynamic>?) ?? {},
      ),
      inventory: DashboardInventoryDto.fromJson(
        (json['inventory'] as Map<String, dynamic>?) ?? {},
      ),
      charts: DashboardChartsDto.fromJson(
        (json['charts'] as Map<String, dynamic>?) ?? {},
      ),
      alerts: json['alerts'] as List<dynamic>? ?? const [],
      recentTransactions:
          (json['recent_transactions'] as List<dynamic>?)
              ?.whereType<Map<String, dynamic>>()
              .map(DashboardRecentTransactionDto.fromJson)
              .toList() ??
          const [],
      quickReports:
          (json['quick_reports'] as List<dynamic>?)
              ?.whereType<Map<String, dynamic>>()
              .map(DashboardQuickReportDto.fromJson)
              .toList() ??
          const [],
    );
  }

  final String generatedAt;
  final DashboardPeriodDto period;
  final DashboardOverviewDto overview;
  final DashboardSalesDto sales;
  final DashboardPurchasesDto purchases;
  final DashboardFinanceDto finance;
  final DashboardInventoryDto inventory;
  final DashboardChartsDto charts;
  final List<dynamic> alerts;
  final List<DashboardRecentTransactionDto> recentTransactions;
  final List<DashboardQuickReportDto> quickReports;
}

class DashboardPeriodDto {
  const DashboardPeriodDto({
    required this.period,
    required this.from,
    required this.to,
  });

  factory DashboardPeriodDto.fromJson(Map<String, dynamic> json) {
    return DashboardPeriodDto(
      period: json['period'] as String? ?? 'this_month',
      from: json['from'] as String? ?? '',
      to: json['to'] as String? ?? '',
    );
  }

  final String period;
  final String from;
  final String to;

  DashboardPeriod get periodEnum => DashboardPeriod.fromApiValue(period);
}

class DashboardOverviewDto {
  const DashboardOverviewDto({
    required this.totalReceivable,
    required this.receivablePartyCount,
    required this.totalPayable,
    required this.payablePartyCount,
  });

  factory DashboardOverviewDto.fromJson(Map<String, dynamic> json) {
    return DashboardOverviewDto(
      totalReceivable: json['total_receivable'] as String? ?? '0',
      receivablePartyCount: json['receivable_party_count'] as int? ?? 0,
      totalPayable: json['total_payable'] as String? ?? '0',
      payablePartyCount: json['payable_party_count'] as int? ?? 0,
    );
  }

  final String totalReceivable;
  final int receivablePartyCount;
  final String totalPayable;
  final int payablePartyCount;
}

class DashboardSalesDto {
  const DashboardSalesDto({
    required this.totalAmount,
    required this.invoiceCount,
    required this.receivedAmount,
    required this.balanceAmount,
  });

  factory DashboardSalesDto.fromJson(Map<String, dynamic> json) {
    return DashboardSalesDto(
      totalAmount: json['total_amount'] as String? ?? '0',
      invoiceCount: json['invoice_count'] as int? ?? 0,
      receivedAmount: json['received_amount'] as String? ?? '0',
      balanceAmount: json['balance_amount'] as String? ?? '0',
    );
  }

  final String totalAmount;
  final int invoiceCount;
  final String receivedAmount;
  final String balanceAmount;
}

class DashboardPurchasesDto {
  const DashboardPurchasesDto({
    required this.totalAmount,
    required this.billCount,
  });

  factory DashboardPurchasesDto.fromJson(Map<String, dynamic> json) {
    return DashboardPurchasesDto(
      totalAmount: json['total_amount'] as String? ?? '0',
      billCount: json['bill_count'] as int? ?? 0,
    );
  }

  final String totalAmount;
  final int billCount;
}

class DashboardFinanceDto {
  const DashboardFinanceDto({
    required this.cashIn,
    required this.cashOut,
    required this.expenses,
  });

  factory DashboardFinanceDto.fromJson(Map<String, dynamic> json) {
    return DashboardFinanceDto(
      cashIn: json['cash_in'] as String? ?? '0',
      cashOut: json['cash_out'] as String? ?? '0',
      expenses: json['expenses'] as String? ?? '0',
    );
  }

  final String cashIn;
  final String cashOut;
  final String expenses;
}

class DashboardInventoryDto {
  const DashboardInventoryDto({
    required this.totalStockValue,
    required this.lowStockCount,
    required this.negativeStockCount,
    required this.lowStockItems,
  });

  factory DashboardInventoryDto.fromJson(Map<String, dynamic> json) {
    return DashboardInventoryDto(
      totalStockValue: json['total_stock_value'] as String? ?? '0',
      lowStockCount: json['low_stock_count'] as int? ?? 0,
      negativeStockCount: json['negative_stock_count'] as int? ?? 0,
      lowStockItems:
          (json['low_stock_items'] as List<dynamic>?)
              ?.whereType<Map<String, dynamic>>()
              .map(DashboardLowStockItemDto.fromJson)
              .toList() ??
          const [],
    );
  }

  final String totalStockValue;
  final int lowStockCount;
  final int negativeStockCount;
  final List<DashboardLowStockItemDto> lowStockItems;
}

class DashboardLowStockItemDto {
  const DashboardLowStockItemDto({
    required this.itemId,
    required this.itemName,
    required this.quantity,
    required this.reorderLevel,
  });

  factory DashboardLowStockItemDto.fromJson(Map<String, dynamic> json) {
    return DashboardLowStockItemDto(
      itemId: json['item_id'] as String? ?? '',
      itemName: json['item_name'] as String? ?? '',
      quantity: json['quantity'] as String? ?? '0',
      reorderLevel: json['reorder_level'] as String? ?? '0',
    );
  }

  final String itemId;
  final String itemName;
  final String quantity;
  final String reorderLevel;
}

class DashboardChartsDto {
  const DashboardChartsDto({
    required this.salesTrend,
    required this.purchasesTrend,
  });

  factory DashboardChartsDto.fromJson(Map<String, dynamic> json) {
    return DashboardChartsDto(
      salesTrend: DashboardTrendDto.fromJson(
        (json['sales_trend'] as Map<String, dynamic>?) ?? {},
      ),
      purchasesTrend: DashboardTrendDto.fromJson(
        (json['purchases_trend'] as Map<String, dynamic>?) ?? {},
      ),
    );
  }

  final DashboardTrendDto salesTrend;
  final DashboardTrendDto purchasesTrend;
}

class DashboardTrendDto {
  const DashboardTrendDto({required this.granularity, required this.points});

  factory DashboardTrendDto.fromJson(Map<String, dynamic> json) {
    return DashboardTrendDto(
      granularity: json['granularity'] as String? ?? 'day',
      points:
          (json['points'] as List<dynamic>?)
              ?.whereType<Map<String, dynamic>>()
              .map(DashboardTrendPointDto.fromJson)
              .toList() ??
          const [],
    );
  }

  final String granularity;
  final List<DashboardTrendPointDto> points;
}

class DashboardTrendPointDto {
  const DashboardTrendPointDto({required this.date, required this.amount});

  factory DashboardTrendPointDto.fromJson(Map<String, dynamic> json) {
    return DashboardTrendPointDto(
      date: json['date'] as String? ?? '',
      amount: json['amount'] as String? ?? '0',
    );
  }

  final String date;
  final String amount;
}

class DashboardRecentTransactionDto {
  const DashboardRecentTransactionDto({
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

  factory DashboardRecentTransactionDto.fromJson(Map<String, dynamic> json) {
    return DashboardRecentTransactionDto(
      id: json['id'] as String? ?? '',
      type: json['type'] as String? ?? '',
      referenceId: json['reference_id'] as String?,
      referenceType: json['reference_type'] as String?,
      referenceNumber: json['reference_number'] as String?,
      partyName: json['party_name'] as String?,
      amount: json['amount'] as String? ?? '0',
      date: json['date'] as String? ?? '',
      direction: json['direction'] as String?,
    );
  }

  final String id;
  final String type;
  final String? referenceId;
  final String? referenceType;
  final String? referenceNumber;
  final String? partyName;
  final String amount;
  final String date;
  final String? direction;
}

class DashboardQuickReportDto {
  const DashboardQuickReportDto({
    required this.key,
    required this.title,
    required this.route,
  });

  factory DashboardQuickReportDto.fromJson(Map<String, dynamic> json) {
    return DashboardQuickReportDto(
      key: json['key'] as String? ?? '',
      title: json['title'] as String? ?? '',
      route: json['route'] as String? ?? '',
    );
  }

  final String key;
  final String title;
  final String route;
}
