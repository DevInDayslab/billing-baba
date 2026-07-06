import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/purchases/models/purchase_bill_form_model.dart';
import 'package:billing_baba/features/purchases/models/purchase_fa_form_model.dart';
import 'package:billing_baba/features/purchases/providers/add_purchase_fa_form_provider.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_form_model.dart';
import 'package:billing_baba/features/sales/presentation/widgets/item_name_autocomplete_field.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_dropdown_options.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_field_decoration.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_generic_select_dropdown.dart';
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
const _assetFlex = 2;
const _descriptionFlex = 2;

const _minLineItemsTableWidth = 940.0;

class PurchaseFaLineItemsTable extends ConsumerWidget {
  const PurchaseFaLineItemsTable({
    this.embedded = false,
    this.batchId,
    super.key,
  });

  final bool embedded;
  final String? batchId;

  static final _amountFormat = NumberFormat('#,##0.00', 'en_IN');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(addPurchaseFaFormProvider(batchId: batchId));
    final notifier =
        ref.read(addPurchaseFaFormProvider(batchId: batchId).notifier);

    final tableContent = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final tableColumn = Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _LineItemsHeader(),
                const Divider(height: 1, color: _cardBorder),
                for (var i = 0; i < form.items.length; i++) ...[
                  if (i > 0) const Divider(height: 1, color: _cardBorder),
                  _LineItemRow(
                    index: i,
                    item: form.items[i],
                    batchId: batchId,
                  ),
                ],
                if (form.lineItemsHasError)
                  const Padding(
                    padding: EdgeInsets.fromLTRB(12, 4, 12, 0),
                    child: Text(
                      'Add at least one asset with name and quantity',
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
                  showTaxTotals: form.items.any(
                    (item) => item.priceIsTaxInclusive,
                  ),
                ),
                const Divider(height: 1, color: _cardBorder),
                _PaymentSummaryRow(
                  grandTotal: form.grandTotal,
                  paidAmount: form.paymentAmount,
                  balanceAmount: form.balanceAmount,
                  onPaidChanged: notifier.updatePaymentAmount,
                ),
              ],
            );

            if (constraints.maxWidth < _minLineItemsTableWidth) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: _minLineItemsTableWidth,
                  child: tableColumn,
                ),
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

    if (embedded) return tableContent;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: _cardBorder),
        borderRadius: AppRadius.lgBorder,
      ),
      child: tableContent,
    );
  }
}

class _LineItemsTableRow extends StatelessWidget {
  const _LineItemsTableRow({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    assert(
      children.length == 9,
      'Purchase FA line items table row must have 9 children',
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: _rowHorizontalPadding),
      child: Row(
        children: [
          SizedBox(width: _indexColWidth, child: children[0]),
          const SizedBox(width: _colGap),
          SizedBox(width: _deleteColWidth, child: children[1]),
          const SizedBox(width: _colGap),
          Expanded(flex: _assetFlex, child: children[2]),
          const SizedBox(width: _colGap),
          Expanded(flex: _descriptionFlex, child: children[3]),
          const SizedBox(width: _colGap),
          SizedBox(width: _qtyColWidth, child: children[4]),
          const SizedBox(width: _colGap),
          SizedBox(
            width: _priceColWidth + _priceTaxModeWidth + 2,
            child: children[5],
          ),
          const SizedBox(width: _colGap),
          SizedBox(width: _taxPercentColWidth, child: children[6]),
          const SizedBox(width: _colGap),
          SizedBox(width: _taxAmtColWidth, child: children[7]),
          const SizedBox(width: _colGap),
          SizedBox(width: _amountColWidth, child: children[8]),
        ],
      ),
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
      child: const _LineItemsTableRow(
        children: [
          Text('#', style: _headerStyle),
          SizedBox.shrink(),
          Text('ASSETS', style: _headerStyle),
          Text('DESCRIPTION', style: _headerStyle),
          Text('QTY', style: _headerStyle),
          Text(
            'PRICE/UNIT',
            style: _headerStyle,
            overflow: TextOverflow.ellipsis,
          ),
          Text('TAX %', style: _headerStyle, overflow: TextOverflow.ellipsis),
          Text(
            'TAX AMT',
            style: _headerStyle,
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            'AMOUNT',
            style: _headerStyle,
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
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

class _TotalsRow extends StatelessWidget {
  const _TotalsRow({
    required this.totalQty,
    required this.totalTax,
    required this.showTaxTotals,
  });

  final double totalQty;
  final double totalTax;
  final bool showTaxTotals;

  static const _valueStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _headerBackground,
      height: _rowHeight,
      child: _LineItemsTableRow(
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
            softWrap: false,
            overflow: TextOverflow.visible,
          ),
          const SizedBox.shrink(),
          Text(
            totalQty == 0 ? '0' : totalQty.toString(),
            style: _valueStyle,
          ),
          const SizedBox.shrink(),
          const SizedBox.shrink(),
          Text(
            showTaxTotals
                ? PurchaseFaLineItemsTable._amountFormat.format(totalTax)
                : '',
            textAlign: TextAlign.right,
            style: _valueStyle,
          ),
          const SizedBox.shrink(),
        ],
      ),
    );
  }
}

class _PaymentSummaryRow extends StatefulWidget {
  const _PaymentSummaryRow({
    required this.grandTotal,
    required this.paidAmount,
    required this.balanceAmount,
    required this.onPaidChanged,
  });

  final double grandTotal;
  final double paidAmount;
  final double balanceAmount;
  final ValueChanged<double> onPaidChanged;

  @override
  State<_PaymentSummaryRow> createState() => _PaymentSummaryRowState();
}

class _PaymentSummaryRowState extends State<_PaymentSummaryRow> {
  late final TextEditingController _paidController;

  @override
  void initState() {
    super.initState();
    _paidController = TextEditingController(
      text: widget.paidAmount == 0 ? '0' : widget.paidAmount.toString(),
    );
  }

  @override
  void didUpdateWidget(_PaymentSummaryRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newText = widget.paidAmount == 0 ? '0' : widget.paidAmount.toString();
    if (widget.paidAmount != oldWidget.paidAmount &&
        newText != _paidController.text) {
      _paidController.text = newText;
    }
  }

  @override
  void dispose() {
    _paidController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _headerBackground,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          const Spacer(),
          _SummaryCell(
            label: 'Total',
            value: PurchaseFaLineItemsTable._amountFormat.format(
              widget.grandTotal,
            ),
            emphasized: true,
          ),
          const SizedBox(width: 16),
          _SummaryCell(
            label: 'Paid',
            child: SizedBox(
              width: 88,
              child: TextField(
                controller: _paidController,
                style: saleFieldTextStyle.copyWith(fontSize: 13),
                decoration: buildSaleFieldDecoration(compact: true),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
                onChanged: (text) =>
                    widget.onPaidChanged(double.tryParse(text) ?? 0),
              ),
            ),
          ),
          const SizedBox(width: 16),
          _SummaryCell(
            label: 'Balance',
            value: PurchaseFaLineItemsTable._amountFormat.format(
              widget.balanceAmount,
            ),
            emphasized: true,
          ),
        ],
      ),
    );
  }
}

class _SummaryCell extends StatelessWidget {
  const _SummaryCell({
    required this.label,
    this.value,
    this.child,
    this.emphasized = false,
  });

  final String label;
  final String? value;
  final Widget? child;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        child ??
            Text(
              value ?? '',
              style: TextStyle(
                fontSize: emphasized ? 14 : 13,
                fontWeight: emphasized ? FontWeight.w700 : FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
      ],
    );
  }
}

class _LineItemRow extends ConsumerWidget {
  const _LineItemRow({
    required this.index,
    required this.item,
    this.batchId,
  });

  final int index;
  final FixedAssetLineItem item;
  final String? batchId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier =
        ref.read(addPurchaseFaFormProvider(batchId: batchId).notifier);

    return SizedBox(
      height: _rowHeight,
      child: _LineItemsTableRow(
        children: [
          Text(
            '${index + 1}',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
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
          ItemNameAutocompleteField(
            value: item.assetName,
            onChanged: (value) => notifier.updateLineItem(
              index,
              item.copyWith(assetName: value),
            ),
            onItemSelected: (catalogItem) => notifier.updateLineItem(
              index,
              item.copyWith(
                assetName: catalogItem.name,
                pricePerUnit: catalogItem.purchasePrice,
              ),
            ),
          ),
          _CompactTextField(
            initialValue: item.description,
            hintText: 'Description',
            onChanged: (value) => notifier.updateLineItem(
              index,
              item.copyWith(description: value),
            ),
          ),
          _CompactNumberField(
            initialValue: item.qty == 0 ? '' : item.qty.toString(),
            hintText: '0',
            onChanged: (value) => notifier.updateLineItem(
              index,
              item.copyWith(qty: double.tryParse(value) ?? 0),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: _CompactNumberField(
                  initialValue: item.pricePerUnit == 0
                      ? ''
                      : item.pricePerUnit.toString(),
                  hintText: '0',
                  onChanged: (value) => notifier.updateLineItem(
                    index,
                    item.copyWith(
                      pricePerUnit: double.tryParse(value) ?? 0,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 2),
              SizedBox(
                width: _priceTaxModeWidth,
                child: SaleGenericSelectDropdown(
                  value: item.priceIsTaxInclusive ? 'With Tax' : 'Without Tax',
                  options: purchasePriceTaxModes,
                  hintText: '',
                  highlight: SaleDropdownHighlight.red,
                  compact: true,
                  minMenuWidth: 132,
                  onSelected: (value) {
                    final withTax = value == 'With Tax';
                    notifier.updateLineItem(
                      index,
                      item.copyWith(
                        priceIsTaxInclusive: withTax,
                        taxPercent: withTax ? item.taxPercent : 0,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          _TaxPercentCell(
            enabled: item.priceIsTaxInclusive,
            taxPercent: item.taxPercent,
            onSelected: (value) => notifier.updateLineItem(
              index,
              item.copyWith(taxPercent: saleTaxSlabs[value] ?? 0),
            ),
          ),
          Text(
            item.priceIsTaxInclusive
                ? PurchaseFaLineItemsTable._amountFormat.format(item.lineTax)
                : '',
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 12,
              color: item.priceIsTaxInclusive
                  ? AppColors.textPrimary
                  : AppColors.textSecondary,
            ),
          ),
          Text(
            PurchaseFaLineItemsTable._amountFormat.format(item.amount),
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _TaxPercentCell extends StatelessWidget {
  const _TaxPercentCell({
    required this.enabled,
    required this.taxPercent,
    required this.onSelected,
  });

  final bool enabled;
  final double taxPercent;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !enabled,
      child: Opacity(
        opacity: enabled ? 1 : 0.45,
        child: SaleGenericSelectDropdown(
          value: enabled ? taxLabelForPurchaseFaPercent(taxPercent) : '',
          options: SaleDropdownOptions.taxSlabs,
          hintText: 'TAX',
          highlight: SaleDropdownHighlight.red,
          compact: true,
          minMenuWidth: 88,
          onSelected: onSelected,
        ),
      ),
    );
  }
}

class _CompactTextField extends StatefulWidget {
  const _CompactTextField({
    required this.initialValue,
    required this.onChanged,
    this.hintText,
  });

  final String initialValue;
  final ValueChanged<String> onChanged;
  final String? hintText;

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
      style: saleFieldTextStyle.copyWith(fontSize: 13),
      decoration: buildSaleFieldDecoration(
        hint: widget.hintText,
        compact: true,
      ),
      onChanged: widget.onChanged,
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
