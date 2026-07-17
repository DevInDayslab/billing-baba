import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/core/theme/list_panel_theme.dart';
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
import 'package:billing_baba/features/reports/presentation/widgets/report_content_panel.dart';
import 'package:billing_baba/features/reports/presentation/widgets/reports_nav_panel.dart';
import 'package:billing_baba/features/reports/providers/reports_nav_intent_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReportsPage extends ConsumerStatefulWidget {
  const ReportsPage({super.key});

  @override
  ConsumerState<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends ConsumerState<ReportsPage> {
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
    WidgetsBinding.instance.addPostFrameCallback((_) => _applyPendingIntent());
  }

  void _applyPendingIntent() {
    final intent = ref.read(reportsNavIntentProvider.notifier).consume();
    if (intent == null || !mounted) return;

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
    });
  }

  @override
  Widget build(BuildContext context) {
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
                          onTransactionSubSelected: (sub) {
                            setState(() {
                              _navGroup = ReportNavGroup.transaction;
                              _selectedTransactionSub = sub;
                            });
                          },
                          onPartySubSelected: (sub) {
                            setState(() {
                              _navGroup = ReportNavGroup.party;
                              _selectedPartySub = sub;
                            });
                          },
                          onGstSubSelected: (sub) {
                            setState(() {
                              _navGroup = ReportNavGroup.gst;
                              _selectedGstSub = sub;
                            });
                          },
                          onItemStockSubSelected: (sub) {
                            setState(() {
                              _navGroup = ReportNavGroup.itemStock;
                              _selectedItemStockSub = sub;
                            });
                          },
                          onBusinessStatusSubSelected: (sub) {
                            setState(() {
                              _navGroup = ReportNavGroup.businessStatus;
                              _selectedBusinessStatusSub = sub;
                            });
                          },
                          onTaxesSubSelected: (sub) {
                            setState(() {
                              _navGroup = ReportNavGroup.taxes;
                              _selectedTaxesSub = sub;
                            });
                          },
                          onExpenseSubSelected: (sub) {
                            setState(() {
                              _navGroup = ReportNavGroup.expenseReport;
                              _selectedExpenseSub = sub;
                            });
                          },
                          onSalePurchaseOrderSubSelected: (sub) {
                            setState(() {
                              _navGroup =
                                  ReportNavGroup.salePurchaseOrderReport;
                              _selectedSalePurchaseOrderSub = sub;
                            });
                          },
                          onOtherIncomeSubSelected: (sub) {
                            setState(() {
                              _navGroup = ReportNavGroup.otherIncomeReport;
                              _selectedOtherIncomeSub = sub;
                            });
                          },
                          onLoanAccountsSubSelected: (sub) {
                            setState(() {
                              _navGroup = ReportNavGroup.loanAccounts;
                              _selectedLoanAccountsSub = sub;
                            });
                          },
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
