import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_form_model.dart';
import 'package:billing_baba/features/sales/presentation/widgets/compact_number_field.dart';
import 'package:billing_baba/features/sales/presentation/widgets/item_name_autocomplete_field.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_dropdown_options.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_field_decoration.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_generic_select_dropdown.dart';
import 'package:billing_baba/features/sales/providers/add_sale_form_provider.dart';
import 'package:billing_baba/features/sales/utils/sale_line_item_catalog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

const _cardBorder = Color(0xFFE0E0E0);
const _headerBackground = Color(0xFFF5F5F5);
const _rowHeight = 48.0;
const _addRowColor = Color(0xFF1565C0);

class SaleLineItemsTable extends ConsumerWidget {
  const SaleLineItemsTable({this.invoiceId, this.embedded = false, super.key});

  final String? invoiceId;
  final bool embedded;

  static final _amountFormat = NumberFormat('#,##0.00', 'en_IN');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(addSaleFormProvider(invoiceId: invoiceId));
    final notifier = ref.read(
      addSaleFormProvider(invoiceId: invoiceId).notifier,
    );

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _LineItemsHeader(),
        const Divider(height: 1, color: _cardBorder),
        for (var i = 0; i < form.items.length; i++) ...[
          if (i > 0) const Divider(height: 1, color: _cardBorder),
          _LineItemRow(
            key: ValueKey(form.items[i].id),
            index: i,
            item: form.items[i],
            invoiceId: invoiceId,
          ),
        ],
        if (form.lineItemsHasError)
          const Padding(
            padding: EdgeInsets.fromLTRB(12, 4, 12, 0),
            child: Text(
              'Add at least one item with name and quantity',
              style: TextStyle(fontSize: 11, color: saleFieldErrorColor),
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: notifier.addLineItem,
              style: TextButton.styleFrom(
                foregroundColor: _addRowColor,
                padding: const EdgeInsets.symmetric(vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                '+ ADD ROW',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ],
    );

    if (embedded) return content;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: _cardBorder),
        borderRadius: AppRadius.lgBorder,
      ),
      child: content,
    );
  }
}

class _LineItemsHeader extends StatelessWidget {
  const _LineItemsHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _headerBackground,
      height: _rowHeight,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: const Row(
        children: [
          SizedBox(width: 28, child: Text('#', style: _headerStyle)),
          Expanded(flex: 3, child: Text('ITEM', style: _headerStyle)),
          SizedBox(width: 64, child: Text('QTY', style: _headerStyle)),
          SizedBox(width: 72, child: Text('UNIT', style: _headerStyle)),
          SizedBox(width: 88, child: Text('PRICE/UNIT', style: _headerStyle)),
          SizedBox(width: 64, child: Text('DISC %', style: _headerStyle)),
          SizedBox(width: 72, child: Text('TAX', style: _headerStyle)),
          SizedBox(
            width: 88,
            child: Text(
              'AMOUNT',
              style: _headerStyle,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  static const _headerStyle = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
  );
}

class _LineItemRow extends ConsumerStatefulWidget {
  const _LineItemRow({
    required this.index,
    required this.item,
    this.invoiceId,
    super.key,
  });

  final int index;
  final SaleLineItem item;
  final String? invoiceId;

  @override
  ConsumerState<_LineItemRow> createState() => _LineItemRowState();
}

class _LineItemRowState extends ConsumerState<_LineItemRow> {
  final _qtyFieldKey = GlobalKey<CompactNumberFieldState>();
  final _qtyFocusNode = FocusNode();

  @override
  void dispose() {
    _qtyFocusNode.dispose();
    super.dispose();
  }

  void _focusQuantityField() {
    _qtyFieldKey.currentState?.requestFocusAndSelectAll();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(
      addSaleFormProvider(invoiceId: widget.invoiceId).notifier,
    );

    return SizedBox(
      height: _rowHeight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            SizedBox(
              width: 28,
              child: Text(
                '${widget.index + 1}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  SizedBox(
                    width: 24,
                    height: 28,
                    child: IconButton(
                      onPressed: () => notifier.removeLineItem(widget.index),
                      icon: const Icon(
                        Icons.delete_outline,
                        size: 16,
                        color: AppColors.error,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      tooltip: 'Delete row',
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: ItemNameAutocompleteField(
                      value: widget.item.itemName,
                      onChanged: (value) => notifier.updateLineItem(
                        widget.index,
                        widget.item.copyWith(itemName: value),
                      ),
                      onItemSelected: (catalogItem) => notifier.updateLineItem(
                        widget.index,
                        applyCatalogItemToLine(widget.item, catalogItem),
                      ),
                      onAfterItemSelected: _focusQuantityField,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            SizedBox(
              width: 64,
              child: CompactNumberField(
                key: _qtyFieldKey,
                value: widget.item.qty,
                hintText: '1',
                focusNode: _qtyFocusNode,
                onChanged: (value) => notifier.updateLineItem(
                  widget.index,
                  widget.item.copyWith(qty: value),
                ),
              ),
            ),
            const SizedBox(width: 4),
            SizedBox(
              width: 72,
              child: SaleGenericSelectDropdown(
                value: widget.item.unit,
                options: SaleDropdownOptions.units,
                hintText: 'UNIT',
                highlight: SaleDropdownHighlight.red,
                compact: true,
                onSelected: (value) => notifier.updateLineItem(
                  widget.index,
                  widget.item.copyWith(unit: value),
                ),
              ),
            ),
            const SizedBox(width: 4),
            SizedBox(
              width: 88,
              child: CompactNumberField(
                key: ValueKey('price_${widget.item.id}'),
                value: widget.item.pricePerUnit,
                hintText: '0',
                onChanged: (value) => notifier.updateLineItem(
                  widget.index,
                  widget.item.copyWith(pricePerUnit: value),
                ),
              ),
            ),
            const SizedBox(width: 4),
            SizedBox(
              width: 64,
              child: CompactNumberField(
                key: ValueKey('disc_${widget.item.id}'),
                value: widget.item.discountPercent,
                hintText: '0',
                onChanged: (value) => notifier.updateLineItem(
                  widget.index,
                  widget.item.copyWith(discountPercent: value),
                ),
              ),
            ),
            const SizedBox(width: 4),
            SizedBox(
              width: 72,
              child: SaleGenericSelectDropdown(
                value: taxLabelForPercent(widget.item.taxPercent),
                options: SaleDropdownOptions.taxSlabs,
                hintText: 'TAX',
                highlight: SaleDropdownHighlight.red,
                compact: true,
                onSelected: (value) => notifier.updateLineItem(
                  widget.index,
                  widget.item.copyWith(taxPercent: saleTaxSlabs[value] ?? 0),
                ),
              ),
            ),
            const SizedBox(width: 4),
            SizedBox(
              width: 88,
              child: Text(
                SaleLineItemsTable._amountFormat.format(widget.item.amount),
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
