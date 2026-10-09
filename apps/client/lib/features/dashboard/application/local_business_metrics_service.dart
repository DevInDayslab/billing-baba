import 'package:billing_baba/core/database/database.dart';
import 'package:billing_baba/features/dashboard/models/dashboard_model.dart';
import 'package:billing_baba/features/dashboard/models/requests/dashboard_requests.dart';
import 'package:billing_baba/features/inventory/inventory_constants.dart';
import 'package:billing_baba/features/inventory/models/item_model.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/inventory_stock_utils.dart';
import 'package:billing_baba/features/parties/application/party_ledger_service.dart';
import 'package:billing_baba/features/parties/application/party_service.dart';
import 'package:billing_baba/features/parties/data/party_local_source.dart';
import 'package:billing_baba/features/parties/utils/party_projected_balance.dart';
import 'package:billing_baba/features/parties/utils/party_timeline_utils.dart';
import 'package:billing_baba/features/purchases/data/expense_local_data_source.dart';
import 'package:billing_baba/features/purchases/data/purchase_local_data_source.dart';
import 'package:billing_baba/features/purchases/models/dto/purchase_document_dto.dart';
import 'package:billing_baba/features/reports/application/reports_service.dart';
import 'package:billing_baba/features/reports/models/report_models.dart';
import 'package:billing_baba/features/reports/models/requests/report_requests.dart';
import 'package:billing_baba/features/sales/data/sales_local_data_source.dart';
import 'package:billing_baba/features/sales/models/dto/sales_document_dto.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_model.dart';
import 'package:billing_baba/shared/utils/reporting_period_range.dart';
import 'package:flutter/material.dart';

/// Offline-first aggregates from Drift for dashboard and reports.
class LocalBusinessMetricsService {
  LocalBusinessMetricsService({
    required AppDatabase db,
    required this.businessIdReader,
    required PartyLedgerService partyLedgerService,
    required PartyService partyService,
  }) : _salesLocal = SalesLocalDataSource(db),
       _purchaseLocal = PurchaseLocalDataSource(db),
       _expenseLocal = ExpenseLocalDataSource(db),
       _partyLocal = PartyLocalSource(db),
       _partyLedgerService = partyLedgerService,
       _partyService = partyService;

  final String Function() businessIdReader;
  final SalesLocalDataSource _salesLocal;
  final PurchaseLocalDataSource _purchaseLocal;
  final ExpenseLocalDataSource _expenseLocal;
  final PartyLocalSource _partyLocal;
  final PartyLedgerService _partyLedgerService;
  final PartyService _partyService;

  String? get _businessId {
    final id = businessIdReader().trim();
    return id.isEmpty ? null : id;
  }

  Future<DashboardOverviewModel> loadOutstandingOverview() async {
    final businessId = _businessId;
    if (businessId == null) {
      return const DashboardOverviewModel(
        totalReceivable: 0,
        receivablePartyCount: 0,
        totalPayable: 0,
        payablePartyCount: 0,
      );
    }

    final parties = await _partyService.loadPartiesForGroupDiscovery();
    final outstandingIndex = await _partyLedgerService.fetchOutstandingIndex(
      businessId: businessId,
    );

    var totalReceivable = 0.0;
    var receivablePartyCount = 0;
    var totalPayable = 0.0;
    var payablePartyCount = 0;

    for (final party in parties) {
      if (!party.isActive) continue;
      final balance = projectedPartyBalance(party, outstandingIndex);
      final projected = party.copyWith(balance: balance);
      if (projected.hasReceivable) {
        totalReceivable += balance;
        receivablePartyCount++;
      } else if (projected.hasPayable) {
        totalPayable += balance.abs();
        payablePartyCount++;
      }
    }

    return DashboardOverviewModel(
      totalReceivable: totalReceivable,
      receivablePartyCount: receivablePartyCount,
      totalPayable: totalPayable,
      payablePartyCount: payablePartyCount,
    );
  }

  Future<LocalPeriodMetrics> loadPeriodMetrics(DashboardQuery query) async {
    final businessId = _businessId;
    if (businessId == null) return LocalPeriodMetrics.empty;

    final range = dateRangeForDashboardPeriod(
      query.period,
      from: query.from,
      to: query.to,
    );

    var salesTotal = 0.0;
    var salesCount = 0;
    var purchaseTotal = 0.0;
    var purchaseCount = 0;
    var expensesTotal = 0.0;

    for (final type in revenueSalesTypes) {
      final docs = await _salesLocal.listByType(
        businessId: businessId,
        documentType: type,
      );
      for (final doc in docs) {
        if (doc.status != 'finalized') continue;
        if (!_inRange(doc.documentDate, range)) continue;
        salesTotal += _parseAmount(doc.totalAmount);
        salesCount++;
      }
    }

    final purchaseDocs = await _purchaseLocal.listByType(
      businessId: businessId,
      documentType: 'purchase_bill',
    );
    for (final doc in purchaseDocs) {
      if (doc.status != 'finalized') continue;
      if (!_inRange(doc.documentDate, range)) continue;
      purchaseTotal += _parseAmount(doc.totalAmount);
      purchaseCount++;
    }

    final expenses = await _expenseLocal.listExpenses(businessId);
    for (final expense in expenses) {
      if (!_inRange(expense.expenseDate, range)) continue;
      expensesTotal += _parseAmount(expense.amount);
    }

    return LocalPeriodMetrics(
      salesTotal: salesTotal,
      salesCount: salesCount,
      purchaseTotal: purchaseTotal,
      purchaseCount: purchaseCount,
      expensesTotal: expensesTotal,
    );
  }

  int countLowStockItems(List<InventoryItem> items) {
    return items.where(isInventoryLowStock).length;
  }

  List<DashboardLowStockItemModel> lowStockPreview(List<InventoryItem> items) {
    final low = items.where(isInventoryLowStock).toList()
      ..sort((a, b) => (a.quantity ?? 0).compareTo(b.quantity ?? 0));
    return low
        .take(5)
        .map(
          (item) => DashboardLowStockItemModel(
            itemId: item.id,
            itemName: item.name,
            quantity: (item.quantity ?? 0).toDouble(),
            reorderLevel: (item.reorderLevel ?? inventoryLowStockThreshold)
                .toDouble(),
          ),
        )
        .toList();
  }

  Future<SaleReportData?> buildSaleReport(ReportQuery query) async {
    final businessId = _businessId;
    if (businessId == null) return null;

    final range = dateRangeForReportQuery(query);
    final partyNames = await _partyNameIndex(businessId);
    final rows = <SaleInvoiceModel>[];

    for (final type in revenueSalesTypes) {
      final docs = await _salesLocal.listByType(
        businessId: businessId,
        documentType: type,
      );
      for (final doc in docs) {
        if (doc.status != 'finalized') continue;
        if (!_inRange(doc.documentDate, range)) continue;
        rows.add(_toSaleInvoice(doc, partyNames));
      }
    }

    rows.sort((a, b) => b.date.compareTo(a.date));
    if (rows.isEmpty) return null;

    final page = query.page < 1 ? 1 : query.page;
    final limit = query.limit < 1 ? 20 : query.limit;
    final start = (page - 1) * limit;
    final pageRows = start >= rows.length
        ? const <SaleInvoiceModel>[]
        : rows.skip(start).take(limit).toList();

    var totalSales = 0.0;
    var received = 0.0;
    var balance = 0.0;
    for (final row in rows) {
      totalSales += row.amount;
      received += row.amount - row.balance;
      balance += row.balance;
    }

    return SaleReportData(
      rows: pageRows,
      totalSalesAmount: totalSales,
      receivedAmount: received,
      balanceAmount: balance,
      meta: ReportPaginationMeta(
        page: page,
        limit: limit,
        total: rows.length,
        totalPages: (rows.length / limit).ceil(),
      ),
    );
  }

  Future<PurchaseReportData?> buildPurchaseReport(ReportQuery query) async {
    final businessId = _businessId;
    if (businessId == null) return null;

    final range = dateRangeForReportQuery(query);
    final partyNames = await _partyNameIndex(businessId);
    final rows = <ReportPurchaseRow>[];

    final docs = await _purchaseLocal.listByType(
      businessId: businessId,
      documentType: 'purchase_bill',
    );
    for (final doc in docs) {
      if (doc.status != 'finalized') continue;
      if (!_inRange(doc.documentDate, range)) continue;
      rows.add(_toPurchaseRow(doc, partyNames));
    }

    rows.sort((a, b) => b.date.compareTo(a.date));
    if (rows.isEmpty) return null;

    final page = query.page < 1 ? 1 : query.page;
    final limit = query.limit < 1 ? 20 : query.limit;
    final start = (page - 1) * limit;
    final pageRows = start >= rows.length
        ? const <ReportPurchaseRow>[]
        : rows.skip(start).take(limit).toList();

    var total = 0.0;
    var paid = 0.0;
    var balance = 0.0;
    for (final row in rows) {
      total += row.amount;
      balance += row.balance;
      paid += row.amount - row.balance;
    }

    return PurchaseReportData(
      rows: pageRows,
      totalAmount: total,
      paidAmount: paid,
      balanceAmount: balance,
      meta: ReportPaginationMeta(
        page: page,
        limit: limit,
        total: rows.length,
        totalPages: (rows.length / limit).ceil(),
      ),
    );
  }

  Future<Map<String, String>> _partyNameIndex(String businessId) async {
    final dtos = await _partyLocal.listActive(businessId);
    return {for (final dto in dtos) dto.id: dto.name};
  }

  bool _inRange(String documentDate, DateTimeRange range) {
    final day = parseDocumentCalendarDay(documentDate);
    if (day == null) return false;
    return isCalendarDayInRange(day, range);
  }

  double _parseAmount(String value) => double.tryParse(value) ?? 0;

  SaleInvoiceModel _toSaleInvoice(
    SalesDocumentDto doc,
    Map<String, String> partyNames,
  ) {
    final total = _parseAmount(doc.totalAmount);
    final paid = _parseAmount(doc.paidAmount);
    final balance = (total - paid).clamp(0.0, double.infinity).toDouble();
    return SaleInvoiceModel(
      id: doc.id,
      invoiceNo: doc.documentNumber ?? doc.documentSeries,
      date: parseDocumentCalendarDay(doc.documentDate) ?? DateTime.now(),
      partyName: partyNames[doc.partyId ?? ''] ?? '—',
      partyId: doc.partyId,
      transactionType: doc.documentType,
      paymentType: doc.paymentMode ?? '—',
      status: _paymentStatus(total, paid),
      amount: total,
      balance: balance,
    );
  }

  ReportPurchaseRow _toPurchaseRow(
    PurchaseDocumentDto doc,
    Map<String, String> partyNames,
  ) {
    final total = _parseAmount(doc.totalAmount);
    final paid = _parseAmount(doc.paidAmount);
    final balance = (total - paid).clamp(0.0, double.infinity).toDouble();
    return ReportPurchaseRow(
      id: doc.id,
      date: parseDocumentCalendarDay(doc.documentDate) ?? DateTime.now(),
      invoiceNo: doc.documentNumber ?? doc.documentSeries,
      partyName: partyNames[doc.partyId] ?? '—',
      paymentType: doc.paymentMode ?? '—',
      status: _paymentStatus(total, paid),
      amount: total,
      balance: balance,
    );
  }

  SaleInvoiceStatus _paymentStatus(double total, double paid) {
    if (total <= 0 || paid >= total) return SaleInvoiceStatus.paid;
    if (paid > 0) return SaleInvoiceStatus.partiallyPaid;
    return SaleInvoiceStatus.unpaid;
  }
}

class LocalPeriodMetrics {
  const LocalPeriodMetrics({
    required this.salesTotal,
    required this.salesCount,
    required this.purchaseTotal,
    required this.purchaseCount,
    required this.expensesTotal,
  });

  static const empty = LocalPeriodMetrics(
    salesTotal: 0,
    salesCount: 0,
    purchaseTotal: 0,
    purchaseCount: 0,
    expensesTotal: 0,
  );

  final double salesTotal;
  final int salesCount;
  final double purchaseTotal;
  final int purchaseCount;
  final double expensesTotal;
}
