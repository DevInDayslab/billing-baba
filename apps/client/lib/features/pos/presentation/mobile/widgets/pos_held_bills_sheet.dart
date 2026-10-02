import 'dart:async';

import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/pos/application/pos_cart_provider.dart';
import 'package:billing_baba/features/pos/models/held_bill.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_bottom_sheet.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

final _timeFormat = DateFormat('hh:mm a');

Future<void> showPosHeldBillsSheet(BuildContext context) {
  return showMobileBottomSheet<void>(
    context: context,
    titleWidget: Consumer(
      builder: (context, ref, _) {
        final count = ref.watch(posCartProvider).heldBills.length;
        final theme = Theme.of(context);

        return Text(
          'Bill on Hold ($count)',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        );
      },
    ),
    builder: (sheetContext) => const _HeldBillsSheetBody(),
  );
}

class PosHeldBillsBadge extends StatelessWidget {
  const PosHeldBillsBadge({
    required this.count,
    required this.onTap,
    super.key,
  });

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.xs),
      child: Material(
        color: AppColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            child: Text(
              '$count Hold',
              style: theme.textTheme.labelMedium?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HeldBillsSheetBody extends ConsumerWidget {
  const _HeldBillsSheetBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final heldBills = ref.watch(posCartProvider).heldBills;
    final cart = ref.read(posCartProvider.notifier);

    if (heldBills.isEmpty) {
      return const MobileEmptyState(
        title: 'No bills on hold',
        message: 'Held bills will appear here when you tap Hold bill.',
        icon: Icons.pause_circle_outline_rounded,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var index = 0; index < heldBills.length; index++) ...[
          if (index > 0) const SizedBox(height: AppSpacing.lg),
          _HeldBillCard(
            bill: heldBills[index],
            orderNumber: index + 1,
            onResume: () {
              cart.resumeBill(heldBills[index]);
              Navigator.of(context).pop();
            },
            onDiscard: () =>
                unawaited(cart.discardHeldBill(heldBills[index].id)),
          ),
        ],
      ],
    );
  }
}

class _HeldBillCard extends StatelessWidget {
  const _HeldBillCard({
    required this.bill,
    required this.orderNumber,
    required this.onResume,
    required this.onDiscard,
  });

  final HeldBill bill;
  final int orderNumber;
  final VoidCallback onResume;
  final VoidCallback onDiscard;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final itemPreview = bill.items
        .map((entry) => entry.item.name)
        .take(2)
        .join(', ');

    return Material(
      color: AppColors.surface,
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.mdBorder,
        side: const BorderSide(color: Color(0xFFE8EAED)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          InkWell(
            onTap: onResume,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.xl + AppSpacing.sm,
                AppSpacing.md,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: AppRadius.mdBorder,
                    ),
                    child: Center(
                      child: Text(
                        '#',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order No. #$orderNumber',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          itemPreview,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Wrap(
                          spacing: AppSpacing.sm,
                          runSpacing: AppSpacing.xs,
                          children: [
                            _InfoChip(
                              label: _timeFormat.format(bill.heldAt),
                              backgroundColor: const Color(0xFFE8F5E9),
                              textColor: const Color(0xFF2E7D32),
                            ),
                            const _InfoChip(
                              label: 'Sale',
                              backgroundColor: Color(0xFFFFF3E0),
                              textColor: Color(0xFFE65100),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: AppSpacing.xs,
            right: AppSpacing.xs,
            child: IconButton(
              onPressed: onDiscard,
              tooltip: 'Discard held bill',
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints.tightFor(width: 32, height: 32),
              icon: Icon(
                Icons.close_rounded,
                color: AppColors.textSecondary.withValues(alpha: 0.8),
                size: AppIconSize.md,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  });

  final String label;
  final Color backgroundColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: textColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
