import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/purchases/application/debit_note_form_provider.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_form_model.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/item_name_autocomplete_field.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_dropdown_options.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_field_decoration.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_generic_select_dropdown.dart';
import 'package:billing_baba/shared/forms/transaction_form_validation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

const _cardBorder = Color(0xFFE0E0E0);
const _headerBackground = Color(0xFFF5F5F5);
const _rowHeight = 48.0;
const _addRowColor = Color(0xFF1565C0);

class DebitNoteLineItemsTable extends ConsumerWidget {
  const DebitNoteLineItemsTable({this.debitNoteId, super.key});

  final String? debitNoteId;

  static final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  static final _qtyFormat = NumberFormat('#,##0', 'en_IN');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(debitNoteFormProvider(debitNoteId: debitNoteId));
    final notifier = ref.read(
      debitNoteFormProvider(debitNoteId: debitNoteId).notifier,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _LineItemsHeader(debitNoteId: debitNoteId),
        const Divider(height: 1, color: _cardBorder),
        for (var i = 0; i < form.items.length; i++) ...[
          if (i > 0) const Divider(height: 1, color: _cardBorder),
          _LineItemRow(
            index: i,
            item: form.items[i],
            debitNoteId: debitNoteId,
          ),
        ],
        if (form.lineItemsHasError)
          const Padding(
            padding: EdgeInsets.fromLTRB(12, 4, 12, 0),
            child: Text(
              kLineItemsValidationMessage,
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
                'ADD ROW',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
        Container(
          color: _headerBackground,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              const Spacer(),
              const Text(
                'TOTAL',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 24),
              SizedBox(
                width: 64,
                child: Text(
                  _qtyFormat.format(
                    form.items.fold<double>(0, (sum, item) => sum + item.qty),
                  ),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 360),
              SizedBox(
                width: 88,
                child: Text(
                  _currencyFormat.format(form.rawGrandTotal),
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LineItemsHeader extends ConsumerWidget {
  const _LineItemsHeader({this.debitNoteId});

  final String? debitNoteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(
      debitNoteFormProvider(debitNoteId: debitNoteId).notifier,
    );

    return Container(
      color: _headerBackground,
      height: _rowHeight,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          const SizedBox(width: 28, child: Text('#', style: _headerStyle)),
          const Expanded(flex: 3, child: Text('ITEM', style: _headerStyle)),
          const SizedBox(width: 64, child: Text('QTY', style: _headerStyle)),
          const SizedBox(width: 72, child: Text('UNIT', style: _headerStyle)),
          const SizedBox(
            width: 88,
            child: Text('PRICE/UNIT', style: _headerStyle),
          ),
          const SizedBox(
            width: 64,
            child: Text('DISCOUNT', style: _headerStyle),
          ),
          const SizedBox(width: 72, child: Text('TAX', style: _headerStyle)),
          SizedBox(
            width: 88,
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'AMOUNT',
                    style: _headerStyle,
                    textAlign: TextAlign.right,
                  ),
                ),
                IconButton(
                  onPressed: notifier.addLineItem,
                  icon: const Icon(Icons.add, size: 18, color: _addRowColor),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: 'Add row',
                ),
              ],
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

class _LineItemRow extends ConsumerWidget {
  const _LineItemRow({
    required this.index,
    required this.item,
    this.debitNoteId,
  });

  final int index;
  final SaleLineItem item;
  final String? debitNoteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(
      debitNoteFormProvider(debitNoteId: debitNoteId).notifier,
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
                '${index + 1}',
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
                      onPressed: () => notifier.removeLineItem(index),
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
                      value: item.itemName,
                      onChanged: (value) => notifier.updateLineItem(
                        index,
                        item.copyWith(itemName: value),
                      ),
                      onItemSelected: (catalogItem) =>
                          notifier.selectCatalogItem(index, catalogItem),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            SizedBox(
              width: 64,
              child: _CompactNumberField(
                initialValue: item.qty == 0 ? '' : item.qty.toString(),
                hintText: '0',
                onChanged: (value) => notifier.updateLineItem(
                  index,
                  item.copyWith(qty: double.tryParse(value) ?? 0),
                ),
              ),
            ),
            const SizedBox(width: 4),
            SizedBox(
              width: 72,
              child: SaleGenericSelectDropdown(
                value: item.unit,
                options: SaleDropdownOptions.units,
                hintText: 'NONE',
                highlight: SaleDropdownHighlight.red,
                compact: true,
                onSelected: (value) => notifier.updateLineItem(
                  index,
                  item.copyWith(unit: value),
                ),
              ),
            ),
            const SizedBox(width: 4),
            SizedBox(
              width: 88,
              child: _CompactNumberField(
                initialValue: item.pricePerUnit == 0
                    ? ''
                    : item.pricePerUnit.toString(),
                hintText: '0',
                onChanged: (value) => notifier.updateLineItem(
                  index,
                  item.copyWith(pricePerUnit: double.tryParse(value) ?? 0),
                ),
              ),
            ),
            const SizedBox(width: 4),
            SizedBox(
              width: 64,
              child: _CompactNumberField(
                initialValue: item.discountPercent == 0
                    ? ''
                    : item.discountPercent.toString(),
                hintText: '0',
                onChanged: (value) => notifier.updateLineItem(
                  index,
                  item.copyWith(discountPercent: double.tryParse(value) ?? 0),
                ),
              ),
            ),
            const SizedBox(width: 4),
            SizedBox(
              width: 72,
              child: SaleGenericSelectDropdown(
                value: taxLabelForPercent(item.taxPercent),
                options: SaleDropdownOptions.taxSlabs,
                hintText: 'NONE',
                highlight: SaleDropdownHighlight.red,
                compact: true,
                onSelected: (value) => notifier.updateLineItem(
                  index,
                  item.copyWith(taxPercent: saleTaxSlabs[value] ?? 0),
                ),
              ),
            ),
            const SizedBox(width: 4),
            SizedBox(
              width: 88,
              child: Text(
                DebitNoteLineItemsTable._currencyFormat.format(item.amount),
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

class _CompactNumberField extends StatefulWidget {
  const _CompactNumberField({
    required this.initialValue,
    required this.onChanged,
    this.hintText,
  });

  final String initialValue;
  final ValueChanged<String> onChanged;
  final String? hintText;

  @override
  State<_CompactNumberField> createState() => _CompactNumberFieldState();
}

class _CompactNumberFieldState extends State<_CompactNumberField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(_CompactNumberField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue &&
        widget.initialValue != _controller.text) {
      _controller.text = widget.initialValue;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      style: saleFieldTextStyle.copyWith(fontSize: 12),
      decoration: buildSaleFieldDecoration(
        hint: widget.hintText,
        compact: true,
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
      ],
      onChanged: widget.onChanged,
    );
  }
}
