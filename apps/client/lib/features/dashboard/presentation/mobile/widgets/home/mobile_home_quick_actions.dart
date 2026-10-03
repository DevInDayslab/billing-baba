import 'dart:async';

import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/dashboard/application/quick_create_executor.dart';
import 'package:billing_baba/features/dashboard/models/quick_create_action.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_sheet_models.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_sheets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Quick action shortcuts — five compact rounded-square tiles.
class MobileHomeQuickActions extends ConsumerWidget {
  const MobileHomeQuickActions({super.key});

  static const _actions = [
    _QuickActionVisual(
      id: 'sale_invoice',
      label: 'New Sale',
      icon: LucideIcons.shoppingCart,
      color: Color(0xFF43A047),
      background: Color(0xFFE8F5E9),
    ),
    _QuickActionVisual(
      id: 'purchase_bill',
      label: 'New Purchase',
      icon: LucideIcons.shoppingBag,
      color: Color(0xFF1E88E5),
      background: Color(0xFFE3F2FD),
    ),
    _QuickActionVisual(
      id: 'payment_in',
      label: 'Receive',
      icon: LucideIcons.phoneIncoming,
      color: Color(0xFF6338E0),
      background: Color(0xFFF3EEFF),
    ),
    _QuickActionVisual(
      id: 'payment_out',
      label: 'Pay',
      icon: LucideIcons.phoneOutgoing,
      color: Color(0xFFE53935),
      background: Color(0xFFFFEBEE),
    ),
    _QuickActionVisual(
      id: 'expenses',
      label: 'Expenses',
      icon: LucideIcons.wallet,
      color: Color(0xFFFB8C00),
      background: Color(0xFFFFF3E0),
    ),
  ];

  static const _allActionVisuals = <_QuickActionVisual>[
    _QuickActionVisual(
      id: 'sale_invoice',
      label: 'Sale Invoice',
      icon: LucideIcons.receipt,
      color: Color(0xFF43A047),
      background: Color(0xFFE8F5E9),
    ),
    _QuickActionVisual(
      id: 'payment_in',
      label: 'Payment-In',
      icon: LucideIcons.phoneIncoming,
      color: Color(0xFF6338E0),
      background: Color(0xFFF3EEFF),
    ),
    _QuickActionVisual(
      id: 'sale_return',
      label: 'Sale Return',
      icon: LucideIcons.undo2,
      color: Color(0xFF43A047),
      background: Color(0xFFE8F5E9),
    ),
    _QuickActionVisual(
      id: 'sale_order',
      label: 'Sale Order',
      icon: LucideIcons.shoppingCart,
      color: Color(0xFF43A047),
      background: Color(0xFFE8F5E9),
    ),
    _QuickActionVisual(
      id: 'estimate_quotation',
      label: 'Estimate/Quotation',
      icon: LucideIcons.fileText,
      color: Color(0xFF43A047),
      background: Color(0xFFE8F5E9),
    ),
    _QuickActionVisual(
      id: 'proforma_invoice',
      label: 'Proforma Invoice',
      icon: LucideIcons.fileText,
      color: Color(0xFF43A047),
      background: Color(0xFFE8F5E9),
    ),
    _QuickActionVisual(
      id: 'delivery_challan',
      label: 'Delivery Challan',
      icon: LucideIcons.truck,
      color: Color(0xFF43A047),
      background: Color(0xFFE8F5E9),
    ),
    _QuickActionVisual(
      id: 'sale_assets',
      label: 'Sale Assets',
      icon: LucideIcons.building,
      color: Color(0xFF43A047),
      background: Color(0xFFE8F5E9),
    ),
    _QuickActionVisual(
      id: 'purchase_bill',
      label: 'Purchase Bill',
      icon: LucideIcons.shoppingBag,
      color: Color(0xFF1E88E5),
      background: Color(0xFFE3F2FD),
    ),
    _QuickActionVisual(
      id: 'payment_out',
      label: 'Payment-Out',
      icon: LucideIcons.phoneOutgoing,
      color: Color(0xFFE53935),
      background: Color(0xFFFFEBEE),
    ),
    _QuickActionVisual(
      id: 'purchase_return',
      label: 'Purchase Return',
      icon: LucideIcons.undo2,
      color: Color(0xFF1E88E5),
      background: Color(0xFFE3F2FD),
    ),
    _QuickActionVisual(
      id: 'purchase_order',
      label: 'Purchase Order',
      icon: LucideIcons.shoppingBasket,
      color: Color(0xFF1E88E5),
      background: Color(0xFFE3F2FD),
    ),
    _QuickActionVisual(
      id: 'purchase_assets',
      label: 'Purchase Assets',
      icon: LucideIcons.building2,
      color: Color(0xFF1E88E5),
      background: Color(0xFFE3F2FD),
    ),
    _QuickActionVisual(
      id: 'expenses',
      label: 'Expenses',
      icon: LucideIcons.wallet,
      color: Color(0xFFFB8C00),
      background: Color(0xFFFFF3E0),
    ),
  ];

  void _openMoreSheet(BuildContext context, WidgetRef ref) {
    MobileQuickAction mobileAction(QuickCreateAction action) {
      final visual = _visualForAction(action.id);
      return MobileQuickAction(
        label: action.label,
        icon: visual.icon,
        iconColor: visual.color,
        backgroundColor: visual.background,
        onTap: () => executeQuickCreate(context, ref, action),
      );
    }

    final sections = [
      MobileQuickActionSection(
        title: 'SALE',
        actions: QuickCreateActions.forCategory(
          QuickCreateCategory.sale,
        ).map(mobileAction).toList(),
      ),
      MobileQuickActionSection(
        title: 'PURCHASE',
        actions: QuickCreateActions.forCategory(
          QuickCreateCategory.purchase,
        ).map(mobileAction).toList(),
      ),
      MobileQuickActionSection(
        title: 'OTHERS',
        actions: QuickCreateActions.forCategory(
          QuickCreateCategory.others,
        ).map(mobileAction).toList(),
      ),
    ];

    unawaited(
      showMobileQuickActionsSheet(
        context: context,
        title: 'All Quick Actions',
        actions: const [],
        sections: sections,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final primary = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.xs,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Quick Actions',
                  style: AppTypography.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => _openMoreSheet(context, ref),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  minimumSize: const Size(40, 32),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'More',
                  style: AppTypography.inter(
                    fontSize: 12,
                    color: primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              for (var i = 0; i < _actions.length; i++) ...[
                if (i > 0) const SizedBox(width: 4),
                Expanded(
                  child: _QuickActionItem(
                    visual: _actions[i],
                    onTap: () {
                      final action = QuickCreateActions.byId(_actions[i].id);
                      if (action != null) {
                        executeQuickCreate(context, ref, action);
                      }
                    },
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  static _QuickActionVisual _visualForAction(String id) {
    return _allActionVisuals.firstWhere(
      (visual) => visual.id == id,
      orElse: () => _QuickActionVisual(
        id: id,
        label: id,
        icon: LucideIcons.plus,
        color: AppColors.primary,
        background: AppColors.tabActiveTint,
      ),
    );
  }
}

class _QuickActionVisual {
  const _QuickActionVisual({
    required this.id,
    required this.label,
    required this.icon,
    required this.color,
    required this.background,
  });

  final String id;
  final String label;
  final IconData icon;
  final Color color;
  final Color background;
}

class _QuickActionItem extends StatelessWidget {
  const _QuickActionItem({required this.visual, required this.onTap});

  final _QuickActionVisual visual;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: visual.label,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.searchBorder,
        child: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: visual.background,
                borderRadius: AppRadius.searchBorder,
              ),
              child: Icon(visual.icon, color: visual.color, size: 22),
            ),
            const SizedBox(height: 6),
            Text(
              visual.label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.inter(
                fontSize: 10,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
                height: 1.15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
