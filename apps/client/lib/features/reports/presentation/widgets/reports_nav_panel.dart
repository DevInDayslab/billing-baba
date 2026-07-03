import 'package:billing_baba/features/reports/models/business_status_report_subsection.dart';
import 'package:billing_baba/features/reports/models/expense_report_subsection.dart';
import 'package:billing_baba/features/reports/models/gst_report_subsection.dart';
import 'package:billing_baba/features/reports/models/item_stock_report_subsection.dart';
import 'package:billing_baba/features/reports/models/party_report_subsection.dart';
import 'package:billing_baba/features/reports/models/report_nav_group.dart';
import 'package:billing_baba/features/reports/models/sale_purchase_order_report_subsection.dart';
import 'package:billing_baba/features/reports/models/transaction_report_subsection.dart';
import 'package:flutter/material.dart';

const _navBackground = Color(0xFFF8F9FB);
const _sectionHeaderColor = Color(0xFF00695C);
const _activeBlue = Color(0xFF1976D2);
const _activeBackground = Color(0xFFE8F1FB);
const _borderColor = Color(0xFFE0E0E0);
const _notificationDot = Color(0xFFE53935);

class ReportsNavPanel extends StatelessWidget {
  const ReportsNavPanel({
    required this.navGroup,
    required this.selectedTransactionSub,
    required this.selectedPartySub,
    required this.selectedGstSub,
    required this.selectedItemStockSub,
    required this.selectedBusinessStatusSub,
    required this.selectedExpenseSub,
    required this.selectedSalePurchaseOrderSub,
    required this.onTransactionSubSelected,
    required this.onPartySubSelected,
    required this.onGstSubSelected,
    required this.onItemStockSubSelected,
    required this.onBusinessStatusSubSelected,
    required this.onExpenseSubSelected,
    required this.onSalePurchaseOrderSubSelected,
    super.key,
  });

  final ReportNavGroup navGroup;
  final TransactionReportSubSection selectedTransactionSub;
  final PartyReportSubSection selectedPartySub;
  final GstReportSubSection selectedGstSub;
  final ItemStockReportSubSection selectedItemStockSub;
  final BusinessStatusReportSubSection selectedBusinessStatusSub;
  final ExpenseReportSubSection selectedExpenseSub;
  final SalePurchaseOrderReportSubSection selectedSalePurchaseOrderSub;
  final ValueChanged<TransactionReportSubSection> onTransactionSubSelected;
  final ValueChanged<PartyReportSubSection> onPartySubSelected;
  final ValueChanged<GstReportSubSection> onGstSubSelected;
  final ValueChanged<ItemStockReportSubSection> onItemStockSubSelected;
  final ValueChanged<BusinessStatusReportSubSection>
  onBusinessStatusSubSelected;
  final ValueChanged<ExpenseReportSubSection> onExpenseSubSelected;
  final ValueChanged<SalePurchaseOrderReportSubSection>
  onSalePurchaseOrderSubSelected;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: _navBackground,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 16),
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
          const SizedBox(height: 8),
          const _SectionHeader(label: 'GST reports'),
          for (final sub in GstReportSubSection.values)
            _NavItemTile(
              label: sub.label,
              isSelected:
                  navGroup == ReportNavGroup.gst && sub == selectedGstSub,
              onTap: () => onGstSubSelected(sub),
            ),
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
