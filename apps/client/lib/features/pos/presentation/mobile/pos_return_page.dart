import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/pos/application/pos_return_service.dart';
import 'package:billing_baba/features/pos/models/payment_entry.dart';
import 'package:billing_baba/features/pos/models/pos_sale.dart';
import 'package:billing_baba/features/pos/models/pos_sale_line_item.dart';
import 'package:billing_baba/features/pos/models/return_item.dart';
import 'package:billing_baba/features/pos/pos_exceptions.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

final _currencyFormat = NumberFormat.currency(
  locale: 'en_IN',
  symbol: '₹',
  decimalDigits: 2,
);

class MobilePosReturnPage extends ConsumerStatefulWidget {
  const MobilePosReturnPage({
    required this.originalSale,
    super.key,
  });

  final PosSale originalSale;

  @override
  ConsumerState<MobilePosReturnPage> createState() =>
      _MobilePosReturnPageState();
}

class _MobilePosReturnPageState extends ConsumerState<MobilePosReturnPage> {
  late final Map<String, int> _returnQtyByItemId;
  PaymentMode _refundMode = PaymentMode.cash;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _returnQtyByItemId = {
      for (final item in widget.originalSale.items)
        if (item.itemId != null) item.itemId!: 0,
    };
  }

  double get _refundTotal {
    var total = 0.0;
    for (final item in widget.originalSale.items) {
      final itemId = item.itemId;
      if (itemId == null) continue;
      final qty = _returnQtyByItemId[itemId] ?? 0;
      if (qty <= 0) continue;
      final unitPrice =
          item.unitPrice ??
          (item.quantity > 0 ? item.lineTotal / item.quantity : 0);
      total += unitPrice * qty;
    }
    return total;
  }

  List<ReturnItem> _buildReturnItems() {
    final items = <ReturnItem>[];
    for (final item in widget.originalSale.items) {
      final itemId = item.itemId;
      if (itemId == null) continue;
      final qty = _returnQtyByItemId[itemId] ?? 0;
      if (qty <= 0) continue;
      final unitPrice =
          item.unitPrice ??
          (item.quantity > 0 ? item.lineTotal / item.quantity : 0);
      items.add(
        ReturnItem(
          itemId: itemId,
          name: item.name,
          quantity: qty,
          unit: item.unit ?? 'pcs',
          unitPrice: unitPrice.toStringAsFixed(4),
          lineTotal: unitPrice * qty,
        ),
      );
    }
    return items;
  }

  Future<void> _processReturn() async {
    final returnItems = _buildReturnItems();
    if (returnItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least one item to return')),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final service = await ref.read(posReturnServiceProvider.future);
      await service.processReturn(
        originalSale: widget.originalSale,
        returnItems: returnItems,
        refundMode: _refundMode,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Return processed')),
      );
      Navigator.of(context).pop();
    } on PosRepositoryException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message),
          backgroundColor: Colors.red.shade700,
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Return failed: $error')),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sale = widget.originalSale;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: MobileAppBar(
        title: 'Return ${sale.docNumber}',
        showBusinessHeader: false,
        showNotification: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                for (final item in sale.items)
                  if (item.itemId != null)
                    _ReturnItemRow(
                      item: item,
                      returnQty: _returnQtyByItemId[item.itemId!] ?? 0,
                      maxQty: item.quantity,
                      onQtyChanged: (qty) {
                        setState(() {
                          _returnQtyByItemId[item.itemId!] = qty;
                        });
                      },
                    ),
                const SizedBox(height: AppSpacing.md),
                _RefundModeSelector(
                  selected: _refundMode,
                  onChanged: (mode) => setState(() => _refundMode = mode),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(top: BorderSide(color: Color(0xFFE0E0E0))),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Refund',
                          style: AppTypography.inter(
                            fontSize: AppTypography.captionSize,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          _currencyFormat.format(_refundTotal),
                          style: AppTypography.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  FilledButton(
                    onPressed: _isProcessing ? null : _processReturn,
                    child: _isProcessing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Process return'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReturnItemRow extends StatelessWidget {
  const _ReturnItemRow({
    required this.item,
    required this.returnQty,
    required this.maxQty,
    required this.onQtyChanged,
  });

  final PosSaleLineItem item;
  final int returnQty;
  final int maxQty;
  final ValueChanged<int> onQtyChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              item.name,
              style: AppTypography.inter(
                fontSize: AppTypography.bodySize,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Sold: $maxQty',
              style: AppTypography.inter(
                fontSize: AppTypography.captionSize,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                IconButton(
                  onPressed: returnQty > 0
                      ? () => onQtyChanged(returnQty - 1)
                      : null,
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                Text(
                  '$returnQty',
                  style: AppTypography.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  onPressed: returnQty < maxQty
                      ? () => onQtyChanged(returnQty + 1)
                      : null,
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RefundModeSelector extends StatelessWidget {
  const _RefundModeSelector({
    required this.selected,
    required this.onChanged,
  });

  final PaymentMode selected;
  final ValueChanged<PaymentMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Refund mode',
          style: AppTypography.inter(
            fontSize: AppTypography.bodySize,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          children: PaymentMode.values.map((mode) {
            final label = switch (mode) {
              PaymentMode.cash => 'Cash',
              PaymentMode.upi => 'UPI',
              PaymentMode.card => 'Card',
              PaymentMode.bank => 'Bank',
            };
            return ChoiceChip(
              label: Text(label),
              selected: selected == mode,
              onSelected: (_) => onChanged(mode),
            );
          }).toList(),
        ),
      ],
    );
  }
}
