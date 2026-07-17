import 'package:billing_baba/features/parties/models/party_model.dart';
import 'package:billing_baba/features/parties/presentation/widgets/party_actions.dart';
import 'package:billing_baba/features/sales/presentation/widgets/shared/sales_action_menu_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PartyActionsMenuButton extends ConsumerWidget {
  const PartyActionsMenuButton({
    required this.party,
    super.key,
  });

  final PartyModel party;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canReceive = PartyActions.canReceivePayment(party);
    final canRecord = PartyActions.canRecordPayment(party);

    return SalesActionMenuButton(
      items: [
        SalesActionMenuItem(
          label: 'View Party',
          onSelected: () => PartyActions.edit(context, ref, party),
        ),
        if (!party.isActive)
          SalesActionMenuItem(
            label: 'Restore Party',
            onSelected: () => PartyActions.restore(context, ref, party),
          ),
        if (party.isActive)
          SalesActionMenuItem(
            label: 'Delete',
            isDestructive: true,
            onSelected: () => PartyActions.delete(context, ref, party),
          ),
        SalesActionMenuItem(
          label: 'Duplicate',
          dividerBefore: true,
          onSelected: () => PartyActions.duplicate(context, ref, party),
        ),
        if (canReceive)
          SalesActionMenuItem(
            label: 'Receive Payment',
            dividerBefore: true,
            onSelected: () => PartyActions.receivePayment(context, party),
          ),
        if (canRecord)
          SalesActionMenuItem(
            label: 'Record Payment',
            dividerBefore: !canReceive,
            onSelected: () => PartyActions.recordPayment(context, party),
          ),
      ],
    );
  }
}
