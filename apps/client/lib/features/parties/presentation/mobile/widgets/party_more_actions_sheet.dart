import 'package:billing_baba/core/widgets/mobile/mobile_sheet_models.dart';
import 'package:billing_baba/core/widgets/mobile/mobile_sheets.dart';
import 'package:billing_baba/features/parties/models/party_model.dart';
import 'package:billing_baba/features/parties/presentation/desktop/widgets/party_actions.dart';
import 'package:billing_baba/features/parties/presentation/desktop/widgets/party_whatsapp_actions.dart';
import 'package:billing_baba/features/parties/presentation/mobile/widgets/party_payment_sheets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
        icon: Icons.edit_outlined,
        label: 'Edit Party',
        onTap: () => PartyActions.edit(context, ref, party),
      ),
      MobileSheetAction(
        icon: Icons.content_copy_outlined,
        label: 'Duplicate',
        onTap: () => PartyActions.duplicate(context, ref, party),
      ),
      MobileSheetAction(
        icon: Icons.sms_outlined,
        label: 'Send SMS Reminder',
        onTap: () => PartyWhatsAppActions.sendPaymentReminderNow(
          context,
          ref,
          party,
          outstanding: outstanding,
        ),
      ),
      MobileSheetAction(
        icon: Icons.schedule_rounded,
        label: 'Set Reminder',
        onTap: () => PartyWhatsAppActions.showReminderDialog(
          context,
          ref,
          party,
          outstanding: outstanding,
        ),
      ),
      if (canReceive)
        MobileSheetAction(
          icon: Icons.call_received_rounded,
          label: 'Receive Payment',
          onTap: () => showMobileReceivePaymentSheet(
            context: context,
            party: party,
          ),
        ),
      if (canRecord)
        MobileSheetAction(
          icon: Icons.call_made_rounded,
          label: 'Record Payment',
          onTap: () => showMobileRecordPaymentSheet(
            context: context,
            party: party,
          ),
        ),
      if (!party.isActive)
        MobileSheetAction(
          icon: Icons.restore_rounded,
          label: 'Restore Party',
          onTap: () => PartyActions.restore(context, ref, party),
        ),
      if (party.isActive)
        MobileSheetAction(
          icon: Icons.delete_outline_rounded,
          label: 'Delete',
          isDestructive: true,
          onTap: () => PartyActions.delete(context, ref, party),
        ),
    ],
  );
}
