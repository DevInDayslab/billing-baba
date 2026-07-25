import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/business/application/business_service.dart';
import 'package:billing_baba/features/pos/application/pos_receipt_printer.dart';
import 'package:billing_baba/features/pos/models/payment_entry.dart';
import 'package:billing_baba/features/pos/models/pos_sale.dart';
import 'package:billing_baba/features/pos/models/pos_sale_line_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// Receipt-style summary for a completed POS sale.
class ReceiptViewWidget extends ConsumerWidget {
  const ReceiptViewWidget({required this.sale, super.key});

  final PosSale sale;

  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  static final _dateFormat = DateFormat('dd MMM yyyy, hh:mm a');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final businessName = ref.watch(sidebarBusinessProvider).name;
    final cgstTotal = _sumTax((item) => item.cgstAmount);
    final sgstTotal = _sumTax((item) => item.sgstAmount);
    final hasSplitTax = cgstTotal > 0 || sgstTotal > 0;

    return Material(
      color: Colors.white,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                businessName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                sale.docNumber,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _dateFormat.format(sale.completedAt),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                sale.displayName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                child: Divider(height: 1, color: Color(0xFFE0E0E0)),
              ),
              _ItemsTable(items: sale.items),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                child: Divider(height: 1, color: Color(0xFFE0E0E0)),
              ),
              _TotalRow(
                label: 'Subtotal',
                value: _currencyFormat.format(sale.totalAmount),
              ),
              if (hasSplitTax) ...[
                _TotalRow(
                  label: 'CGST',
                  value: _currencyFormat.format(cgstTotal),
                ),
                _TotalRow(
                  label: 'SGST',
                  value: _currencyFormat.format(sgstTotal),
                ),
              ] else
                _TotalRow(
                  label: 'Tax',
                  value: _currencyFormat.format(sale.taxAmount),
                ),
              const SizedBox(height: AppSpacing.sm),
              _TotalRow(
                label: 'Grand Total',
                value: _currencyFormat.format(sale.finalAmount),
                emphasized: true,
              ),
              const SizedBox(height: AppSpacing.sm),
              if (sale.payments.length > 1) ...[
                for (final payment in sale.payments)
                  _TotalRow(
                    label: _paymentModeLabel(payment.mode),
                    value: _currencyFormat.format(payment.amount),
                  ),
              ] else
                _TotalRow(
                  label: 'Payment',
                  value: _paymentLabel(sale),
                ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        try {
                          await ref
                              .read(posReceiptPrinterProvider)
                              .preview(
                                context: context,
                                sale: sale,
                                ref: ref,
                              );
                        } catch (error) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Print failed: $error')),
                          );
                        }
                      },
                      icon: const Icon(Icons.print_outlined, size: 18),
                      label: const Text('Print'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Done'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _sumTax(double? Function(PosSaleLineItem item) selector) {
    return sale.items.fold<double>(
      0,
      (sum, item) => sum + (selector(item) ?? 0),
    );
  }

  static String _paymentLabel(PosSale sale) {
    if (sale.payments.isNotEmpty) {
      if (sale.payments.length == 1) {
        return '${_paymentModeLabel(sale.payments.first.mode)} · ${_currencyFormat.format(sale.payments.first.amount)}';
      }
      return sale.payments
          .map(
            (p) =>
                '${_paymentModeLabel(p.mode)} · ${_currencyFormat.format(p.amount)}',
          )
          .join(', ');
    }
    return switch (sale.paymentMethod?.split(',').first.trim()) {
      'upi' => 'UPI',
      'card' => 'Card',
      'bank_transfer' => 'Bank',
      _ => 'Cash',
    };
  }

  static String _paymentModeLabel(PaymentMode mode) => switch (mode) {
    PaymentMode.cash => 'Cash',
    PaymentMode.upi => 'UPI',
    PaymentMode.card => 'Card',
    PaymentMode.bank => 'Bank',
  };
}

class _ItemsTable extends StatelessWidget {
  const _ItemsTable({required this.items});

  final List<PosSaleLineItem> items;

  static final NumberFormat _currencyFormat = ReceiptViewWidget._currencyFormat;

  @override
  Widget build(BuildContext context) {
    const headerStyle = TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      color: AppColors.textSecondary,
    );
    const cellStyle = TextStyle(
      fontSize: 12,
      color: AppColors.textPrimary,
    );

    return Table(
      columnWidths: const {
        0: FlexColumnWidth(3),
        1: IntrinsicColumnWidth(),
        2: IntrinsicColumnWidth(),
        3: IntrinsicColumnWidth(),
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        const TableRow(
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: 6),
              child: Text('Item', style: headerStyle),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 6),
              child: Text(
                'Qty',
                style: headerStyle,
                textAlign: TextAlign.right,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 6),
              child: Text(
                'Rate',
                style: headerStyle,
                textAlign: TextAlign.right,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 6),
              child: Text(
                'Total',
                style: headerStyle,
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
        for (final item in items)
          TableRow(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  item.name,
                  style: cellStyle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  '${item.quantity}',
                  style: cellStyle,
                  textAlign: TextAlign.right,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  _currencyFormat.format(
                    item.quantity > 0 ? item.lineTotal / item.quantity : 0,
                  ),
                  style: cellStyle,
                  textAlign: TextAlign.right,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  _currencyFormat.format(item.lineTotal),
                  style: cellStyle.copyWith(fontWeight: FontWeight.w600),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class _TotalRow extends StatelessWidget {
  const _TotalRow({
    required this.label,
    required this.value,
    this.emphasized = false,
  });

  final String label;
  final String value;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: emphasized ? 15 : 13,
      fontWeight: emphasized ? FontWeight.w700 : FontWeight.w500,
      color: AppColors.textPrimary,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(child: Text(label, style: style)),
          Text(value, style: style),
        ],
      ),
    );
  }
}
