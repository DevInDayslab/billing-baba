import 'package:billing_baba/features/reports/models/business_status_report_subsection.dart';
import 'package:billing_baba/features/reports/models/item_stock_report_subsection.dart';
import 'package:billing_baba/features/reports/models/party_report_subsection.dart';
import 'package:billing_baba/features/reports/models/report_nav_group.dart';
import 'package:billing_baba/features/reports/models/transaction_report_subsection.dart';
import 'package:billing_baba/features/reports/presentation/pages/reports_page.dart' show ReportsPage;

/// One-shot navigation target for [ReportsPage] when opened from the dashboard.
final class ReportsNavIntent {
  const ReportsNavIntent._({
    required this.group,
    this.transactionSub,
    this.partySub,
    this.itemStockSub,
    this.businessStatusSub,
  });

  factory ReportsNavIntent.transaction(TransactionReportSubSection sub) {
    return ReportsNavIntent._(
      group: ReportNavGroup.transaction,
      transactionSub: sub,
    );
  }

  factory ReportsNavIntent.party(PartyReportSubSection sub) {
    return ReportsNavIntent._(
      group: ReportNavGroup.party,
      partySub: sub,
    );
  }

  factory ReportsNavIntent.itemStock(ItemStockReportSubSection sub) {
    return ReportsNavIntent._(
      group: ReportNavGroup.itemStock,
      itemStockSub: sub,
    );
  }

  factory ReportsNavIntent.businessStatus(
    BusinessStatusReportSubSection sub,
  ) {
    return ReportsNavIntent._(
      group: ReportNavGroup.businessStatus,
      businessStatusSub: sub,
    );
  }

  final ReportNavGroup group;
  final TransactionReportSubSection? transactionSub;
  final PartyReportSubSection? partySub;
  final ItemStockReportSubSection? itemStockSub;
  final BusinessStatusReportSubSection? businessStatusSub;
}
