import 'package:billing_baba/features/reports/models/business_status_report_subsection.dart';
import 'package:billing_baba/features/reports/models/expense_report_subsection.dart';
import 'package:billing_baba/features/reports/models/gst_report_subsection.dart';
import 'package:billing_baba/features/reports/models/item_stock_report_subsection.dart';
import 'package:billing_baba/features/reports/models/loan_accounts_report_subsection.dart';
import 'package:billing_baba/features/reports/models/other_income_report_subsection.dart';
import 'package:billing_baba/features/reports/models/party_report_subsection.dart';
import 'package:billing_baba/features/reports/models/report_nav_group.dart';
import 'package:billing_baba/features/reports/models/report_subsection_entry.dart';
import 'package:billing_baba/features/reports/models/sale_purchase_order_report_subsection.dart';
import 'package:billing_baba/features/reports/models/taxes_report_subsection.dart';
import 'package:billing_baba/features/reports/models/transaction_report_subsection.dart';

/// Canonical list of report groups and subsections for mobile navigation.
abstract final class ReportsNavCatalog {
  static const List<ReportNavGroup> groups = ReportNavGroup.values;

  static ReportSubsectionEntry? subsection(
    ReportNavGroup group,
    String subsectionId,
  ) {
    for (final entry in subsectionsFor(group)) {
      if (entry.id == subsectionId) return entry;
    }
    return null;
  }

  static List<ReportSubsectionEntry> subsectionsFor(ReportNavGroup group) {
    return switch (group) {
      ReportNavGroup.transaction => TransactionReportSubSection.values
          .map(
            (sub) => ReportSubsectionEntry(
              id: sub.name,
              label: sub.label,
              showNotificationDot: sub.showNotificationDot,
            ),
          )
          .toList(growable: false),
      ReportNavGroup.party => PartyReportSubSection.values
          .map((sub) => ReportSubsectionEntry(id: sub.name, label: sub.label))
          .toList(growable: false),
      ReportNavGroup.gst => GstReportSubSection.values
          .map((sub) => ReportSubsectionEntry(id: sub.name, label: sub.label))
          .toList(growable: false),
      ReportNavGroup.itemStock => ItemStockReportSubSection.values
          .map((sub) => ReportSubsectionEntry(id: sub.name, label: sub.label))
          .toList(growable: false),
      ReportNavGroup.businessStatus => BusinessStatusReportSubSection.values
          .map((sub) => ReportSubsectionEntry(id: sub.name, label: sub.label))
          .toList(growable: false),
      ReportNavGroup.taxes => TaxesReportSubSection.values
          .map((sub) => ReportSubsectionEntry(id: sub.name, label: sub.label))
          .toList(growable: false),
      ReportNavGroup.expenseReport => ExpenseReportSubSection.values
          .map((sub) => ReportSubsectionEntry(id: sub.name, label: sub.label))
          .toList(growable: false),
      ReportNavGroup.salePurchaseOrderReport =>
        SalePurchaseOrderReportSubSection.values
            .map(
              (sub) => ReportSubsectionEntry(id: sub.name, label: sub.label),
            )
            .toList(growable: false),
      ReportNavGroup.otherIncomeReport => OtherIncomeReportSubSection.values
          .map((sub) => ReportSubsectionEntry(id: sub.name, label: sub.label))
          .toList(growable: false),
      ReportNavGroup.loanAccounts => LoanAccountsReportSubSection.values
          .map((sub) => ReportSubsectionEntry(id: sub.name, label: sub.label))
          .toList(growable: false),
    };
  }
}
