import 'dart:async';

import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/core/theme/list_panel_theme.dart';
import 'package:billing_baba/features/reports/application/expense_column_filters_provider.dart';
import 'package:billing_baba/features/reports/application/phase1_report_providers.dart';
import 'package:billing_baba/features/reports/application/report_filters_provider.dart';
import 'package:billing_baba/features/reports/application/reports_nav_intent_provider.dart';
import 'package:billing_baba/features/reports/application/reports_service.dart';
import 'package:billing_baba/features/reports/models/reports_nav_intent.dart';
import 'package:billing_baba/shared/widgets/table_filters/filter_models.dart';
import 'package:billing_baba/features/reports/application/bill_wise_profit_column_filters_provider.dart';
import 'package:billing_baba/features/reports/application/cash_flow_column_filters_provider.dart';
import 'package:billing_baba/features/reports/application/sale_purchase_orders_column_filters_provider.dart';
import 'package:billing_baba/features/reports/application/sale_report_column_filters_provider.dart';
import 'package:billing_baba/features/reports/models/business_status_report_subsection.dart';
import 'package:billing_baba/features/reports/models/expense_report_subsection.dart';
import 'package:billing_baba/features/reports/models/gst_report_subsection.dart';
import 'package:billing_baba/features/reports/models/item_stock_report_subsection.dart';
import 'package:billing_baba/features/reports/models/loan_accounts_report_subsection.dart';
import 'package:billing_baba/features/reports/models/other_income_report_subsection.dart';
import 'package:billing_baba/features/reports/models/party_report_subsection.dart';
import 'package:billing_baba/features/reports/models/report_nav_group.dart';
import 'package:billing_baba/features/reports/models/sale_purchase_order_report_subsection.dart';
import 'package:billing_baba/features/reports/models/taxes_report_subsection.dart';
import 'package:billing_baba/features/reports/models/transaction_report_subsection.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/report_content_panel.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/reports_nav_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DesktopReportsPage extends ConsumerStatefulWidget {
  const DesktopReportsPage({super.key});

  @override
  ConsumerState<DesktopReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends ConsumerState<DesktopReportsPage> {
  ReportNavGroup _navGroup = ReportNavGroup.transaction;
  TransactionReportSubSection _selectedTransactionSub =
      TransactionReportSubSection.sale;
  PartyReportSubSection _selectedPartySub =
      PartyReportSubSection.partyStatement;
  GstReportSubSection _selectedGstSub = GstReportSubSection.gstr1;
  ItemStockReportSubSection _selectedItemStockSub =
      ItemStockReportSubSection.stockSummary;
  BusinessStatusReportSubSection _selectedBusinessStatusSub =
      BusinessStatusReportSubSection.bankStatement;
  TaxesReportSubSection _selectedTaxesSub = TaxesReportSubSection.gstReport;
  ExpenseReportSubSection _selectedExpenseSub = ExpenseReportSubSection.expense;
  SalePurchaseOrderReportSubSection _selectedSalePurchaseOrderSub =
      SalePurchaseOrderReportSubSection.salePurchaseOrders;
  OtherIncomeReportSubSection _selectedOtherIncomeSub =
      OtherIncomeReportSubSection.otherIncome;
  LoanAccountsReportSubSection _selectedLoanAccountsSub =
      LoanAccountsReportSubSection.loanStatement;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _applyPendingIntent();
      _prefetchReportsShell();
    });
  }

  void _prefetchReportsShell() {
    unawaited(ref.read(reportsServiceProvider.future));
    unawaited(
      ref.read(saleReportProvider.future).then<void>((_) {}, onError: (_) {}),
    );
    unawaited(
      ref
          .read(purchaseReportProvider.future)
          .then<void>((_) {}, onError: (_) {}),
    );
    unawaited(
      ref
          .read(stockSummaryReportProvider.future)
          .then<void>((_) {}, onError: (_) {}),
    );
  }

  void _applyPendingIntent() {
    final intent = ref.read(reportsNavIntentProvider.notifier).consume();
    if (intent == null || !mounted) return;

    ref.read(reportFiltersProvider.notifier).resetForReportSwitch();
    final categoryId = intent.expenseCategoryId;
    final categoryName = intent.expenseCategoryName;
    if (categoryId != null && categoryId.isNotEmpty) {
      ref.read(reportFiltersProvider.notifier).setCategoryId(categoryId);
    }
    if (categoryName != null && categoryName.isNotEmpty) {
      ref
          .read(expenseColumnFiltersProvider.notifier)
          .setCategoryColumnFilter(SelectColumnFilter(value: categoryName));
    }
    if (intent.bankAccountId != null && intent.bankAccountId!.isNotEmpty) {
      ref
          .read(reportFiltersProvider.notifier)
          .setBankAccountId(intent.bankAccountId);
    }
    setState(() {
      _navGroup = intent.group;
      if (intent.transactionSub != null) {
        _selectedTransactionSub = intent.transactionSub!;
      }
      if (intent.partySub != null) {
        _selectedPartySub = intent.partySub!;
      }
      if (intent.itemStockSub != null) {
        _selectedItemStockSub = intent.itemStockSub!;
      }
      if (intent.businessStatusSub != null) {
        _selectedBusinessStatusSub = intent.businessStatusSub!;
      }
      if (intent.gstSub != null) {
        _selectedGstSub = intent.gstSub!;
      }
      if (intent.taxesSub != null) {
        _selectedTaxesSub = intent.taxesSub!;
      }
      if (intent.expenseSub != null) {
        _selectedExpenseSub = intent.expenseSub!;
      }
      if (intent.salePurchaseOrderSub != null) {
        _selectedSalePurchaseOrderSub = intent.salePurchaseOrderSub!;
      }
      if (intent.otherIncomeSub != null) {
        _selectedOtherIncomeSub = intent.otherIncomeSub!;
      }
      if (intent.loanAccountsSub != null) {
        _selectedLoanAccountsSub = intent.loanAccountsSub!;
      }
    });
  }

  void _selectReport({
    required ReportNavGroup group,
    TransactionReportSubSection? transactionSub,
    PartyReportSubSection? partySub,
    GstReportSubSection? gstSub,
    ItemStockReportSubSection? itemStockSub,
    BusinessStatusReportSubSection? businessStatusSub,
    TaxesReportSubSection? taxesSub,
    ExpenseReportSubSection? expenseSub,
    SalePurchaseOrderReportSubSection? salePurchaseOrderSub,
    OtherIncomeReportSubSection? otherIncomeSub,
    LoanAccountsReportSubSection? loanAccountsSub,
  }) {
    ref.read(reportFiltersProvider.notifier).resetForReportSwitch();
    if (transactionSub != null &&
        transactionSub != TransactionReportSubSection.sale) {
      ref.read(saleReportColumnFiltersProvider.notifier).reset();
    }
    if (transactionSub != null &&
        transactionSub != TransactionReportSubSection.billWiseProfit) {
      ref.read(billWiseProfitColumnFiltersProvider.notifier).reset();
    }
    if (transactionSub != null &&
        transactionSub != TransactionReportSubSection.cashFlow) {
      ref.read(cashFlowColumnFiltersProvider.notifier).reset();
    }
    if (salePurchaseOrderSub == null ||
        salePurchaseOrderSub !=
            SalePurchaseOrderReportSubSection.salePurchaseOrders) {
      ref
          .read(salePurchaseOrdersColumnFiltersProvider.notifier)
          .reset();
    }
    setState(() {
      _navGroup = group;
      if (transactionSub != null) _selectedTransactionSub = transactionSub;
      if (partySub != null) _selectedPartySub = partySub;
      if (gstSub != null) _selectedGstSub = gstSub;
      if (itemStockSub != null) _selectedItemStockSub = itemStockSub;
      if (businessStatusSub != null) {
        _selectedBusinessStatusSub = businessStatusSub;
      }
      if (taxesSub != null) _selectedTaxesSub = taxesSub;
      if (expenseSub != null) _selectedExpenseSub = expenseSub;
      if (salePurchaseOrderSub != null) {
        _selectedSalePurchaseOrderSub = salePurchaseOrderSub;
      }
      if (otherIncomeSub != null) _selectedOtherIncomeSub = otherIncomeSub;
      if (loanAccountsSub != null) _selectedLoanAccountsSub = loanAccountsSub;
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<ReportsNavIntent?>(reportsNavIntentProvider, (previous, next) {
      if (next == null) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _applyPendingIntent();
      });
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final navWidth = (constraints.maxWidth * 0.2).clamp(200.0, 280.0);

              return DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppRadius.lgBorder,
                  border: Border.all(color: listPanelCardBorder),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0A000000),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: AppRadius.lgBorder,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        width: navWidth,
                        child: ReportsNavPanel(
                          navGroup: _navGroup,
                          selectedTransactionSub: _selectedTransactionSub,
                          selectedPartySub: _selectedPartySub,
                          selectedGstSub: _selectedGstSub,
                          selectedItemStockSub: _selectedItemStockSub,
                          selectedBusinessStatusSub: _selectedBusinessStatusSub,
                          selectedTaxesSub: _selectedTaxesSub,
                          selectedExpenseSub: _selectedExpenseSub,
                          selectedSalePurchaseOrderSub:
                              _selectedSalePurchaseOrderSub,
                          selectedOtherIncomeSub: _selectedOtherIncomeSub,
                          selectedLoanAccountsSub: _selectedLoanAccountsSub,
                          onTransactionSubSelected: (sub) => _selectReport(
                            group: ReportNavGroup.transaction,
                            transactionSub: sub,
                          ),
                          onPartySubSelected: (sub) => _selectReport(
                            group: ReportNavGroup.party,
                            partySub: sub,
                          ),
                          onGstSubSelected: (sub) => _selectReport(
                            group: ReportNavGroup.gst,
                            gstSub: sub,
                          ),
                          onItemStockSubSelected: (sub) => _selectReport(
                            group: ReportNavGroup.itemStock,
                            itemStockSub: sub,
                          ),
                          onBusinessStatusSubSelected: (sub) => _selectReport(
                            group: ReportNavGroup.businessStatus,
                            businessStatusSub: sub,
                          ),
                          onTaxesSubSelected: (sub) => _selectReport(
                            group: ReportNavGroup.taxes,
                            taxesSub: sub,
                          ),
                          onExpenseSubSelected: (sub) => _selectReport(
                            group: ReportNavGroup.expenseReport,
                            expenseSub: sub,
                          ),
                          onSalePurchaseOrderSubSelected: (sub) =>
                              _selectReport(
                                group: ReportNavGroup.salePurchaseOrderReport,
                                salePurchaseOrderSub: sub,
                              ),
                          onOtherIncomeSubSelected: (sub) => _selectReport(
                            group: ReportNavGroup.otherIncomeReport,
                            otherIncomeSub: sub,
                          ),
                          onLoanAccountsSubSelected: (sub) => _selectReport(
                            group: ReportNavGroup.loanAccounts,
                            loanAccountsSub: sub,
                          ),
                        ),
                      ),
                      const VerticalDivider(
                        width: 1,
                        color: listPanelCardBorder,
                      ),
                      Expanded(
                        child: ReportContentPanel(
                          navGroup: _navGroup,
                          transactionSub:
                              _navGroup == ReportNavGroup.transaction
                              ? _selectedTransactionSub
                              : null,
                          partySub: _navGroup == ReportNavGroup.party
                              ? _selectedPartySub
                              : null,
                          gstSub: _navGroup == ReportNavGroup.gst
                              ? _selectedGstSub
                              : null,
                          itemStockSub: _navGroup == ReportNavGroup.itemStock
                              ? _selectedItemStockSub
                              : null,
                          businessStatusSub:
                              _navGroup == ReportNavGroup.businessStatus
                              ? _selectedBusinessStatusSub
                              : null,
                          taxesSub: _navGroup == ReportNavGroup.taxes
                              ? _selectedTaxesSub
                              : null,
                          expenseSub: _navGroup == ReportNavGroup.expenseReport
                              ? _selectedExpenseSub
                              : null,
                          salePurchaseOrderSub:
                              _navGroup ==
                                  ReportNavGroup.salePurchaseOrderReport
                              ? _selectedSalePurchaseOrderSub
                              : null,
                          otherIncomeSub:
                              _navGroup == ReportNavGroup.otherIncomeReport
                              ? _selectedOtherIncomeSub
                              : null,
                          loanAccountsSub:
                              _navGroup == ReportNavGroup.loanAccounts
                              ? _selectedLoanAccountsSub
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
