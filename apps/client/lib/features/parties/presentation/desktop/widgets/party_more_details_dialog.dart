import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/collaboration/application/permission_service_provider.dart';
import 'package:billing_baba/features/collaboration/domain/models/permission_module.dart';
import 'package:billing_baba/features/parties/application/parties_providers.dart';
import 'package:billing_baba/features/parties/models/party_ledger_model.dart';
import 'package:billing_baba/features/parties/models/party_model.dart';
import 'package:billing_baba/features/parties/presentation/desktop/widgets/party_actions.dart';
import 'package:billing_baba/features/pricing/models/price_tier.dart';
import 'package:billing_baba/shared/widgets/app_ellipsis_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> showPartyMoreDetailsDialog(
  BuildContext context,
  WidgetRef ref, {
  required PartyModel party,
  required String businessName,
  required AsyncValue<PartyLedgerModel> ledgerAsync,
}) {
  return showDialog<void>(
    context: context,
    builder: (dialogContext) => PartyMoreDetailsDialog(
      party: party,
      businessName: businessName,
      ledgerAsync: ledgerAsync,
      onEdit: () {
        Navigator.of(dialogContext).pop();
        PartyActions.edit(context, ref, party);
      },
    ),
  );
}

class PartyMoreDetailsDialog extends ConsumerWidget {
  const PartyMoreDetailsDialog({
    required this.party,
    required this.businessName,
    required this.ledgerAsync,
    required this.onEdit,
    super.key,
  });

  final PartyModel party;
  final String businessName;
  final AsyncValue<PartyLedgerModel> ledgerAsync;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canEdit = ref
        .watch(permissionServiceProvider)
        .canEdit(PermissionModule.party);
    final outstandingIndex = ref.watch(partyOutstandingIndexProvider).value;
    final outstanding = ledgerAsync.maybeWhen(
      data: (ledger) => ledger.summary.outstanding,
      orElse: () => party.balance,
    );
    final projected = projectedPartyBalance(party, outstandingIndex);

    final lines = <_DetailLine>[
      _DetailLine('Party Type', party.partyTypeLabel),
      _DetailLine('Status', party.statusLabel),
      if (party.alias.trim().isNotEmpty) _DetailLine('Alias', party.alias.trim()),
      if (party.partyGroup.trim().isNotEmpty)
        _DetailLine('Party Group', party.partyGroup.trim()),
      if (party.areaCode.trim().isNotEmpty)
        _DetailLine('Area Code', party.areaCode.trim()),
      if (businessName.trim().isNotEmpty)
        _DetailLine('Business Name', businessName.trim()),
      _DetailLine(
        'Outstanding Balance',
        PartyModel.displayOutstanding(outstanding),
      ),
      if (projected != party.balance)
        _DetailLine(
          'Projected Balance',
          PartyModel.displayOutstanding(projected),
        ),
      if (party.gstType.trim().isNotEmpty)
        _DetailLine('GST Type', party.gstType.trim()),
      if (party.state.trim().isNotEmpty) _DetailLine('State', party.state.trim()),
      if (party.shippingAddress.trim().isNotEmpty)
        _DetailLine('Shipping Address', party.shippingAddress.trim()),
      if (party.notes.trim().isNotEmpty) _DetailLine('Notes', party.notes.trim()),
      _DetailLine('Default Price Tier', PriceTier.labelFor(party.defaultPriceTier)),
      if (party.openingBalance != 0)
        _DetailLine(
          'Opening Balance',
          PartyModel.displayOpeningBalance(party.openingBalance),
        ),
      if (party.additionalField1.trim().isNotEmpty)
        _DetailLine('Additional Field 1', party.additionalField1.trim()),
      if (party.additionalField2.trim().isNotEmpty)
        _DetailLine('Additional Field 2', party.additionalField2.trim()),
    ];

    return AlertDialog(
      title: const Text('More Details'),
      content: SizedBox(
        width: 480,
        child: lines.isEmpty
            ? const Text('No additional details for this party.')
            : ListView.separated(
                shrinkWrap: true,
                itemCount: lines.length,
                separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, index) {
                  final line = lines[index];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        line.label.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      AppEllipsisText(
                        line.value,
                        maxLines: 4,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  );
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
        if (canEdit)
          FilledButton(
            onPressed: onEdit,
            child: const Text('Edit Party'),
          ),
      ],
    );
  }
}

class _DetailLine {
  const _DetailLine(this.label, this.value);

  final String label;
  final String value;
}
