import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_card.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_widgets.dart'
    show MobileTransactionPage;
import 'package:billing_baba/shared/widgets/mobile/transaction/mobile_transaction_models.dart';
import 'package:billing_baba/shared/widgets/mobile/transaction/mobile_transaction_page.dart'
    show MobileTransactionPage;
import 'package:billing_baba/shared/widgets/mobile/transaction/mobile_transaction_widgets.dart'
    show MobileTransactionPage;
import 'package:flutter/material.dart';

/// Default transaction row card for [MobileTransactionPage].
class MobileTransactionCard extends StatelessWidget {
  const MobileTransactionCard({
    required this.item,
    required this.onTap,
    super.key,
  });

  final MobileTransactionListItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MobileCard(
      selected: item.isHighlighted,
      onTap: onTap,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (item.leadingIcon != null) ...[
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: AppRadius.mdBorder,
              ),
              child: Icon(
                item.leadingIcon,
                color: AppColors.primary,
                size: AppIconSize.lg,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (item.subtitle != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    item.subtitle!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (item.dateLabel != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    item.dateLabel!,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                item.amountLabel,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: item.amountColor ?? AppColors.textPrimary,
                ),
              ),
              if (item.statusLabel != null) ...[
                const SizedBox(height: AppSpacing.xs),
                _StatusChip(
                  label: item.statusLabel!,
                  color: item.statusColor,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, this.color});

  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final resolved = color ?? AppColors.textSecondary;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: resolved.withValues(alpha: 0.12),
        borderRadius: AppRadius.smBorder,
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: resolved,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
