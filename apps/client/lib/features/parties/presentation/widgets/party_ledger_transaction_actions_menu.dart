import 'package:billing_baba/features/parties/models/party_ledger_model.dart';
import 'package:billing_baba/features/parties/presentation/utils/party_ledger_transaction_table_actions.dart';
import 'package:billing_baba/features/sales/presentation/widgets/shared/sales_action_menu_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Instant ⋮ menu for a ledger row. Opens synchronously via [SalesActionMenuButton];
/// document resolution runs only after the user selects an action.
class PartyLedgerTransactionActionsMenu extends ConsumerWidget {
  const PartyLedgerTransactionActionsMenu({
    required this.transaction,
    super.key,
  });

  final PartyLedgerTransactionModel transaction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final referenceId = transaction.referenceId?.trim();
    if (referenceId == null || referenceId.isEmpty) {
      return const SizedBox(width: 32, height: 32);
    }

    return SalesActionMenuButton(
      items: PartyLedgerTransactionTableActions.buildMenuItems(
        transaction: transaction,
        context: context,
        ref: ref,
      ),
    );
  }
}
