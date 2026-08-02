import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MobileDocumentSummaryCard extends StatelessWidget {
  const MobileDocumentSummaryCard({
    required this.subtotal,
    required this.tax,
    required this.total,
    super.key,
    this.discount = 0,
    this.extraRows = const [],
  });

  final double subtotal;
  final double tax;
  final double total;
  final double discount;
  final List<MobileSummaryRow> extraRows;

  static final _currency = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(top: AppSpacing.md),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            _row('Subtotal', subtotal),
            if (discount > 0) _row('Discount', -discount),
            if (tax > 0) _row('Tax', tax),
            for (final row in extraRows) _row(row.label, row.amount),
            const Divider(),
            _row('Total', total, emphasized: true),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, double amount, {bool emphasized = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTypography.inter(
                fontSize: emphasized
                    ? AppTypography.subtitleSize
                    : AppTypography.bodySize,
                fontWeight: emphasized ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
          Text(
            _currency.format(amount),
            style: AppTypography.inter(
              fontSize: emphasized
                  ? AppTypography.subtitleSize
                  : AppTypography.bodySize,
              fontWeight: emphasized ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class MobileSummaryRow {
  const MobileSummaryRow({required this.label, required this.amount});

  final String label;
  final double amount;
}
