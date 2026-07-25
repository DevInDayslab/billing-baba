import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/core/widgets/list_panel_header.dart';
import 'package:billing_baba/features/pos/application/pos_cart_provider.dart';
import 'package:billing_baba/features/pos/application/pos_cart_state.dart';
import 'package:billing_baba/features/pos/presentation/desktop/widgets/cart_row.dart';
import 'package:billing_baba/features/pos/presentation/desktop/widgets/pos_panel.dart';
import 'package:billing_baba/features/pos/presentation/desktop/widgets/pos_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

final _currencyFormat = NumberFormat.currency(
  locale: 'en_IN',
  symbol: '₹',
  decimalDigits: 2,
);

class CartPanel extends ConsumerWidget {
  const CartPanel({
    required this.onHoldBill,
    this.onPrint,
    super.key,
  });

  final VoidCallback onHoldBill;
  final VoidCallback? onPrint;

  static const _tableMinWidth = 640.0;

  static const _cartColumns = [
    ListPanelColumn(label: 'PRODUCT', flex: 3),
    ListPanelColumn(label: 'QTY', flex: 2),
    ListPanelColumn(label: 'UNIT'),
    ListPanelColumn(label: 'RATE'),
    ListPanelColumn(label: 'DISC'),
    ListPanelColumn(label: 'AMOUNT'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(posCartProvider);

    return PosPanel(
      child: SizedBox.expand(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.sm,
                AppSpacing.sm,
              ),
              child: Row(
                children: [
                  const Text('Current Bill', style: PosStyles.panelTitleStyle),
                  const SizedBox(width: AppSpacing.sm),
                  _InfoChip(label: '${cart.totalItems} Items'),
                  const SizedBox(width: AppSpacing.sm),
                  _InfoChip(label: 'Qty: ${cart.totalQty}'),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.more_vert, size: 20),
                    color: AppColors.textSecondary,
                    onPressed: () {},
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: posCardBorder),
            Expanded(
              child: _CartItemsSection(cart: cart),
            ),
            const Divider(height: 1, color: posCardBorder),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 260),
              child: SingleChildScrollView(
                child: _BillSummary(cart: cart),
              ),
            ),
            const Divider(height: 1, color: posCardBorder),
            _BottomActionBar(onHoldBill: onHoldBill, onPrint: onPrint),
          ],
        ),
      ),
    );
  }
}

class _CartItemsSection extends StatelessWidget {
  const _CartItemsSection({required this.cart});

  final PosCartState cart;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final needsScroll = constraints.maxWidth < CartPanel._tableMinWidth;
        const header = ListPanelHeader(columns: CartPanel._cartColumns);
        final body = cart.items.isEmpty
            ? const ListPanelEmptyState(message: 'No items in cart')
            : ListView.builder(
                itemCount: cart.items.length,
                itemBuilder: (context, index) =>
                    CartRow(cartItem: cart.items[index]),
              );

        final table = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            header,
            Expanded(child: body),
          ],
        );

        if (!needsScroll) {
          return table;
        }

        return ClipRect(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: CartPanel._tableMinWidth,
              height: constraints.maxHeight,
              child: table,
            ),
          ),
        );
      },
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: posSelectedBackground,
        borderRadius: AppRadius.smBorder,
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Text(
        label,
        style: PosStyles.metadataStyle.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

class _BillSummary extends ConsumerWidget {
  const _BillSummary({required this.cart});

  final PosCartState cart;

  Future<void> _showBillDiscountDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final controller = TextEditingController(
      text: cart.billDiscountPercent > 0
          ? cart.billDiscountPercent.toStringAsFixed(0)
          : '',
    );

    final result = await showDialog<double>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Bill Discount'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Discount %',
            suffixText: '%',
            hintText: '0–100',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final value = double.tryParse(controller.text.trim()) ?? 0;
              Navigator.of(dialogContext).pop(value.clamp(0, 100));
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );

    controller.dispose();
    if (result != null) {
      ref.read(posCartProvider.notifier).updateBillDiscount(result);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balanceColor = cart.balance == 0
        ? posPositiveColor
        : posNegativeColor;

    return LayoutBuilder(
      builder: (context, constraints) {
        final stackSummary = constraints.maxWidth < 480;

        final leftColumn = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SummaryRow(
              label: 'Subtotal',
              value: _currencyFormat.format(cart.subtotal),
            ),
            _SummaryRow(
              label: 'Discount',
              value: '-${_currencyFormat.format(cart.totalDiscount)}',
              valueColor: posNegativeColor,
            ),
            InkWell(
              onTap: () => _showBillDiscountDialog(context, ref),
              child: _SummaryRow(
                label: 'Bill Discount',
                value: cart.billDiscountPercent > 0
                    ? '-${_currencyFormat.format(cart.billDiscountAmount)} (${cart.billDiscountPercent.toStringAsFixed(0)}%)'
                    : '${cart.billDiscountPercent.toStringAsFixed(0)}%',
                valueColor: cart.billDiscountPercent > 0
                    ? posNegativeColor
                    : AppColors.primary,
              ),
            ),
            _SummaryRow(
              label: 'Taxable Amount',
              value: _currencyFormat.format(cart.taxableAfterBillDiscount),
            ),
            _SummaryRow(
              label: 'CGST (9%)',
              value: _currencyFormat.format(cart.cgst),
            ),
            _SummaryRow(
              label: 'SGST (9%)',
              value: _currencyFormat.format(cart.sgst),
            ),
            _SummaryRow(
              label: 'Round Off',
              value: _currencyFormat.format(cart.roundOff),
            ),
          ],
        );

        final rightColumn = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Total Payable', style: PosStyles.metadataStyle),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Text(
                      _currencyFormat.format(cart.totalPayable),
                      style: PosStyles.totalPayableStyle,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            _SummaryRow(
              label: 'Paid Amount',
              value: _currencyFormat.format(cart.totalPaid),
              valueColor: posPositiveColor,
            ),
            _SummaryRow(
              label: 'Balance',
              value: _currencyFormat.format(cart.balance),
              valueColor: balanceColor,
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: _StatBox(
                    label: 'Total Items',
                    value: '${cart.totalItems}',
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _StatBox(
                    label: 'Total Qty',
                    value: '${cart.totalQty}',
                  ),
                ),
              ],
            ),
          ],
        );

        return Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: stackSummary
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    leftColumn,
                    const SizedBox(height: AppSpacing.md),
                    rightColumn,
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: leftColumn),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(child: rightColumn),
                  ],
                ),
        );
      },
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
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
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: PosStyles.metadataStyle,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              value,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 12,
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

class _StatBox extends StatelessWidget {
  const _StatBox({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: AppRadius.smBorder,
        border: Border.all(color: posCardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: PosStyles.metadataStyle.copyWith(fontSize: 10),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomActionBar extends StatelessWidget {
  const _BottomActionBar({
    required this.onHoldBill,
    this.onPrint,
  });

  final VoidCallback onHoldBill;
  final VoidCallback? onPrint;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wrapButtons = constraints.maxWidth < 420;

        final buttons = [
          OutlinedButton(
            onPressed: onHoldBill,
            style: PosButtonStyles.primaryOutlined,
            child: Text(
              wrapButtons ? 'Hold (F7)' : 'Hold Bill (F7)',
              style: const TextStyle(fontSize: 11),
            ),
          ),
          OutlinedButton(
            onPressed: () {},
            style: PosButtonStyles.primaryOutlined,
            child: const Text('Save Draft', style: TextStyle(fontSize: 11)),
          ),
          OutlinedButton(
            onPressed: onPrint,
            style: PosButtonStyles.primaryOutlined,
            child: Text(
              wrapButtons ? 'Print' : 'Print (F8)',
              style: const TextStyle(fontSize: 11),
            ),
          ),
        ];

        return Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: wrapButtons
              ? Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: buttons
                      .map(
                        (button) => SizedBox(
                          width: (constraints.maxWidth - 22) / 2,
                          child: button,
                        ),
                      )
                      .toList(),
                )
              : Row(
                  children: [
                    for (var i = 0; i < buttons.length; i++) ...[
                      if (i > 0) const SizedBox(width: AppSpacing.sm),
                      Expanded(child: buttons[i]),
                    ],
                  ],
                ),
        );
      },
    );
  }
}
