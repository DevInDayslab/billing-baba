import 'dart:math' as math;

import 'package:billing_baba/features/reports/models/report_models.dart';

class TrialBalanceBuiltReport {
  const TrialBalanceBuiltReport({
    required this.rows,
    required this.totalDebit,
    required this.totalCredit,
    required this.isBalanced,
  });

  final List<ReportTrialBalanceRow> rows;
  final double totalDebit;
  final double totalCredit;
  final bool isBalanced;
}

/// Builds trial balance rows using the same structure as the API accounting report.
class TrialBalanceReportBuilder {
  const TrialBalanceReportBuilder._();

  static TrialBalanceBuiltReport build({
    required double openingCash,
    required double closingCash,
    required double cashReceived,
    required double cashPaid,
    required double receivableOpening,
    required double receivableClosing,
    required double payableOpening,
    required double payableClosing,
    required double purchaseTotal,
    required double purchaseReturnTotal,
    required double salesTotal,
    required double salesReturnTotal,
    required double expenseTotal,
    required double stockValue,
    required double partyOpening,
    required double netProfit,
    String? searchQuery,
  }) {
    final receivableDebit =
        math.max(0, receivableClosing - receivableOpening).toDouble();
    final receivableCredit =
        math.max(0, receivableOpening - receivableClosing).toDouble();

    final payableDebit =
        math.max(0, payableOpening - payableClosing).toDouble();
    final payableCredit =
        math.max(0, payableClosing - payableOpening).toDouble();

    final stockOpening = math
        .max(0, stockValue - (purchaseTotal - purchaseReturnTotal))
        .toDouble();

    final openingEquity =
        openingCash + receivableOpening + stockValue - payableOpening;
    final openingRetained = openingEquity - partyOpening;
    final closingEquity =
        closingCash + receivableClosing + stockValue - payableClosing;
    final closingRetained = closingEquity - partyOpening - netProfit;
    final retainedMovement = closingRetained - openingRetained;

    var rows = <ReportTrialBalanceRow>[
      _trialRow(
        'Cash & Bank',
        openingCash,
        cashReceived,
        cashPaid,
      ),
      _trialRow(
        'Sundry Debtors',
        receivableOpening,
        receivableDebit,
        receivableCredit,
      ),
      _trialRow(
        'Stock in Hand',
        stockOpening,
        purchaseTotal,
        purchaseReturnTotal,
      ),
      _trialRow(
        'Sundry Creditors',
        -payableOpening,
        payableDebit,
        payableCredit,
      ),
      _trialRow('Capital Account', partyOpening, 0, 0),
      _trialRow(
        'Retained Earnings / Opening Balance',
        openingRetained,
        retainedMovement > 0 ? retainedMovement : 0,
        retainedMovement < 0 ? retainedMovement.abs() : 0,
      ),
      _trialRow('Sales', 0, salesReturnTotal, salesTotal),
      _trialRow('Purchases', 0, purchaseTotal, purchaseReturnTotal),
      _trialRow('Expenses', 0, expenseTotal, 0),
      _trialRow(
        'Net Profit',
        0,
        netProfit < 0 ? netProfit.abs() : 0,
        netProfit > 0 ? netProfit : 0,
      ),
    ];

    final q = searchQuery?.trim().toLowerCase();
    if (q != null && q.isNotEmpty) {
      rows = rows
          .where((row) => row.accountName.toLowerCase().contains(q))
          .toList();
    }

    var totalDebit = 0.0;
    var totalCredit = 0.0;
    for (final row in rows) {
      if (row.closingDebit > 0) {
        totalDebit += row.closingDebit;
      }
      if (row.closingCredit > 0) {
        totalCredit += row.closingCredit;
      }
    }

    final difference = totalDebit - totalCredit;
    if (difference.abs() > 0.01) {
      final rounding = _trialRow(
        'Rounding Difference',
        0,
        difference < 0 ? difference.abs() : 0,
        difference > 0 ? difference : 0,
      );
      rows = [...rows, rounding];
      if (rounding.closingDebit > 0) totalDebit += rounding.closingDebit;
      if (rounding.closingCredit > 0) totalCredit += rounding.closingCredit;
    }

    return TrialBalanceBuiltReport(
      rows: rows,
      totalDebit: totalDebit,
      totalCredit: totalCredit,
      isBalanced: (totalDebit - totalCredit).abs() < 0.02,
    );
  }

  static bool hasMeaningfulActivity({
    required List<ReportTrialBalanceRow> rows,
    required double totalDebit,
    required double totalCredit,
  }) {
    for (final row in rows) {
      if (row.accountName == 'Rounding Difference') continue;
      if (row.opening.abs() > 0.001) return true;
      if (row.debit.abs() > 0.001) return true;
      if (row.credit.abs() > 0.001) return true;
      if (row.closingDebit.abs() > 0.001) return true;
      if (row.closingCredit.abs() > 0.001) return true;
    }
    return totalDebit.abs() > 0.001 || totalCredit.abs() > 0.001;
  }

  static ReportTrialBalanceRow _trialRow(
    String accountName,
    double opening,
    double debit,
    double credit,
  ) {
    final closing = opening + debit - credit;
    final isDebit = closing >= 0;
    return ReportTrialBalanceRow(
      accountName: accountName,
      opening: opening,
      debit: debit,
      credit: credit,
      closingDebit: isDebit ? closing.abs() : 0,
      closingCredit: isDebit ? 0 : closing.abs(),
    );
  }
}
