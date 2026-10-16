import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_bottom_sheet.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_sheet_models.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Vyapar-style transaction picker opened from the center POS action.
Future<void> showMobileTransactionMenuSheet({
  required BuildContext context,
}) {
  return showMobileBottomSheet<void>(
    context: context,
    maxHeightFraction: 0.88,
    titleWidget: const _TransactionMenuSheetHeader(),
    builder: (sheetContext) {
      return _TransactionMenuContent(
        sections: mobileTransactionMenuSections(sheetContext),
        onItemTap: (item) {
          Navigator.of(sheetContext).pop();
          item.onTap();
        },
      );
    },
  );
}

/// Default sale / purchase / other transaction menu sections.
///
/// Quick Create only launches create forms — never transaction list screens.
List<MobileTransactionMenuSection> mobileTransactionMenuSections(
  BuildContext context,
) {
  void go(String route) => context.push(route);

  return [
    MobileTransactionMenuSection(
      title: 'Sale Transactions',
      items: [
        MobileTransactionMenuItem(
          label: 'Payment-In',
          icon: LucideIcons.phoneIncoming,
          showHighlight: true,
          onTap: () => go(AppRoutes.addPaymentIn),
        ),
        MobileTransactionMenuItem(
          label: 'Sale Return',
          icon: LucideIcons.undo2,
          onTap: () => go(AppRoutes.addCreditNote),
        ),
        MobileTransactionMenuItem(
          label: 'Delivery Challan',
          icon: LucideIcons.truck,
          onTap: () => go(AppRoutes.addDeliveryChallan),
        ),
        MobileTransactionMenuItem(
          label: 'Estimate/Quotation',
          icon: LucideIcons.calculator,
          onTap: () => go(AppRoutes.addEstimate),
        ),
        MobileTransactionMenuItem(
          label: 'Proforma Invoice',
          icon: LucideIcons.fileText,
          onTap: () => go(AppRoutes.addProforma),
        ),
        MobileTransactionMenuItem(
          label: 'Sale Order',
          icon: LucideIcons.clipboardList,
          onTap: () => go(AppRoutes.addSaleOrder),
        ),
        MobileTransactionMenuItem(
          label: 'Sale Invoice',
          icon: LucideIcons.receipt,
          onTap: () => go(AppRoutes.addSale),
        ),
        MobileTransactionMenuItem(
          label: 'Mobile POS',
          icon: LucideIcons.zap,
          onTap: () => go(AppRoutes.saleScreen),
        ),
      ],
    ),
    MobileTransactionMenuSection(
      title: 'Purchase Transactions',
      items: [
        MobileTransactionMenuItem(
          label: 'Purchase',
          icon: LucideIcons.shoppingCart,
          onTap: () => go(AppRoutes.addPurchase),
        ),
        MobileTransactionMenuItem(
          label: 'Payment-Out',
          icon: LucideIcons.phoneOutgoing,
          showHighlight: true,
          onTap: () => go(AppRoutes.addPaymentOut),
        ),
        MobileTransactionMenuItem(
          label: 'Purchase Return',
          icon: LucideIcons.shoppingCart,
          onTap: () => go(AppRoutes.addDebitNote),
        ),
        MobileTransactionMenuItem(
          label: 'Purchase Order',
          icon: LucideIcons.clipboardCheck,
          onTap: () => go(AppRoutes.addPurchaseOrder),
        ),
      ],
    ),
    MobileTransactionMenuSection(
      title: 'Other Transactions',
      items: [
        MobileTransactionMenuItem(
          label: 'Expenses',
          icon: LucideIcons.wallet,
          showHighlight: true,
          onTap: () => go(AppRoutes.addExpense),
        ),
      ],
    ),
  ];
}

class _TransactionMenuSheetHeader extends StatelessWidget {
  const _TransactionMenuSheetHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Sale Transactions',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(
            LucideIcons.x,
            color: AppColors.textSecondary.withValues(alpha: 0.7),
          ),
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints.tightFor(width: 32, height: 32),
        ),
      ],
    );
  }
}

class _TransactionMenuContent extends StatelessWidget {
  const _TransactionMenuContent({
    required this.sections,
    required this.onItemTap,
  });

  final List<MobileTransactionMenuSection> sections;
  final ValueChanged<MobileTransactionMenuItem> onItemTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < sections.length; i++) ...[
          if (i > 0) ...[
            const SizedBox(height: AppSpacing.md),
            Divider(
              height: 1,
              thickness: 1,
              color: AppColors.textSecondary.withValues(alpha: 0.15),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          _TransactionMenuSection(
            section: sections[i],
            onItemTap: onItemTap,
          ),
        ],
      ],
    );
  }
}

class _TransactionMenuSection extends StatelessWidget {
  const _TransactionMenuSection({
    required this.section,
    required this.onItemTap,
  });

  final MobileTransactionMenuSection section;
  final ValueChanged<MobileTransactionMenuItem> onItemTap;

  static const _columns = 3;
  static const _iconBackground = Color(0xFFE8F4FD);
  static const _iconColor = Color(0xFF1E2A3A);
  static const _highlightColor = Color(0xFFFF9800);

  @override
  Widget build(BuildContext context) {
    final rows = <List<MobileTransactionMenuItem>>[];
    for (var i = 0; i < section.items.length; i += _columns) {
      final end = (i + _columns).clamp(0, section.items.length);
      rows.add(section.items.sublist(i, end));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          section.title,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        for (var rowIndex = 0; rowIndex < rows.length; rowIndex++) ...[
          if (rowIndex > 0) const SizedBox(height: AppSpacing.xl),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var col = 0; col < _columns; col++) ...[
                if (col > 0) const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: col < rows[rowIndex].length
                      ? _TransactionMenuTile(
                          item: rows[rowIndex][col],
                          iconBackground: _iconBackground,
                          iconColor: _iconColor,
                          highlightColor: _highlightColor,
                          onTap: rows[rowIndex][col].enabled
                              ? () => onItemTap(rows[rowIndex][col])
                              : null,
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }
}

class _TransactionMenuTile extends StatelessWidget {
  const _TransactionMenuTile({
    required this.item,
    required this.iconBackground,
    required this.iconColor,
    required this.highlightColor,
    this.onTap,
  });

  final MobileTransactionMenuItem item;
  final Color iconBackground;
  final Color iconColor;
  final Color highlightColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: onTap == null ? 0.45 : 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.mdBorder,
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: iconBackground,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(item.icon, color: iconColor, size: 26),
                ),
                if (item.showHighlight)
                  const Positioned(
                    top: -4,
                    right: -6,
                    child: _SparkleAccent(),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              item.label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
                fontSize: 11,
                height: 1.25,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SparkleAccent extends StatelessWidget {
  const _SparkleAccent();

  static const _color = Color(0xFFFF9800);

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 18,
      height: 14,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            top: 4,
            child: Icon(LucideIcons.star, size: 7, color: _color),
          ),
          Positioned(
            left: 6,
            top: 0,
            child: Icon(LucideIcons.star, size: 9, color: _color),
          ),
          Positioned(
            left: 11,
            top: 5,
            child: Icon(LucideIcons.star, size: 6, color: _color),
          ),
        ],
      ),
    );
  }
}
