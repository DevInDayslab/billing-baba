import 'package:billing_baba/core/network/offline_ui_messages.dart';
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
                            SnackBar(
                              content: Text(
                                OfflineUiMessages.messageFor(error),
                              ),
                            ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _ReceiptItemLineRow(
          item: 'Item',
          qty: 'Qty',
          rate: 'Rate',
          total: 'Total',
          isHeader: true,
        ),
        for (final item in items)
          _ReceiptItemLineRow(
            item: item.name,
            qty: '${item.quantity}',
            rate: _currencyFormat.format(_rateFor(item)),
            total: _currencyFormat.format(item.lineTotal),
            emphasizeTotal: true,
          ),
      ],
    );
  }

  static double _rateFor(PosSaleLineItem item) {
    if (item.unitPrice != null) return item.unitPrice!;
    if (item.quantity <= 0) return 0;
    return item.lineTotal / item.quantity;
  }
}

/// Fixed-width numeric columns so qty / rate / total do not crowd together.
class _ReceiptItemLineRow extends StatelessWidget {
  const _ReceiptItemLineRow({
    required this.item,
    required this.qty,
    required this.rate,
    required this.total,
    this.isHeader = false,
    this.emphasizeTotal = false,
  });

  final String item;
  final String qty;
  final String rate;
  final String total;
  final bool isHeader;
  final bool emphasizeTotal;

  static const _qtyWidth = 40.0;
  static const _rateWidth = 80.0;
  static const _totalWidth = 92.0;
  static const _columnGap = 10.0;

  @override
  Widget build(BuildContext context) {
    final headerStyle = const TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      color: AppColors.textSecondary,
    );
    final cellStyle = TextStyle(
      fontSize: 12,
      fontWeight: emphasizeTotal ? FontWeight.w600 : FontWeight.w400,
      color: AppColors.textPrimary,
    );
    final style = isHeader ? headerStyle : cellStyle;

    return Padding(
      padding: isHeader
          ? const EdgeInsets.only(bottom: 6)
          : const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              item,
              style: style,
              maxLines: isHeader ? 1 : 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(
            width: _qtyWidth,
            child: Text(qty, style: style, textAlign: TextAlign.right),
          ),
          const SizedBox(width: _columnGap),
          SizedBox(
            width: _rateWidth,
            child: Text(rate, style: style, textAlign: TextAlign.right),
          ),
          const SizedBox(width: _columnGap),
          SizedBox(
            width: _totalWidth,
            child: Text(total, style: style, textAlign: TextAlign.right),
          ),
        ],
      ),
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
