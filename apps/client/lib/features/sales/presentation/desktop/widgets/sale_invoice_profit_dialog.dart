import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_form_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Future<void> showSaleInvoiceProfitDialog(
  BuildContext context, {
  required AddSaleFormState form,
}) {
  final currency = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );
  final saleTotal = form.rawGrandTotal;
  final costTotal = form.estimatedCostTotal;
  final hasCost = form.items.any((line) => line.unitCost > 0 && line.qty > 0);
  final profit = form.estimatedProfitTotal;

  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Sale profit'),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ProfitRow(label: 'Sale amount', value: currency.format(saleTotal)),
            const SizedBox(height: AppSpacing.sm),
            _ProfitRow(
              label: 'Estimated cost',
              value: hasCost
                  ? currency.format(costTotal)
                  : 'Add purchase prices on items',
              muted: !hasCost,
            ),
            const Divider(height: 24),
            _ProfitRow(
              label: 'Profit',
              value: hasCost ? currency.format(profit) : '—',
              valueColor: hasCost && profit >= 0
                  ? const Color(0xFF2E7D32)
                  : (hasCost ? const Color(0xFFC62828) : null),
              isBold: true,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    ),
  );
}

class _ProfitRow extends StatelessWidget {
  const _ProfitRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.isBold = false,
    this.muted = false,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final bool isBold;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: muted
                  ? AppColors.textSecondary
                  : AppColors.textPrimary,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 15 : 14,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.w500,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
