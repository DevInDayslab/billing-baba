import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/sales/models/sale_document_model.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_form_model.dart';
import 'package:billing_baba/features/sales/presentation/widgets/item_name_autocomplete_field.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_dropdown_options.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_field_decoration.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_generic_select_dropdown.dart';
import 'package:billing_baba/features/sales/providers/sale_document_form_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

const _cardBorder = Color(0xFFE0E0E0);
const _headerBackground = Color(0xFFF5F5F5);
const _rowHeight = 48.0;
const _deleteColWidth = 28.0;
const _addRowButtonColor = Color(0xFF1565C0);

/// Line items table for estimate/proforma forms — no discount column.
class SaleDocumentLineItemsTable extends ConsumerWidget {
  const SaleDocumentLineItemsTable({
    required this.documentType,
    super.key,
  });

  final SaleDocumentType documentType;

  static final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(saleDocumentFormProvider(documentType));
    final notifier = ref.read(
      saleDocumentFormProvider(documentType).notifier,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _LineItemsHeader(),
        const Divider(height: 1, color: _cardBorder),
        for (var i = 0; i < form.items.length; i++) ...[
          if (i > 0) const Divider(height: 1, color: _cardBorder),
          _LineItemRow(
            index: i,
            item: form.items[i],
            documentType: documentType,
          ),
        ],
        if (form.lineItemsHasError)
          const Padding(
            padding: EdgeInsets.fromLTRB(12, 4, 12, 0),
            child: Text(
              'Add at least one item with a name',
              style: TextStyle(fontSize: 11, color: saleFieldErrorColor),
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              OutlinedButton(
                onPressed: notifier.addLineItem,
                style: OutlinedButton.styleFrom(
                  foregroundColor: _addRowButtonColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  side: const BorderSide(color: _cardBorder),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: const Text(
                  'ADD ROW',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ),
              const Spacer(),
              Text(
                'Total: ${_currencyFormat.format(form.items.fold<double>(0, (sum, item) => sum + item.amount))}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
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
          SizedBox(width: 24, child: Text('#', style: _headerStyle)),
          SizedBox(width: _deleteColWidth),
          Expanded(flex: 3, child: Text('ITEM', style: _headerStyle)),
          SizedBox(width: 64, child: Text('QTY', style: _headerStyle)),
          SizedBox(width: 72, child: Text('UNIT', style: _headerStyle)),
          SizedBox(width: 88, child: Text('PRICE/UNIT', style: _headerStyle)),
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

class _LineItemRow extends ConsumerWidget {
  const _LineItemRow({
    required this.index,
    required this.item,
    required this.documentType,
  });

  final int index;
  final SaleLineItem item;
  final SaleDocumentType documentType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(
      saleDocumentFormProvider(documentType).notifier,
    );

    return SizedBox(
      height: _rowHeight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            SizedBox(
              width: 24,
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            SizedBox(
              width: _deleteColWidth,
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
            Expanded(
              flex: 3,
              child: ItemNameAutocompleteField(
                value: item.itemName,
                onChanged: (value) => notifier.updateLineItem(
                  index,
                  item.copyWith(itemName: value),
                ),
                onItemSelected: (catalogItem) => notifier.updateLineItem(
                  index,
                  item.copyWith(
                    itemName: catalogItem.name,
                    pricePerUnit: catalogItem.salePrice,
                  ),
                ),
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
                hintText: 'UNIT',
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
              width: 72,
              child: SaleGenericSelectDropdown(
                value: taxLabelForPercent(item.taxPercent),
                options: SaleDropdownOptions.taxSlabs,
                hintText: 'TAX',
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
                SaleDocumentLineItemsTable._currencyFormat.format(item.amount),
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
      style: saleFieldTextStyle.copyWith(fontSize: 13),
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
