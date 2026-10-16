import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/pos/application/pos_cart_provider.dart';
import 'package:billing_baba/features/pos/models/cart_item.dart';
import 'package:billing_baba/features/pos/presentation/desktop/widgets/pos_item_thumbnail.dart';
import 'package:billing_baba/features/sales/utils/sale_price_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

final _currency = NumberFormat.currency(
  locale: 'en_IN',
  symbol: '₹',
  decimalDigits: 2,
);

const _tintPurple = Color(0xFFF5F0FF);
const _tintPurpleBorder = Color(0xFFE8DEFF);
const _infoBackground = Color(0xFFF5F5F5);

enum _IncrementMode { amount, percent }

class _LineIncrementPreview {
  const _LineIncrementPreview({
    required this.line,
    required this.currentRate,
    required this.proposedRate,
    required this.appliedRate,
    required this.cappedByMrp,
  });

  final CartItem line;
  final double currentRate;
  final double proposedRate;
  final double appliedRate;
  final bool cappedByMrp;
}

class SaleScreenPriceIncrementDialog extends ConsumerStatefulWidget {
  const SaleScreenPriceIncrementDialog({
    required this.cartSessionKey,
    required this.lines,
    super.key,
  });

  final String cartSessionKey;
  final List<CartItem> lines;

  static Future<void> show(
    BuildContext context, {
    required String cartSessionKey,
    required List<CartItem> lines,
  }) {
    return showDialog<void>(
      context: context,
      builder: (context) => SaleScreenPriceIncrementDialog(
        cartSessionKey: cartSessionKey,
        lines: lines,
      ),
    );
  }

  @override
  ConsumerState<SaleScreenPriceIncrementDialog> createState() =>
      _SaleScreenPriceIncrementDialogState();
}

class _SaleScreenPriceIncrementDialogState
    extends ConsumerState<SaleScreenPriceIncrementDialog> {
  _IncrementMode _mode = _IncrementMode.amount;
  final _amountController = TextEditingController(text: '0.00');
  final _percentController = TextEditingController(text: '0');

  @override
  void dispose() {
    _amountController.dispose();
    _percentController.dispose();
    super.dispose();
  }

  double? _amountPerItem() {
    if (_mode != _IncrementMode.amount) return null;
    final total = SalePriceInput.parse(_amountController.text.trim());
    if (total <= 0 || widget.lines.isEmpty) return null;
    return total / widget.lines.length;
  }

  List<_LineIncrementPreview> _buildPreviews() {
    final lines = widget.lines;
    if (lines.isEmpty) return const [];

    if (_mode == _IncrementMode.amount) {
      final perLine = _amountPerItem();
      if (perLine == null) return const [];
      return lines.map((line) {
        final current = line.unitPrice;
        return _previewFor(line, current, current + perLine);
      }).toList();
    }

    final percent = double.tryParse(_percentController.text.trim()) ?? 0;
    if (percent <= 0) return const [];
    return lines.map((line) {
      final current = line.unitPrice;
      return _previewFor(line, current, current * (1 + percent / 100));
    }).toList();
  }

  _LineIncrementPreview _previewFor(
    CartItem line,
    double current,
    double proposed,
  ) {
    final mrp = line.item.mrp;
    var applied = proposed;
    var capped = false;
    if (mrp != null && mrp > 0 && proposed > mrp) {
      applied = mrp;
      capped = true;
    }
    return _LineIncrementPreview(
      line: line,
      currentRate: current,
      proposedRate: proposed,
      appliedRate: applied,
      cappedByMrp: capped,
    );
  }

  bool get _canApply {
    final previews = _buildPreviews();
    return previews.isNotEmpty &&
        previews.any((p) => p.appliedRate > p.currentRate);
  }

  void _apply() {
    final previews = _buildPreviews();
    if (previews.isEmpty) return;

    final notifier =
        ref.read(posCartProvider(sessionKey: widget.cartSessionKey).notifier);
    for (final preview in previews) {
      notifier.updateUnitPrice(preview.line.item.id, preview.appliedRate);
    }
    Navigator.of(context).pop();
  }

  void _showSelectedItems() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Selected items'),
        content: SizedBox(
          width: 360,
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: widget.lines.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final line = widget.lines[index];
              return ListTile(
                leading: PosItemThumbnail(item: line.item, size: 40),
                title: Text(line.item.name),
                subtitle: Text(
                  'Qty ${line.quantity} · ${_currency.format(line.unitPrice)}',
                ),
              );
            },
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

  @override
  Widget build(BuildContext context) {
    final previews = _buildPreviews();
    final perItem = _amountPerItem();
    final count = widget.lines.length;
    final textTheme = Theme.of(context).textTheme;

    final maxDialogHeight = MediaQuery.sizeOf(context).height * 0.88;

    return Dialog(
      alignment: Alignment.center,
      backgroundColor: AppColors.surface,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.lg,
      ),
      shape: RoundedRectangleBorder(borderRadius: AppRadius.lgBorder),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 560,
          maxHeight: maxDialogHeight,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.md,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _tintPurple,
                      borderRadius: AppRadius.mdBorder,
                    ),
                    child: const Icon(
                      LucideIcons.trendingUp,
                      size: 22,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Price increment',
                          style: textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Increase the price for selected items.',
                          style: textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                0,
                AppSpacing.lg,
                AppSpacing.md,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                    _SelectedItemsBar(
                      count: count,
                      lines: widget.lines,
                      onViewItems: _showSelectedItems,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'Increment type',
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Expanded(
                          child: _IncrementTypeCard(
                            label: 'By amount',
                            symbol: '₹',
                            selected: _mode == _IncrementMode.amount,
                            onTap: () => setState(
                              () => _mode = _IncrementMode.amount,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: _IncrementTypeCard(
                            label: 'By percentage',
                            symbol: '%',
                            selected: _mode == _IncrementMode.percent,
                            onTap: () => setState(
                              () => _mode = _IncrementMode.percent,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    if (_mode == _IncrementMode.amount) ...[
                      Text(
                        'Total increase (₹)',
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      TextField(
                        controller: _amountController,
                        keyboardType: SalePriceInput.keyboardType,
                        inputFormatters: SalePriceInput.formatters,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: InputDecoration(
                          prefixText: '₹ ',
                          prefixStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                          hintText: '0.00',
                          filled: true,
                          fillColor: AppColors.surface,
                          border: OutlineInputBorder(
                            borderRadius: AppRadius.mdBorder,
                            borderSide: const BorderSide(
                              color: Color(0xFFE0E0E0),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: AppRadius.mdBorder,
                            borderSide: const BorderSide(
                              color: Color(0xFFE0E0E0),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: AppRadius.mdBorder,
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                              width: 1.5,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.md,
                          ),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'This amount will be added to the current price of '
                        'each selected item.',
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      const _HowItWorksBox(
                        body:
                            'The entered amount will be split equally across '
                            'all selected items (per unit rate).',
                      ),
                    ] else ...[
                      Text(
                        'Increase (%)',
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      TextField(
                        controller: _percentController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d{0,2}'),
                          ),
                        ],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: InputDecoration(
                          suffixText: '%',
                          hintText: '0',
                          filled: true,
                          fillColor: AppColors.surface,
                          border: OutlineInputBorder(
                            borderRadius: AppRadius.mdBorder,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.md,
                          ),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Each selected item’s unit rate will increase by this '
                        'percentage.',
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      const _HowItWorksBox(
                        body:
                            'The percentage is applied to each item’s current '
                            'selling rate. Prices are capped at MRP when set.',
                      ),
                    ],
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'Preview',
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    if (_mode == _IncrementMode.amount)
                      _AmountPreviewCard(
                        perItem: perItem ?? 0,
                        itemCount: count,
                      )
                    else if (previews.isNotEmpty)
                      _PercentPreviewList(previews: previews)
                    else
                      const _PercentPreviewEmpty(),
                    if (previews.any((p) => p.cappedByMrp)) ...[
                      const SizedBox(height: AppSpacing.sm),
                      ...previews.where((p) => p.cappedByMrp).map(
                        (p) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            '${p.line.item.name}: MRP limit — capped at '
                            '${_currency.format(p.appliedRate)}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.error,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _canApply ? _apply : null,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      icon: const Icon(Icons.check, size: 20),
                      label: const Text('Apply'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectedItemsBar extends StatelessWidget {
  const _SelectedItemsBar({
    required this.count,
    required this.lines,
    required this.onViewItems,
  });

  final int count;
  final List<CartItem> lines;
  final VoidCallback onViewItems;

  @override
  Widget build(BuildContext context) {
    final thumbs = lines.take(3).toList();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm + 2,
      ),
      decoration: BoxDecoration(
        color: _tintPurple,
        borderRadius: AppRadius.mdBorder,
        border: Border.all(color: _tintPurpleBorder),
      ),
      child: Row(
        children: [
          const Icon(
            LucideIcons.shoppingCart,
            size: 18,
            color: AppColors.primary,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              '$count selected item${count == 1 ? '' : 's'}',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
          for (final line in thumbs) ...[
            PosItemThumbnail(item: line.item, size: 32),
            const SizedBox(width: 4),
          ],
          TextButton(
            onPressed: onViewItems,
            child: const Text('View items >'),
          ),
        ],
      ),
    );
  }
}

class _IncrementTypeCard extends StatelessWidget {
  const _IncrementTypeCard({
    required this.label,
    required this.symbol,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String symbol;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.mdBorder,
        child: Ink(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: selected ? _tintPurple : AppColors.surface,
            borderRadius: AppRadius.mdBorder,
            border: Border.all(
              color: selected ? AppColors.primary : const Color(0xFFE0E0E0),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Text(
                symbol,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: selected
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: selected
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                  ),
                ),
              ),
              Icon(
                selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
                size: 20,
                color: selected ? AppColors.primary : AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HowItWorksBox extends StatelessWidget {
  const _HowItWorksBox({required this.body});

  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: _infoBackground,
        borderRadius: AppRadius.mdBorder,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline,
            size: 20,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'How it works',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AmountPreviewCard extends StatelessWidget {
  const _AmountPreviewCard({
    required this.perItem,
    required this.itemCount,
  });

  final double perItem;
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: _tintPurple,
        borderRadius: AppRadius.mdBorder,
        border: Border.all(color: _tintPurpleBorder),
      ),
      child: Row(
        children: [
          const Icon(
            LucideIcons.calculator,
            size: 20,
            color: AppColors.primary,
          ),
          const SizedBox(width: AppSpacing.md),
          const Expanded(
            child: Text(
              'Increase per item',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _currency.format(perItem),
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: AppColors.primary,
                ),
              ),
              Text(
                '(split across $itemCount item${itemCount == 1 ? '' : 's'})',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PercentPreviewEmpty extends StatelessWidget {
  const _PercentPreviewEmpty();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: _tintPurple,
        borderRadius: AppRadius.mdBorder,
        border: Border.all(color: _tintPurpleBorder),
      ),
      child: const Row(
        children: [
          Icon(
            LucideIcons.calculator,
            size: 20,
            color: AppColors.primary,
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              'Enter a percentage to see updated rates',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PercentPreviewList extends StatelessWidget {
  const _PercentPreviewList({required this.previews});

  final List<_LineIncrementPreview> previews;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: _tintPurple,
        borderRadius: AppRadius.mdBorder,
        border: Border.all(color: _tintPurpleBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final preview in previews)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      preview.line.item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Text(
                    '${_currency.format(preview.currentRate)} → '
                    '${_currency.format(preview.appliedRate)}',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: preview.cappedByMrp
                          ? AppColors.error
                          : AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
