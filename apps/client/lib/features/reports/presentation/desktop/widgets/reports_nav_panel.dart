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
import 'package:billing_baba/features/reports/application/reports_nav_catalog.dart';
import 'package:billing_baba/features/settings/application/gst_tax_settings_provider.dart';
import 'package:billing_baba/features/settings/models/gst_tax_settings_behavior.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _navBackground = Color(0xFFF8F9FB);
const _sectionHeaderColor = Color(0xFF00695C);
const _activeBlue = Color(0xFF1976D2);
const _activeBackground = Color(0xFFE8F1FB);
const _borderColor = Color(0xFFE0E0E0);
const _notificationDot = Color(0xFFE53935);

class ReportsNavPanel extends ConsumerWidget {
  const ReportsNavPanel({
    required this.navGroup,
    required this.selectedTransactionSub,
    required this.selectedPartySub,
    required this.selectedGstSub,
    required this.selectedItemStockSub,
    required this.selectedBusinessStatusSub,
    required this.selectedTaxesSub,
    required this.selectedExpenseSub,
    required this.selectedSalePurchaseOrderSub,
    required this.selectedOtherIncomeSub,
    required this.selectedLoanAccountsSub,
    required this.onTransactionSubSelected,
    required this.onPartySubSelected,
    required this.onGstSubSelected,
    required this.onItemStockSubSelected,
    required this.onBusinessStatusSubSelected,
    required this.onTaxesSubSelected,
    required this.onExpenseSubSelected,
    required this.onSalePurchaseOrderSubSelected,
    required this.onOtherIncomeSubSelected,
    required this.onLoanAccountsSubSelected,
    super.key,
  });

  final ReportNavGroup navGroup;
  final TransactionReportSubSection selectedTransactionSub;
  final PartyReportSubSection selectedPartySub;
  final GstReportSubSection selectedGstSub;
  final ItemStockReportSubSection selectedItemStockSub;
  final BusinessStatusReportSubSection selectedBusinessStatusSub;
  final TaxesReportSubSection selectedTaxesSub;
  final ExpenseReportSubSection selectedExpenseSub;
  final SalePurchaseOrderReportSubSection selectedSalePurchaseOrderSub;
  final OtherIncomeReportSubSection selectedOtherIncomeSub;
  final LoanAccountsReportSubSection selectedLoanAccountsSub;
  final ValueChanged<TransactionReportSubSection> onTransactionSubSelected;
  final ValueChanged<PartyReportSubSection> onPartySubSelected;
  final ValueChanged<GstReportSubSection> onGstSubSelected;
  final ValueChanged<ItemStockReportSubSection> onItemStockSubSelected;
  final ValueChanged<BusinessStatusReportSubSection>
  onBusinessStatusSubSelected;
  final ValueChanged<TaxesReportSubSection> onTaxesSubSelected;
  final ValueChanged<ExpenseReportSubSection> onExpenseSubSelected;
  final ValueChanged<SalePurchaseOrderReportSubSection>
  onSalePurchaseOrderSubSelected;
  final ValueChanged<OtherIncomeReportSubSection> onOtherIncomeSubSelected;
  final ValueChanged<LoanAccountsReportSubSection> onLoanAccountsSubSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gst = ref.watch(effectiveGstTaxSettingsProvider);
    final gstSubs = ReportsNavCatalog.subsectionsFor(
      ReportNavGroup.gst,
      gstSettings: gst,
    );
    final taxesSubs = ReportsNavCatalog.subsectionsFor(
      ReportNavGroup.taxes,
      gstSettings: gst,
    );

    return ColoredBox(
      color: _navBackground,
      child: ListView(
        // Extra space so the last section (Loan Accounts) is fully visible.
        padding: const EdgeInsets.only(bottom: 48),
        children: [
          const _SectionHeader(label: 'Transaction report'),
          for (final sub in TransactionReportSubSection.values)
            _NavItemTile(
              label: sub.label,
              isSelected:
                  navGroup == ReportNavGroup.transaction &&
                  sub == selectedTransactionSub,
              showNotificationDot: sub.showNotificationDot,
              onTap: () => onTransactionSubSelected(sub),
            ),
          const SizedBox(height: 8),
          const _SectionHeader(label: 'Party report'),
          for (final sub in PartyReportSubSection.values)
            _NavItemTile(
              label: sub.label,
              isSelected:
                  navGroup == ReportNavGroup.party && sub == selectedPartySub,
              onTap: () => onPartySubSelected(sub),
            ),
          if (gst.showGstReportNav && gstSubs.isNotEmpty) ...[
            const SizedBox(height: 8),
            const _SectionHeader(label: 'GST reports'),
            for (final entry in gstSubs)
              _NavItemTile(
                label: entry.label,
                isSelected:
                    navGroup == ReportNavGroup.gst &&
                    entry.id == selectedGstSub.name,
                onTap: () => onGstSubSelected(
                  GstReportSubSection.values.byName(entry.id),
                ),
              ),
          ],
          const SizedBox(height: 8),
          const _SectionHeader(label: 'Item/Stock report'),
          for (final sub in ItemStockReportSubSection.values)
            _NavItemTile(
              label: sub.label,
              isSelected:
                  navGroup == ReportNavGroup.itemStock &&
                  sub == selectedItemStockSub,
              onTap: () => onItemStockSubSelected(sub),
            ),
          const SizedBox(height: 8),
          const _SectionHeader(label: 'Business Status'),
          for (final sub in BusinessStatusReportSubSection.values)
            _NavItemTile(
              label: sub.label,
              isSelected:
                  navGroup == ReportNavGroup.businessStatus &&
                  sub == selectedBusinessStatusSub,
              onTap: () => onBusinessStatusSubSelected(sub),
            ),
          if (taxesSubs.isNotEmpty) ...[
            const SizedBox(height: 8),
            const _SectionHeader(label: 'Taxes'),
            for (final entry in taxesSubs)
              _NavItemTile(
                label: entry.label,
                isSelected:
                    navGroup == ReportNavGroup.taxes &&
                    entry.id == selectedTaxesSub.name,
                onTap: () => onTaxesSubSelected(
                  TaxesReportSubSection.values.byName(entry.id),
                ),
              ),
          ],
          const SizedBox(height: 8),
          const _SectionHeader(label: 'Expense report'),
          for (final sub in ExpenseReportSubSection.values)
            _NavItemTile(
              label: sub.label,
              isSelected:
                  navGroup == ReportNavGroup.expenseReport &&
                  sub == selectedExpenseSub,
              onTap: () => onExpenseSubSelected(sub),
            ),
          const SizedBox(height: 8),
          const _SectionHeader(label: 'Sale/Purchase Order Report'),
          for (final sub in SalePurchaseOrderReportSubSection.values)
            _NavItemTile(
              label: sub.label,
              isSelected:
                  navGroup == ReportNavGroup.salePurchaseOrderReport &&
                  sub == selectedSalePurchaseOrderSub,
              onTap: () => onSalePurchaseOrderSubSelected(sub),
            ),
          const SizedBox(height: 8),
          const _SectionHeader(label: 'Other Income Report'),
          for (final sub in OtherIncomeReportSubSection.values)
            _NavItemTile(
              label: sub.label,
              isSelected:
                  navGroup == ReportNavGroup.otherIncomeReport &&
                  sub == selectedOtherIncomeSub,
              onTap: () => onOtherIncomeSubSelected(sub),
            ),
          const SizedBox(height: 8),
          const _SectionHeader(label: 'Loan Accounts'),
          for (final sub in LoanAccountsReportSubSection.values)
            _NavItemTile(
              label: sub.label,
              isSelected:
                  navGroup == ReportNavGroup.loanAccounts &&
                  sub == selectedLoanAccountsSub,
              onTap: () => onLoanAccountsSubSelected(sub),
            ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: _sectionHeaderColor,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

class _NavItemTile extends StatelessWidget {
  const _NavItemTile({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.showNotificationDot = false,
  });

  final String label;
  final bool isSelected;
  final bool showNotificationDot;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? _activeBackground : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: isSelected ? _activeBlue : Colors.transparent,
                width: 3,
              ),
              bottom: const BorderSide(color: _borderColor, width: 0.5),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 12, 12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? _activeBlue : const Color(0xFF424242),
                    height: 1.35,
                  ),
                ),
              ),
              if (showNotificationDot)
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: _notificationDot,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
