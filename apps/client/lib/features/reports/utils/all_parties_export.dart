import 'package:billing_baba/features/parties/models/party_model.dart';
import 'package:billing_baba/features/reports/utils/report_formatters.dart';

const allPartiesExportHeaders = [
  '#',
  'Party Name',
  'Email',
  'Phone No.',
  'Receivable Balance',
  'Payable Balance',
  'Credit Limit',
];

List<String> allPartiesExportRow(int index, PartyModel party) {
  final email = party.email.isEmpty ? '—' : party.email;
  final receivable = party.balance > 0
      ? formatReportCurrency(party.balance)
      : '—';
  final payable = party.balance < 0
      ? formatReportCurrency(party.balance.abs())
      : '—';
  final creditLimit = party.creditLimit.isEmpty
      ? '—'
      : formatReportCurrency(double.tryParse(party.creditLimit) ?? 0);

  return [
    '${index + 1}',
    party.name,
    email,
    party.phone,
    receivable,
    payable,
    creditLimit,
  ];
}
