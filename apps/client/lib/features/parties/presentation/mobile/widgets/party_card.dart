import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/inventory_styles.dart';
import 'package:billing_baba/features/parties/models/party_model.dart';
import 'package:billing_baba/features/parties/presentation/desktop/widgets/party_avatar.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_card.dart';
import 'package:flutter/material.dart';

/// Party row card for the mobile list.
class MobilePartyCard extends StatelessWidget {
  const MobilePartyCard({
    required this.party,
    required this.onTap,
    super.key,
    this.displayBalance,
    this.isSelected = false,
  });

  final PartyModel party;
  final VoidCallback onTap;

  /// Projected ledger outstanding — mirrors desktop [projectedPartyBalance].
  final double? displayBalance;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final balance = displayBalance ?? party.balance;
    final amountColor = balance > 0
        ? inventoryPositiveColor
        : balance < 0
        ? inventoryNegativeColor
        : AppColors.textSecondary;
    final amountText = PartyModel.displayOutstanding(balance);

    return MobileCard(
      selected: isSelected,
      onTap: onTap,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          PartyAvatar(
            name: party.name,
            seed: party.id,
            partyId: party.id,
            diameter: 44,
            profileImageUrl: party.profileImageUrl,
            profileMediaAssetId: party.profileMediaAssetId,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        party.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: party.isActive
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (!party.isActive) ...[
                      const SizedBox(width: AppSpacing.sm),
                      const _StatusChip(label: 'Inactive'),
                    ],
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  _subtitleFor(party),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amountText,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: amountColor,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                party.partyTypeLabel,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _subtitleFor(PartyModel party) {
    final phone = party.phone.trim();
    if (phone.isNotEmpty) return phone;
    final gstin = party.gstin.trim();
    if (gstin.isNotEmpty) return gstin;
    return party.partyTypeLabel;
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: AppRadius.smBorder,
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Colors.grey.shade700,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
