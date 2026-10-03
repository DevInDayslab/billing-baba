import 'dart:async';

import 'package:billing_baba/features/parties/application/party_ledger_service.dart';
import 'package:billing_baba/features/parties/models/party_model.dart';
import 'package:billing_baba/features/parties/presentation/desktop/widgets/party_actions.dart';
import 'package:billing_baba/features/parties/presentation/desktop/widgets/party_export_actions.dart';
import 'package:billing_baba/features/parties/presentation/mobile/widgets/party_payment_sheets.dart';
import 'package:billing_baba/features/parties/presentation/utils/party_ledger_print_actions.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_sheet_models.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_sheets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lucide_icons_flutter/lucide_icons.dart';

/// More actions bottom sheet for a party.
Future<void> showPartyMoreActionsSheet({
  required BuildContext context,
  required WidgetRef ref,
  required PartyModel party,
  required double outstanding,
}) {
  final canReceive = PartyActions.canReceivePayment(party);
  final canRecord = PartyActions.canRecordPayment(party);

  return showMobileMoreActionsSheet(
    context: context,
    actions: [
      MobileSheetAction(
        icon: LucideIcons.pencil,
        label: 'Edit Party',
        onTap: () => PartyActions.edit(context, ref, party),
      ),
      MobileSheetAction(
        icon: LucideIcons.copy,
        label: 'Duplicate',
        onTap: () => PartyActions.duplicate(context, ref, party),
      ),
      MobileSheetAction(
        icon: LucideIcons.printer,
        label: 'Print Ledger',
        onTap: () {
          final ledger = ref.read(partyTimelineProvider(party.id)).value;
          unawaited(
            PartyLedgerPrintActions.previewLedger(
              context: context,
              ref: ref,
              party: party,
              transactions: ledger?.transactions ?? const [],
              outstanding: outstanding,
              creditLimit: ledger?.summary.creditLimit,
            ),
          );
        },
      ),
      MobileSheetAction(
        icon: LucideIcons.table,
        label: 'Export Ledger',
        onTap: () {
          final ledger = ref.read(partyTimelineProvider(party.id)).value;
          unawaited(
            PartyExportActions.exportLedgerTransactions(
              context,
              partyName: party.name,
              transactions: ledger?.transactions ?? const [],
            ),
          );
        },
      ),
      if (canReceive)
        MobileSheetAction(
          icon: LucideIcons.phoneIncoming,
          label: 'Receive Payment',
          onTap: () => showMobileReceivePaymentSheet(
            context: context,
            ref: ref,
            party: party,
          ),
        ),
      if (canRecord)
        MobileSheetAction(
          icon: LucideIcons.phoneOutgoing,
          label: 'Record Payment',
          onTap: () => showMobileRecordPaymentSheet(
            context: context,
            ref: ref,
            party: party,
          ),
        ),
      if (!party.isActive)
        MobileSheetAction(
          icon: LucideIcons.rotateCcw,
          label: 'Restore Party',
          onTap: () => PartyActions.restore(context, ref, party),
        ),
      if (party.isActive)
        MobileSheetAction(
          icon: LucideIcons.trash2,
          label: 'Delete',
          isDestructive: true,
          onTap: () => PartyActions.delete(context, ref, party),
        ),
    ],
  );
}
