import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/dashboard/presentation/mobile/application/mobile_home_models.dart';
import 'package:flutter/material.dart';

/// Compact transaction card for the home feed.
class MobileHomeTransactionCard extends StatelessWidget {
  const MobileHomeTransactionCard({
    required this.item,
    super.key,
    this.onPrint,
    this.onShare,
    this.onPdf,
    this.onTap,
  });

  final MobileHomeTransactionItem item;
  final VoidCallback? onPrint;
  final VoidCallback? onShare;
  final VoidCallback? onPdf;
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
            vertical: 10,
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colors.bg,
                  shape: BoxShape.circle,
                ),
                child: Icon(iconData, color: colors.fg, size: 18),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
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
                    Text(
                      item.documentNumber,
                      style: AppTypography.inter(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                        height: 1.3,
                      ),
                    ),
                    Text(
                      item.timeLabel ?? item.dateLabel,
                      style: AppTypography.inter(
                        fontSize: 10.5,
                        color: AppColors.textSecondary.withValues(alpha: 0.85),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              _ActionButton(
                icon: Icons.print_outlined,
                onTap: onPrint,
                semanticLabel: 'Print ${item.documentNumber}',
              ),
              _ActionButton(
                icon: Icons.share_outlined,
                onTap: onShare,
                semanticLabel: 'Share ${item.documentNumber}',
              ),
              _PdfAction(onTap: onPdf),
              const SizedBox(width: AppSpacing.xs),
              _AmountBadge(
                amount: item.totalLabel,
                paymentMethod: item.paymentMethod,
                colors: colors,
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSecondary.withValues(alpha: 0.4),
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }

  static IconData _iconForFilter(MobileHomeTransactionFilterType type) {
    return switch (type) {
      MobileHomeTransactionFilterType.sale => Icons.shopping_cart_outlined,
      MobileHomeTransactionFilterType.purchase => Icons.shopping_bag_outlined,
      MobileHomeTransactionFilterType.paymentIn => Icons.south_west_rounded,
      MobileHomeTransactionFilterType.paymentOut => Icons.north_east_rounded,
      MobileHomeTransactionFilterType.expense =>
        Icons.account_balance_wallet_outlined,
      _ => Icons.receipt_long_outlined,
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
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(
            icon,
            size: 15,
            color: AppColors.textSecondary.withValues(alpha: 0.55),
          ),
        ),
      ),
    );
  }
}

class _PdfAction extends StatelessWidget {
  const _PdfAction({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Open PDF',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Text(
            'PDF',
            style: AppTypography.inter(
              fontSize: 10,
              color: AppColors.danger,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _AmountBadge extends StatelessWidget {
  const _AmountBadge({
    required this.amount,
    required this.colors,
    this.paymentMethod,
  });

  final String amount;
  final ColorPair colors;
  final String? paymentMethod;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 72),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: colors.bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            amount,
            style: AppTypography.inter(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: colors.fg,
              height: 1.1,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (paymentMethod != null && paymentMethod!.isNotEmpty)
            Text(
              paymentMethod!,
              style: AppTypography.inter(
                fontSize: 9,
                color: colors.fg.withValues(alpha: 0.8),
                fontWeight: FontWeight.w600,
                height: 1.2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
    );
  }
}
