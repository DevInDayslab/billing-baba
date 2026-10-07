import 'package:billing_baba/core/routing/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/application/inventory_transaction_table_service.dart';
import 'package:billing_baba/features/inventory/models/product_transaction_model.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/inventory_stock_utils.dart';
import 'package:billing_baba/shared/utils/date_time_utils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

Future<void> showInventoryProductTransactionDetail(
  BuildContext context, {
  required ProductTransaction transaction,
  required String unitLabel,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (dialogContext) => _ProductTransactionDetailDialog(
      transaction: transaction,
      unitLabel: unitLabel,
    ),
  );
}

class _ProductTransactionDetailDialog extends StatelessWidget {
  const _ProductTransactionDetailDialog({
    required this.transaction,
    required this.unitLabel,
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
        ? AppColors.success
        : AppColors.error;
    final signedPrefix = transaction.isInbound ? '+' : '-';
    final unit = transaction.unit ?? unitLabel;
    final quantityText =
        '$signedPrefix${formatQuantityValue(transaction.quantity)} $unit';

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.lg,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 520,
          maxHeight: MediaQuery.sizeOf(context).height * 0.85,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.sm,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Transaction details',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    tooltip: 'Close',
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _DetailRow(
                      label: 'Type',
                      value: InventoryTransactionTableService.typeDisplayLabel(
                        transaction,
                      ),
                    ),
                    _DetailRow(
                      label: 'Invoice / Ref.',
                      value: _referenceLabel(transaction),
                    ),
                    _DetailRow(label: 'Party', value: transaction.partyName),
                    _DetailRow(
                      label: 'Date',
                      value: DateTimeUtils.formatDisplayDateTime(
                        transaction.date,
                      ),
                    ),
                    _DetailRow(
                      label: 'Quantity',
                      value: quantityText,
                      valueStyle: TextStyle(
                        color: quantityColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    _DetailRow(
                      label: 'Price / unit',
                      value: transaction.pricePerUnit > 0
                          ? _currencyFormat.format(transaction.pricePerUnit)
                          : inventoryEmDash,
                    ),
                    _DetailRow(label: 'Status', value: transaction.status),
                    if (transaction.godownName != null &&
                        transaction.godownName!.trim().isNotEmpty)
                      _DetailRow(
                        label: 'Godown',
                        value: transaction.godownName!,
                      ),
                    if (transaction.notes != null &&
                        transaction.notes!.trim().isNotEmpty)
                      _DetailRow(label: 'Notes', value: transaction.notes!),
                  ],
                ),
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                  ),
                  if (_documentRoute(transaction) != null) ...[
                    const SizedBox(width: AppSpacing.sm),
                    FilledButton(
                      onPressed: () {
                        final route = _documentRoute(transaction);
                        if (route == null) return;
                        Navigator.of(context).pop();
                        context.push(route);
                      },
                      child: const Text('Open document'),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _referenceLabel(ProductTransaction transaction) {
    final invoice = transaction.invoiceRefNo.trim();
    if (invoice.isNotEmpty) return invoice;
    return transaction.referenceNo.trim().isEmpty
        ? inventoryEmDash
        : transaction.referenceNo;
  }

  static String? _documentRoute(ProductTransaction transaction) {
    final documentId = transaction.referenceDocumentId;
    if (documentId == null || documentId.isEmpty) return null;

    final type = (transaction.referenceDocumentType ?? '').toLowerCase();
    if (type.contains('purchase')) {
      return '${AppRoutes.editPurchase}/$documentId';
    }
    if (type.contains('sales')) {
      return '${AppRoutes.editSale}/$documentId';
    }

    return switch (transaction.movementType) {
      'purchase' || 'purchase_document' || 'purchase_return' =>
        '${AppRoutes.editPurchase}/$documentId',
      'sale' || 'sales_document' || 'sales_return' =>
        '${AppRoutes.editSale}/$documentId',
      _ => null,
    };
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.valueStyle,
  });

  final String label;
  final String value;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: valueStyle ??
                  const TextStyle(
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
