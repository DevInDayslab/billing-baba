import 'package:billing_baba/features/reports/models/requests/report_requests.dart';

class ReportPeriodDto {
  const ReportPeriodDto({
    required this.period,
    required this.from,
    required this.to,
  });

  factory ReportPeriodDto.fromJson(Map<String, dynamic> json) {
    return ReportPeriodDto(
      period: json['period'] as String? ?? 'this_month',
      from: json['from'] as String? ?? '',
      to: json['to'] as String? ?? '',
    );
  }

  final String period;
  final String from;
  final String to;
}

class ReportAmountSummaryDto {
  const ReportAmountSummaryDto({
    required this.totalAmount,
    required this.count, this.receivedAmount,
    this.balanceAmount,
    this.paidAmount,
  });

  factory ReportAmountSummaryDto.fromJson(Map<String, dynamic> json) {
    return ReportAmountSummaryDto(
      totalAmount: json['total_amount'] as String? ?? '0',
      receivedAmount: json['received_amount'] as String?,
      balanceAmount: json['balance_amount'] as String?,
      paidAmount: json['paid_amount'] as String?,
      count: (json['count'] as num?)?.toInt() ?? 0,
    );
  }

  final String totalAmount;
  final String? receivedAmount;
  final String? balanceAmount;
  final String? paidAmount;
  final int count;
}

class ReportSaleRowDto {
  const ReportSaleRowDto({
    required this.id,
    required this.documentNumber,
    required this.documentDate,
    required this.documentType, required this.status, required this.totalAmount, required this.balanceAmount, this.partyId,
    this.partyName,
    this.paymentMode,
  });

  factory ReportSaleRowDto.fromJson(Map<String, dynamic> json) {
    return ReportSaleRowDto(
      id: json['id'] as String,
      documentNumber: json['document_number'] as String? ?? '',
      documentDate: json['document_date'] as String? ?? '',
      partyId: json['party_id'] as String?,
      partyName: json['party_name'] as String?,
      documentType: json['document_type'] as String? ?? '',
      paymentMode: json['payment_mode'] as String?,
      status: json['status'] as String? ?? '',
      totalAmount: json['total_amount'] as String? ?? '0',
      balanceAmount: json['balance_amount'] as String? ?? '0',
    );
  }

  final String id;
  final String documentNumber;
  final String documentDate;
  final String? partyId;
  final String? partyName;
  final String documentType;
  final String? paymentMode;
  final String status;
  final String totalAmount;
  final String balanceAmount;
}

class ReportPurchaseRowDto {
  const ReportPurchaseRowDto({
    required this.id,
    required this.documentNumber,
    required this.documentDate,
    required this.partyId,
    required this.partyName,
    required this.status, required this.totalAmount, required this.balanceAmount, this.paymentMode,
  });

  factory ReportPurchaseRowDto.fromJson(Map<String, dynamic> json) {
    return ReportPurchaseRowDto(
      id: json['id'] as String,
      documentNumber: json['document_number'] as String? ?? '',
      documentDate: json['document_date'] as String? ?? '',
      partyId: json['party_id'] as String,
      partyName: json['party_name'] as String? ?? '',
      paymentMode: json['payment_mode'] as String?,
      status: json['status'] as String? ?? '',
      totalAmount: json['total_amount'] as String? ?? '0',
      balanceAmount: json['balance_amount'] as String? ?? '0',
    );
  }

  final String id;
  final String documentNumber;
  final String documentDate;
  final String partyId;
  final String partyName;
  final String? paymentMode;
  final String status;
  final String totalAmount;
  final String balanceAmount;
}

class SaleReportPayloadDto {
  const SaleReportPayloadDto({
    required this.period,
    required this.summary,
    required this.rows,
  });

  factory SaleReportPayloadDto.fromJson(Map<String, dynamic> json) {
    return SaleReportPayloadDto(
      period: ReportPeriodDto.fromJson(
        (json['period'] as Map<String, dynamic>?) ?? {},
      ),
      summary: ReportAmountSummaryDto.fromJson(
        (json['summary'] as Map<String, dynamic>?) ?? {},
      ),
      rows: (json['rows'] as List<dynamic>? ?? [])
          .map((e) => ReportSaleRowDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  final ReportPeriodDto period;
  final ReportAmountSummaryDto summary;
  final List<ReportSaleRowDto> rows;
}

class PurchaseReportPayloadDto {
  const PurchaseReportPayloadDto({
    required this.period,
    required this.summary,
    required this.rows,
  });

  factory PurchaseReportPayloadDto.fromJson(Map<String, dynamic> json) {
    return PurchaseReportPayloadDto(
      period: ReportPeriodDto.fromJson(
        (json['period'] as Map<String, dynamic>?) ?? {},
      ),
      summary: ReportAmountSummaryDto.fromJson(
        (json['summary'] as Map<String, dynamic>?) ?? {},
      ),
      rows: (json['rows'] as List<dynamic>? ?? [])
          .map((e) => ReportPurchaseRowDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  final ReportPeriodDto period;
  final ReportAmountSummaryDto summary;
  final List<ReportPurchaseRowDto> rows;
}

class ReportStockSummaryRowDto {
  const ReportStockSummaryRowDto({
    required this.itemId,
    required this.itemName,
    required this.stockQty, required this.averageCost, required this.stockValue, this.categoryId,
    this.salePrice,
  });

  factory ReportStockSummaryRowDto.fromJson(Map<String, dynamic> json) {
    return ReportStockSummaryRowDto(
      itemId: json['item_id'] as String,
      itemName: json['item_name'] as String? ?? '',
      categoryId: json['category_id'] as String?,
      stockQty: json['stock_qty'] as String? ?? '0',
      averageCost: json['average_cost'] as String? ?? '0',
      stockValue: json['stock_value'] as String? ?? '0',
      salePrice: json['sale_price'] as String?,
    );
  }

  final String itemId;
  final String itemName;
  final String? categoryId;
  final String stockQty;
  final String averageCost;
  final String stockValue;
  final String? salePrice;
}

class StockSummaryPayloadDto {
  const StockSummaryPayloadDto({
    required this.totalStockValue,
    required this.rows,
  });

  factory StockSummaryPayloadDto.fromJson(Map<String, dynamic> json) {
    return StockSummaryPayloadDto(
      totalStockValue: json['total_stock_value'] as String? ?? '0',
      rows: (json['rows'] as List<dynamic>? ?? [])
          .map(
            (e) => ReportStockSummaryRowDto.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  final String totalStockValue;
  final List<ReportStockSummaryRowDto> rows;
}

class ReportLowStockRowDto {
  const ReportLowStockRowDto({
    required this.itemId,
    required this.itemName,
    required this.currentStock,
    required this.minStock,
    required this.shortage,
  });

  factory ReportLowStockRowDto.fromJson(Map<String, dynamic> json) {
    return ReportLowStockRowDto(
      itemId: json['item_id'] as String,
      itemName: json['item_name'] as String? ?? '',
      currentStock: json['current_stock'] as String? ?? '0',
      minStock: json['min_stock'] as String? ?? '0',
      shortage: json['shortage'] as String? ?? '0',
    );
  }

  final String itemId;
  final String itemName;
  final String currentStock;
  final String minStock;
  final String shortage;
}

class LowStockPayloadDto {
  const LowStockPayloadDto({
    required this.lowStockCount,
    required this.rows,
  });

  factory LowStockPayloadDto.fromJson(Map<String, dynamic> json) {
    return LowStockPayloadDto(
      lowStockCount: (json['low_stock_count'] as num?)?.toInt() ?? 0,
      rows: (json['rows'] as List<dynamic>? ?? [])
          .map((e) => ReportLowStockRowDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  final int lowStockCount;
  final List<ReportLowStockRowDto> rows;
}

class ReportPartyOutstandingSummaryDto {
  const ReportPartyOutstandingSummaryDto({
    required this.totalReceivable,
    required this.receivablePartyCount,
    required this.totalPayable,
    required this.payablePartyCount,
  });

  factory ReportPartyOutstandingSummaryDto.fromJson(Map<String, dynamic> json) {
    return ReportPartyOutstandingSummaryDto(
      totalReceivable: json['total_receivable'] as String? ?? '0',
      receivablePartyCount:
          (json['receivable_party_count'] as num?)?.toInt() ?? 0,
      totalPayable: json['total_payable'] as String? ?? '0',
      payablePartyCount: (json['payable_party_count'] as num?)?.toInt() ?? 0,
    );
  }

  final String totalReceivable;
  final int receivablePartyCount;
  final String totalPayable;
  final int payablePartyCount;
}

class ReportPartyOutstandingRowDto {
  const ReportPartyOutstandingRowDto({
    required this.partyId,
    required this.partyName,
    required this.balance, required this.balanceType, this.phone,
    this.email,
  });

  factory ReportPartyOutstandingRowDto.fromJson(Map<String, dynamic> json) {
    return ReportPartyOutstandingRowDto(
      partyId: json['party_id'] as String,
      partyName: json['party_name'] as String? ?? '',
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      balance: json['balance'] as String? ?? '0',
      balanceType: json['balance_type'] as String? ?? 'settled',
    );
  }

  final String partyId;
  final String partyName;
  final String? phone;
  final String? email;
  final String balance;
  final String balanceType;
}

class PartyOutstandingPayloadDto {
  const PartyOutstandingPayloadDto({
    required this.summary,
    required this.rows,
  });

  factory PartyOutstandingPayloadDto.fromJson(Map<String, dynamic> json) {
    return PartyOutstandingPayloadDto(
      summary: ReportPartyOutstandingSummaryDto.fromJson(
        (json['summary'] as Map<String, dynamic>?) ?? {},
      ),
      rows: (json['rows'] as List<dynamic>? ?? [])
          .map(
            (e) =>
                ReportPartyOutstandingRowDto.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  final ReportPartyOutstandingSummaryDto summary;
  final List<ReportPartyOutstandingRowDto> rows;
}

class ReportPartyStatementEntryDto {
  const ReportPartyStatementEntryDto({
    required this.id,
    required this.date,
    required this.type,
    required this.refNo,
    required this.debit, required this.credit, required this.balance, this.description,
  });

  factory ReportPartyStatementEntryDto.fromJson(Map<String, dynamic> json) {
    return ReportPartyStatementEntryDto(
      id: json['id'] as String,
      date: json['date'] as String? ?? '',
      type: json['type'] as String? ?? '',
      refNo: json['ref_no'] as String? ?? '',
      description: json['description'] as String?,
      debit: json['debit'] as String? ?? '0',
      credit: json['credit'] as String? ?? '0',
      balance: json['balance'] as String? ?? '0',
    );
  }

  final String id;
  final String date;
  final String type;
  final String refNo;
  final String? description;
  final String debit;
  final String credit;
  final String balance;
}

class ReportPartyStatementSummaryDto {
  const ReportPartyStatementSummaryDto({
    required this.totalSale,
    required this.totalPurchase,
    required this.totalMoneyIn,
    required this.totalMoneyOut,
    required this.totalReceivable,
  });

  factory ReportPartyStatementSummaryDto.fromJson(Map<String, dynamic> json) {
    return ReportPartyStatementSummaryDto(
      totalSale: json['total_sale'] as String? ?? '0',
      totalPurchase: json['total_purchase'] as String? ?? '0',
      totalMoneyIn: json['total_money_in'] as String? ?? '0',
      totalMoneyOut: json['total_money_out'] as String? ?? '0',
      totalReceivable: json['total_receivable'] as String? ?? '0',
    );
  }

  final String totalSale;
  final String totalPurchase;
  final String totalMoneyIn;
  final String totalMoneyOut;
  final String totalReceivable;
}

class PartyStatementPayloadDto {
  const PartyStatementPayloadDto({
    required this.period,
    required this.partyId,
    required this.summary,
    required this.entries,
  });

  factory PartyStatementPayloadDto.fromJson(Map<String, dynamic> json) {
    return PartyStatementPayloadDto(
      period: ReportPeriodDto.fromJson(
        (json['period'] as Map<String, dynamic>?) ?? {},
      ),
      partyId: json['party_id'] as String? ?? '',
      summary: ReportPartyStatementSummaryDto.fromJson(
        (json['summary'] as Map<String, dynamic>?) ?? {},
      ),
      entries: (json['entries'] as List<dynamic>? ?? [])
          .map(
            (e) =>
                ReportPartyStatementEntryDto.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  final ReportPeriodDto period;
  final String partyId;
  final ReportPartyStatementSummaryDto summary;
  final List<ReportPartyStatementEntryDto> entries;
}

class ReportTransactionRowDto {
  const ReportTransactionRowDto({
    required this.id,
    required this.date,
    required this.refNo,
    required this.category, required this.type, required this.total, required this.received, required this.balance, required this.moneyIn, required this.moneyOut, required this.status, this.partyId,
    this.partyName,
    this.paymentType,
  });

  factory ReportTransactionRowDto.fromJson(Map<String, dynamic> json) {
    return ReportTransactionRowDto(
      id: json['id'] as String,
      date: json['date'] as String? ?? '',
      refNo: json['ref_no'] as String? ?? '',
      partyId: json['party_id'] as String?,
      partyName: json['party_name'] as String?,
      category: json['category'] as String? ?? '',
      type: json['type'] as String? ?? '',
      total: json['total'] as String? ?? '0',
      received: json['received'] as String? ?? '0',
      balance: json['balance'] as String? ?? '0',
      moneyIn: json['money_in'] as String? ?? '0',
      moneyOut: json['money_out'] as String? ?? '0',
      status: json['status'] as String? ?? '',
      paymentType: json['payment_type'] as String?,
    );
  }

  final String id;
  final String date;
  final String refNo;
  final String? partyId;
  final String? partyName;
  final String category;
  final String type;
  final String total;
  final String received;
  final String balance;
  final String moneyIn;
  final String moneyOut;
  final String status;
  final String? paymentType;
}

class DayBookPayloadDto {
  const DayBookPayloadDto({
    required this.date,
    required this.totalMoneyIn,
    required this.totalMoneyOut,
    required this.netTotal,
    required this.rows,
  });

  factory DayBookPayloadDto.fromJson(Map<String, dynamic> json) {
    return DayBookPayloadDto(
      date: json['date'] as String? ?? '',
      totalMoneyIn: json['total_money_in'] as String? ?? '0',
      totalMoneyOut: json['total_money_out'] as String? ?? '0',
      netTotal: json['net_total'] as String? ?? '0',
      rows: (json['rows'] as List<dynamic>? ?? [])
          .map(
            (e) => ReportTransactionRowDto.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  final String date;
  final String totalMoneyIn;
  final String totalMoneyOut;
  final String netTotal;
  final List<ReportTransactionRowDto> rows;
}

class AllTransactionsPayloadDto {
  const AllTransactionsPayloadDto({
    required this.period,
    required this.rows,
  });

  factory AllTransactionsPayloadDto.fromJson(Map<String, dynamic> json) {
    return AllTransactionsPayloadDto(
      period: ReportPeriodDto.fromJson(
        (json['period'] as Map<String, dynamic>?) ?? {},
      ),
      rows: (json['rows'] as List<dynamic>? ?? [])
          .map(
            (e) => ReportTransactionRowDto.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  final ReportPeriodDto period;
  final List<ReportTransactionRowDto> rows;
}

class ReportProfitLossItemDto {
  const ReportProfitLossItemDto({
    required this.particular,
    required this.amount,
    required this.isHeader,
    required this.indent,
  });

  factory ReportProfitLossItemDto.fromJson(Map<String, dynamic> json) {
    return ReportProfitLossItemDto(
      particular: json['particular'] as String? ?? '',
      amount: json['amount'] as String? ?? '0',
      isHeader: json['is_header'] as bool? ?? false,
      indent: (json['indent'] as num?)?.toInt() ?? 0,
    );
  }

  final String particular;
  final String amount;
  final bool isHeader;
  final int indent;
}

class ProfitLossPayloadDto {
  const ProfitLossPayloadDto({
    required this.period,
    required this.netProfit,
    required this.items,
  });

  factory ProfitLossPayloadDto.fromJson(Map<String, dynamic> json) {
    return ProfitLossPayloadDto(
      period: ReportPeriodDto.fromJson(
        (json['period'] as Map<String, dynamic>?) ?? {},
      ),
      netProfit: json['net_profit'] as String? ?? '0',
      items: (json['items'] as List<dynamic>? ?? [])
          .map(
            (e) => ReportProfitLossItemDto.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  final ReportPeriodDto period;
  final String netProfit;
  final List<ReportProfitLossItemDto> items;
}

class ReportGstrRowDto {
  const ReportGstrRowDto({
    required this.invoiceNo, required this.date, required this.value, required this.taxRate, required this.taxableValue, required this.integratedTax, required this.centralTax, required this.stateTax, required this.cess, this.gstin,
    this.partyName,
  });

  factory ReportGstrRowDto.fromJson(Map<String, dynamic> json) {
    return ReportGstrRowDto(
      gstin: json['gstin'] as String?,
      partyName: json['party_name'] as String?,
      invoiceNo: json['invoice_no'] as String? ?? '',
      date: json['date'] as String? ?? '',
      value: json['value'] as String? ?? '0',
      taxRate: json['tax_rate'] as String? ?? '0',
      taxableValue: json['taxable_value'] as String? ?? '0',
      integratedTax: json['integrated_tax'] as String? ?? '0',
      centralTax: json['central_tax'] as String? ?? '0',
      stateTax: json['state_tax'] as String? ?? '0',
      cess: json['cess'] as String? ?? '0',
    );
  }

  final String? gstin;
  final String? partyName;
  final String invoiceNo;
  final String date;
  final String value;
  final String taxRate;
  final String taxableValue;
  final String integratedTax;
  final String centralTax;
  final String stateTax;
  final String cess;
}

class GstrReportPayloadDto {
  const GstrReportPayloadDto({
    required this.period,
    required this.rows,
  });

  factory GstrReportPayloadDto.fromJson(Map<String, dynamic> json) {
    return GstrReportPayloadDto(
      period: ReportPeriodDto.fromJson(
        (json['period'] as Map<String, dynamic>?) ?? {},
      ),
      rows: (json['rows'] as List<dynamic>? ?? [])
          .map((e) => ReportGstrRowDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  final ReportPeriodDto period;
  final List<ReportGstrRowDto> rows;
}

class ReportGstr3bRowDto {
  const ReportGstr3bRowDto({
    required this.nature,
    required this.taxableValue,
    required this.integratedTax,
    required this.centralTax,
    required this.stateTax,
    required this.cess,
  });

  factory ReportGstr3bRowDto.fromJson(Map<String, dynamic> json) {
    return ReportGstr3bRowDto(
      nature: json['nature'] as String? ?? '',
      taxableValue: json['taxable_value'] as String? ?? '0',
      integratedTax: json['integrated_tax'] as String? ?? '0',
      centralTax: json['central_tax'] as String? ?? '0',
      stateTax: json['state_tax'] as String? ?? '0',
      cess: json['cess'] as String? ?? '0',
    );
  }

  final String nature;
  final String taxableValue;
  final String integratedTax;
  final String centralTax;
  final String stateTax;
  final String cess;
}

class Gstr3bPayloadDto {
  const Gstr3bPayloadDto({
    required this.period,
    required this.rows,
  });

  factory Gstr3bPayloadDto.fromJson(Map<String, dynamic> json) {
    return Gstr3bPayloadDto(
      period: ReportPeriodDto.fromJson(
        (json['period'] as Map<String, dynamic>?) ?? {},
      ),
      rows: (json['rows'] as List<dynamic>? ?? [])
          .map((e) => ReportGstr3bRowDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  final ReportPeriodDto period;
  final List<ReportGstr3bRowDto> rows;
}

class PaginatedReportResponse<T> {
  const PaginatedReportResponse({
    required this.data,
    required this.meta,
  });

  final T data;
  final ReportPaginationMeta meta;
}
