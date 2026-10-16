import 'package:billing_baba/core/database/database.dart';
import 'package:billing_baba/features/dashboard/models/dashboard_model.dart';
import 'package:billing_baba/features/dashboard/models/requests/dashboard_requests.dart';
import 'package:billing_baba/features/inventory/data/category_local_source.dart';
import 'package:billing_baba/features/inventory/data/inventory_stock_local_data_source.dart';
import 'package:billing_baba/features/inventory/data/item_local_source.dart';
import 'package:billing_baba/features/inventory/inventory_constants.dart';
import 'package:billing_baba/features/inventory/models/item_model.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/inventory_stock_utils.dart';
import 'package:billing_baba/features/parties/application/party_ledger_service.dart';
import 'package:billing_baba/features/parties/application/party_service.dart';
import 'package:billing_baba/features/parties/data/party_local_source.dart';
import 'package:billing_baba/features/parties/models/party_model.dart';
import 'package:billing_baba/features/parties/utils/party_projected_balance.dart';
import 'package:billing_baba/features/parties/utils/party_timeline_utils.dart';
import 'package:billing_baba/features/purchases/data/expense_local_data_source.dart';
import 'package:billing_baba/features/purchases/data/purchase_local_data_source.dart';
import 'package:billing_baba/features/purchases/models/dto/purchase_document_dto.dart';
import 'package:billing_baba/features/reports/application/reports_service.dart';
import 'package:billing_baba/features/reports/models/report_models.dart';
import 'package:billing_baba/features/reports/models/requests/report_requests.dart';
import 'package:billing_baba/features/parties/models/party_ledger_model.dart';
import 'package:billing_baba/features/reports/utils/item_detail_ledger.dart';
import 'package:billing_baba/features/reports/utils/party_statement_report_builder.dart';
import 'package:billing_baba/features/reports/utils/report_transaction_table_shared.dart';
import 'package:billing_baba/features/reports/utils/profit_loss_report_builder.dart';
import 'package:billing_baba/features/reports/utils/balance_sheet_report_builder.dart';
import 'package:billing_baba/features/reports/utils/expense_report_builder.dart';
import 'package:billing_baba/features/reports/utils/sale_purchase_order_report_builder.dart';
import 'package:billing_baba/features/purchases/purchase_constants.dart';
import 'package:billing_baba/features/reports/utils/stock_transfer_report_builder.dart';
import 'package:billing_baba/features/reports/utils/trial_balance_report_builder.dart';
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
       _itemsLocal = ItemLocalSource(db),
       _categoriesLocal = CategoryLocalSource(db),
       _stockLocal = InventoryStockLocalDataSource(db),
       _partyLedgerService = partyLedgerService,
       _partyService = partyService;

  final String Function() businessIdReader;
  final SalesLocalDataSource _salesLocal;
  final PurchaseLocalDataSource _purchaseLocal;
  final ExpenseLocalDataSource _expenseLocal;
  final PartyLocalSource _partyLocal;
  final ItemLocalSource _itemsLocal;
  final CategoryLocalSource _categoriesLocal;
  final InventoryStockLocalDataSource _stockLocal;
  final PartyLedgerService _partyLedgerService;
  final PartyService _partyService;

  String? get _businessId {
    final id = businessIdReader().trim();
    return id.isEmpty ? null : id;
  }

  Future<Map<String, String>> activeItemNameById() async {
    final businessId = _businessId;
    if (businessId == null) return {};
    final items = await _itemsLocal.listActive(businessId);
    return {for (final item in items) item.id: item.name};
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

  Future<List<DashboardTrendPointModel>> loadSalesTrend(
    DashboardQuery query,
  ) async {
    final businessId = _businessId;
    if (businessId == null) return const [];

    final range = dateRangeForDashboardPeriod(
      query.period,
      from: query.from,
      to: query.to,
    );
    final amountsByDay = <DateTime, double>{};

    for (final type in revenueSalesTypes) {
      final docs = await _salesLocal.listByType(
        businessId: businessId,
        documentType: type,
      );
      for (final doc in docs) {
        if (doc.status != 'finalized') continue;
        if (!_inRange(doc.documentDate, range)) continue;
        final day = parseDocumentCalendarDay(doc.documentDate);
        if (day == null) continue;
        final key = DateTime(day.year, day.month, day.day);
        amountsByDay[key] =
            (amountsByDay[key] ?? 0) + _parseAmount(doc.totalAmount);
      }
    }

    final points = amountsByDay.entries
        .map(
          (entry) => DashboardTrendPointModel(
            date: entry.key,
            amount: entry.value,
          ),
        )
        .toList();
    points.sort((a, b) => a.date.compareTo(b.date));
    return points;
  }

  Future<List<DashboardTrendPointModel>> loadPurchasesTrend(
    DashboardQuery query,
  ) async {
    final businessId = _businessId;
    if (businessId == null) return const [];

    final range = dateRangeForDashboardPeriod(
      query.period,
      from: query.from,
      to: query.to,
    );
    final amountsByDay = <DateTime, double>{};

    final purchaseDocs = await _purchaseLocal.listByType(
      businessId: businessId,
      documentType: 'purchase_bill',
    );
    for (final doc in purchaseDocs) {
      if (doc.status != 'finalized') continue;
      if (!_inRange(doc.documentDate, range)) continue;
      final day = parseDocumentCalendarDay(doc.documentDate);
      if (day == null) continue;
      final key = DateTime(day.year, day.month, day.day);
      amountsByDay[key] =
          (amountsByDay[key] ?? 0) + _parseAmount(doc.totalAmount);
    }

    final points = amountsByDay.entries
        .map(
          (entry) => DashboardTrendPointModel(
            date: entry.key,
            amount: entry.value,
          ),
        )
        .toList();
    points.sort((a, b) => a.date.compareTo(b.date));
    return points;
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

  Future<ExpensesReportData?> buildExpensesReport(ReportQuery query) async {
    final businessId = _businessId;
    if (businessId == null) return null;

    final expenses = await _expenseLocal.listExpenses(businessId);
    final partyNames = await _partyNameIndex(businessId);
    return buildLocalExpensesReport(
      expenses: expenses,
      partyNames: partyNames,
      query: query,
    );
  }

  Future<ExpenseByCategoryReportData?> buildExpenseByCategoryReport(
    ReportQuery query,
  ) async {
    final businessId = _businessId;
    if (businessId == null) return null;

    final expenses = await _expenseLocal.listExpenses(businessId);
    final categories = await _expenseLocal.listCategories(businessId);
    return buildLocalExpenseByCategoryReport(
      expenses: expenses,
      categories: categories,
      query: query,
    );
  }

  Future<ExpenseByItemReportData?> buildExpenseByItemReport(
    ReportQuery query,
  ) async {
    final businessId = _businessId;
    if (businessId == null) return null;

    final expenses = await _expenseLocal.listExpenses(businessId);
    final catalogItems = await _expenseLocal.listExpenseItems(businessId);
    return buildLocalExpenseByItemReport(
      expenses: expenses,
      catalogItems: catalogItems,
      query: query,
    );
  }

  Future<SalePurchaseOrdersReportData?> buildSalePurchaseOrdersReport(
    ReportQuery query,
  ) async {
    final businessId = _businessId;
    if (businessId == null) {
      return null;
    }

    final partyNames = await _partyNameIndex(businessId);
    final saleOrders = await _salesLocal.listByType(
      businessId: businessId,
      documentType: 'sale_order',
    );
    final purchaseOrders = await _purchaseLocal.listByType(
      businessId: businessId,
      documentType: PurchaseDocumentType.purchaseOrder.apiValue,
    );
    return buildLocalSalePurchaseOrdersReport(
      saleOrders: saleOrders,
      purchaseOrders: purchaseOrders,
      partyNames: partyNames,
      query: query,
    );
  }

  Future<BillWiseProfitReportData?> buildBillWiseProfit(ReportQuery query) async {
    final businessId = _businessId;
    if (businessId == null) return null;

    final range = dateRangeForReportQuery(query);
    final partyNames = await _partyNameIndex(businessId);
    final purchasePrices = await _itemPurchasePriceIndex(businessId);
    final rows = <ReportBillWiseProfitRow>[];
    final q = query.q?.trim().toLowerCase();

    for (final type in revenueSalesTypes) {
      final docs = await _salesLocal.listByType(
        businessId: businessId,
        documentType: type,
      );
      for (final doc in docs) {
        if (doc.status != 'finalized') continue;
        if (!_inRange(doc.documentDate, range)) continue;
        if (query.partyId != null &&
            query.partyId!.isNotEmpty &&
            doc.partyId != query.partyId) {
          continue;
        }

        final partyName = partyNames[doc.partyId ?? ''] ?? '—';
        final invoiceNo = doc.documentNumber ?? doc.documentSeries;
        if (q != null && q.isNotEmpty) {
          final matchesParty = partyName.toLowerCase().contains(q);
          final matchesInvoice = invoiceNo.toLowerCase().contains(q);
          if (!matchesParty && !matchesInvoice) continue;
        }

        var purchaseAmount = 0.0;
        for (final line in doc.lines) {
          final qty = double.tryParse(line.quantity) ?? 0;
          final unitCost = purchasePrices[line.itemId] ?? 0;
          purchaseAmount += qty * unitCost;
        }

        final saleAmount = _parseAmount(doc.totalAmount);
        rows.add(
          ReportBillWiseProfitRow(
            date: parseDocumentCalendarDay(doc.documentDate) ?? DateTime.now(),
            invoiceNo: invoiceNo,
            partyName: partyName,
            saleAmount: saleAmount,
            purchaseAmount: purchaseAmount,
            profit: saleAmount - purchaseAmount,
          ),
        );
      }
    }

    rows.sort((a, b) => b.date.compareTo(a.date));
    if (rows.isEmpty) return null;

    final page = query.page < 1 ? 1 : query.page;
    final limit = query.limit < 1 ? 20 : query.limit;
    final start = (page - 1) * limit;
    final pageRows = start >= rows.length
        ? const <ReportBillWiseProfitRow>[]
        : rows.skip(start).take(limit).toList();
    final totalPages = rows.isEmpty ? 1 : (rows.length / limit).ceil();

    return BillWiseProfitReportData(
      rows: pageRows,
      meta: ReportPaginationMeta(
        page: page,
        limit: limit,
        total: rows.length,
        totalPages: totalPages,
      ),
    );
  }

  Future<PartyOutstandingReportData?> buildPartyOutstanding(
    ReportQuery query,
  ) async {
    final businessId = _businessId;
    if (businessId == null) return null;

    final parties = await _partyService.loadPartiesForGroupDiscovery();
    if (parties.isEmpty) return null;

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

    final q = query.q?.trim().toLowerCase();
    final rows = <PartyModel>[];

    for (final party in parties) {
      final balance = projectedPartyBalance(party, outstandingIndex);
      final projected = party.copyWith(balance: balance);

      if (!_matchesReportPartyType(projected.partyType, query.partyType)) {
        continue;
      }

      final partyGroup = query.partyGroup?.trim();
      if (partyGroup != null &&
          partyGroup.isNotEmpty &&
          projected.partyGroup != partyGroup) {
        continue;
      }

      if (query.status == 'active' && !projected.isActive) continue;
      if (query.status == 'inactive' && projected.isActive) continue;

      if (q != null && q.isNotEmpty) {
        final name = projected.name.toLowerCase();
        final phone = projected.phone.toLowerCase();
        final email = projected.email.toLowerCase();
        if (!name.contains(q) && !phone.contains(q) && !email.contains(q)) {
          continue;
        }
      }

      rows.add(projected);
    }

    rows.sort(
      (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    );

    final page = query.page < 1 ? 1 : query.page;
    final limit = query.limit < 1 ? 20 : query.limit;
    final start = (page - 1) * limit;
    final pageRows = start >= rows.length
        ? const <PartyModel>[]
        : rows.skip(start).take(limit).toList();
    final totalPages = rows.isEmpty ? 1 : (rows.length / limit).ceil();

    return PartyOutstandingReportData(
      rows: pageRows,
      totalReceivable: totalReceivable,
      receivablePartyCount: receivablePartyCount,
      totalPayable: totalPayable,
      payablePartyCount: payablePartyCount,
      meta: ReportPaginationMeta(
        page: page,
        limit: limit,
        total: rows.length,
        totalPages: totalPages,
      ),
    );
  }

  Future<PartyWiseProfitLossReportData?> buildPartyWiseProfitLoss(
    ReportQuery query,
  ) async {
    final businessId = _businessId;
    if (businessId == null) return null;

    final range = dateRangeForReportQuery(query);
    final purchasePrices = await _itemPurchasePriceIndex(businessId);
    final parties = await _partyLocal.listActive(businessId);

    final saleByParty = <String, double>{};
    final costByParty = <String, double>{};
    final purchaseByParty = <String, double>{};

    for (final type in revenueSalesTypes) {
      final docs = await _salesLocal.listByType(
        businessId: businessId,
        documentType: type,
      );
      for (final doc in docs) {
        if (doc.status != 'finalized') continue;
        if (!_inRange(doc.documentDate, range)) continue;
        final partyId = doc.partyId?.trim();
        if (partyId == null || partyId.isEmpty) continue;

        saleByParty[partyId] =
            (saleByParty[partyId] ?? 0) + _parseAmount(doc.totalAmount);

        var lineCost = 0.0;
        for (final line in doc.lines) {
          final qty = double.tryParse(line.quantity) ?? 0;
          lineCost += qty * (purchasePrices[line.itemId] ?? 0);
        }
        costByParty[partyId] = (costByParty[partyId] ?? 0) + lineCost;
      }
    }

    final purchaseDocs = await _purchaseLocal.listByType(
      businessId: businessId,
      documentType: 'purchase_bill',
    );
    for (final doc in purchaseDocs) {
      if (doc.status != 'finalized') continue;
      if (!_inRange(doc.documentDate, range)) continue;
      final partyId = doc.partyId.trim();
      if (partyId.isEmpty) continue;
      purchaseByParty[partyId] =
          (purchaseByParty[partyId] ?? 0) + _parseAmount(doc.totalAmount);
    }

    final q = query.q?.trim().toLowerCase();
    final rows = <ReportPartyWiseProfitLossRow>[];

    for (final party in parties) {
      if (!_matchesReportPartyType(party.partyType, query.partyType)) {
        continue;
      }
      final partyGroup = query.partyGroup?.trim();
      if (partyGroup != null &&
          partyGroup.isNotEmpty &&
          party.partyCategory != partyGroup) {
        continue;
      }
      final partyIdFilter = query.partyId?.trim();
      if (partyIdFilter != null &&
          partyIdFilter.isNotEmpty &&
          party.id != partyIdFilter) {
        continue;
      }

      final sale = saleByParty[party.id] ?? 0;
      final billPurchase = purchaseByParty[party.id] ?? 0;
      final cost = costByParty[party.id] ?? 0;
      final purchaseAmount = billPurchase + cost;
      if (sale <= 0 && purchaseAmount <= 0) continue;

      if (q != null && q.isNotEmpty) {
        final name = party.name.toLowerCase();
        final phone = (party.mobile ?? '').toLowerCase();
        if (!name.contains(q) && !phone.contains(q)) continue;
      }

      rows.add(
        ReportPartyWiseProfitLossRow(
          partyName: party.name,
          phone: party.mobile ?? '',
          saleAmount: sale,
          purchaseAmount: purchaseAmount,
          profit: sale - purchaseAmount,
        ),
      );
    }

    rows.sort(
      (a, b) => b.partyName.toLowerCase().compareTo(a.partyName.toLowerCase()),
    );

    final page = query.page < 1 ? 1 : query.page;
    final limit = query.limit < 1 ? 20 : query.limit;
    final start = (page - 1) * limit;
    final pageRows = start >= rows.length
        ? const <ReportPartyWiseProfitLossRow>[]
        : rows.skip(start).take(limit).toList();
    final totalPages = rows.isEmpty ? 1 : (rows.length / limit).ceil();

    return PartyWiseProfitLossReportData(
      rows: pageRows,
      meta: ReportPaginationMeta(
        page: page,
        limit: limit,
        total: rows.length,
        totalPages: totalPages,
      ),
    );
  }

  Future<SalePurchaseByPartyReportData?> buildSalePurchaseByParty(
    ReportQuery query,
  ) async {
    final businessId = _businessId;
    if (businessId == null) return null;

    final allRows = await _collectSalePurchaseByPartyRows(businessId, query);
    return _paginateSalePurchaseByParty(allRows, query);
  }

  Future<SalePurchaseByPartyGroupReportData?> buildSalePurchaseByPartyGroup(
    ReportQuery query,
  ) async {
    final businessId = _businessId;
    if (businessId == null) return null;

    final parties = await _partyLocal.listActive(businessId);
    final categoryByPartyId = {
      for (final party in parties) party.id: party.partyCategory ?? 'custom',
    };

    final baseRows = await _collectSalePurchaseByPartyRows(businessId, query);
    var groupRows = baseRows
        .map(
          (row) => ReportSalePurchaseByPartyGroupRow(
            partyGroup: categoryByPartyId[row.partyId] ?? 'custom',
            partyName: row.partyName,
            saleAmount: row.saleAmount,
            purchaseAmount: row.purchaseAmount,
          ),
        )
        .toList();

    final partyGroup = query.partyGroup?.trim();
    if (partyGroup != null && partyGroup.isNotEmpty) {
      groupRows = groupRows.where((row) => row.partyGroup == partyGroup).toList();
    }

    groupRows.sort(
      (a, b) => b.saleAmount.compareTo(a.saleAmount),
    );

    final page = query.page < 1 ? 1 : query.page;
    final limit = query.limit < 1 ? 20 : query.limit;
    final start = (page - 1) * limit;
    final pageRows = start >= groupRows.length
        ? const <ReportSalePurchaseByPartyGroupRow>[]
        : groupRows.skip(start).take(limit).toList();
    final totalPages = groupRows.isEmpty ? 1 : (groupRows.length / limit).ceil();

    return SalePurchaseByPartyGroupReportData(
      rows: pageRows,
      meta: ReportPaginationMeta(
        page: page,
        limit: limit,
        total: groupRows.length,
        totalPages: totalPages,
      ),
    );
  }

  Future<List<_SalePurchaseByPartyAcc>> _collectSalePurchaseByPartyRows(
    String businessId,
    ReportQuery query,
  ) async {
    final range = dateRangeForReportQuery(query);
    final parties = await _partyLocal.listActive(businessId);

    final saleByParty = <String, double>{};
    final salePartials = await Future.wait(
      revenueSalesTypes.map((type) async {
        final partial = <String, double>{};
        final docs = await _salesLocal.listByType(
          businessId: businessId,
          documentType: type,
        );
        for (final doc in docs) {
          if (doc.status != 'finalized') continue;
          if (!_inRange(doc.documentDate, range)) continue;
          final partyId = doc.partyId?.trim();
          if (partyId == null || partyId.isEmpty) continue;
          partial[partyId] =
              (partial[partyId] ?? 0) + _parseAmount(doc.totalAmount);
        }
        return partial;
      }),
    );
    for (final partial in salePartials) {
      for (final entry in partial.entries) {
        saleByParty[entry.key] = (saleByParty[entry.key] ?? 0) + entry.value;
      }
    }

    final purchaseByParty = <String, double>{};
    final purchaseDocs = await _purchaseLocal.listByType(
      businessId: businessId,
      documentType: 'purchase_bill',
    );
    for (final doc in purchaseDocs) {
      if (doc.status != 'finalized') continue;
      if (!_inRange(doc.documentDate, range)) continue;
      final partyId = doc.partyId.trim();
      if (partyId.isEmpty) continue;
      purchaseByParty[partyId] =
          (purchaseByParty[partyId] ?? 0) + _parseAmount(doc.totalAmount);
    }

    final q = query.q?.trim().toLowerCase();
    final rows = <_SalePurchaseByPartyAcc>[];

    for (final party in parties) {
      if (!_matchesReportPartyType(party.partyType, query.partyType)) {
        continue;
      }

      final sale = saleByParty[party.id] ?? 0;
      final purchase = purchaseByParty[party.id] ?? 0;
      if (sale <= 0 && purchase <= 0) continue;

      if (q != null && q.isNotEmpty) {
        final name = party.name.toLowerCase();
        final phone = (party.mobile ?? '').toLowerCase();
        if (!name.contains(q) && !phone.contains(q)) continue;
      }

      rows.add(
        _SalePurchaseByPartyAcc(
          partyId: party.id,
          partyName: party.name,
          saleAmount: sale,
          purchaseAmount: purchase,
        ),
      );
    }

    rows.sort((a, b) => b.saleAmount.compareTo(a.saleAmount));
    return rows;
  }

  SalePurchaseByPartyReportData _paginateSalePurchaseByParty(
    List<_SalePurchaseByPartyAcc> rows,
    ReportQuery query,
  ) {
    final page = query.page < 1 ? 1 : query.page;
    final limit = query.limit < 1 ? 20 : query.limit;
    final start = (page - 1) * limit;
    final slice = start >= rows.length
        ? const <_SalePurchaseByPartyAcc>[]
        : rows.skip(start).take(limit).toList();
    final totalPages = rows.isEmpty ? 1 : (rows.length / limit).ceil();

    return SalePurchaseByPartyReportData(
      rows: [
        for (final row in slice)
          ReportSalePurchaseByPartyRow(
            partyName: row.partyName,
            saleAmount: row.saleAmount,
            purchaseAmount: row.purchaseAmount,
          ),
      ],
      meta: ReportPaginationMeta(
        page: page,
        limit: limit,
        total: rows.length,
        totalPages: totalPages,
      ),
    );
  }

  Future<PartyReportByItemReportData?> buildPartyReportByItem(
    ReportQuery query,
  ) async {
    final businessId = _businessId;
    final itemId = query.itemId?.trim();
    if (businessId == null || itemId == null || itemId.isEmpty) {
      return null;
    }

    final range = dateRangeForReportQuery(query);
    final parties = await _partyLocal.listActive(businessId);
    final partyById = {for (final party in parties) party.id: party};

    final saleQtyByParty = <String, double>{};
    final saleAmtByParty = <String, double>{};
    final purchaseQtyByParty = <String, double>{};
    final purchaseAmtByParty = <String, double>{};

    for (final type in revenueSalesTypes) {
      final docs = await _salesLocal.listByType(
        businessId: businessId,
        documentType: type,
      );
      for (final doc in docs) {
        if (doc.status != 'finalized') continue;
        if (!_inRange(doc.documentDate, range)) continue;
        final partyId = doc.partyId?.trim();
        if (partyId == null || partyId.isEmpty) continue;

        for (final line in doc.lines) {
          if (line.itemId != itemId) continue;
          final qty = double.tryParse(line.quantity) ?? 0;
          final amount = _parseAmount(line.lineTotal);
          saleQtyByParty[partyId] = (saleQtyByParty[partyId] ?? 0) + qty;
          saleAmtByParty[partyId] = (saleAmtByParty[partyId] ?? 0) + amount;
        }
      }
    }

    final purchaseDocs = await _purchaseLocal.listByType(
      businessId: businessId,
      documentType: 'purchase_bill',
    );
    for (final doc in purchaseDocs) {
      if (doc.status != 'finalized') continue;
      if (!_inRange(doc.documentDate, range)) continue;
      final partyId = doc.partyId.trim();
      if (partyId.isEmpty) continue;

      for (final line in doc.lines) {
        if (line.itemId != itemId) continue;
        final qty = double.tryParse(line.quantity) ?? 0;
        final amount = _parseAmount(line.lineTotal);
        purchaseQtyByParty[partyId] = (purchaseQtyByParty[partyId] ?? 0) + qty;
        purchaseAmtByParty[partyId] =
            (purchaseAmtByParty[partyId] ?? 0) + amount;
      }
    }

    final partyIds = <String>{
      ...saleQtyByParty.keys,
      ...purchaseQtyByParty.keys,
    };

    final q = query.q?.trim().toLowerCase();
    final rows = <ReportPartyByItemRow>[];

    for (final partyId in partyIds) {
      final party = partyById[partyId];
      if (party == null) continue;
      if (!_matchesReportPartyType(party.partyType, query.partyType)) {
        continue;
      }
      final partyGroup = query.partyGroup?.trim();
      if (partyGroup != null &&
          partyGroup.isNotEmpty &&
          party.partyCategory != partyGroup) {
        continue;
      }
      final partyIdFilter = query.partyId?.trim();
      if (partyIdFilter != null &&
          partyIdFilter.isNotEmpty &&
          party.id != partyIdFilter) {
        continue;
      }

      final saleQty = saleQtyByParty[partyId] ?? 0;
      final saleAmt = saleAmtByParty[partyId] ?? 0;
      final purchaseQty = purchaseQtyByParty[partyId] ?? 0;
      final purchaseAmt = purchaseAmtByParty[partyId] ?? 0;
      if (saleQty <= 0 &&
          saleAmt <= 0 &&
          purchaseQty <= 0 &&
          purchaseAmt <= 0) {
        continue;
      }

      if (q != null && q.isNotEmpty) {
        if (!party.name.toLowerCase().contains(q)) continue;
      }

      rows.add(
        ReportPartyByItemRow(
          partyName: party.name,
          saleQuantity: saleQty,
          saleAmount: saleAmt,
          purchaseQuantity: purchaseQty,
          purchaseAmount: purchaseAmt,
        ),
      );
    }

    rows.sort((a, b) => b.saleAmount.compareTo(a.saleAmount));

    final page = query.page < 1 ? 1 : query.page;
    final limit = query.limit < 1 ? 20 : query.limit;
    final start = (page - 1) * limit;
    final pageRows = start >= rows.length
        ? const <ReportPartyByItemRow>[]
        : rows.skip(start).take(limit).toList();
    final totalPages = rows.isEmpty ? 1 : (rows.length / limit).ceil();

    return PartyReportByItemReportData(
      rows: pageRows,
      meta: ReportPaginationMeta(
        page: page,
        limit: limit,
        total: rows.length,
        totalPages: totalPages,
      ),
    );
  }

  Future<ItemReportByPartyReportData?> buildItemReportByParty(
    ReportQuery query,
  ) async {
    final businessId = _businessId;
    if (businessId == null) return null;

    final range = dateRangeForReportQuery(query);
    final parties = await _partyLocal.listActive(businessId);
    final partyById = {for (final party in parties) party.id: party};
    final items = await _itemsLocal.listActive(businessId);
    final itemById = {for (final item in items) item.id: item};

    final aggregates = <String, _ItemPartySaleAgg>{};
    final itemIdFilter = query.itemId?.trim();
    final partyIdFilter = query.partyId?.trim();

    for (final type in revenueSalesTypes) {
      final docs = await _salesLocal.listByType(
        businessId: businessId,
        documentType: type,
      );
      for (final doc in docs) {
        if (doc.status != 'finalized') continue;
        if (!_inRange(doc.documentDate, range)) continue;

        final partyId = doc.partyId?.trim();
        if (partyId == null || partyId.isEmpty) continue;
        if (partyIdFilter != null &&
            partyIdFilter.isNotEmpty &&
            partyId != partyIdFilter) {
          continue;
        }

        final party = partyById[partyId];
        if (party == null) continue;
        if (!_matchesReportPartyType(party.partyType, query.partyType)) {
          continue;
        }
        final partyGroup = query.partyGroup?.trim();
        if (partyGroup != null &&
            partyGroup.isNotEmpty &&
            party.partyCategory != partyGroup) {
          continue;
        }

        for (final line in doc.lines) {
          final itemId = line.itemId;
          if (itemIdFilter != null &&
              itemIdFilter.isNotEmpty &&
              itemId != itemIdFilter) {
            continue;
          }

          final item = itemById[itemId];
          final itemName = item?.name ?? 'Unknown item';
          final key = '$itemId|$partyId';
          final agg = aggregates.putIfAbsent(key, _ItemPartySaleAgg.new);
          agg.itemName = itemName;
          agg.partyName = party.name;
          final qty = double.tryParse(line.quantity) ?? 0;
          agg.quantity += qty;
          agg.amount += _parseAmount(line.lineTotal);
        }
      }
    }

    final q = query.q?.trim().toLowerCase();
    final rows = <ReportItemByPartyRow>[];

    for (final agg in aggregates.values) {
      if (agg.quantity <= 0 && agg.amount <= 0) continue;
      if (q != null && q.isNotEmpty) {
        final party = agg.partyName.toLowerCase();
        final item = agg.itemName.toLowerCase();
        if (!party.contains(q) && !item.contains(q)) continue;
      }
      rows.add(
        ReportItemByPartyRow(
          itemName: agg.itemName,
          partyName: agg.partyName,
          quantity: agg.quantity,
          amount: agg.amount,
        ),
      );
    }

    rows.sort((a, b) => b.amount.compareTo(a.amount));

    var totalSaleAmount = 0.0;
    for (final row in rows) {
      totalSaleAmount += row.amount;
    }

    final page = query.page < 1 ? 1 : query.page;
    final limit = query.limit < 1 ? 20 : query.limit;
    final start = (page - 1) * limit;
    final pageRows = start >= rows.length
        ? const <ReportItemByPartyRow>[]
        : rows.skip(start).take(limit).toList();
    final totalPages = rows.isEmpty ? 1 : (rows.length / limit).ceil();

    return ItemReportByPartyReportData(
      rows: pageRows,
      totalSaleAmount: totalSaleAmount,
      meta: ReportPaginationMeta(
        page: page,
        limit: limit,
        total: rows.length,
        totalPages: totalPages,
      ),
    );
  }

  Future<ItemWiseProfitLossReportData?> buildItemWiseProfitLoss(
    ReportQuery query,
  ) async {
    final businessId = _businessId;
    if (businessId == null) return null;

    final range = dateRangeForReportQuery(query);
    final purchasePrices = await _itemPurchasePriceIndex(businessId);
    final items = await _itemsLocal.listActive(businessId);
    final itemNameById = {for (final item in items) item.id: item.name};

    final saleByItem = <String, _ItemWiseSaleAgg>{};
    final purchaseByItem = <String, double>{};

    for (final type in revenueSalesTypes) {
      final docs = await _salesLocal.listByType(
        businessId: businessId,
        documentType: type,
      );
      for (final doc in docs) {
        if (doc.status != 'finalized') continue;
        if (!_inRange(doc.documentDate, range)) continue;

        for (final line in doc.lines) {
          final itemId = line.itemId;
          final qty = double.tryParse(line.quantity) ?? 0;
          final saleAmount = _parseAmount(line.lineTotal);
          final cost = qty * (purchasePrices[itemId] ?? 0);
          final agg = saleByItem.putIfAbsent(itemId, _ItemWiseSaleAgg.new);
          agg.itemName = itemNameById[itemId] ?? 'Unknown item';
          agg.saleAmount += saleAmount;
          agg.costAmount += cost;
        }
      }
    }

    final purchaseDocs = await _purchaseLocal.listByType(
      businessId: businessId,
      documentType: 'purchase_bill',
    );
    for (final doc in purchaseDocs) {
      if (doc.status != 'finalized') continue;
      if (!_inRange(doc.documentDate, range)) continue;

      for (final line in doc.lines) {
        final itemId = line.itemId;
        purchaseByItem[itemId] =
            (purchaseByItem[itemId] ?? 0) + _parseAmount(line.lineTotal);
      }
    }

    final q = query.q?.trim().toLowerCase();
    final categoryId = query.categoryId?.trim();
    final rows = <ReportItemWiseProfitLossRow>[];

    for (final entry in saleByItem.entries) {
      final itemId = entry.key;
      final agg = entry.value;
      if (categoryId != null && categoryId.isNotEmpty) {
        final item = items.where((i) => i.id == itemId).firstOrNull;
        if (item?.categoryId != categoryId) continue;
      }
      if (q != null && q.isNotEmpty) {
        if (!agg.itemName.toLowerCase().contains(q)) continue;
      }

      final purchase = purchaseByItem[itemId] ?? 0;
      final cost = agg.costAmount;
      final sale = agg.saleAmount;
      final profit = sale - purchase - cost;

      rows.add(
        ReportItemWiseProfitLossRow(
          itemName: agg.itemName,
          saleAmount: sale,
          purchaseAmount: purchase + cost,
          profit: profit,
        ),
      );
    }

    rows.sort((a, b) => b.saleAmount.compareTo(a.saleAmount));

    var totalSaleAmount = 0.0;
    var totalProfit = 0.0;
    for (final row in rows) {
      totalSaleAmount += row.saleAmount;
      totalProfit += row.profit;
    }

    final page = query.page < 1 ? 1 : query.page;
    final limit = query.limit < 1 ? 20 : query.limit;
    final start = (page - 1) * limit;
    final pageRows = start >= rows.length
        ? const <ReportItemWiseProfitLossRow>[]
        : rows.skip(start).take(limit).toList();
    final totalPages = rows.isEmpty ? 1 : (rows.length / limit).ceil();

    return ItemWiseProfitLossReportData(
      rows: pageRows,
      totalSaleAmount: totalSaleAmount,
      totalProfit: totalProfit,
      meta: ReportPaginationMeta(
        page: page,
        limit: limit,
        total: rows.length,
        totalPages: totalPages,
      ),
    );
  }

  Future<ItemWiseDiscountReportData?> buildItemWiseDiscount(
    ReportQuery query,
  ) async {
    final businessId = _businessId;
    if (businessId == null) return null;

    final range = dateRangeForReportQuery(query);
    final items = await _itemsLocal.listActive(businessId);
    final itemNameById = {for (final item in items) item.id: item.name};
    final categoryByItemId = {for (final item in items) item.id: item.categoryId};

    final byItem = <String, _ItemWiseDiscountAgg>{};

    for (final type in revenueSalesTypes) {
      final docs = await _salesLocal.listByType(
        businessId: businessId,
        documentType: type,
      );
      for (final doc in docs) {
        if (doc.status != 'finalized') continue;
        if (!_inRange(doc.documentDate, range)) continue;

        for (final line in doc.lines) {
          final itemId = line.itemId;
          final discount = _parseAmount(line.discountAmount);
          if (discount <= 0) continue;

          final qty = double.tryParse(line.quantity) ?? 0;
          final unitPrice = _parseAmount(line.unitPrice);
          final agg = byItem.putIfAbsent(itemId, _ItemWiseDiscountAgg.new);
          agg.itemName = itemNameById[itemId] ?? 'Unknown item';
          agg.saleQty += qty;
          agg.saleAmount += qty * unitPrice;
          agg.discountAmount += discount;
        }
      }
    }

    final q = query.q?.trim().toLowerCase();
    final categoryId = query.categoryId?.trim();
    final rows = <ReportItemDiscountRow>[];

    for (final entry in byItem.entries) {
      final itemId = entry.key;
      final agg = entry.value;
      if (agg.discountAmount <= 0) continue;

      if (categoryId != null && categoryId.isNotEmpty) {
        if (categoryByItemId[itemId] != categoryId) continue;
      }
      if (q != null && q.isNotEmpty) {
        if (!agg.itemName.toLowerCase().contains(q)) continue;
      }

      final gross = agg.saleAmount;
      final percent = gross > 0 ? (agg.discountAmount / gross) * 100 : 0.0;
      rows.add(
        ReportItemDiscountRow(
          itemName: agg.itemName,
          saleQty: agg.saleQty,
          saleAmount: gross,
          discountAmount: agg.discountAmount,
          discountPercent: percent,
        ),
      );
    }

    rows.sort((a, b) => b.discountAmount.compareTo(a.discountAmount));

    var totalSaleAmount = 0.0;
    var totalDiscountAmount = 0.0;
    for (final row in rows) {
      totalSaleAmount += row.saleAmount;
      totalDiscountAmount += row.discountAmount;
    }

    final page = query.page < 1 ? 1 : query.page;
    final limit = query.limit < 1 ? 20 : query.limit;
    final start = (page - 1) * limit;
    final pageRows = start >= rows.length
        ? const <ReportItemDiscountRow>[]
        : rows.skip(start).take(limit).toList();
    final totalPages = rows.isEmpty ? 1 : (rows.length / limit).ceil();

    return ItemWiseDiscountReportData(
      rows: pageRows,
      totalSaleAmount: totalSaleAmount,
      totalDiscountAmount: totalDiscountAmount,
      meta: ReportPaginationMeta(
        page: page,
        limit: limit,
        total: rows.length,
        totalPages: totalPages,
      ),
    );
  }

  Future<StockTransferReportData?> buildStockTransfer(ReportQuery query) async {
    final businessId = _businessId;
    if (businessId == null) return null;

    final range = dateRangeForReportQuery(query);
    final from = DateTime(range.start.year, range.start.month, range.start.day);
    final toExclusive = DateTime(
      range.end.year,
      range.end.month,
      range.end.day,
    ).add(const Duration(days: 1));

    final movements = await _stockLocal.listStockTransferMovements(
      businessId: businessId,
      fromInclusive: from.toUtc(),
      toExclusive: toExclusive.toUtc(),
    );

    final built = buildStockTransferReportFromMovements(
      movements: movements,
      query: query,
    );

    return StockTransferReportData(
      rows: built.rows,
      totalQtyTransferred: built.totalQtyTransferred,
      totalValue: built.totalValue,
      meta: built.meta,
    );
  }

  Future<AllTransactionsReportData?> buildAllTransactions(
    ReportQuery query,
  ) async {
    final businessId = _businessId;
    if (businessId == null) return null;

    final range = dateRangeForReportQuery(query);
    final rows = _filterTransactionRows(
      await _buildLocalTransactionRows(businessId, range),
      documentType: query.documentType,
      searchQuery: query.q,
    );

    final page = query.page < 1 ? 1 : query.page;
    final limit = query.limit < 1 ? 20 : query.limit;
    final start = (page - 1) * limit;
    final pageRows = start >= rows.length
        ? const <ReportTransactionRow>[]
        : rows.skip(start).take(limit).toList();

    final totalPages = rows.isEmpty ? 1 : (rows.length / limit).ceil();

    return AllTransactionsReportData(
      rows: pageRows,
      meta: ReportPaginationMeta(
        page: page,
        limit: limit,
        total: rows.length,
        totalPages: totalPages,
      ),
    );
  }

  Future<PartyStatementReportData?> buildPartyStatement(
    ReportQuery query,
  ) async {
    final businessId = _businessId;
    final partyId = query.partyId?.trim();
    if (businessId == null || partyId == null || partyId.isEmpty) {
      return null;
    }

    try {
      final ledger = await _partyLedgerService.fetchPartyLedger(
        businessId: businessId,
        partyId: partyId,
        filter: PartyLedgerFilter.all,
      );
      return PartyStatementReportBuilder.build(
        ledger: ledger,
        query: query,
      );
    } on StateError {
      return null;
    }
  }

  Future<DayBookReportData?> buildDayBook(ReportQuery query) async {
    final businessId = _businessId;
    if (businessId == null) return null;

    final day = _resolveDayBookDate(query);
    final dayRange = DateTimeRange(start: day, end: day);

    final filtered = _filterTransactionRows(
      await _buildLocalTransactionRows(businessId, dayRange),
      documentType: query.documentType,
      searchQuery: query.q,
    );

    var totalMoneyIn = 0.0;
    var totalMoneyOut = 0.0;
    for (final row in filtered) {
      totalMoneyIn += row.moneyIn;
      totalMoneyOut += row.moneyOut;
    }

    return DayBookReportData(
      rows: filtered,
      totalMoneyIn: totalMoneyIn,
      totalMoneyOut: totalMoneyOut,
      netTotal: totalMoneyIn - totalMoneyOut,
    );
  }

  Future<CashFlowReportData?> buildCashFlow(ReportQuery query) async {
    final businessId = _businessId;
    if (businessId == null) return null;

    final range = dateRangeForReportQuery(query);
    final cashRows = _filterTransactionRows(
      await _buildLocalCashFlowRows(businessId, range),
      searchQuery: query.q,
    );

    final opening = await _localOpeningCashBalance(businessId, range.start);
    if (cashRows.isEmpty && opening == 0) return null;

    var totalMoneyIn = 0.0;
    var totalMoneyOut = 0.0;
    for (final row in cashRows) {
      totalMoneyIn += row.moneyIn;
      totalMoneyOut += row.moneyOut;
    }

    return CashFlowReportData(
      rows: cashRows,
      openingBalance: opening,
      closingBalance: opening + totalMoneyIn - totalMoneyOut,
      totalMoneyIn: totalMoneyIn,
      totalMoneyOut: totalMoneyOut,
    );
  }

  DateTime _resolveDayBookDate(ReportQuery query) {
    final raw = query.date ?? DateTime.now();
    return DateTime(raw.year, raw.month, raw.day);
  }

  Future<List<ReportTransactionRow>> _buildLocalTransactionRows(
    String businessId,
    DateTimeRange range,
  ) async {
    final partyNames = await _partyNameIndex(businessId);
    final rows = <ReportTransactionRow>[];

    for (final type in revenueSalesTypes) {
      final docs = await _salesLocal.listByType(
        businessId: businessId,
        documentType: type,
      );
      for (final doc in docs) {
        if (doc.status != 'finalized') continue;
        if (!_inRange(doc.documentDate, range)) continue;
        final total = _parseAmount(doc.totalAmount);
        final paid = _parseAmount(doc.paidAmount);
        final balance = (total - paid).clamp(0.0, double.infinity).toDouble();
        final date = parseDocumentCalendarDay(doc.documentDate) ?? range.start;
        rows.add(
          ReportTransactionRow(
            id: doc.id,
            date: date,
            refNo: doc.documentNumber ?? doc.documentSeries,
            partyName: partyNames[doc.partyId ?? ''] ?? '—',
            category: 'Sales',
            type: 'Sale',
            total: total,
            received: paid,
            balance: balance,
            status: doc.status,
            paymentType: doc.paymentMode ?? '',
          ),
        );
      }
    }

    final purchaseDocs = await _purchaseLocal.listByType(
      businessId: businessId,
      documentType: 'purchase_bill',
    );
    for (final doc in purchaseDocs) {
      if (doc.status != 'finalized') continue;
      if (!_inRange(doc.documentDate, range)) continue;
      final total = _parseAmount(doc.totalAmount);
      final paid = _parseAmount(doc.paidAmount);
      final balance = (total - paid).clamp(0.0, double.infinity).toDouble();
      final date = parseDocumentCalendarDay(doc.documentDate) ?? range.start;
      rows.add(
        ReportTransactionRow(
          id: doc.id,
          date: date,
          refNo: doc.documentNumber ?? doc.documentSeries,
          partyName: partyNames[doc.partyId] ?? '—',
          category: 'Purchase',
          type: 'Purchase',
          total: total,
          received: paid,
          balance: balance,
          moneyOut: total,
          dueDate: doc.dueDate != null
              ? parseDocumentCalendarDay(doc.dueDate!)
              : null,
          status: doc.status,
          paymentType: doc.paymentMode ?? '',
        ),
      );
    }

    final expenses = await _expenseLocal.listExpenses(businessId);
    for (final expense in expenses) {
      if (!_inRange(expense.expenseDate, range)) continue;
      final amount = _parseAmount(expense.amount);
      final date =
          parseDocumentCalendarDay(expense.expenseDate) ?? range.start;
      rows.add(
        ReportTransactionRow(
          id: expense.id,
          date: date,
          refNo: expense.description?.trim().isNotEmpty == true
              ? expense.description!.trim()
              : expense.id,
          partyName: expense.partyName?.trim().isNotEmpty == true
              ? expense.partyName!.trim()
              : '—',
          category: 'Expense',
          type: 'Expense',
          total: amount,
          moneyOut: amount,
          status: 'paid',
          paymentType: expense.paymentMode ?? '',
        ),
      );
    }

    rows.sort((a, b) => b.date.compareTo(a.date));
    return rows;
  }

  Future<List<ReportTransactionRow>> _buildLocalCashFlowRows(
    String businessId,
    DateTimeRange range,
  ) async {
    final partyNames = await _partyNameIndex(businessId);
    final rows = <ReportTransactionRow>[];

    for (final type in revenueSalesTypes) {
      final docs = await _salesLocal.listByType(
        businessId: businessId,
        documentType: type,
      );
      for (final doc in docs) {
        if (doc.status != 'finalized') continue;
        if (!_isCashPaymentMode(doc.paymentMode)) continue;
        if (!_inRange(doc.documentDate, range)) continue;
        final total = _parseAmount(doc.totalAmount);
        final paid = _parseAmount(doc.paidAmount);
        final moneyIn = paid > 0 ? paid : total;
        if (moneyIn <= 0) continue;
        final date = parseDocumentCalendarDay(doc.documentDate) ?? range.start;
        rows.add(
          ReportTransactionRow(
            id: doc.id,
            date: date,
            refNo: doc.documentNumber ?? doc.documentSeries,
            partyName: partyNames[doc.partyId ?? ''] ?? '—',
            category: 'Sales',
            type: 'Sale',
            total: total,
            received: paid,
            balance: (total - paid).clamp(0.0, double.infinity).toDouble(),
            moneyIn: moneyIn,
            status: doc.status,
            paymentType: 'cash',
          ),
        );
      }
    }

    final purchaseDocs = await _purchaseLocal.listByType(
      businessId: businessId,
      documentType: 'purchase_bill',
    );
    for (final doc in purchaseDocs) {
      if (doc.status != 'finalized') continue;
      if (!_isCashPaymentMode(doc.paymentMode)) continue;
      if (!_inRange(doc.documentDate, range)) continue;
      final total = _parseAmount(doc.totalAmount);
      final paid = _parseAmount(doc.paidAmount);
      final moneyOut = paid > 0 ? paid : total;
      if (moneyOut <= 0) continue;
      final date = parseDocumentCalendarDay(doc.documentDate) ?? range.start;
      rows.add(
        ReportTransactionRow(
          id: doc.id,
          date: date,
          refNo: doc.documentNumber ?? doc.documentSeries,
          partyName: partyNames[doc.partyId] ?? '—',
          category: 'Purchase',
          type: 'Purchase',
          total: total,
          received: paid,
          balance: (total - paid).clamp(0.0, double.infinity).toDouble(),
          moneyOut: moneyOut,
          dueDate: doc.dueDate != null
              ? parseDocumentCalendarDay(doc.dueDate!)
              : null,
          status: doc.status,
          paymentType: 'cash',
        ),
      );
    }

    final expenses = await _expenseLocal.listExpenses(businessId);
    for (final expense in expenses) {
      if (!_isCashPaymentMode(expense.paymentMode)) continue;
      if (!_inRange(expense.expenseDate, range)) continue;
      final amount = _parseAmount(expense.amount);
      if (amount <= 0) continue;
      final date =
          parseDocumentCalendarDay(expense.expenseDate) ?? range.start;
      rows.add(
        ReportTransactionRow(
          id: expense.id,
          date: date,
          refNo: expense.description?.trim().isNotEmpty == true
              ? expense.description!.trim()
              : expense.id,
          partyName: expense.partyName?.trim().isNotEmpty == true
              ? expense.partyName!.trim()
              : '—',
          category: 'Expense',
          type: 'Expense',
          total: amount,
          moneyOut: amount,
          status: 'paid',
          paymentType: 'cash',
        ),
      );
    }

    rows.sort((a, b) => b.date.compareTo(a.date));
    return rows;
  }

  Future<double> _localOpeningCashBalance(
    String businessId,
    DateTime rangeStart,
  ) async {
    final dayBefore = DateTime(
      rangeStart.year,
      rangeStart.month,
      rangeStart.day,
    ).subtract(const Duration(days: 1));
    final range = DateTimeRange(start: DateTime(2000), end: dayBefore);
    final rows = await _buildLocalCashFlowRows(businessId, range);
    var net = 0.0;
    for (final row in rows) {
      net += row.moneyIn - row.moneyOut;
    }
    return net;
  }

  bool _isCashPaymentMode(String? mode) {
    return (mode ?? '').trim().toLowerCase() == 'cash';
  }

  List<ReportTransactionRow> _filterTransactionRows(
    List<ReportTransactionRow> rows, {
    String? documentType,
    String? searchQuery,
  }) {
    final typeLabel = _mapTransactionDocumentTypeFilter(documentType);
    final q = searchQuery?.trim().toLowerCase();
    return rows.where((row) {
      if (typeLabel != null && row.type != typeLabel) return false;
      if (q == null || q.isEmpty) return true;
      return row.partyName.toLowerCase().contains(q) ||
          row.refNo.toLowerCase().contains(q) ||
          row.type.toLowerCase().contains(q) ||
          row.category.toLowerCase().contains(q) ||
          row.status.toLowerCase().contains(q);
    }).toList();
  }

  String? _mapTransactionDocumentTypeFilter(String? documentType) {
    if (documentType == null || documentType.isEmpty) return null;
    return switch (documentType) {
      'sale' => 'Sale',
      'purchase' => 'Purchase',
      'payment_in' => 'Payment In',
      'payment_out' => 'Payment Out',
      'expense' => 'Expense',
      _ => null,
    };
  }

  Future<TrialBalanceReportData?> buildTrialBalance(ReportQuery query) async {
    final businessId = _businessId;
    if (businessId == null) return null;

    final range = dateRangeForReportQuery(query);
    final openingAsOf = DateTime(
      range.start.year,
      range.start.month,
      range.start.day,
    ).subtract(const Duration(days: 1));
    final closingAsOf = DateTime(
      range.end.year,
      range.end.month,
      range.end.day,
    );

    final salesTotal = await _sumSalesInRange(businessId, range, revenueSalesTypes);
    final salesReturnTotal = await _sumSalesInRange(
      businessId,
      range,
      const {'sales_return'},
    );
    final purchaseTotal = await _sumPurchasesInRange(
      businessId,
      range,
      'purchase_bill',
    );
    final purchaseReturnTotal = await _sumPurchasesInRange(
      businessId,
      range,
      'purchase_return',
    );

    final expenses = await _expenseLocal.listExpenses(businessId);
    var expenseTotal = 0.0;
    for (final expense in expenses) {
      if (!_inRange(expense.expenseDate, range)) continue;
      expenseTotal += _parseAmount(expense.amount);
    }

    final stockValue = await _localStockValue(businessId);
    final netProfit = ProfitLossReportBuilder.build(
      netSales: salesTotal - salesReturnTotal,
      netPurchases: purchaseTotal - purchaseReturnTotal,
      expenseTotal: expenseTotal,
      stockValue: stockValue,
    ).netProfit;

    final openingOutstanding = await _partyLedgerService.fetchOutstandingTotalsAsOf(
      businessId: businessId,
      asOfInclusive: openingAsOf,
    );
    final closingOutstanding = await _partyLedgerService.fetchOutstandingTotalsAsOf(
      businessId: businessId,
      asOfInclusive: closingAsOf,
    );

    final openingCash = await _localOpeningCashBalance(businessId, range.start);
    final cashRows = await _buildLocalCashFlowRows(businessId, range);
    var cashReceived = 0.0;
    var cashPaid = 0.0;
    for (final row in cashRows) {
      cashReceived += row.moneyIn;
      cashPaid += row.moneyOut;
    }
    final closingCash = openingCash + cashReceived - cashPaid;

    var partyOpening = 0.0;
    for (final party in await _partyLocal.listActive(businessId)) {
      partyOpening += _parseAmount(party.openingBalance);
    }

    final built = TrialBalanceReportBuilder.build(
      openingCash: openingCash,
      closingCash: closingCash,
      cashReceived: cashReceived,
      cashPaid: cashPaid,
      receivableOpening: openingOutstanding.receivable,
      receivableClosing: closingOutstanding.receivable,
      payableOpening: openingOutstanding.payable,
      payableClosing: closingOutstanding.payable,
      purchaseTotal: purchaseTotal,
      purchaseReturnTotal: purchaseReturnTotal,
      salesTotal: salesTotal,
      salesReturnTotal: salesReturnTotal,
      expenseTotal: expenseTotal,
      stockValue: stockValue,
      partyOpening: partyOpening,
      netProfit: netProfit,
      searchQuery: query.q,
    );

    if (!TrialBalanceReportBuilder.hasMeaningfulActivity(
      rows: built.rows,
      totalDebit: built.totalDebit,
      totalCredit: built.totalCredit,
    )) {
      return null;
    }

    return TrialBalanceReportData(
      rows: built.rows,
      totalDebit: built.totalDebit,
      totalCredit: built.totalCredit,
      isBalanced: built.isBalanced,
    );
  }

  Future<BalanceSheetReportData?> buildBalanceSheet(ReportQuery query) async {
    final businessId = _businessId;
    if (businessId == null) return null;

    final range = dateRangeForReportQuery(query);
    final asOn = DateTime(range.end.year, range.end.month, range.end.day);
    final openingAsOf = DateTime(
      range.start.year,
      range.start.month,
      range.start.day,
    ).subtract(const Duration(days: 1));

    final salesTotal = await _sumSalesInRange(businessId, range, revenueSalesTypes);
    final salesReturnTotal = await _sumSalesInRange(
      businessId,
      range,
      const {'sales_return'},
    );
    final purchaseTotal = await _sumPurchasesInRange(
      businessId,
      range,
      'purchase_bill',
    );
    final purchaseReturnTotal = await _sumPurchasesInRange(
      businessId,
      range,
      'purchase_return',
    );

    final expenses = await _expenseLocal.listExpenses(businessId);
    var expenseTotal = 0.0;
    for (final expense in expenses) {
      if (!_inRange(expense.expenseDate, range)) continue;
      expenseTotal += _parseAmount(expense.amount);
    }

    final stockValue = await _localStockValue(businessId);
    final netProfit = ProfitLossReportBuilder.build(
      netSales: salesTotal - salesReturnTotal,
      netPurchases: purchaseTotal - purchaseReturnTotal,
      expenseTotal: expenseTotal,
      stockValue: stockValue,
    ).netProfit;

    final closingOutstanding = await _partyLedgerService.fetchOutstandingTotalsAsOf(
      businessId: businessId,
      asOfInclusive: asOn,
    );
    final openingOutstanding = await _partyLedgerService.fetchOutstandingTotalsAsOf(
      businessId: businessId,
      asOfInclusive: openingAsOf,
    );

    final cash = await _localCashBalanceAsOf(businessId, asOn);
    final openingCash = await _localCashBalanceAsOf(businessId, openingAsOf);

    var partyOpening = 0.0;
    for (final party in await _partyLocal.listActive(businessId)) {
      partyOpening += _parseAmount(party.openingBalance);
    }

    final built = BalanceSheetReportBuilder.build(
      cash: cash,
      receivable: closingOutstanding.receivable,
      payable: closingOutstanding.payable,
      stockValue: stockValue,
      netProfit: netProfit,
      partyOpening: partyOpening,
      openingCash: openingCash,
      openingReceivable: openingOutstanding.receivable,
      openingPayable: openingOutstanding.payable,
      openingStock: stockValue,
      asOn: asOn,
    );

    if (!BalanceSheetReportBuilder.hasMeaningfulActivity(
      assets: built.assets,
      liabilities: built.liabilities,
      assetsTotal: built.assetsTotal,
      liabilitiesTotal: built.liabilitiesTotal,
      netProfit: built.netProfit,
    )) {
      return null;
    }

    return BalanceSheetReportData(
      assets: built.assets,
      liabilities: built.liabilities,
      assetsTotal: built.assetsTotal,
      liabilitiesTotal: built.liabilitiesTotal,
      netProfit: built.netProfit,
      openingAssets: built.openingAssets,
      closingAssets: built.closingAssets,
      openingLiabilities: built.openingLiabilities,
      closingLiabilities: built.closingLiabilities,
      openingEquity: built.openingEquity,
      closingEquity: built.closingEquity,
      isBalanced: built.isBalanced,
      asOn: built.asOn,
    );
  }

  Future<double> _localCashBalanceAsOf(
    String businessId,
    DateTime asOfInclusive,
  ) async {
    final nextDay = DateTime(
      asOfInclusive.year,
      asOfInclusive.month,
      asOfInclusive.day,
    ).add(const Duration(days: 1));
    return _localOpeningCashBalance(businessId, nextDay);
  }

  Future<double> _localStockValue(String businessId) async {
    final items = await _itemsLocal.listActive(businessId);
    var total = 0.0;
    for (final item in items) {
      if (!item.hasStockTracking) continue;
      final qty = double.tryParse(item.quantity ?? '') ?? 0;
      if (qty <= 0) continue;
      final price = double.tryParse(item.purchasePrice) ?? 0;
      total += qty * price;
    }
    return total;
  }

  Future<ProfitLossReportData?> buildProfitLoss(ReportQuery query) async {
    final businessId = _businessId;
    if (businessId == null) return null;

    final range = dateRangeForReportQuery(query);
    final salesTotal = await _sumSalesInRange(businessId, range, revenueSalesTypes);
    final salesReturnTotal = await _sumSalesInRange(
      businessId,
      range,
      const {'sales_return'},
    );
    final purchaseTotal = await _sumPurchasesInRange(
      businessId,
      range,
      'purchase_bill',
    );
    final purchaseReturnTotal = await _sumPurchasesInRange(
      businessId,
      range,
      'purchase_return',
    );

    final expenses = await _expenseLocal.listExpenses(businessId);
    var expenseTotal = 0.0;
    for (final expense in expenses) {
      if (!_inRange(expense.expenseDate, range)) continue;
      expenseTotal += _parseAmount(expense.amount);
    }

    final netSales = salesTotal - salesReturnTotal;
    final netPurchases = purchaseTotal - purchaseReturnTotal;
    if (netSales == 0 &&
        netPurchases == 0 &&
        expenseTotal == 0 &&
        salesReturnTotal == 0 &&
        purchaseReturnTotal == 0) {
      return null;
    }

    final built = ProfitLossReportBuilder.build(
      netSales: netSales,
      netPurchases: netPurchases,
      expenseTotal: expenseTotal,
    );
    return ProfitLossReportData(
      items: built.items,
      netProfit: built.netProfit,
    );
  }

  Future<double> _sumSalesInRange(
    String businessId,
    DateTimeRange range,
    Set<String> documentTypes,
  ) async {
    var total = 0.0;
    for (final type in documentTypes) {
      final docs = await _salesLocal.listByType(
        businessId: businessId,
        documentType: type,
      );
      for (final doc in docs) {
        if (doc.status != 'finalized') continue;
        if (!_inRange(doc.documentDate, range)) continue;
        total += _parseAmount(doc.totalAmount);
      }
    }
    return total;
  }

  Future<double> _sumPurchasesInRange(
    String businessId,
    DateTimeRange range,
    String documentType,
  ) async {
    var total = 0.0;
    final docs = await _purchaseLocal.listByType(
      businessId: businessId,
      documentType: documentType,
    );
    for (final doc in docs) {
      if (doc.status != 'finalized') continue;
      if (!_inRange(doc.documentDate, range)) continue;
      total += _parseAmount(doc.totalAmount);
    }
    return total;
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

  /// Offline stock summary (Vyapar-style item list with qty and valuation).
  Future<StockSummaryReportData?> buildStockSummary(ReportQuery query) async {
    final businessId = _businessId;
    if (businessId == null) return null;

    final stockByItem = await _aggregateLocalStock(
      businessId: businessId,
      godownId: query.godownId,
    );

    final items = await _itemsLocal.listActive(
      businessId,
      filter: (
        searchQuery: query.q,
        categoryId: query.categoryId,
        brandId: null,
        itemType: 'product',
      ),
    );

    final rows = <ReportStockSummaryRow>[];
    for (final item in items) {
      if (!item.hasStockTracking) continue;
      if (query.itemId != null &&
          query.itemId!.isNotEmpty &&
          item.id != query.itemId) {
        continue;
      }

      final agg = stockByItem[item.id];
      final qtyFromLevels = agg?.totalQty ?? 0;
      final qtyFromItem = _parseAmount(item.quantity ?? '0');
      final stockQty = qtyFromLevels > 0 ? qtyFromLevels : qtyFromItem;

      if (query.inStockOnly && stockQty <= 0) continue;

      final purchaseFromItem = _parseAmount(item.purchasePrice);
      final averageCost = stockQty > 0 && agg != null && agg.totalQty > 0
          ? agg.stockValue / agg.totalQty
          : purchaseFromItem;
      final stockValue = agg != null && agg.stockValue > 0
          ? agg.stockValue
          : stockQty * purchaseFromItem;

      rows.add(
        ReportStockSummaryRow(
          itemName: item.name,
          salePrice: _parseAmount(item.salePrice),
          purchasePrice: averageCost,
          stockQty: stockQty,
          stockValue: stockValue,
          categoryId: item.categoryId ?? '',
        ),
      );
    }

    if (rows.isEmpty) return null;

    rows.sort(
      (a, b) => a.itemName.toLowerCase().compareTo(b.itemName.toLowerCase()),
    );

    var totalStockValue = 0.0;
    for (final row in rows) {
      totalStockValue += row.stockValue;
    }

    final page = query.page < 1 ? 1 : query.page;
    final limit = query.limit < 1 ? 20 : query.limit;
    final start = (page - 1) * limit;
    final pageRows = start >= rows.length
        ? const <ReportStockSummaryRow>[]
        : rows.skip(start).take(limit).toList();
    final totalPages = rows.isEmpty ? 1 : (rows.length / limit).ceil();

    return StockSummaryReportData(
      rows: pageRows,
      totalStockValue: totalStockValue,
      meta: ReportPaginationMeta(
        page: page,
        limit: limit,
        total: rows.length,
        totalPages: totalPages,
      ),
    );
  }

  /// Items at or below reorder level (Vyapar / API low-stock report parity).
  Future<LowStockReportData?> buildLowStock(ReportQuery query) async {
    final businessId = _businessId;
    if (businessId == null) return null;

    final stockByItem = await _aggregateLocalStock(
      businessId: businessId,
      godownId: query.godownId,
    );

    final items = await _itemsLocal.listActive(
      businessId,
      filter: (
        searchQuery: query.q,
        categoryId: query.categoryId,
        brandId: null,
        itemType: 'product',
      ),
    );

    final rows = <ReportLowStockRow>[];
    for (final item in items) {
      if (!item.hasStockTracking) continue;
      if (query.itemId != null &&
          query.itemId!.isNotEmpty &&
          item.id != query.itemId) {
        continue;
      }

      final minStock = _parseAmount(item.reorderLevel ?? '0');
      if (minStock <= 0) continue;

      final agg = stockByItem[item.id];
      final qtyFromLevels = agg?.totalQty ?? 0;
      final qtyFromItem = _parseAmount(item.quantity ?? '0');
      final currentStock = qtyFromLevels > 0 ? qtyFromLevels : qtyFromItem;

      if (query.inStockOnly && currentStock <= 0) continue;
      if (currentStock > minStock) continue;

      final shortage = (minStock - currentStock) > 0
          ? minStock - currentStock
          : 0.0;

      rows.add(
        ReportLowStockRow(
          itemName: item.name,
          minStock: minStock,
          currentStock: currentStock,
          shortage: shortage,
        ),
      );
    }

    rows.sort(
      (a, b) => b.shortage.compareTo(a.shortage),
    );

    final page = query.page < 1 ? 1 : query.page;
    final limit = query.limit < 1 ? 20 : query.limit;
    final start = (page - 1) * limit;
    final pageRows = start >= rows.length
        ? const <ReportLowStockRow>[]
        : rows.skip(start).take(limit).toList();
    final totalPages = rows.isEmpty ? 1 : (rows.length / limit).ceil();

    return LowStockReportData(
      rows: pageRows,
      lowStockCount: rows.length,
      meta: ReportPaginationMeta(
        page: page,
        limit: limit,
        total: rows.length,
        totalPages: totalPages,
      ),
    );
  }

  Future<StockDetailReportData?> buildStockDetail(ReportQuery query) async {
    final businessId = _businessId;
    if (businessId == null) return null;

    final range = dateRangeForReportQuery(query);
    final stockByItem = await _aggregateLocalStock(
      businessId: businessId,
      godownId: query.godownId,
    );

    final items = await _itemsLocal.listActive(
      businessId,
      filter: (
        searchQuery: query.q,
        categoryId: query.categoryId,
        brandId: null,
        itemType: 'product',
      ),
    );
    final itemById = {for (final item in items) item.id: item};

    final periodIn = <String, double>{};
    final periodOut = <String, double>{};

    final movements = await _stockLocal.listMovementsInRange(
      businessId: businessId,
      from: range.start,
      to: range.end,
      godownId: query.godownId,
      itemId: query.itemId,
    );

    if (movements.isNotEmpty) {
      for (final movement in movements) {
        final delta = _parseAmount(movement.quantity);
        if (delta > 0) {
          periodIn[movement.itemId] = (periodIn[movement.itemId] ?? 0.0) + delta;
        } else if (delta < 0) {
          periodOut[movement.itemId] =
              (periodOut[movement.itemId] ?? 0.0) - delta;
        }
      }
    } else {
      await _accumulateStockDetailFromDocuments(
        businessId: businessId,
        range: range,
        periodIn: periodIn,
        periodOut: periodOut,
        itemIdFilter: query.itemId,
      );
    }

    final itemIds = <String>{
      ...stockByItem.keys,
      ...periodIn.keys,
      ...periodOut.keys,
    };

    final rows = <ReportStockDetailRow>[];
    for (final itemId in itemIds) {
      if (query.itemId != null &&
          query.itemId!.isNotEmpty &&
          itemId != query.itemId) {
        continue;
      }

      final item = itemById[itemId];
      if (item != null && !item.hasStockTracking) continue;
      if (query.categoryId != null &&
          query.categoryId!.isNotEmpty &&
          item?.categoryId != query.categoryId) {
        continue;
      }

      final itemName = item?.name ?? 'Unknown item';
      final closingFromLevels = stockByItem[itemId]?.totalQty ?? 0.0;
      final closingFromItem = item != null
          ? _parseAmount(item.quantity ?? '0')
          : 0.0;
      final closing = closingFromLevels > 0
          ? closingFromLevels
          : closingFromItem;

      final inQty = periodIn[itemId] ?? 0.0;
      final outQty = periodOut[itemId] ?? 0.0;
      final opening = closing - inQty + outQty;

      if (opening == 0 && inQty == 0 && outQty == 0 && closing == 0) {
        continue;
      }

      rows.add(
        ReportStockDetailRow(
          itemName: itemName,
          openingQty: opening,
          inQty: inQty,
          outQty: outQty,
          closingQty: closing,
        ),
      );
    }

    rows.sort(
      (a, b) => a.itemName.toLowerCase().compareTo(b.itemName.toLowerCase()),
    );

    final page = query.page < 1 ? 1 : query.page;
    final limit = query.limit < 1 ? 20 : query.limit;
    final start = (page - 1) * limit;
    final pageRows = start >= rows.length
        ? const <ReportStockDetailRow>[]
        : rows.skip(start).take(limit).toList();
    final totalPages = rows.isEmpty ? 1 : (rows.length / limit).ceil();

    return StockDetailReportData(
      rows: pageRows,
      meta: ReportPaginationMeta(
        page: page,
        limit: limit,
        total: rows.length,
        totalPages: totalPages,
      ),
    );
  }

  Future<ItemDetailReportData?> buildItemDetail(ReportQuery query) async {
    final businessId = _businessId;
    final itemId = query.itemId;
    if (businessId == null || itemId == null || itemId.isEmpty) return null;

    final range = dateRangeForReportQuery(query);
    final partyNames = await _partyNameIndex(businessId);
    final rows = <ReportItemDetailRow>[];

    for (final type in revenueSalesTypes) {
      final docs = await _salesLocal.listByType(
        businessId: businessId,
        documentType: type,
      );
      for (final doc in docs) {
        if (doc.status != 'finalized') continue;
        if (!_inRange(doc.documentDate, range)) continue;
        final party = partyNames[doc.partyId ?? ''] ?? '';
        for (final line in doc.lines) {
          if (line.itemId != itemId) continue;
          final qty = double.tryParse(line.quantity) ?? 0;
          if (qty <= 0) continue;
          final day =
              parseDocumentCalendarDay(doc.documentDate) ?? DateTime.now();
          rows.add(
            ReportItemDetailRow(
              date: day,
              type: 'Sale',
              refNo: doc.documentNumber ?? '',
              partyName: party,
              quantity: qty,
              price: _parseAmount(line.unitPrice),
              amount: _parseAmount(line.lineTotal),
            ),
          );
        }
      }
    }

    final purchaseDocs = await _purchaseLocal.listByType(
      businessId: businessId,
      documentType: 'purchase_bill',
    );
    for (final doc in purchaseDocs) {
      if (doc.status != 'finalized') continue;
      if (!_inRange(doc.documentDate, range)) continue;
      final party = partyNames[doc.partyId ?? ''] ?? '';
      for (final line in doc.lines) {
        if (line.itemId != itemId) continue;
        final qty = double.tryParse(line.quantity) ?? 0;
        if (qty <= 0) continue;
        final day =
            parseDocumentCalendarDay(doc.documentDate) ?? DateTime.now();
        rows.add(
          ReportItemDetailRow(
            date: day,
            type: 'Purchase',
            refNo: doc.documentNumber ?? '',
            partyName: party,
            quantity: qty,
            price: _parseAmount(line.unitPrice),
            amount: _parseAmount(line.lineTotal),
          ),
        );
      }
    }

    var periodSale = 0.0;
    var periodPurchase = 0.0;
    for (final row in rows) {
      if (row.type == 'Sale') {
        periodSale += row.quantity;
      } else {
        periodPurchase += row.quantity;
      }
    }

    final stockByItem = await _aggregateLocalStock(
      businessId: businessId,
      godownId: query.godownId,
    );
    final closing = stockByItem[itemId]?.totalQty ?? 0.0;
    final opening = itemDetailPeriodOpeningQty(
      currentClosingQty: closing,
      periodPurchaseQty: periodPurchase,
      periodSaleQty: periodSale,
    );

    final ledger = buildItemDetailLedgerRows(
      rows,
      openingQty: opening,
      newestFirst: true,
    );

    final page = query.page < 1 ? 1 : query.page;
    final limit = query.limit < 1 ? 20 : query.limit;
    final start = (page - 1) * limit;
    final pageLedger = start >= ledger.length
        ? const <ReportItemDetailTableRow>[]
        : ledger.skip(start).take(limit).toList();
    final totalPages = ledger.isEmpty ? 1 : (ledger.length / limit).ceil();

    return ItemDetailReportData(
      rows: pageLedger.map((entry) => entry.row).toList(),
      meta: ReportPaginationMeta(
        page: page,
        limit: limit,
        total: ledger.length,
        totalPages: totalPages,
      ),
      openingQuantity: opening,
      ledgerRows: pageLedger,
    );
  }

  Future<CategoryAmountReportData?> buildSalePurchaseByItemCategory(
    ReportQuery query,
  ) async {
    final businessId = _businessId;
    if (businessId == null) return null;

    final range = dateRangeForReportQuery(query);
    final categories = await _categoriesLocal.listActive(businessId);
    final categoryNameById = {
      for (final category in categories) category.id: category.name,
    };

    final items = await _itemsLocal.listActive(businessId);
    final itemCategoryById = {
      for (final item in items) item.id: item.categoryId,
    };

    final categoryIdFilter = query.categoryId?.trim();
    final saleByCategory = <String, double>{};
    final purchaseByCategory = <String, double>{};

    for (final type in revenueSalesTypes) {
      final docs = await _salesLocal.listByType(
        businessId: businessId,
        documentType: type,
      );
      for (final doc in docs) {
        if (doc.status != 'finalized') continue;
        if (!_inRange(doc.documentDate, range)) continue;

        for (final line in doc.lines) {
          final categoryId = itemCategoryById[line.itemId];
          if (categoryIdFilter != null &&
              categoryIdFilter.isNotEmpty &&
              categoryId != categoryIdFilter) {
            continue;
          }
          final label = _categoryLabel(categoryId, categoryNameById);
          saleByCategory[label] =
              (saleByCategory[label] ?? 0.0) + _parseAmount(line.lineTotal);
        }
      }
    }

    final purchaseDocs = await _purchaseLocal.listByType(
      businessId: businessId,
      documentType: 'purchase_bill',
    );
    for (final doc in purchaseDocs) {
      if (doc.status != 'finalized') continue;
      if (!_inRange(doc.documentDate, range)) continue;

      for (final line in doc.lines) {
        final categoryId = itemCategoryById[line.itemId];
        if (categoryIdFilter != null &&
            categoryIdFilter.isNotEmpty &&
            categoryId != categoryIdFilter) {
          continue;
        }
        final label = _categoryLabel(categoryId, categoryNameById);
        purchaseByCategory[label] =
            (purchaseByCategory[label] ?? 0.0) + _parseAmount(line.lineTotal);
      }
    }

    final categoryNames = <String>{
      ...saleByCategory.keys,
      ...purchaseByCategory.keys,
    };

    final q = query.q?.trim().toLowerCase();
    final rows = <ReportCategoryAmountRow>[];
    for (final category in categoryNames) {
      if (q != null && q.isNotEmpty && !category.toLowerCase().contains(q)) {
        continue;
      }
      final saleAmount = saleByCategory[category] ?? 0.0;
      final purchaseAmount = purchaseByCategory[category] ?? 0.0;
      if (saleAmount == 0 && purchaseAmount == 0) continue;
      rows.add(
        ReportCategoryAmountRow(
          category: category,
          saleAmount: saleAmount,
          purchaseAmount: purchaseAmount,
        ),
      );
    }

    rows.sort(
      (a, b) => a.category.toLowerCase().compareTo(b.category.toLowerCase()),
    );

    return CategoryAmountReportData(rows: rows);
  }

  Future<CategoryAmountReportData?> buildItemCategoryWiseProfitLoss(
    ReportQuery query,
  ) =>
      buildSalePurchaseByItemCategory(query);

  Future<CategoryAmountReportData?> buildStockSummaryByItemCategory(
    ReportQuery query,
  ) async {
    final businessId = _businessId;
    if (businessId == null) return null;

    final range = dateRangeForReportQuery(query);
    final categories = await _categoriesLocal.listActive(businessId);
    final categoryNameById = {
      for (final category in categories) category.id: category.name,
    };

    final stockByItem = await _aggregateLocalStock(
      businessId: businessId,
      godownId: query.godownId,
    );

    final items = await _itemsLocal.listActive(
      businessId,
      filter: (
        searchQuery: null,
        categoryId: query.categoryId,
        brandId: null,
        itemType: 'product',
      ),
    );

    final stockValueByCategory = <String, double>{};
    final lowStockCategoryNames = <String>{};

    for (final item in items) {
      if (!item.hasStockTracking) continue;

      final categoryId = item.categoryId;
      if (query.categoryId != null &&
          query.categoryId!.isNotEmpty &&
          categoryId != query.categoryId) {
        continue;
      }

      final label = _categoryLabel(categoryId, categoryNameById);
      final agg = stockByItem[item.id];
      final qtyFromLevels = agg?.totalQty ?? 0.0;
      final qtyFromItem = _parseAmount(item.quantity ?? '0');
      final stockQty = qtyFromLevels > 0 ? qtyFromLevels : qtyFromItem;

      final purchaseFromItem = _parseAmount(item.purchasePrice);
      final stockValue = agg != null && agg.stockValue > 0
          ? agg.stockValue
          : stockQty * purchaseFromItem;

      stockValueByCategory[label] =
          (stockValueByCategory[label] ?? 0.0) + stockValue;

      final reorderLevel = _parseAmount(item.reorderLevel ?? '0');
      if (reorderLevel > 0 && stockQty <= reorderLevel) {
        lowStockCategoryNames.add(label);
      }
    }

    final itemCategoryById = {
      for (final item in items) item.id: item.categoryId,
    };
    final saleByCategory = <String, double>{};
    final categoryIdFilter = query.categoryId?.trim();

    for (final type in revenueSalesTypes) {
      final docs = await _salesLocal.listByType(
        businessId: businessId,
        documentType: type,
      );
      for (final doc in docs) {
        if (doc.status != 'finalized') continue;
        if (!_inRange(doc.documentDate, range)) continue;

        for (final line in doc.lines) {
          final categoryId = itemCategoryById[line.itemId];
          if (categoryIdFilter != null &&
              categoryIdFilter.isNotEmpty &&
              categoryId != categoryIdFilter) {
            continue;
          }
          final label = _categoryLabel(categoryId, categoryNameById);
          saleByCategory[label] =
              (saleByCategory[label] ?? 0.0) + _parseAmount(line.lineTotal);
        }
      }
    }

    final categoryNames = <String>{
      ...stockValueByCategory.keys,
      ...saleByCategory.keys,
    };

    final q = query.q?.trim().toLowerCase();
    final rows = <ReportCategoryAmountRow>[];
    for (final category in categoryNames) {
      if (q != null && q.isNotEmpty && !category.toLowerCase().contains(q)) {
        continue;
      }
      final saleAmount = saleByCategory[category] ?? 0.0;
      final stockValue = stockValueByCategory[category] ?? 0.0;
      if (saleAmount == 0 && stockValue == 0) continue;
      rows.add(
        ReportCategoryAmountRow(
          category: category,
          saleAmount: saleAmount,
          purchaseAmount: stockValue,
        ),
      );
    }

    rows.sort(
      (a, b) => a.category.toLowerCase().compareTo(b.category.toLowerCase()),
    );

    return CategoryAmountReportData(
      rows: rows,
      lowStockCategoryNames: lowStockCategoryNames,
    );
  }

  Future<void> _accumulateStockDetailFromDocuments({
    required String businessId,
    required DateTimeRange range,
    required Map<String, double> periodIn,
    required Map<String, double> periodOut,
    String? itemIdFilter,
  }) async {
    for (final type in revenueSalesTypes) {
      final docs = await _salesLocal.listByType(
        businessId: businessId,
        documentType: type,
      );
      for (final doc in docs) {
        if (doc.status != 'finalized') continue;
        if (!_inRange(doc.documentDate, range)) continue;
        for (final line in doc.lines) {
          if (itemIdFilter != null &&
              itemIdFilter.isNotEmpty &&
              line.itemId != itemIdFilter) {
            continue;
          }
          final qty = double.tryParse(line.quantity) ?? 0;
          if (qty <= 0) continue;
          periodOut[line.itemId] = (periodOut[line.itemId] ?? 0) + qty;
        }
      }
    }

    final purchaseDocs = await _purchaseLocal.listByType(
      businessId: businessId,
      documentType: 'purchase_bill',
    );
    for (final doc in purchaseDocs) {
      if (doc.status != 'finalized') continue;
      if (!_inRange(doc.documentDate, range)) continue;
      for (final line in doc.lines) {
        if (itemIdFilter != null &&
            itemIdFilter.isNotEmpty &&
            line.itemId != itemIdFilter) {
          continue;
        }
        final qty = double.tryParse(line.quantity) ?? 0;
        if (qty <= 0) continue;
        periodIn[line.itemId] = (periodIn[line.itemId] ?? 0) + qty;
      }
    }
  }

  Future<Map<String, _LocalStockAggregate>> _aggregateLocalStock({
    required String businessId,
    String? godownId,
  }) async {
    final levelRows = await _stockLocal.listAllStockLevels(businessId: businessId);
    final totals = <String, _LocalStockAggregate>{};

    for (final row in levelRows) {
      if (godownId != null &&
          godownId.isNotEmpty &&
          row.godownId != godownId) {
        continue;
      }
      final qty = _parseAmount(row.currentQuantity);
      final unitCost = _parseAmount(row.averageCost);
      final agg = totals.putIfAbsent(row.itemId, _LocalStockAggregate.new);
      agg.totalQty += qty;
      agg.stockValue += qty * unitCost;
    }
    return totals;
  }

  Future<Map<String, String>> _partyNameIndex(String businessId) async {
    final dtos = await _partyLocal.listActive(businessId);
    return {for (final dto in dtos) dto.id: dto.name};
  }

  Future<Map<String, double>> _itemPurchasePriceIndex(String businessId) async {
    final items = await _itemsLocal.listActive(businessId);
    return {
      for (final item in items)
        item.id: double.tryParse(item.purchasePrice) ?? 0,
    };
  }

  bool _inRange(String documentDate, DateTimeRange range) {
    final day = parseDocumentCalendarDay(documentDate);
    if (day == null) return false;
    return isCalendarDayInRange(day, range);
  }

  String _categoryLabel(
    String? categoryId,
    Map<String, String> categoryNameById,
  ) {
    if (categoryId == null || categoryId.isEmpty) return 'Uncategorized';
    return categoryNameById[categoryId] ?? 'Uncategorized';
  }

  bool _matchesReportPartyType(String partyType, String? filter) {
    if (filter == null || filter.isEmpty) return true;
    if (filter == 'customer') {
      return partyType == 'customer' || partyType == 'both';
    }
    if (filter == 'supplier') {
      return partyType == 'supplier' || partyType == 'both';
    }
    return partyType == filter;
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

class _LocalStockAggregate {
  double totalQty = 0;
  double stockValue = 0;
}

class _ItemPartySaleAgg {
  String itemName = '';
  String partyName = '';
  double quantity = 0;
  double amount = 0;
}

class _ItemWiseSaleAgg {
  String itemName = '';
  double saleAmount = 0;
  double costAmount = 0;
}

class _ItemWiseDiscountAgg {
  String itemName = '';
  double saleQty = 0;
  double saleAmount = 0;
  double discountAmount = 0;
}

class _SalePurchaseByPartyAcc {
  const _SalePurchaseByPartyAcc({
    required this.partyId,
    required this.partyName,
    required this.saleAmount,
    required this.purchaseAmount,
  });

  final String partyId;
  final String partyName;
  final double saleAmount;
  final double purchaseAmount;
}
