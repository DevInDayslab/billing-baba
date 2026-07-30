import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/purchases/application/add_expense_form_provider.dart';
import 'package:billing_baba/features/purchases/models/expense_form_model.dart';
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
const _rowHorizontalPadding = 12.0;

const _indexColWidth = 28.0;
const _deleteColWidth = 28.0;
const _qtyColWidth = 72.0;
const _priceColWidth = 100.0;
const _priceTaxModeWidth = 92.0;
const _taxPercentColWidth = 72.0;
const _taxAmtColWidth = 88.0;
const _amountColWidth = 96.0;
const _colGap = 6.0;
const _itemFlex = 2;
const _descriptionFlex = 2;

const _minTableWidthNoGst = 720.0;
const _minTableWidthGst = 960.0;

class ExpenseLineItemsTable extends ConsumerWidget {
  const ExpenseLineItemsTable({this.expenseId, super.key});

  final String? expenseId;

  static final _amountFormat = NumberFormat('#,##0.00', 'en_IN');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(addExpenseFormProvider(expenseId: expenseId));
    final notifier = ref.read(
      addExpenseFormProvider(expenseId: expenseId).notifier,
    );
    final minWidth = form.gstEnabled ? _minTableWidthGst : _minTableWidthNoGst;

    final tableContent = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final tableColumn = Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _LineItemsHeader(gstEnabled: form.gstEnabled),
                const Divider(height: 1, color: _cardBorder),
                for (var i = 0; i < form.items.length; i++) ...[
                  if (i > 0) const Divider(height: 1, color: _cardBorder),
                  _LineItemRow(
                    index: i,
                    item: form.items[i],
                    gstEnabled: form.gstEnabled,
                    expenseId: expenseId,
                  ),
                ],
                if (form.lineItemsHasError)
                  const Padding(
                    padding: EdgeInsets.fromLTRB(12, 4, 12, 0),
                    child: Text(
                      kLineItemsValidationMessage,
                      style: TextStyle(
                        fontSize: 11,
                        color: saleFieldErrorColor,
                      ),
                    ),
                  ),
                const Divider(height: 1, color: _cardBorder),
                _TotalsRow(
                  totalQty: form.totalQty,
                  totalTax: form.totalTax,
                  gstEnabled: form.gstEnabled,
                ),
              ],
            );

            if (constraints.maxWidth < minWidth) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(width: minWidth, child: tableColumn),
              );
            }
            return tableColumn;
          },
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
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
      ],
    );

    return tableContent;
  }
}

class _LineItemsTableRow extends StatelessWidget {
  const _LineItemsTableRow({
    required this.gstEnabled,
    required this.children,
  });

  final bool gstEnabled;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: _rowHorizontalPadding),
      child: Row(
        children: [
          SizedBox(width: _indexColWidth, child: children[0]),
          const SizedBox(width: _colGap),
          SizedBox(width: _deleteColWidth, child: children[1]),
          const SizedBox(width: _colGap),
          Expanded(flex: _itemFlex, child: children[2]),
          const SizedBox(width: _colGap),
          Expanded(flex: _descriptionFlex, child: children[3]),
          const SizedBox(width: _colGap),
          SizedBox(width: _qtyColWidth, child: children[4]),
          const SizedBox(width: _colGap),
          SizedBox(
            width: gstEnabled
                ? _priceColWidth + _priceTaxModeWidth + 2
                : _priceColWidth,
            child: children[5],
          ),
          if (gstEnabled) ...[
            const SizedBox(width: _colGap),
            SizedBox(width: _taxPercentColWidth, child: children[6]),
            const SizedBox(width: _colGap),
            SizedBox(width: _taxAmtColWidth, child: children[7]),
          ],
          const SizedBox(width: _colGap),
          SizedBox(width: _amountColWidth, child: children[gstEnabled ? 8 : 6]),
        ],
      ),
    );
  }
}

class _LineItemsHeader extends StatelessWidget {
  const _LineItemsHeader({required this.gstEnabled});

  final bool gstEnabled;

  static const _headerStyle = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _headerBackground,
      height: _rowHeight,
      child: _LineItemsTableRow(
        gstEnabled: gstEnabled,
        children: [
          const Text('#', style: _headerStyle),
          const SizedBox.shrink(),
          const Text('ITEM', style: _headerStyle),
          const Text('DESCRIPTION', style: _headerStyle),
          const Text('QTY', style: _headerStyle),
          const Text(
            'PRICE/UNIT',
            style: _headerStyle,
            overflow: TextOverflow.ellipsis,
          ),
          if (gstEnabled) ...[
            const Text(
              'TAX %',
              style: _headerStyle,
              overflow: TextOverflow.ellipsis,
            ),
            const Text(
              'TAX AMT',
              style: _headerStyle,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const Text(
            'AMOUNT',
            style: _headerStyle,
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _LineItemRow extends ConsumerWidget {
  const _LineItemRow({
    required this.index,
    required this.item,
    required this.gstEnabled,
    this.expenseId,
  });

  final int index;
  final ExpenseLineItem item;
  final bool gstEnabled;
  final String? expenseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(
      addExpenseFormProvider(expenseId: expenseId).notifier,
    );

    return SizedBox(
      height: _rowHeight,
      child: _LineItemsTableRow(
        gstEnabled: gstEnabled,
        children: [
          Text(
            '${index + 1}',
            style: saleFieldTextStyle.copyWith(fontSize: 12),
          ),
          IconButton(
            onPressed: () => notifier.removeLineItem(index),
            icon: const Icon(
              Icons.close,
              size: 16,
              color: AppColors.textSecondary,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
            tooltip: 'Remove row',
          ),
          ItemNameAutocompleteField(
            value: item.itemName,
            onChanged: (value) => notifier.updateLineItem(
              index,
              item.copyWith(itemName: value),
            ),
            onItemSelected: (catalogItem) => notifier.updateLineItem(
              index,
              item.copyWith(
                itemName: catalogItem.name,
                pricePerUnit: catalogItem.purchasePrice,
              ),
            ),
          ),
          _CompactTextField(
            initialValue: item.description,
            hint: 'Description',
            onChanged: (value) => notifier.updateLineItem(
              index,
              item.copyWith(description: value),
            ),
          ),
          _CompactNumberField(
            initialValue: item.qty,
            onChanged: (value) => notifier.updateLineItem(
              index,
              item.copyWith(qty: value),
            ),
          ),
          if (gstEnabled)
            Row(
              children: [
                Expanded(
                  child: _CompactNumberField(
                    initialValue: item.pricePerUnit,
                    onChanged: (value) => notifier.updateLineItem(
                      index,
                      item.copyWith(pricePerUnit: value),
                    ),
                  ),
                ),
                const SizedBox(width: 2),
                SizedBox(
                  width: _priceTaxModeWidth,
                  child: SaleGenericSelectDropdown(
                    value: item.priceIsTaxInclusive
                        ? 'With Tax'
                        : 'Without Tax',
                    options: const ['Without Tax', 'With Tax'],
                    compact: true,
                    onSelected: (value) => notifier.updateLineItem(
                      index,
                      item.copyWith(
                        priceIsTaxInclusive: value == 'With Tax',
                      ),
                    ),
                  ),
                ),
              ],
            )
          else
            _CompactNumberField(
              initialValue: item.pricePerUnit,
              onChanged: (value) => notifier.updateLineItem(
                index,
                item.copyWith(pricePerUnit: value),
              ),
            ),
          if (gstEnabled) ...[
            SaleGenericSelectDropdown(
              value: item.taxPercent == 0
                  ? 'NONE'
                  : '${item.taxPercent.toInt()}%',
              options: SaleDropdownOptions.taxSlabs,
              compact: true,
              onSelected: (value) {
                final percent = value == 'NONE'
                    ? 0.0
                    : double.tryParse(value.replaceAll('%', '')) ?? 0;
                notifier.updateLineItem(
                  index,
                  item.copyWith(taxPercent: percent),
                );
              },
            ),
            Text(
              ExpenseLineItemsTable._amountFormat.format(item.lineTax),
              textAlign: TextAlign.right,
              style: saleFieldTextStyle.copyWith(fontSize: 12),
            ),
          ],
          Text(
            ExpenseLineItemsTable._amountFormat.format(item.amount),
            textAlign: TextAlign.right,
            style: saleFieldTextStyle.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _TotalsRow extends StatelessWidget {
  const _TotalsRow({
    required this.totalQty,
    required this.totalTax,
    required this.gstEnabled,
  });

  final double totalQty;
  final double totalTax;
  final bool gstEnabled;

  @override
  Widget build(BuildContext context) {
    const valueStyle = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    );

    return Container(
      color: _headerBackground,
      height: _rowHeight,
      child: _LineItemsTableRow(
        gstEnabled: gstEnabled,
        children: [
          const SizedBox.shrink(),
          const SizedBox.shrink(),
          const Text(
            'TOTAL',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox.shrink(),
          Text(
            totalQty == 0 ? '0' : totalQty.toString(),
            style: valueStyle,
          ),
          const SizedBox.shrink(),
          if (gstEnabled) ...[
            const SizedBox.shrink(),
            Text(
              ExpenseLineItemsTable._amountFormat.format(totalTax),
              textAlign: TextAlign.right,
              style: valueStyle,
            ),
          ],
          const SizedBox.shrink(),
        ],
      ),
    );
  }
}

class _CompactTextField extends StatefulWidget {
  const _CompactTextField({
    required this.initialValue,
    required this.onChanged,
    this.hint,
  });

  final String initialValue;
  final ValueChanged<String> onChanged;
  final String? hint;

  @override
  State<_CompactTextField> createState() => _CompactTextFieldState();
}

class _CompactTextFieldState extends State<_CompactTextField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(_CompactTextField oldWidget) {
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
      decoration: buildSaleFieldDecoration(hint: widget.hint, compact: true),
      onChanged: widget.onChanged,
    );
  }
}

class _CompactNumberField extends StatefulWidget {
  const _CompactNumberField({
    required this.initialValue,
    required this.onChanged,
  });

  final double initialValue;
  final ValueChanged<double> onChanged;

  @override
  State<_CompactNumberField> createState() => _CompactNumberFieldState();
}

class _CompactNumberFieldState extends State<_CompactNumberField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.initialValue == 0 ? '' : widget.initialValue.toString(),
    );
  }

  @override
  void didUpdateWidget(_CompactNumberField oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newText = widget.initialValue == 0
        ? ''
        : widget.initialValue.toString();
    if (widget.initialValue != oldWidget.initialValue &&
        newText != _controller.text) {
      _controller.text = newText;
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
      decoration: buildSaleFieldDecoration(compact: true),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
      ],
      onChanged: (text) => widget.onChanged(double.tryParse(text) ?? 0),
    );
  }
}
