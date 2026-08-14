import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/inventory_styles.dart';
import 'package:billing_baba/features/parties/models/party_model.dart';
import 'package:billing_baba/features/parties/presentation/desktop/widgets/party_avatar.dart';
import 'package:billing_baba/shared/widgets/app_ellipsis_text.dart';
import 'package:flutter/material.dart';

/// Party identity header for the mobile detail screen.
class MobilePartyDetailHeader extends StatelessWidget {
  const MobilePartyDetailHeader({
    required this.party,
    required this.outstandingLabel,
    super.key,
    this.creditLimitLabel,
    this.onAvatarTap,
  });

  final PartyModel party;
  final String outstandingLabel;
  final String? creditLimitLabel;
  final VoidCallback? onAvatarTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final outstandingColor = party.hasReceivable
        ? inventoryPositiveColor
        : party.hasPayable
        ? inventoryNegativeColor
        : AppColors.textSecondary;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PartyAvatar(
            name: party.name,
            seed: party.id,
            partyId: party.id,
            diameter: 64,
            profileImageUrl: party.profileImageUrl,
            profileMediaAssetId: party.profileMediaAssetId,
            onTap: onAvatarTap,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: AppEllipsisText(
                        PartyModel.displayNameWithLegal(party),
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: party.isActive
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                        ),
                        maxLines: 2,
                      ),
                    ),
                    if (!party.isActive)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: AppRadius.smBorder,
                        ),
                        child: Text(
                          'Inactive',
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  party.partyTypeLabel,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                if (party.phone.trim().isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    PartyModel.displayPhones(party),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.md),
                Text(
                  outstandingLabel,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: outstandingColor,
                  ),
                ),
                Text(
                  'Outstanding',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                if (creditLimitLabel != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Credit limit: $creditLimitLabel',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
