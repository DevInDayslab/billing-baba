import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/pos/application/pos_return_service.dart';
import 'package:billing_baba/features/pos/models/payment_entry.dart';
import 'package:billing_baba/features/pos/models/pos_sale.dart';
import 'package:billing_baba/features/pos/models/pos_sale_line_item.dart';
import 'package:billing_baba/features/pos/models/return_item.dart';
import 'package:billing_baba/features/pos/pos_exceptions.dart';
import 'package:billing_baba/features/pos/presentation/widgets/receipt_view_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

final _currencyFormat = NumberFormat.currency(
  locale: 'en_IN',
  symbol: '₹',
  decimalDigits: 2,
);

/// Page to process a partial or full return against a completed POS sale.
class PosReturnPage extends ConsumerStatefulWidget {
  const PosReturnPage({required this.originalSale, super.key});

  final PosSale originalSale;

  @override
  ConsumerState<PosReturnPage> createState() => _PosReturnPageState();
}

class _PosReturnPageState extends ConsumerState<PosReturnPage> {
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
          item.unitPrice ?? (item.quantity > 0 ? item.lineTotal / item.quantity : 0);
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
          item.unitPrice ?? (item.quantity > 0 ? item.lineTotal / item.quantity : 0);
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
      final returnSale = await service.processReturn(
        originalSale: widget.originalSale,
        returnItems: returnItems,
        refundMode: _refundMode,
      );

      if (!mounted) return;
      await _showReturnReceipt(returnSale);
      if (mounted) {
        Navigator.of(context).pop();
      }
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
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _showReturnReceipt(PosSale returnSale) {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.lg,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: AppSpacing.md),
                child: Text(
                  'Return Receipt',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              ReceiptViewWidget(sale: returnSale),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sale = widget.originalSale;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Return — ${sale.docNumber}'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                for (final item in sale.items)
                  if (item.itemId != null)
                    _ReturnItemRow(
                      item: item,
                      returnQty: _returnQtyByItemId[item.itemId!] ?? 0,
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
            padding: const EdgeInsets.all(AppSpacing.md),
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
                        const Text(
                          'Refund Amount',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          _currencyFormat.format(_refundTotal),
                          style: const TextStyle(
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
                        : const Text('Process Return'),
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
    required this.onQtyChanged,
  });

  final PosSaleLineItem item;
  final int returnQty;
  final ValueChanged<int> onQtyChanged;

  @override
  Widget build(BuildContext context) {
    final unitPrice = item.unitPrice ??
        (item.quantity > 0 ? item.lineTotal / item.quantity : 0);

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Sold: ${item.quantity} · Rate: ${_currencyFormat.format(unitPrice)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: returnQty > 0
                      ? () => onQtyChanged(returnQty - 1)
                      : null,
                ),
                Text(
                  '$returnQty',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: returnQty < item.quantity
                      ? () => onQtyChanged(returnQty + 1)
                      : null,
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Refund Mode',
              style: TextStyle(fontWeight: FontWeight.w600),
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
        ),
      ),
    );
  }
}
