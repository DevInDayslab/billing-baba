import 'package:billing_baba/features/parties/models/party_ledger_model.dart';
import 'package:billing_baba/features/reports/application/reports_service.dart';
import 'package:billing_baba/features/reports/models/report_models.dart';
import 'package:billing_baba/features/reports/models/requests/report_requests.dart';
import 'package:billing_baba/shared/utils/reporting_period_range.dart';

/// Builds party statement rows and summary from local party ledger data.
class PartyStatementReportBuilder {
  const PartyStatementReportBuilder._();

  static PartyStatementReportData build({
    required PartyLedgerModel ledger,
    required ReportQuery query,
  }) {
    final range = dateRangeForReportQuery(query);
    final opening = ledger.summary.openingBalance;

    final sorted = [...ledger.transactions];
    sorted.sort((a, b) {
      final dayCompare = _calendarDay(a.date).compareTo(_calendarDay(b.date));
      if (dayCompare != 0) return dayCompare;
      return a.createdAt.compareTo(b.createdAt);
    });

    final balanceById = <String, double>{};
    var running = opening;
    for (final tx in sorted) {
      running += tx.debit - tx.credit;
      balanceById[tx.id] = running;
    }

    final periodEntries = <ReportPartyStatementEntry>[];
    var moneyIn = 0.0;
    var moneyOut = 0.0;

    for (final tx in sorted) {
      if (!isCalendarDayInRange(tx.date, range)) continue;

      final entryType = tx.entryType;
      if (entryType == 'payment' && tx.credit > 0) {
        moneyIn += tx.credit;
      }
      if ((entryType == 'payment' && tx.debit > 0) || entryType == 'expense') {
        moneyOut += tx.debit + tx.credit;
      }

      final amount = tx.debit > 0 ? tx.debit : tx.credit;
      periodEntries.add(
        ReportPartyStatementEntry(
          date: tx.date,
          type: entryType,
          refNo: _refNo(tx.referenceNumber),
          debit: tx.debit,
          credit: tx.credit,
          total: amount,
          balance: balanceById[tx.id] ?? running,
        ),
      );
    }

    return PartyStatementReportData(
      entries: periodEntries,
      summary: ReportPartyStatementSummary(
        totalSale: ledger.summary.totalSales,
        totalPurchase: ledger.summary.totalPurchases,
        totalMoneyIn: moneyIn,
        totalMoneyOut: moneyOut,
        totalReceivable: ledger.summary.receiveAmount,
      ),
    );
  }

  static DateTime _calendarDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static String _refNo(String? referenceNumber) {
    final trimmed = referenceNumber?.trim();
    if (trimmed == null || trimmed.isEmpty) return '-';
    return trimmed;
  }
}
