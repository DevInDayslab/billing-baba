import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/parties/models/party_model.dart';
import 'package:billing_baba/features/parties/presentation/desktop/widgets/party_actions.dart';
import 'package:billing_baba/features/parties/presentation/desktop/widgets/party_whatsapp_actions.dart';
import 'package:billing_baba/features/parties/presentation/mobile/widgets/party_payment_sheets.dart';
import 'package:billing_baba/shared/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Primary quick actions shown on the mobile party detail screen.
class MobilePartyQuickActions extends ConsumerWidget {
  const MobilePartyQuickActions({
    required this.party,
    required this.outstanding,
    super.key,
  });

  final PartyModel party;
  final double outstanding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canReceive = PartyActions.canReceivePayment(party);
    final canRecord = PartyActions.canRecordPayment(party);

    final primaryLabel = canReceive
        ? 'Receive Payment'
        : canRecord
        ? 'Record Payment'
        : 'Payment';
    final primaryAction = canReceive
        ? () => showMobileReceivePaymentSheet(
            context: context,
            ref: ref,
            party: party,
          )
        : canRecord
        ? () => showMobileRecordPaymentSheet(
            context: context,
            ref: ref,
            party: party,
          )
        : null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: [
          Expanded(
            child: AppButton(
              label: primaryLabel,
              onPressed: primaryAction,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => PartyWhatsAppActions.sendPaymentReminderNow(
                context,
                ref,
                party,
                outstanding: outstanding,
              ),
              icon: const Icon(LucideIcons.messageCircle, size: 18),
              label: const Text('WhatsApp'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.mdBorder,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
