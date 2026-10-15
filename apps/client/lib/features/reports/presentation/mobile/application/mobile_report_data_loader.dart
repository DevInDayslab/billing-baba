import 'package:billing_baba/core/network/api_error_parser.dart';
import 'package:billing_baba/core/network/network_exception_classifier.dart';
import 'package:billing_baba/core/network/offline_ui_messages.dart';
import 'package:billing_baba/features/parties/models/party_model.dart';
import 'package:billing_baba/features/reports/application/gst_report_provider.dart';
import 'package:billing_baba/features/reports/application/tax_report_provider.dart';
import 'package:billing_baba/features/reports/application/phase1_report_providers.dart';
import 'package:billing_baba/features/reports/application/report_providers.dart';
import 'package:billing_baba/features/reports/models/dto/gst_report_v2_dto.dart';
import 'package:billing_baba/features/reports/models/gst_report_type.dart';
import 'package:billing_baba/features/reports/application/reports_service.dart';
import 'package:billing_baba/features/reports/models/report_models.dart';
import 'package:billing_baba/features/reports/models/report_nav_group.dart';
import 'package:billing_baba/features/reports/models/tax_report_kind.dart';
import 'package:billing_baba/features/reports/presentation/mobile/application/mobile_report_formatters.dart';
import 'package:billing_baba/features/reports/presentation/mobile/application/mobile_tax_report_data_loader.dart';
import 'package:billing_baba/features/reports/presentation/mobile/application/mobile_other_income_loan_report_mapper.dart';
import 'package:billing_baba/features/reports/presentation/mobile/application/mobile_report_subsection_registry.dart';
import 'package:billing_baba/features/reports/presentation/mobile/models/mobile_report_view_model.dart';
import 'package:billing_baba/features/reports/utils/expense_export.dart';
import 'package:billing_baba/features/reports/utils/report_formatters.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Loads and maps report provider data into [MobileReportViewData].
abstract final class MobileReportDataLoader {
  static AsyncValue<MobileReportViewData> watch(
    WidgetRef ref,
    ReportNavGroup group,
    String subsectionId,
  ) {
    final config = MobileReportSubsectionRegistry.config(group, subsectionId);
    if (config == null) {
      return const AsyncData(MobileReportViewData.empty);
    }

    final async = switch ((group, subsectionId)) {
      (ReportNavGroup.transaction, 'sale') =>
        ref
            .watch(saleReportProvider)
            .whenData((data) => _fromSale(data, config)),
      (ReportNavGroup.transaction, 'purchase') =>
        ref
            .watch(purchaseReportProvider)
            .whenData((data) => _fromPurchase(data, config)),
      (ReportNavGroup.transaction, 'dayBook') =>
        ref
            .watch(dayBookReportProvider)
            .whenData((data) => _fromDayBook(data, config)),
      (ReportNavGroup.transaction, 'allTransaction') =>
        ref
            .watch(allTransactionsReportProvider)
            .whenData(
              (data) => _fromTransactions(data.rows, data.meta.total, config),
            ),
      (ReportNavGroup.transaction, 'profitLoss') =>
        ref
            .watch(profitLossReportProvider)
            .whenData((data) => _fromProfitLoss(data, config)),
      (ReportNavGroup.transaction, 'billWiseProfit') =>
        ref
            .watch(billWiseProfitReportProvider)
            .whenData((data) => _fromBillWiseProfit(data, config)),
      (ReportNavGroup.transaction, 'cashFlow') =>
        ref
            .watch(cashFlowReportProvider)
            .whenData((data) => _fromCashFlow(data, config)),
      (ReportNavGroup.transaction, 'trialBalance') =>
        ref
            .watch(trialBalanceReportProvider)
            .whenData((data) => _fromTrialBalance(data, config)),
      (ReportNavGroup.transaction, 'balanceSheet') =>
        ref
            .watch(balanceSheetReportProvider)
            .whenData((data) => _fromBalanceSheet(data, config)),
      (ReportNavGroup.party, 'partyStatement') =>
        ref
            .watch(partyStatementReportProvider)
            .whenData(
              (data) => data == null
                  ? _empty(config)
                  : _fromPartyStatement(data, config),
            ),
      (ReportNavGroup.party, 'partyWiseProfitLoss') =>
        ref
            .watch(partyWiseProfitLossReportProvider)
            .whenData((data) => _fromPartyWiseProfitLoss(data, config)),
      (ReportNavGroup.party, 'allParties') =>
        ref
            .watch(partyOutstandingReportProvider)
            .whenData((data) => _fromAllParties(data, config)),
      (ReportNavGroup.party, 'partyReportByItem') =>
        ref
            .watch(partyReportByItemReportProvider)
            .whenData(
              (data) => data == null
                  ? _empty(config)
                  : _fromPartyByItem(data, config),
            ),
      (ReportNavGroup.party, 'salePurchaseByParty') =>
        ref
            .watch(salePurchaseByPartyReportProvider)
            .whenData((data) => _fromSalePurchaseByParty(data, config)),
      (ReportNavGroup.party, 'salePurchaseByPartyGroup') =>
        ref
            .watch(salePurchaseByPartyGroupReportProvider)
            .whenData((data) => _fromSalePurchaseByPartyGroup(data, config)),
      (ReportNavGroup.gst, _) when _gstTypeForSubsection(subsectionId) != null =>
        ref
            .watch(gstReportProvider(_gstTypeForSubsection(subsectionId)!))
            .whenData(
              (data) => MobileTaxReportDataLoader.mapGstEnvelope(data, config),
            ),
      (ReportNavGroup.itemStock, 'itemReportByParty') =>
        ref
            .watch(itemReportByPartyReportProvider)
            .whenData((data) => _fromItemReportByParty(data, config)),
      (ReportNavGroup.itemStock, 'itemWiseProfitLoss') =>
        ref
            .watch(itemWiseProfitLossReportProvider)
            .whenData((data) => _fromItemWiseProfitLoss(data, config)),
      (ReportNavGroup.itemStock, 'lowStockSummary') =>
        ref
            .watch(lowStockReportProvider)
            .whenData((data) => _fromLowStock(data, config)),
      (ReportNavGroup.itemStock, 'stockDetail') =>
        ref
            .watch(stockDetailReportProvider)
            .whenData((data) => _fromStockDetail(data, config)),
      (ReportNavGroup.itemStock, 'salePurchaseReportByItemCategory') =>
        ref
            .watch(salePurchaseByItemCategoryReportProvider)
            .whenData((data) => _fromCategoryAmount(data, config)),
      (ReportNavGroup.itemStock, 'stockSummaryReportByItemCategory') =>
        ref
            .watch(stockSummaryByItemCategoryReportProvider)
            .whenData((data) => _fromCategoryAmount(data, config)),
      (ReportNavGroup.itemStock, 'itemCategoryWiseProfitLoss') =>
        ref
            .watch(itemCategoryWiseProfitLossReportProvider)
            .whenData((data) => _fromCategoryAmount(data, config)),
      (ReportNavGroup.itemStock, 'itemWiseDiscount') =>
        ref
            .watch(itemWiseDiscountReportProvider)
            .whenData((data) => _fromItemWiseDiscount(data, config)),
      (ReportNavGroup.itemStock, 'manufacturingReport') =>
        ref
            .watch(manufacturingReportProvider)
            .whenData((data) => _fromManufacturing(data, config)),
      (ReportNavGroup.itemStock, 'consumptionReport') =>
        ref
            .watch(consumptionReportProvider)
            .whenData((data) => _fromConsumption(data, config)),
      (ReportNavGroup.itemStock, 'stockTransferReport') =>
        ref
            .watch(stockTransferReportProvider)
            .whenData((data) => _fromStockTransfer(data, config)),
      (ReportNavGroup.businessStatus, 'bankStatement') =>
        ref
            .watch(bankStatementReportProvider)
            .whenData(
              (data) => data == null
                  ? _empty(config)
                  : _fromBankStatement(data, config),
            ),
      (ReportNavGroup.taxes, _) when _taxKindForSubsection(subsectionId) != null =>
        ref
            .watch(taxReportProvider(_taxKindForSubsection(subsectionId)!))
            .whenData(
              (data) => MobileTaxReportDataLoader.mapGstEnvelope(data, config),
            ),
      (ReportNavGroup.expenseReport, 'expense') =>
        ref
            .watch(expensesReportProvider)
            .whenData((data) => _fromExpenses(data, config)),
      (ReportNavGroup.expenseReport, 'expenseCategoryReport') =>
        ref
            .watch(expenseByCategoryReportProvider)
            .whenData((data) => _fromExpenseCategories(data, config)),
      (ReportNavGroup.expenseReport, 'expenseItemReport') =>
        ref
            .watch(expenseByItemReportProvider)
            .whenData((data) => _fromExpenseItems(data, config)),
      (ReportNavGroup.salePurchaseOrderReport, 'salePurchaseOrders') =>
        ref
            .watch(salePurchaseOrdersReportProvider)
            .whenData((data) => _fromSalePurchaseOrders(data, config)),
      (ReportNavGroup.salePurchaseOrderReport, 'salePurchaseOrderItem') =>
        ref
            .watch(salePurchaseOrderItemsReportProvider)
            .whenData((data) => _fromSalePurchaseOrderItems(data, config)),
      (ReportNavGroup.otherIncomeReport, 'otherIncome') =>
        ref
            .watch(otherIncomeReportProvider)
            .whenData(
              (data) =>
                  MobileOtherIncomeLoanReportMapper.fromOtherIncome(data, config),
            ),
      (ReportNavGroup.otherIncomeReport, 'otherIncomeCategoryReport') =>
        ref
            .watch(otherIncomeByCategoryReportProvider)
            .whenData(
              (data) => MobileOtherIncomeLoanReportMapper.fromOtherIncomeCategories(
                data,
                config,
              ),
            ),
      (ReportNavGroup.otherIncomeReport, 'otherIncomeItemReport') =>
        ref
            .watch(otherIncomeByItemReportProvider)
            .whenData(
              (data) => MobileOtherIncomeLoanReportMapper.fromOtherIncomeItems(
                data,
                config,
              ),
            ),
      (ReportNavGroup.loanAccounts, 'loanStatement') =>
        ref
            .watch(loanStatementReportProvider)
            .whenData(
              (data) => data == null
                  ? _empty(config)
                  : MobileOtherIncomeLoanReportMapper.fromLoanStatement(
                      data,
                      config,
                    ),
            ),
      _ => AsyncData(_empty(config)),
    };

    // Prefer empty/offline error UX over demo data when the API is unreachable.
    if (async.hasError && _shouldUseDemoFallback(async.error!)) {
      return AsyncData(_empty(config));
    }

    if (async.hasValue) {
      return AsyncData(async.requireValue);
    }

    return async.when(
      skipLoadingOnReload: true,
      skipLoadingOnRefresh: true,
      loading: () => const AsyncLoading(),
      error: (error, stackTrace) {
        if (_shouldUseDemoFallback(error)) {
          return AsyncData(_empty(config));
        }
        return AsyncError(error, stackTrace);
      },
      data: AsyncData.new,
    );
  }

  static bool _shouldUseDemoFallback(Object error) {
    if (error is ReportsException && error.code == 'OFFLINE') return true;
    if (error is DioException && ApiErrorParser.isOffline(error)) return true;
    if (NetworkExceptionClassifier.isConnectivityError(error)) return true;
    if (OfflineUiMessages.isOfflineError(error)) return true;
    return false;
  }

  static void refresh(WidgetRef ref, ReportNavGroup group, String id) {
    switch ((group, id)) {
      case (ReportNavGroup.transaction, 'sale'):
        ref.read(saleReportProvider.notifier).refresh();
      case (ReportNavGroup.transaction, 'purchase'):
        ref.read(purchaseReportProvider.notifier).refresh();
      case (ReportNavGroup.transaction, 'dayBook'):
        ref.read(dayBookReportProvider.notifier).refresh();
      case (ReportNavGroup.transaction, 'allTransaction'):
        ref.read(allTransactionsReportProvider.notifier).refresh();
      case (ReportNavGroup.transaction, 'profitLoss'):
        ref.read(profitLossReportProvider.notifier).refresh();
      case (ReportNavGroup.transaction, 'billWiseProfit'):
        ref.read(billWiseProfitReportProvider.notifier).refresh();
      case (ReportNavGroup.transaction, 'cashFlow'):
        ref.read(cashFlowReportProvider.notifier).refresh();
      case (ReportNavGroup.transaction, 'trialBalance'):
        ref.read(trialBalanceReportProvider.notifier).refresh();
      case (ReportNavGroup.transaction, 'balanceSheet'):
        ref.read(balanceSheetReportProvider.notifier).refresh();
      case (ReportNavGroup.party, 'partyStatement'):
        ref.read(partyStatementReportProvider.notifier).refresh();
      case (ReportNavGroup.party, 'partyWiseProfitLoss'):
        ref.read(partyWiseProfitLossReportProvider.notifier).refresh();
      case (ReportNavGroup.party, 'allParties'):
        ref.read(partyOutstandingReportProvider.notifier).refresh();
      case (ReportNavGroup.party, 'partyReportByItem'):
        ref.read(partyReportByItemReportProvider.notifier).refresh();
      case (ReportNavGroup.party, 'salePurchaseByParty'):
        ref.read(salePurchaseByPartyReportProvider.notifier).refresh();
      case (ReportNavGroup.party, 'salePurchaseByPartyGroup'):
        ref.read(salePurchaseByPartyGroupReportProvider.notifier).refresh();
      case (ReportNavGroup.gst, _):
        final gstType = _gstTypeForSubsection(id);
        if (gstType != null) {
          ref.read(gstReportProvider(gstType).notifier).refresh();
        }
      case (ReportNavGroup.itemStock, 'itemReportByParty'):
        ref.read(itemReportByPartyReportProvider.notifier).refresh();
      case (ReportNavGroup.itemStock, 'itemWiseProfitLoss'):
        ref.read(itemWiseProfitLossReportProvider.notifier).refresh();
      case (ReportNavGroup.itemStock, 'lowStockSummary'):
        ref.read(lowStockReportProvider.notifier).refresh();
      case (ReportNavGroup.itemStock, 'stockDetail'):
        ref.read(stockDetailReportProvider.notifier).refresh();
      case (ReportNavGroup.itemStock, 'salePurchaseReportByItemCategory'):
        ref.read(salePurchaseByItemCategoryReportProvider.notifier).refresh();
      case (ReportNavGroup.itemStock, 'stockSummaryReportByItemCategory'):
        ref.read(stockSummaryByItemCategoryReportProvider.notifier).refresh();
      case (ReportNavGroup.itemStock, 'itemCategoryWiseProfitLoss'):
        ref.read(itemCategoryWiseProfitLossReportProvider.notifier).refresh();
      case (ReportNavGroup.itemStock, 'itemWiseDiscount'):
        ref.read(itemWiseDiscountReportProvider.notifier).refresh();
      case (ReportNavGroup.itemStock, 'manufacturingReport'):
        ref.read(manufacturingReportProvider.notifier).refresh();
      case (ReportNavGroup.itemStock, 'consumptionReport'):
        ref.read(consumptionReportProvider.notifier).refresh();
      case (ReportNavGroup.itemStock, 'stockTransferReport'):
        ref.read(stockTransferReportProvider.notifier).refresh();
      case (ReportNavGroup.businessStatus, 'bankStatement'):
        ref.read(bankStatementReportProvider.notifier).refresh();
      case (ReportNavGroup.taxes, _):
        final taxKind = _taxKindForSubsection(id);
        if (taxKind != null) {
          ref.read(taxReportProvider(taxKind).notifier).refresh();
        }
      case (ReportNavGroup.expenseReport, 'expense'):
        ref.read(expensesReportProvider.notifier).refresh();
      case (ReportNavGroup.expenseReport, 'expenseCategoryReport'):
        ref.read(expenseByCategoryReportProvider.notifier).refresh();
      case (ReportNavGroup.expenseReport, 'expenseItemReport'):
        ref.read(expenseByItemReportProvider.notifier).refresh();
      case (ReportNavGroup.salePurchaseOrderReport, 'salePurchaseOrders'):
        ref.read(salePurchaseOrdersReportProvider.notifier).refresh();
      case (ReportNavGroup.salePurchaseOrderReport, 'salePurchaseOrderItem'):
        ref.read(salePurchaseOrderItemsReportProvider.notifier).refresh();
      case (ReportNavGroup.otherIncomeReport, 'otherIncome'):
        ref.read(otherIncomeReportProvider.notifier).refresh();
      case (ReportNavGroup.otherIncomeReport, 'otherIncomeCategoryReport'):
        ref.read(otherIncomeByCategoryReportProvider.notifier).refresh();
      case (ReportNavGroup.otherIncomeReport, 'otherIncomeItemReport'):
        ref.read(otherIncomeByItemReportProvider.notifier).refresh();
      case (ReportNavGroup.loanAccounts, 'loanStatement'):
        ref.read(loanStatementReportProvider.notifier).refresh();
      default:
        break;
    }
  }

  static MobileReportViewData _empty(MobileReportSubsectionConfig config) {
    return MobileReportViewData(
      summaryMetrics: [
        MobileReportSummaryMetric(label: config.summaryLabels[0], value: '0'),
        MobileReportSummaryMetric(
          label: config.summaryLabels[1],
          value: formatReportCurrency(0),
        ),
        MobileReportSummaryMetric(
          label: config.summaryLabels[2],
          value: formatReportCurrency(0),
        ),
      ],
      rows: const [],
      totalCount: 0,
    );
  }

  static MobileReportViewData _build({
    required MobileReportSubsectionConfig config,
    required int count,
    required List<MobileReportSummaryMetric> metrics,
    required List<MobileReportRow> rows,
    List<String> filterChips = const [],
    List<String> exportHeaders = const ['Name', 'Reference', 'Value'],
    List<List<String>> exportRows = const [],
  }) {
    return MobileReportViewData(
      summaryMetrics: metrics,
      rows: rows,
      totalCount: count,
      filterChips: filterChips,
      exportHeaders: exportHeaders,
      exportRows: exportRows,
    );
  }

  static MobileReportRow _row(
    MobileReportSubsectionConfig config, {
    required String title,
    required String reference,
    required List<String> values,
    DateTime? dateTime,
  }) {
    return MobileReportRow(
      title: title,
      reference: shortenMobileReportReference(reference),
      dateTime: dateTime,
      columns: [
        for (var i = 0; i < config.columnLabels.length; i++)
          MobileReportRowColumn(
            label: config.columnLabels[i],
            value: i < values.length ? values[i] : '-',
          ),
      ],
    );
  }

  static MobileReportViewData _fromSale(
    SaleReportData data,
    MobileReportSubsectionConfig config,
  ) {
    return _build(
      config: config,
      count: data.meta.total,
      metrics: [
        MobileReportSummaryMetric(
          label: config.summaryLabels[0],
          value: '${data.meta.total}',
        ),
        MobileReportSummaryMetric(
          label: config.summaryLabels[1],
          value: formatReportCurrency(data.totalSalesAmount),
        ),
        MobileReportSummaryMetric(
          label: config.summaryLabels[2],
          value: formatReportCurrency(data.balanceAmount),
          valueColor: const Color(0xFF2E7D32),
        ),
      ],
      rows: [
        for (final invoice in data.rows) _fromSaleInvoice(invoice, config),
      ],
      filterChips: const ['Txns Type - Sale'],
    );
  }

  static MobileReportRow _fromSaleInvoice(
    SaleInvoiceModel invoice,
    MobileReportSubsectionConfig config,
  ) {
    return _row(
      config,
      title: invoice.partyName,
      reference: '${config.referencePrefix} ${invoice.invoiceNo}',
      dateTime: invoice.date,
      values: [
        formatReportCurrency(invoice.amount),
        formatReportCurrency(invoice.balance),
        formatMobileReportDueDate(invoice.dueDate ?? invoice.date),
      ],
    );
  }

  static MobileReportViewData _fromPurchase(
    PurchaseReportData data,
    MobileReportSubsectionConfig config,
  ) {
    return _build(
      config: config,
      count: data.meta.total,
      metrics: [
        MobileReportSummaryMetric(
          label: config.summaryLabels[0],
          value: '${data.meta.total}',
        ),
        MobileReportSummaryMetric(
          label: config.summaryLabels[1],
          value: formatReportCurrency(data.totalAmount),
        ),
        MobileReportSummaryMetric(
          label: config.summaryLabels[2],
          value: formatReportCurrency(data.balanceAmount),
        ),
      ],
      rows: [
        for (final row in data.rows)
          _row(
            config,
            title: row.partyName,
            reference: '${config.referencePrefix} ${row.invoiceNo}',
            dateTime: row.date,
            values: [
              formatReportCurrency(row.amount),
              formatReportCurrency(row.balance),
              formatMobileReportDueDate(row.date),
            ],
          ),
      ],
      filterChips: const ['Txns Type - Purchase'],
    );
  }

  static MobileReportViewData _fromDayBook(
    DayBookReportData data,
    MobileReportSubsectionConfig config,
  ) {
    final rowMoneyIn = data.rows.fold<double>(
      0,
      (sum, row) => sum + row.moneyIn,
    );
    final rowMoneyOut = data.rows.fold<double>(
      0,
      (sum, row) => sum + row.moneyOut,
    );
    final totalMoneyIn = data.totalMoneyIn != 0 || rowMoneyIn == 0
        ? data.totalMoneyIn
        : rowMoneyIn;
    final totalMoneyOut = data.totalMoneyOut != 0 || rowMoneyOut == 0
        ? data.totalMoneyOut
        : rowMoneyOut;

    return _build(
      config: config,
      count: data.rows.length,
      metrics: [
        MobileReportSummaryMetric(
          label: config.summaryLabels[0],
          value: '${data.rows.length}',
        ),
        MobileReportSummaryMetric(
          label: config.summaryLabels[1],
          value: formatReportCurrency(totalMoneyIn),
        ),
        MobileReportSummaryMetric(
          label: config.summaryLabels[2],
          value: formatReportCurrency(totalMoneyOut),
        ),
      ],
      rows: [
        for (final row in data.rows)
          _row(
            config,
            title: row.partyName.isEmpty ? row.category : row.partyName,
            reference: '${config.referencePrefix} ${row.refNo}',
            dateTime: row.date,
            values: [
              formatReportCurrency(row.total),
              formatReportCurrency(row.moneyIn),
              formatReportCurrency(row.moneyOut),
            ],
          ),
      ],
    );
  }

  static MobileReportViewData _fromTransactions(
    List<ReportTransactionRow> rows,
    int total,
    MobileReportSubsectionConfig config, {
    List<MobileReportSummaryMetric>? metrics,
  }) {
    final totalAmount = rows.fold<double>(0, (sum, row) => sum + row.total);
    final totalBalance = rows.fold<double>(0, (sum, row) => sum + row.balance);
    return _build(
      config: config,
      count: total,
      metrics:
          metrics ??
          [
            MobileReportSummaryMetric(
              label: config.summaryLabels[0],
              value: '$total',
            ),
            MobileReportSummaryMetric(
              label: config.summaryLabels[1],
              value: formatReportCurrency(totalAmount),
            ),
            MobileReportSummaryMetric(
              label: config.summaryLabels[2],
              value: formatReportCurrency(totalBalance),
            ),
          ],
      rows: [
        for (final row in rows)
          _row(
            config,
            title: row.partyName,
            reference: '${config.referencePrefix} ${row.refNo}',
            dateTime: row.date,
            values: [
              formatReportCurrency(row.total),
              formatReportCurrency(row.balance),
              formatMobileReportDueDate(row.dueDate ?? row.date),
            ],
          ),
      ],
    );
  }

  static MobileReportViewData _fromProfitLoss(
    ProfitLossReportData data,
    MobileReportSubsectionConfig config,
  ) {
    return _build(
      config: config,
      count: data.items.length,
      metrics: [
        MobileReportSummaryMetric(
          label: config.summaryLabels[0],
          value: '${data.items.length}',
        ),
        MobileReportSummaryMetric(
          label: config.summaryLabels[1],
          value: formatReportCurrency(data.netProfit),
          valueColor: data.netProfit >= 0
              ? const Color(0xFF2E7D32)
              : const Color(0xFFE53935),
        ),
        MobileReportSummaryMetric(
          label: config.summaryLabels[2],
          value: formatReportCurrency(
            data.items.fold<double>(0, (sum, item) => sum + item.amount),
          ),
        ),
      ],
      rows: [
        for (final item in data.items)
          _row(
            config,
            title: item.particular,
            reference: item.isHeader ? 'HEADER' : config.referencePrefix,
            values: [
              formatReportCurrency(item.amount),
              if (item.isHeader) 'Header' else 'Line',
              '${item.indent}',
            ],
          ),
      ],
    );
  }

  static MobileReportViewData _fromBillWiseProfit(
    BillWiseProfitReportData data,
    MobileReportSubsectionConfig config,
  ) {
    final totalProfit = data.rows.fold<double>(
      0,
      (sum, row) => sum + row.profit,
    );
    return _build(
      config: config,
      count: data.meta.total,
      metrics: [
        MobileReportSummaryMetric(
          label: config.summaryLabels[0],
          value: '${data.meta.total}',
        ),
        MobileReportSummaryMetric(
          label: config.summaryLabels[1],
          value: formatReportCurrency(totalProfit),
        ),
        MobileReportSummaryMetric(
          label: config.summaryLabels[2],
          value: formatReportCurrency(
            data.rows.fold<double>(0, (sum, row) => sum + row.saleAmount),
          ),
        ),
      ],
      rows: [
        for (final row in data.rows)
          _row(
            config,
            title: row.partyName,
            reference: '${config.referencePrefix} ${row.invoiceNo}',
            dateTime: row.date,
            values: [
              formatReportCurrency(row.saleAmount),
              formatReportCurrency(row.profit),
              formatMobileReportDueDate(row.date),
            ],
          ),
      ],
    );
  }

  static MobileReportViewData _fromCashFlow(
    CashFlowReportData data,
    MobileReportSubsectionConfig config,
  ) {
    var running = data.openingBalance;
    final rows = <MobileReportRow>[];
    var rowMoneyIn = 0.0;
    var rowMoneyOut = 0.0;
    for (final row in data.rows) {
      rowMoneyIn += row.moneyIn;
      rowMoneyOut += row.moneyOut;
      running += row.moneyIn - row.moneyOut;
      rows.add(
        _row(
          config,
          title: row.partyName.isEmpty ? row.category : row.partyName,
          reference: '${config.referencePrefix} ${row.refNo}',
          dateTime: row.date,
          values: [
            formatReportCurrency(row.moneyIn),
            formatReportCurrency(row.moneyOut),
            formatReportCurrency(running),
          ],
        ),
      );
    }

    // Prefer API totals; fall back to row sums when API returns zeros.
    final totalMoneyIn = data.totalMoneyIn != 0 || rowMoneyIn == 0
        ? data.totalMoneyIn
        : rowMoneyIn;
    final closingBalance =
        data.closingBalance != 0 ||
            (rowMoneyIn == 0 && rowMoneyOut == 0 && data.openingBalance == 0)
        ? data.closingBalance
        : data.openingBalance + rowMoneyIn - rowMoneyOut;

    return _build(
      config: config,
      count: data.rows.length,
      metrics: [
        MobileReportSummaryMetric(
          label: config.summaryLabels[0],
          value: '${data.rows.length}',
        ),
        MobileReportSummaryMetric(
          label: config.summaryLabels[1],
          value: formatReportCurrency(totalMoneyIn),
        ),
        MobileReportSummaryMetric(
          label: config.summaryLabels[2],
          value: formatReportCurrency(closingBalance),
        ),
      ],
      rows: rows,
    );
  }

  static MobileReportViewData _fromTrialBalance(
    TrialBalanceReportData data,
    MobileReportSubsectionConfig config,
  ) {
    return _build(
      config: config,
      count: data.rows.length,
      metrics: [
        MobileReportSummaryMetric(
          label: config.summaryLabels[0],
          value: '${data.rows.length}',
        ),
        MobileReportSummaryMetric(
          label: config.summaryLabels[1],
          value: formatReportCurrency(data.totalDebit),
        ),
        MobileReportSummaryMetric(
          label: config.summaryLabels[2],
          value: formatReportCurrency(data.totalCredit),
        ),
      ],
      rows: [
        for (final row in data.rows)
          _row(
            config,
            title: row.accountName,
            reference: config.referencePrefix,
            values: [
              formatReportCurrency(row.debit),
              formatReportCurrency(row.credit),
              formatReportCurrency(row.closingDebit + row.closingCredit),
            ],
          ),
      ],
    );
  }

  static MobileReportViewData _fromBalanceSheet(
    BalanceSheetReportData data,
    MobileReportSubsectionConfig config,
  ) {
    final assets = data.assets.fold<double>(
      0,
      (sum, item) => sum + item.amount,
    );
    final liabilities = data.liabilities.fold<double>(
      0,
      (sum, item) => sum + item.amount,
    );
    return _build(
      config: config,
      count: data.assets.length + data.liabilities.length,
      metrics: [
        MobileReportSummaryMetric(
          label: config.summaryLabels[0],
          value: '${data.assets.length + data.liabilities.length}',
        ),
        MobileReportSummaryMetric(
          label: config.summaryLabels[1],
          value: formatReportCurrency(assets),
        ),
        MobileReportSummaryMetric(
          label: config.summaryLabels[2],
          value: formatReportCurrency(liabilities),
        ),
      ],
      rows: [
        for (final item in [...data.assets, ...data.liabilities])
          _row(
            config,
            title: item.name,
            reference: item.isHeader ? 'HEADER' : config.referencePrefix,
            values: [
              formatReportCurrency(item.amount),
              if (item.isHeader) 'Header' else 'Line',
              '${item.indent}',
            ],
          ),
      ],
    );
  }

  static MobileReportViewData _fromPartyStatement(
    PartyStatementReportData data,
    MobileReportSubsectionConfig config,
  ) {
    return _build(
      config: config,
      count: data.entries.length,
      metrics: [
        MobileReportSummaryMetric(
          label: config.summaryLabels[0],
          value: '${data.entries.length}',
        ),
        MobileReportSummaryMetric(
          label: config.summaryLabels[1],
          value: formatReportCurrency(data.summary.totalSale),
        ),
        MobileReportSummaryMetric(
          label: config.summaryLabels[2],
          value: formatReportCurrency(data.summary.totalReceivable),
        ),
      ],
      rows: [
        for (final entry in data.entries)
          _row(
            config,
            title: entry.type,
            reference: '${config.referencePrefix} ${entry.refNo}',
            dateTime: entry.date,
            values: [
              formatReportCurrency(entry.total),
              formatReportCurrency(entry.balance),
              formatMobileReportDueDate(entry.date),
            ],
          ),
      ],
    );
  }

  static MobileReportViewData _fromPartyWiseProfitLoss(
    PartyWiseProfitLossReportData data,
    MobileReportSubsectionConfig config,
  ) {
    final totalProfit = data.rows.fold<double>(
      0,
      (sum, row) => sum + row.profit,
    );
    return _build(
      config: config,
      count: data.meta.total,
      metrics: [
        MobileReportSummaryMetric(
          label: config.summaryLabels[0],
          value: '${data.meta.total}',
        ),
        MobileReportSummaryMetric(
          label: config.summaryLabels[1],
          value: formatReportCurrency(totalProfit),
        ),
        MobileReportSummaryMetric(
          label: config.summaryLabels[2],
          value: formatReportCurrency(
            data.rows.fold<double>(0, (sum, row) => sum + row.saleAmount),
          ),
        ),
      ],
      rows: [
        for (final row in data.rows)
          _row(
            config,
            title: row.partyName,
            reference: config.referencePrefix,
            values: [
              formatReportCurrency(row.saleAmount),
              formatReportCurrency(row.purchaseAmount),
              formatReportCurrency(row.profit),
            ],
          ),
      ],
    );
  }

  static MobileReportViewData _fromAllParties(
    PartyOutstandingReportData data,
    MobileReportSubsectionConfig config,
  ) {
    return _build(
      config: config,
      count: data.meta.total,
      metrics: [
        MobileReportSummaryMetric(
          label: config.summaryLabels[0],
          value: '${data.meta.total}',
        ),
        MobileReportSummaryMetric(
          label: config.summaryLabels[1],
          value: formatReportCurrency(data.totalReceivable),
        ),
        MobileReportSummaryMetric(
          label: config.summaryLabels[2],
          value: formatReportCurrency(data.totalPayable),
        ),
      ],
      rows: [
        for (final party in data.rows) _fromParty(party, config),
      ],
    );
  }

  static MobileReportRow _fromParty(
    PartyModel party,
    MobileReportSubsectionConfig config,
  ) {
    final receivable = party.balance > 0 ? party.balance : 0.0;
    final payable = party.balance < 0 ? party.balance.abs() : 0.0;
    final creditLimit =
        double.tryParse(party.creditLimit.replaceAll(',', '')) ?? 0;
    return _row(
      config,
      title: party.name,
      reference: config.referencePrefix,
      values: [
        formatReportCurrency(receivable),
        formatReportCurrency(payable),
        formatReportCurrency(creditLimit),
      ],
    );
  }

  static MobileReportViewData _fromPartyByItem(
    PartyReportByItemReportData data,
    MobileReportSubsectionConfig config,
  ) {
    return _build(
      config: config,
      count: data.meta.total,
      metrics: _countTotalMetrics(
        data.meta.total,
        data.rows,
        (row) => row.saleAmount + row.purchaseAmount,
        config: config,
      ),
      rows: [
        for (final row in data.rows)
          _row(
            config,
            title: row.partyName,
            reference: config.referencePrefix,
            values: [
              '${row.saleQuantity}',
              formatReportCurrency(row.saleAmount),
              formatReportCurrency(row.purchaseAmount),
            ],
          ),
      ],
    );
  }

  static MobileReportViewData _fromSalePurchaseByParty(
    SalePurchaseByPartyReportData data,
    MobileReportSubsectionConfig config,
  ) {
    return _build(
      config: config,
      count: data.meta.total,
      metrics: _countTotalMetrics(
        data.meta.total,
        data.rows,
        (row) => row.saleAmount + row.purchaseAmount,
        config: config,
      ),
      rows: [
        for (final row in data.rows)
          _row(
            config,
            title: row.partyName,
            reference: config.referencePrefix,
            values: [
              formatReportCurrency(row.saleAmount),
              formatReportCurrency(row.purchaseAmount),
              formatReportCurrency(row.saleAmount - row.purchaseAmount),
            ],
          ),
      ],
    );
  }

  static MobileReportViewData _fromSalePurchaseByPartyGroup(
    SalePurchaseByPartyGroupReportData data,
    MobileReportSubsectionConfig config,
  ) {
    return _build(
      config: config,
      count: data.meta.total,
      metrics: _countTotalMetrics(
        data.meta.total,
        data.rows,
        (row) => row.saleAmount + row.purchaseAmount,
        config: config,
      ),
      rows: [
        for (final row in data.rows)
          _row(
            config,
            title: row.partyName,
            reference: row.partyGroup,
            values: [
              formatReportCurrency(row.saleAmount),
              formatReportCurrency(row.purchaseAmount),
              formatReportCurrency(row.saleAmount - row.purchaseAmount),
            ],
          ),
      ],
    );
  }

  static TaxReportKind? _taxKindForSubsection(String id) => switch (id) {
    'gstReport' => TaxReportKind.gstRegister,
    'gstRateReport' => TaxReportKind.gstRateSummary,
    'formNo27Eq' => TaxReportKind.form27eq,
    'tcsReceivable' => TaxReportKind.tcsReceivable,
    'tdsPayable' => TaxReportKind.tdsPayable,
    'tdsReceivable' => TaxReportKind.tdsReceivable,
    _ => null,
  };

  static GstReportType? _gstTypeForSubsection(String id) => switch (id) {
    'gstr1' => GstReportType.gstr1,
    'gstr2' => GstReportType.gstr2,
    'gstr3b' => GstReportType.gstr3b,
    'gstr9' => GstReportType.gstr9,
    'saleSummaryByHsn' => GstReportType.hsnSummary,
    'sacReport' => GstReportType.sacReport,
    _ => null,
  };

  static double _gstRowAmount(Map<String, dynamic> row, String key) =>
      double.tryParse(row[key]?.toString() ?? '') ?? 0;

  static MobileReportViewData _fromGstr(
    List<ReportGstrRow> rows,
    MobileReportSubsectionConfig config,
  ) {
    return _build(
      config: config,
      count: rows.length,
      metrics: _countTotalMetrics(
        rows.length,
        rows,
        (row) => row.value,
        config: config,
      ),
      rows: [
        for (final row in rows)
          _row(
            config,
            title: row.partyName,
            reference: '${config.referencePrefix} ${row.invoiceNo}',
            dateTime: row.date,
            values: [
              formatReportCurrency(row.taxableValue),
              formatReportCurrency(row.integratedTax),
              formatReportCurrency(row.value),
            ],
          ),
      ],
    );
  }

  static MobileReportViewData _fromGstr3b(
    Gstr3bReportData data,
    MobileReportSubsectionConfig config,
  ) {
    return _build(
      config: config,
      count: data.rows.length,
      metrics: _countTotalMetrics(
        data.rows.length,
        data.rows,
        (row) => row.taxableValue,
        config: config,
      ),
      rows: [
        for (final row in data.rows)
          _row(
            config,
            title: row.nature,
            reference: config.referencePrefix,
            values: [
              formatReportCurrency(row.taxableValue),
              formatReportCurrency(row.integratedTax),
              formatReportCurrency(row.cess),
            ],
          ),
      ],
    );
  }

  static MobileReportViewData _fromGstr9(
    Gstr9ReportData data,
    MobileReportSubsectionConfig config,
  ) {
    return _build(
      config: config,
      count: data.rows.length,
      metrics: _countTotalMetrics(
        data.rows.length,
        data.rows,
        (row) => row.taxableValue,
        config: config,
      ),
      rows: [
        for (final row in data.rows)
          _row(
            config,
            title: row.label,
            reference: config.referencePrefix,
            values: [
              formatReportCurrency(row.taxableValue),
              formatReportCurrency(row.integratedTax),
              formatReportCurrency(row.centralTax + row.stateTax),
            ],
          ),
      ],
    );
  }

  static MobileReportViewData _fromHsn(
    SaleSummaryByHsnReportData data,
    MobileReportSubsectionConfig config,
  ) {
    return _build(
      config: config,
      count: data.rows.length,
      metrics: _countTotalMetrics(
        data.rows.length,
        data.rows,
        (row) => row.totalValue,
        config: config,
      ),
      rows: [
        for (final row in data.rows)
          _row(
            config,
            title: row.description.isEmpty ? row.hsn : row.description,
            reference: row.hsn,
            values: [
              formatReportCurrency(row.taxableValue),
              formatReportCurrency(row.igst),
              formatReportCurrency(row.totalValue),
            ],
          ),
      ],
    );
  }

  static MobileReportViewData _fromSac(
    SacReportData data,
    MobileReportSubsectionConfig config,
  ) {
    return _build(
      config: config,
      count: data.rows.length,
      metrics: _countTotalMetrics(
        data.rows.length,
        data.rows,
        (row) => row.totalValue,
        config: config,
      ),
      rows: [
        for (final row in data.rows)
          _row(
            config,
            title: row.sac,
            reference: row.invoiceType,
            values: [
              formatReportCurrency(row.taxableValue),
              formatReportCurrency(row.igst),
              formatReportCurrency(row.totalValue),
            ],
          ),
      ],
    );
  }

  static MobileReportViewData _fromItemReportByParty(
    ItemReportByPartyReportData data,
    MobileReportSubsectionConfig config,
  ) {
    return _build(
      config: config,
      count: data.meta.total,
      metrics: _countTotalMetrics(
        data.meta.total,
        data.rows,
        (row) => row.amount,
        config: config,
      ),
      rows: [
        for (final row in data.rows)
          _row(
            config,
            title: row.itemName,
            reference: row.partyName,
            values: [
              '${row.quantity}',
              formatReportCurrency(row.amount),
              '-',
            ],
          ),
      ],
    );
  }

  static MobileReportViewData _fromItemWiseProfitLoss(
    ItemWiseProfitLossReportData data,
    MobileReportSubsectionConfig config,
  ) {
    return _build(
      config: config,
      count: data.meta.total,
      metrics: _countTotalMetrics(
        data.meta.total,
        data.rows,
        (row) => row.profit,
        config: config,
      ),
      rows: [
        for (final row in data.rows)
          _row(
            config,
            title: row.itemName,
            reference: config.referencePrefix,
            values: [
              formatReportCurrency(row.saleAmount),
              formatReportCurrency(row.purchaseAmount),
              formatReportCurrency(row.profit),
            ],
          ),
      ],
    );
  }

  static MobileReportViewData _fromLowStock(
    LowStockReportData data,
    MobileReportSubsectionConfig config,
  ) {
    return _build(
      config: config,
      count: data.meta.total,
      metrics: [
        MobileReportSummaryMetric(
          label: config.summaryLabels[0],
          value: '${data.meta.total}',
        ),
        MobileReportSummaryMetric(
          label: config.summaryLabels[1],
          value: '${data.lowStockCount}',
          valueColor: const Color(0xFFE53935),
        ),
        MobileReportSummaryMetric(
          label: config.summaryLabels[2],
          value: formatReportCurrency(
            data.rows.fold<double>(0, (sum, row) => sum + row.shortage),
          ),
        ),
      ],
      rows: [
        for (final row in data.rows)
          _row(
            config,
            title: row.itemName,
            reference: config.referencePrefix,
            values: [
              '${row.currentStock}',
              '${row.minStock}',
              '${row.shortage}',
            ],
          ),
      ],
    );
  }

  static MobileReportViewData _fromStockDetail(
    StockDetailReportData data,
    MobileReportSubsectionConfig config,
  ) {
    return _build(
      config: config,
      count: data.meta.total,
      metrics: _countTotalMetrics(
        data.meta.total,
        data.rows,
        (row) => row.closingQty,
        config: config,
      ),
      rows: [
        for (final row in data.rows)
          _row(
            config,
            title: row.itemName,
            reference: config.referencePrefix,
            values: [
              '${row.openingQty}',
              '${row.inQty}',
              '${row.closingQty}',
            ],
          ),
      ],
    );
  }

  static MobileReportViewData _fromCategoryAmount(
    CategoryAmountReportData data,
    MobileReportSubsectionConfig config,
  ) {
    return _build(
      config: config,
      count: data.rows.length,
      metrics: _countTotalMetrics(
        data.rows.length,
        data.rows,
        (row) => row.saleAmount + row.purchaseAmount,
        config: config,
      ),
      rows: [
        for (final row in data.rows)
          _row(
            config,
            title: row.category,
            reference: config.referencePrefix,
            values: [
              formatReportCurrency(row.saleAmount),
              formatReportCurrency(row.purchaseAmount),
              formatReportCurrency(row.saleAmount - row.purchaseAmount),
            ],
          ),
      ],
    );
  }

  static MobileReportViewData _fromItemWiseDiscount(
    ItemWiseDiscountReportData data,
    MobileReportSubsectionConfig config,
  ) {
    return _build(
      config: config,
      count: data.meta.total,
      metrics: _countTotalMetrics(
        data.meta.total,
        data.rows,
        (row) => row.discountAmount,
        config: config,
      ),
      rows: [
        for (final row in data.rows)
          _row(
            config,
            title: row.itemName,
            reference: config.referencePrefix,
            values: [
              '${row.saleQty}',
              formatReportCurrency(row.discountAmount),
              '${row.discountPercent.toStringAsFixed(1)}%',
            ],
          ),
      ],
    );
  }

  static MobileReportViewData _fromManufacturing(
    ManufacturingReportData data,
    MobileReportSubsectionConfig config,
  ) {
    return _build(
      config: config,
      count: data.meta.total,
      metrics: _countTotalMetrics(
        data.meta.total,
        data.rows,
        (row) => row.cost,
        config: config,
      ),
      rows: [
        for (final row in data.rows)
          _row(
            config,
            title: row.itemName,
            reference: '${config.referencePrefix} ${row.refNo}',
            dateTime: row.date,
            values: [
              '${row.quantity}',
              formatReportCurrency(row.cost),
              formatMobileReportDueDate(row.date),
            ],
          ),
      ],
    );
  }

  static MobileReportViewData _fromConsumption(
    ConsumptionReportData data,
    MobileReportSubsectionConfig config,
  ) {
    return _build(
      config: config,
      count: data.meta.total,
      metrics: _countTotalMetrics(
        data.meta.total,
        data.rows,
        (row) => row.value,
        config: config,
      ),
      rows: [
        for (final row in data.rows)
          _row(
            config,
            title: row.itemName,
            reference: '${config.referencePrefix} ${row.refNo}',
            dateTime: row.date,
            values: [
              '${row.quantity}',
              formatReportCurrency(row.value),
              formatMobileReportDueDate(row.date),
            ],
          ),
      ],
    );
  }

  static MobileReportViewData _fromStockTransfer(
    StockTransferReportData data,
    MobileReportSubsectionConfig config,
  ) {
    return _build(
      config: config,
      count: data.meta.total,
      metrics: _countTotalMetrics(
        data.meta.total,
        data.rows,
        (row) => row.quantity,
        config: config,
      ),
      rows: [
        for (final row in data.rows)
          _row(
            config,
            title: row.itemName,
            reference: '${config.referencePrefix} ${row.refNo}',
            dateTime: row.date,
            values: [
              row.fromGodown,
              row.toGodown,
              '${row.quantity}',
            ],
          ),
      ],
    );
  }

  static MobileReportViewData _fromBankStatement(
    BankStatementReportData data,
    MobileReportSubsectionConfig config,
  ) {
    return _build(
      config: config,
      count: data.rows.length,
      metrics: [
        MobileReportSummaryMetric(
          label: config.summaryLabels[0],
          value: data.openingBalance != null
              ? formatReportCurrency(double.tryParse(data.openingBalance!) ?? 0)
              : '${data.rows.length}',
        ),
        MobileReportSummaryMetric(
          label: config.summaryLabels[1],
          value: formatReportCurrency(
            data.rows.fold<double>(0, (sum, row) => sum + row.moneyIn),
          ),
        ),
        MobileReportSummaryMetric(
          label: config.summaryLabels[2],
          value: formatReportCurrency(
            data.rows.fold<double>(0, (sum, row) => sum + row.moneyOut),
          ),
        ),
        if (data.closingBalance != null)
          MobileReportSummaryMetric(
            label: 'Closing',
            value: formatReportCurrency(
              double.tryParse(data.closingBalance!) ?? 0,
            ),
          ),
      ],
      rows: [
        for (final row in data.rows)
          _row(
            config,
            title: row.description,
            reference: '${config.referencePrefix} ${row.refNo}',
            dateTime: row.date,
            values: [
              formatReportCurrency(row.moneyIn),
              formatReportCurrency(row.moneyOut),
              formatReportCurrency(row.balance),
            ],
          ),
      ],
    );
  }

  static MobileReportViewData _fromExpenses(
    ExpensesReportData data,
    MobileReportSubsectionConfig config,
  ) {
    return _build(
      config: config,
      count: data.meta.total,
      metrics: [
        MobileReportSummaryMetric(
          label: config.summaryLabels[0],
          value: '${data.meta.total}',
        ),
        MobileReportSummaryMetric(
          label: config.summaryLabels[1],
          value: formatReportCurrency(data.totalAmount),
        ),
        MobileReportSummaryMetric(
          label: config.summaryLabels[2],
          value: formatReportCurrency(data.totalAmount),
        ),
      ],
      rows: [
        for (final row in data.rows)
          _row(
            config,
            title: row.partyName.isEmpty ? row.category : row.partyName,
            reference: '${config.referencePrefix} ${row.expenseNo}',
            dateTime: row.date,
            values: [
              formatReportCurrency(row.amount),
              expenseReportStatusLabel(row.status),
              formatMobileReportDueDate(row.dueDate),
            ],
          ),
      ],
    );
  }

  static MobileReportViewData _fromExpenseCategories(
    ExpenseByCategoryReportData data,
    MobileReportSubsectionConfig config,
  ) {
    return _build(
      config: config,
      count: data.rows.length,
      metrics: _countTotalMetrics(
        data.rows.length,
        data.rows,
        (row) => row.amount,
        config: config,
      ),
      rows: [
        for (final row in data.rows)
          _row(
            config,
            title: row.category,
            reference: config.referencePrefix,
            values: [
              formatReportCurrency(row.amount),
              '${row.count}',
              '-',
            ],
          ),
      ],
    );
  }

  static MobileReportViewData _fromExpenseItems(
    ExpenseByItemReportData data,
    MobileReportSubsectionConfig config,
  ) {
    return _build(
      config: config,
      count: data.rows.length,
      metrics: _countTotalMetrics(
        data.rows.length,
        data.rows,
        (row) => row.amount,
        config: config,
      ),
      rows: [
        for (final row in data.rows)
          _row(
            config,
            title: row.itemName,
            reference: row.category,
            values: [
              formatReportCurrency(row.amount),
              '${row.count}',
              '-',
            ],
          ),
      ],
    );
  }

  static MobileReportViewData _fromSalePurchaseOrders(
    SalePurchaseOrdersReportData data,
    MobileReportSubsectionConfig config,
  ) {
    return _build(
      config: config,
      count: data.meta.total,
      metrics: [
        MobileReportSummaryMetric(
          label: config.summaryLabels[0],
          value: '${data.meta.total}',
        ),
        MobileReportSummaryMetric(
          label: config.summaryLabels[1],
          value: formatReportCurrency(data.totalAmount),
        ),
        MobileReportSummaryMetric(
          label: config.summaryLabels[2],
          value: formatReportCurrency(data.totalAmount),
        ),
      ],
      rows: [
        for (final row in data.rows)
          _row(
            config,
            title: row.partyName,
            reference: '${config.referencePrefix} ${row.orderNo}',
            dateTime: row.date,
            values: [
              formatReportCurrency(row.amount),
              row.status,
              formatMobileReportDueDate(row.dueDate),
            ],
          ),
      ],
    );
  }

  static MobileReportViewData _fromSalePurchaseOrderItems(
    SalePurchaseOrderItemsReportData data,
    MobileReportSubsectionConfig config,
  ) {
    return _build(
      config: config,
      count: data.meta.total,
      metrics: _countTotalMetrics(
        data.meta.total,
        data.rows,
        (row) => row.amount,
        config: config,
      ),
      rows: [
        for (final row in data.rows)
          _row(
            config,
            title: row.itemName,
            reference: '${config.referencePrefix} ${row.orderNo}',
            values: [
              '${row.quantity}',
              formatReportCurrency(row.amount),
              row.partyName,
            ],
          ),
      ],
    );
  }

  static List<MobileReportSummaryMetric> _countTotalMetrics<T>(
    int count,
    List<T> rows,
    double Function(T row) amountSelector, {
    MobileReportSubsectionConfig? config,
  }) {
    final total = rows.fold<double>(0, (sum, row) => sum + amountSelector(row));
    final labels =
        config?.summaryLabels ?? const ['No of Txns', 'Total', 'Balance Due'];
    return [
      MobileReportSummaryMetric(label: labels[0], value: '$count'),
      MobileReportSummaryMetric(
        label: labels[1],
        value: formatReportCurrency(total),
      ),
      MobileReportSummaryMetric(
        label: labels[2],
        value: formatReportCurrency(total),
      ),
    ];
  }
}
