import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/core/utils/date_time_utils.dart';
import 'package:billing_baba/core/widgets/mobile/mobile_card.dart';
import 'package:billing_baba/features/inventory/models/product_transaction_model.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/inventory_movement_indicator.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/inventory_stock_utils.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/inventory_styles.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

/// Single service transaction row for mobile item details.
class MobileItemTransactionTile extends StatelessWidget {
  const MobileItemTransactionTile({
    required this.transaction,
    required this.unitLabel,
    super.key,
  });

  final ProductTransaction transaction;
  final String unitLabel;

  static final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final quantityColor = transaction.isInbound
        ? inventoryPositiveColor
        : inventoryNegativeColor;
    final signedPrefix = transaction.isInbound ? '+' : '-';
    final unit = transaction.unit ?? unitLabel;
    final quantityText =
        '$signedPrefix${formatQuantityValue(transaction.quantity)} $unit';
    final priceText = transaction.pricePerUnit > 0
        ? _currencyFormat.format(transaction.pricePerUnit)
        : inventoryEmDash;
    final typeLabel = _typeLabel(transaction);
    final invoiceRef = _invoiceRef(transaction);

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
                  typeLabel,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              _StatusChip(status: transaction.status),
            ],
          ),
          const Gap(AppSpacing.sm),
          _MetaLine(label: 'Invoice / Ref.', value: invoiceRef),
          _MetaLine(label: 'Party', value: transaction.partyName),
          _MetaLine(
            label: 'Date',
            value: DateTimeUtils.formatDisplayDateTime(transaction.date),
          ),
          _MetaLine(
            label: 'Quantity',
            value: quantityText,
            valueColor: quantityColor,
          ),
          _MetaLine(label: 'Price / Unit', value: priceText),
        ],
      ),
    );
  }

  static String _typeLabel(ProductTransaction transaction) {
    final type = transaction.transactionType;
    final godown = transaction.godownName?.trim();
    if (godown != null && godown.isNotEmpty) {
      return '$type ($godown)';
    }
    return type;
  }

  static String _invoiceRef(ProductTransaction transaction) {
    final ref = transaction.invoiceRefNo.trim();
    if (ref.isNotEmpty) return ref;
    final reference = transaction.referenceNo.trim();
    return reference.isNotEmpty ? reference : inventoryEmDash;
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final normalized = status.trim();
    if (normalized.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE8EAED)),
      ),
      child: Text(
        normalized.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 10,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _MetaLine extends StatelessWidget {
  const _MetaLine({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

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
                color: valueColor ?? AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
