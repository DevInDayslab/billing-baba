import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_dropdown_options.dart';
import 'package:billing_baba/features/sales/presentation/mobile/widgets/mobile_sale_form_widgets.dart';
import 'package:billing_baba/shared/widgets/mobile/forms/mobile_document_visibility.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_option_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// Totals, optional round-off, received amount, and payment mode rows.
class MobileDocumentTotalsSection extends StatelessWidget {
  const MobileDocumentTotalsSection({
    required this.visibility,
    required this.totalAmount,
    super.key,
    this.subtotal,
    this.taxAmount,
    this.roundOff = false,
    this.onRoundOffChanged,
    this.receivedAmount,
    this.onReceivedAmountChanged,
    this.paymentType,
    this.paymentAmount,
    this.onPaymentTypeTap,
    this.onPaymentAmountChanged,
    this.onAddPaymentType,
    this.payments = const [],
  });

  final MobileDocumentVisibility visibility;
  final double totalAmount;
  final double? subtotal;
  final double? taxAmount;
  final bool roundOff;
  final ValueChanged<bool>? onRoundOffChanged;
  final double? receivedAmount;
  final ValueChanged<double>? onReceivedAmountChanged;
  final String? paymentType;
  final double? paymentAmount;
  final VoidCallback? onPaymentTypeTap;
  final ValueChanged<double>? onPaymentAmountChanged;
  final VoidCallback? onAddPaymentType;
  final List<({String type, double amount})> payments;

  static final _currency = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '',
    decimalDigits: 2,
  );

  String _fmt(double value) {
    if (value <= 0) return '—';
    return _currency.format(value).trim();
  }

  @override
  Widget build(BuildContext context) {
    if (!visibility.showTotals) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (subtotal != null || taxAmount != null) ...[
          _SummaryRow(label: 'Subtotal', value: _fmt(subtotal ?? 0)),
          const SizedBox(height: AppSpacing.sm),
          _SummaryRow(label: 'Tax', value: _fmt(taxAmount ?? 0)),
          const SizedBox(height: AppSpacing.md),
        ],
        MobileSaleTotalRow(amountLabel: _fmt(totalAmount)),
        if (visibility.showRoundOff && onRoundOffChanged != null) ...[
          const SizedBox(height: AppSpacing.md),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: Text(
              'Round Off',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            value: roundOff,
            onChanged: onRoundOffChanged,
          ),
        ],
        if (visibility.showReceivedAmount &&
            onReceivedAmountChanged != null) ...[
          const SizedBox(height: AppSpacing.md),
          MobileSaleFormField(
            label: 'Received',
            hintText: '0.00',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp('[0-9.]')),
            ],
            onChanged: (value) {
              onReceivedAmountChanged!(double.tryParse(value) ?? 0);
            },
          ),
        ],
        if (visibility.showPaymentSection) ...[
          const SizedBox(height: AppSpacing.lg),
          for (final payment in payments) ...[
            Row(
              children: [
                Expanded(
                  child: MobileSalePickerField(
                    label: 'Payment Type',
                    value: payment.type,
                    onTap: onPaymentTypeTap ?? () {},
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: MobileSaleFormField(
                    label: 'Amount',
                    hintText: payment.amount > 0
                        ? payment.amount.toStringAsFixed(2)
                        : '0.00',
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp('[0-9.]')),
                    ],
                    onChanged: (value) {
                      onPaymentAmountChanged?.call(
                        double.tryParse(value) ?? 0,
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          if (payments.isEmpty && paymentType != null)
            Row(
              children: [
                Expanded(
                  child: MobileSalePickerField(
                    label: 'Payment Type',
                    value: paymentType!,
                    onTap: onPaymentTypeTap ?? () {},
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: MobileSaleFormField(
                    label: 'Amount',
                    hintText: (paymentAmount ?? 0) > 0
                        ? (paymentAmount ?? 0).toStringAsFixed(2)
                        : '0.00',
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp('[0-9.]')),
                    ],
                    onChanged: (value) {
                      onPaymentAmountChanged?.call(
                        double.tryParse(value) ?? 0,
                      );
                    },
                  ),
                ),
              ],
            ),
          if (onAddPaymentType != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: onAddPaymentType,
                child: const Text('+ Add Payment type'),
              ),
            ),
          ],
        ],
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const Spacer(),
        Text(
          '₹ $value',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

Future<String?> pickMobilePaymentType(
  BuildContext context, {
  String? selected,
}) {
  return showMobileOptionSheet<String>(
    context: context,
    title: 'Payment Type',
    selected: selected,
    options: [
      for (final type in SaleDropdownOptions.paymentTypes)
        MobileOption(value: type, label: type),
    ],
  );
}
