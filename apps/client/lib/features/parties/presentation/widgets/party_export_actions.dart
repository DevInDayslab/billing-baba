import 'package:billing_baba/features/export/application/adapters/party_ledger_export_adapter.dart';
import 'package:billing_baba/features/export/presentation/widgets/export_actions.dart';
import 'package:billing_baba/features/parties/models/party_ledger_model.dart';
import 'package:flutter/material.dart';

/// Export actions for the Parties module.
abstract final class PartyExportActions {
  static Future<void> exportLedgerTransactions(
    BuildContext context, {
    required String partyName,
    required List<PartyLedgerTransactionModel> transactions,
  }) async {
    if (transactions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No transactions to export'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    await ExportActions.exportXlsx(
      context,
      sheet: buildPartyLedgerExportSheet(transactions: transactions),
      filenameBase: partyLedgerExportFilename(partyName),
    );
  }
}
