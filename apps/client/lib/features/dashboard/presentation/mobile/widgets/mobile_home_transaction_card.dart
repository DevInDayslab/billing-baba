import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/dashboard/presentation/mobile/application/mobile_home_models.dart';
import 'package:flutter/material.dart';

import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Compact transaction card for the home feed.
class MobileHomeTransactionCard extends StatelessWidget {
  const MobileHomeTransactionCard({
    required this.item,
    super.key,
    this.onPrint,
    this.onShare,
    this.onTap,
  });

  final MobileHomeTransactionItem item;
  final VoidCallback? onPrint;
  final VoidCallback? onShare;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = item.statusType.colors;
    final iconData = _iconForFilter(item.filterType);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.cardBorder,
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadius.cardBorder,
            border: Border.all(color: AppColors.chipBorder),
            boxShadow: AppShadows.subtle,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: 12,
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colors.bg,
                  shape: BoxShape.circle,
                ),
                child: Icon(iconData, color: colors.fg, size: 22),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            item.title ?? item.partyName,
                            style: AppTypography.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                              height: 1.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (item.paymentMethod != null &&
                            item.paymentMethod!.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          _PaymentPill(
                            label: item.paymentMethod!,
                            colors: colors,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.documentNumber,
                      style: AppTypography.inter(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.timeLabel ?? item.dateLabel,
                      style: AppTypography.inter(
                        fontSize: 10.5,
                        color: AppColors.textSecondary.withValues(alpha: 0.85),
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ActionButton(
                    icon: LucideIcons.printer,
                    onTap: onPrint,
                    semanticLabel: 'Print ${item.documentNumber}',
                  ),
                  _ActionButton(
                    icon: LucideIcons.share2,
                    onTap: onShare,
                    semanticLabel: 'Share ${item.documentNumber}',
                  ),
                ],
              ),
              const SizedBox(width: AppSpacing.xs),
              _AmountBadge(
                amount: item.totalLabel,
                colors: colors,
              ),
            ],
          ),
        ),
      ),
    );
  }

  static IconData _iconForFilter(MobileHomeTransactionFilterType type) {
    return switch (type) {
      MobileHomeTransactionFilterType.sale => LucideIcons.shoppingCart,
      MobileHomeTransactionFilterType.purchase => LucideIcons.shoppingBag,
      MobileHomeTransactionFilterType.paymentIn => LucideIcons.arrowUp,
      MobileHomeTransactionFilterType.paymentOut => LucideIcons.arrowDown,
      MobileHomeTransactionFilterType.expense => LucideIcons.wallet,
      _ => LucideIcons.receipt,
    };
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.semanticLabel,
    this.onTap,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Icon(
            icon,
            size: 18,
            color: AppColors.textSecondary.withValues(alpha: 0.65),
          ),
        ),
      ),
    );
  }
}

class _PaymentPill extends StatelessWidget {
  const _PaymentPill({
    required this.label,
    required this.colors,
  });

  final String label;
  final ColorPair colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: colors.bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colors.fg.withValues(alpha: 0.2)),
      ),
      child: Text(
        label,
        style: AppTypography.inter(
          fontSize: 9,
          color: colors.fg,
          fontWeight: FontWeight.w600,
          height: 1.2,
        ),
      ),
    );
  }
}

class _AmountBadge extends StatelessWidget {
  const _AmountBadge({
    required this.amount,
    required this.colors,
  });

  final String amount;
  final ColorPair colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 68, maxWidth: 88),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: colors.bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        amount,
        style: AppTypography.inter(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: colors.fg,
          height: 1.1,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.right,
      ),
    );
  }
}
