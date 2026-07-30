import 'package:billing_baba/features/parties/models/party_model.dart';
import 'package:billing_baba/features/reports/models/report_models.dart';

class ReportCashFlowTableRow {
  const ReportCashFlowTableRow({
    required this.transaction,
    required this.runningBalance,
  });

  final ReportTransactionRow transaction;
  final double runningBalance;
}

class ReportItemDetailTableRow {
  const ReportItemDetailTableRow({
    required this.row,
    required this.closingQty,
  });

  final ReportItemDetailRow row;
  final double closingQty;
}

class ReportSalePurchaseByPartyTableRow {
  const ReportSalePurchaseByPartyTableRow({
    required this.row,
    this.party,
  });

  final ReportSalePurchaseByPartyRow row;
  final PartyModel? party;
}

List<String> reportUniqueSortedValues(Iterable<String> values) {
  return values
      .map((value) => value.trim())
      .where((value) => value.isNotEmpty)
      .toSet()
      .toList()
    ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
}

List<String> reportStatusValuesFromRows(Iterable<String> values) {
  return reportUniqueSortedValues(values);
}
