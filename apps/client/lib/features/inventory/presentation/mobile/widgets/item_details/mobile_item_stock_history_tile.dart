import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/shared/utils/date_time_utils.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_card.dart';
import 'package:billing_baba/features/inventory/models/product_transaction_model.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/inventory_movement_indicator.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/inventory_stock_utils.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/inventory_styles.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

/// Single stock history row for mobile item details.
class MobileItemStockHistoryTile extends StatelessWidget {
  const MobileItemStockHistoryTile({
    required this.transaction,
    required this.unitLabel,
    this.balance,
    super.key,
  });

  final ProductTransaction transaction;
  final String unitLabel;
  final double? balance;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final quantityColor = transaction.isInbound
        ? inventoryPositiveColor
        : inventoryNegativeColor;
    final signedPrefix = transaction.isInbound ? '+' : '-';
    final unit = transaction.unit ?? unitLabel;
    final changeText =
        '$signedPrefix${formatQuantityValue(transaction.quantity)} $unit';
    final balanceText = balance == null
        ? inventoryEmDash
        : formatQuantityValue(balance!);
    final userName = transaction.createdByName?.trim();
    final notes = transaction.notes?.trim();
    final reference = transaction.referenceNo.trim().isNotEmpty
        ? transaction.referenceNo
        : null;
    final godown = transaction.godownName?.trim();

    return MobileCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              InventoryMovementIndicator(
                movementType: transaction.movementType,
              ),
              const Gap(AppSpacing.sm),
              Expanded(
                child: Text(
                  transaction.typeLabel,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                changeText,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: quantityColor,
                ),
              ),
            ],
          ),
          const Gap(AppSpacing.sm),
          _MetaLine(
            label: 'Date',
            value: DateTimeUtils.formatDisplayDateTime(transaction.date),
          ),
          _MetaLine(
            label: 'Balance',
            value: balanceText,
          ),
          if (userName != null && userName.isNotEmpty)
            _MetaLine(label: 'Updated By', value: userName),
          if (godown != null && godown.isNotEmpty)
            _MetaLine(label: 'Godown', value: godown),
          if (reference != null)
            _MetaLine(label: 'Reference', value: reference),
          if (notes != null && notes.isNotEmpty)
            _MetaLine(label: 'Notes', value: notes),
        ],
      ),
    );
  }
}

class _MetaLine extends StatelessWidget {
  const _MetaLine({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xxs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 88,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
