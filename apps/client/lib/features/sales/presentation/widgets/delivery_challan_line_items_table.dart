import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_form_model.dart';
import 'package:billing_baba/features/sales/presentation/widgets/item_name_autocomplete_field.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_dropdown_options.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_field_decoration.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_generic_select_dropdown.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_item_serial_no_dialog.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_line_items_table_layout.dart';
import 'package:billing_baba/features/sales/providers/delivery_challan_form_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

const _addRowColor = AppColors.primary;
const _gridBorderless = true;

/// Full Vyapar-style line items grid for delivery challan forms.
class DeliveryChallanLineItemsTable extends ConsumerStatefulWidget {
  const DeliveryChallanLineItemsTable({
    this.embedded = false,
    super.key,
  });

  final bool embedded;

  static final _amountFormat = NumberFormat('#,##0.00', 'en_IN');

  @override
  ConsumerState<DeliveryChallanLineItemsTable> createState() =>
      _DeliveryChallanLineItemsTableState();
}

class _DeliveryChallanLineItemsTableState
    extends ConsumerState<DeliveryChallanLineItemsTable> {
  int _activeRowIndex = 0;

  @override
  Widget build(BuildContext context) {
    final form = ref.watch(deliveryChallanFormProvider);
    final notifier = ref.read(deliveryChallanFormProvider.notifier);
    final items = form.items;
    final lineItemsHasError = form.lineItemsHasError;

    if (_activeRowIndex >= items.length) {
      _activeRowIndex = items.isEmpty ? 0 : items.length - 1;
    }

    final totalQty = items.fold<double>(0, (sum, item) => sum + item.qty);
    final totalTax = items.fold<double>(0, (sum, item) => sum + item.lineTax);
    final totalAmount =
        items.fold<double>(0, (sum, item) => sum + item.amount);

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final widths = SaleLineItemTableLayout.columnWidthsFor(
              constraints.maxWidth,
            );

            return DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(
                  color: SaleLineItemTableLayout.gridBorderColor,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _LineItemsHeader(widths: widths),
                  for (var i = 0; i < items.length; i++)
                    _LineItemRow(
                      index: i,
                      item: items[i],
                      widths: widths,
                      isActive: i == _activeRowIndex,
                      onActivate: () => setState(() => _activeRowIndex = i),
                      onConfirm: () {
                        notifier.confirmLineItem(i);
                        setState(() => _activeRowIndex = i + 1);
                      },
                    ),
                  _TotalsRow(
                    widths: widths,
                    totalQty: totalQty,
                    totalTax: totalTax,
                    totalAmount: totalAmount,
                  ),
                ],
              ),
            );
          },
        ),
        if (lineItemsHasError)
          const Padding(
            padding: EdgeInsets.fromLTRB(12, 4, 12, 0),
            child: Text(
              'Add at least one item with name and quantity',
              style: TextStyle(fontSize: 11, color: saleFieldErrorColor),
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 6, 12, 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton(
              onPressed: () {
                notifier.addLineItem();
                setState(() => _activeRowIndex = items.length);
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: _addRowColor,
                side: const BorderSide(color: _addRowColor),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
      ],
    );

    if (widget.embedded) return content;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: SaleLineItemTableLayout.gridBorderColor),
        borderRadius: AppRadius.lgBorder,
      ),
      child: content,
    );
  }
}

class _LineItemsHeader extends StatelessWidget {
  const _LineItemsHeader({required this.widths});

  final SaleLineItemColumnWidths widths;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: SaleLineItemTableLayout.headerBackground,
        border: Border(
          bottom: BorderSide(color: SaleLineItemTableLayout.gridBorderColor),
        ),
      ),
      child: SizedBox(
        height: SaleLineItemTableLayout.rowHeight,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SaleLineItemGridHeaderCell(
              label: 'ITEM',
              width: widths.index + widths.item,
            ),
            SaleLineItemGridHeaderCell(
              label: 'SERIAL NO.',
              width: widths.serial,
            ),
            SaleLineItemGridHeaderCell(
              label: 'DESCRIPTION',
              width: widths.description,
            ),
            SaleLineItemGridHeaderCell(
              label: 'BATCH NO.',
              width: widths.batch,
            ),
            SaleLineItemGridHeaderCell(
              label: 'MODEL NO.',
              width: widths.model,
            ),
            SaleLineItemGridHeaderCell(
              label: 'EXP. DATE',
              width: widths.expDate,
            ),
            SaleLineItemGridHeaderCell(
              label: 'MFG. DATE',
              width: widths.mfgDate,
            ),
            SaleLineItemGridHeaderCell(label: 'MRP', width: widths.mrp),
            SaleLineItemGridHeaderCell(label: 'SIZE', width: widths.size),
            SaleLineItemGridHeaderCell(label: 'QTY', width: widths.qty),
            SaleLineItemGridHeaderCell(label: 'UNIT', width: widths.unit),
            SaleLineItemGridHeaderCell(
              label: 'PRICE/UNIT',
              width: widths.price,
            ),
            SaleLineItemGridHeaderCell(
              label: 'TAX %',
              width: widths.taxPercent,
            ),
            SaleLineItemGridHeaderCell(
              label: 'TAX AMOUNT',
              width: widths.taxAmount,
            ),
            SaleLineItemGridHeaderCell(
              label: 'AMOUNT',
              width: widths.amount,
              alignRight: true,
            ),
            SaleLineItemGridCell(width: widths.actions, child: const SizedBox()),
          ],
        ),
      ),
    );
  }
}

class _LineItemRow extends ConsumerWidget {
  const _LineItemRow({
    required this.index,
    required this.item,
    required this.isActive,
    required this.onActivate,
    required this.onConfirm,
    required this.widths,
  });

  final int index;
  final SaleLineItem item;
  final bool isActive;
  final VoidCallback onActivate;
  final VoidCallback onConfirm;
  final SaleLineItemColumnWidths widths;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(deliveryChallanFormProvider.notifier);

    Future<void> pickDate({
      required DateTime? current,
      required void Function(DateTime) onSelected,
    }) async {
      final picked = await showDatePicker(
        context: context,
        initialDate: current ?? DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
      );
      if (picked != null) onSelected(picked);
    }

    return Material(
      color: saleLineItemRowBackground(isActive: isActive, isOdd: index.isOdd),
      child: InkWell(
        onTap: onActivate,
        child: DecoratedBox(
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: SaleLineItemTableLayout.gridBorderColor),
            ),
          ),
          child: SizedBox(
            height: SaleLineItemTableLayout.rowHeight,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SaleLineItemGridCell(
                  width: widths.index,
                  alignment: Alignment.center,
                  child: isActive
                      ? const Icon(Icons.bolt, size: 16, color: _addRowColor)
                      : Text(
                          '${index + 1}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                ),
                SaleLineItemGridCell(
                  width: widths.item,
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Barcode scanner coming soon'),
                            ),
                          );
                        },
                        child: const Icon(
                          Icons.qr_code_scanner,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: SaleCompactFieldBox(
                          child: ItemNameAutocompleteField(
                            value: item.itemName,
                            borderless: _gridBorderless,
                            onChanged: (value) => notifier.updateLineItem(
                              index,
                              item.copyWith(itemName: value),
                            ),
                            onItemSelected: (catalogItem) =>
                                notifier.updateLineItem(
                              index,
                              item.copyWith(
                                itemId: catalogItem.id,
                                itemName: catalogItem.name,
                                pricePerUnit: catalogItem.salePrice,
                                unit: catalogItem.unit ?? item.unit,
                                mrp: catalogItem.salePrice,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SaleLineItemGridCell(
                  width: widths.serial,
                  child: _CompactTextField(
                    initialValue: item.serialNo,
                    hintText: 'Serial',
                    borderless: _gridBorderless,
                    onChanged: (value) => notifier.updateLineItem(
                      index,
                      item.copyWith(serialNo: value),
                    ),
                    suffixIcon: IconButton(
                      onPressed: () async {
                        final result = await showSaleItemSerialNoDialog(
                          context,
                          initialSerials: item.serialNo,
                          requiredQty: item.qty,
                        );
                        if (result == null) return;
                        notifier.updateLineItem(
                          index,
                          item.copyWith(serialNo: result),
                        );
                      },
                      icon: const Icon(Icons.list, size: 14),
                      padding: EdgeInsets.zero,
                      style: IconButton.styleFrom(
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      tooltip: 'Serial numbers',
                    ),
                  ),
                ),
                SaleLineItemGridCell(
                  width: widths.description,
                  child: _CompactTextField(
                    initialValue: item.description,
                    hintText: 'Description',
                    borderless: _gridBorderless,
                    onChanged: (value) => notifier.updateLineItem(
                      index,
                      item.copyWith(description: value),
                    ),
                  ),
                ),
                SaleLineItemGridCell(
                  width: widths.batch,
                  child: _CompactTextField(
                    initialValue: item.batchNo,
                    hintText: 'Batch',
                    borderless: _gridBorderless,
                    onChanged: (value) => notifier.updateLineItem(
                      index,
                      item.copyWith(batchNo: value),
                    ),
                  ),
                ),
                SaleLineItemGridCell(
                  width: widths.model,
                  child: _CompactTextField(
                    initialValue: item.modelNo,
                    hintText: 'Model',
                    borderless: _gridBorderless,
                    onChanged: (value) => notifier.updateLineItem(
                      index,
                      item.copyWith(modelNo: value),
                    ),
                  ),
                ),
                SaleLineItemGridCell(
                  width: widths.expDate,
                  child: _CompactDateTrigger(
                    date: item.expDate,
                    borderless: _gridBorderless,
                    onTap: () => pickDate(
                      current: item.expDate,
                      onSelected: (date) => notifier.updateLineItem(
                        index,
                        item.copyWith(expDate: date),
                      ),
                    ),
                  ),
                ),
                SaleLineItemGridCell(
                  width: widths.mfgDate,
                  child: _CompactDateTrigger(
                    date: item.mfgDate,
                    borderless: _gridBorderless,
                    onTap: () => pickDate(
                      current: item.mfgDate,
                      onSelected: (date) => notifier.updateLineItem(
                        index,
                        item.copyWith(mfgDate: date),
                      ),
                    ),
                  ),
                ),
                SaleLineItemGridCell(
                  width: widths.mrp,
                  child: _CompactNumberField(
                    initialValue: item.mrp == 0 ? '' : item.mrp.toString(),
                    hintText: '0',
                    borderless: _gridBorderless,
                    onChanged: (value) => notifier.updateLineItem(
                      index,
                      item.copyWith(mrp: double.tryParse(value) ?? 0),
                    ),
                  ),
                ),
                SaleLineItemGridCell(
                  width: widths.size,
                  child: _CompactTextField(
                    initialValue: item.size,
                    hintText: 'Size',
                    borderless: _gridBorderless,
                    onChanged: (value) => notifier.updateLineItem(
                      index,
                      item.copyWith(size: value),
                    ),
                  ),
                ),
                SaleLineItemGridCell(
                  width: widths.qty,
                  child: _CompactNumberField(
                    initialValue: item.qty == 0 ? '' : item.qty.toString(),
                    hintText: '0',
                    borderless: _gridBorderless,
                    onChanged: (value) => notifier.updateLineItem(
                      index,
                      item.copyWith(qty: double.tryParse(value) ?? 0),
                    ),
                  ),
                ),
                SaleLineItemGridCell(
                  width: widths.unit,
                  child: SaleGenericSelectDropdown(
                    value: item.unit,
                    options: SaleDropdownOptions.units,
                    hintText: 'NOS',
                    highlight: SaleDropdownHighlight.red,
                    compact: true,
                    minMenuWidth: 72,
                    borderless: _gridBorderless,
                    onSelected: (value) => notifier.updateLineItem(
                      index,
                      item.copyWith(unit: value),
                    ),
                  ),
                ),
                SaleLineItemGridCell(
                  width: widths.price,
                  child: _CompactNumberField(
                    initialValue: item.pricePerUnit == 0
                        ? ''
                        : item.pricePerUnit.toString(),
                    hintText: '0',
                    borderless: _gridBorderless,
                    onChanged: (value) => notifier.updateLineItem(
                      index,
                      item.copyWith(
                        pricePerUnit: double.tryParse(value) ?? 0,
                      ),
                    ),
                  ),
                ),
                SaleLineItemGridCell(
                  width: widths.taxPercent,
                  child: SaleGenericSelectDropdown(
                    value: taxLabelForPercent(item.taxPercent),
                    options: SaleDropdownOptions.taxSlabs,
                    hintText: 'Select',
                    highlight: SaleDropdownHighlight.red,
                    compact: true,
                    borderless: _gridBorderless,
                    minMenuWidth: 88,
                    onSelected: (value) => notifier.updateLineItem(
                      index,
                      item.copyWith(taxPercent: saleTaxSlabs[value] ?? 0),
                    ),
                  ),
                ),
                SaleLineItemGridCell(
                  width: widths.taxAmount,
                  child: Text(
                    DeliveryChallanLineItemsTable._amountFormat.format(item.lineTax),
                    style: TextStyle(
                      fontSize: 12,
                      color: item.taxPercent > 0
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SaleLineItemGridCell(
                  width: widths.amount,
                  alignment: Alignment.centerRight,
                  child: Text(
                    DeliveryChallanLineItemsTable._amountFormat.format(item.amount),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SaleLineItemGridCell(
                  width: widths.actions,
                  alignment: Alignment.center,
                  child: isActive
                      ? SaleLineItemConfirmButton(onPressed: onConfirm)
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CompactDateTrigger extends StatelessWidget {
  const _CompactDateTrigger({
    required this.date,
    required this.onTap,
    this.borderless = false,
  });

  final DateTime? date;
  final VoidCallback onTap;
  final bool borderless;

  @override
  Widget build(BuildContext context) {
    return SaleFieldTrigger(
      onTap: onTap,
      compact: true,
      borderless: borderless,
      child: Text(
        date != null
            ? '${date!.day.toString().padLeft(2, '0')}/${date!.month.toString().padLeft(2, '0')}/${date!.year}'
            : '',
        style: saleFieldTextStyle.copyWith(fontSize: 11),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class _TotalsRow extends StatelessWidget {
  const _TotalsRow({
    required this.widths,
    required this.totalQty,
    required this.totalTax,
    required this.totalAmount,
  });

  final SaleLineItemColumnWidths widths;
  final double totalQty;
  final double totalTax;
  final double totalAmount;

  static const _labelStyle = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: AppColors.textSecondary,
  );

  static const _valueStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: SaleLineItemTableLayout.headerBackground,
        border: Border(
          top: BorderSide(color: SaleLineItemTableLayout.gridBorderColor),
          bottom: BorderSide(color: SaleLineItemTableLayout.gridBorderColor),
        ),
      ),
      child: SizedBox(
        height: SaleLineItemTableLayout.rowHeight,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SaleLineItemGridCell(
              width: widths.index + widths.item,
              child: const Text('TOTAL', style: _labelStyle),
            ),
            SaleLineItemGridCell(width: widths.serial, child: const SizedBox()),
            SaleLineItemGridCell(
              width: widths.description,
              child: const SizedBox(),
            ),
            SaleLineItemGridCell(width: widths.batch, child: const SizedBox()),
            SaleLineItemGridCell(width: widths.model, child: const SizedBox()),
            SaleLineItemGridCell(width: widths.expDate, child: const SizedBox()),
            SaleLineItemGridCell(width: widths.mfgDate, child: const SizedBox()),
            SaleLineItemGridCell(width: widths.mrp, child: const SizedBox()),
            SaleLineItemGridCell(width: widths.size, child: const SizedBox()),
            SaleLineItemGridCell(
              width: widths.qty,
              child: Text(
                totalQty == totalQty.roundToDouble()
                    ? totalQty.toInt().toString()
                    : totalQty.toStringAsFixed(2),
                style: _valueStyle,
              ),
            ),
            SaleLineItemGridCell(width: widths.unit, child: const SizedBox()),
            SaleLineItemGridCell(
              width: widths.price,
              child: const SizedBox(),
            ),
            SaleLineItemGridCell(
              width: widths.taxPercent,
              child: const SizedBox(),
            ),
            SaleLineItemGridCell(
              width: widths.taxAmount,
              child: Text(
                DeliveryChallanLineItemsTable._amountFormat.format(totalTax),
                style: _valueStyle,
              ),
            ),
            SaleLineItemGridCell(
              width: widths.amount,
              alignment: Alignment.centerRight,
              child: Text(
                DeliveryChallanLineItemsTable._amountFormat.format(totalAmount),
                style: _valueStyle,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SaleLineItemGridCell(width: widths.actions, child: const SizedBox()),
          ],
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
    this.suffixIcon,
    this.borderless = false,
  });

  final String initialValue;
  final ValueChanged<String> onChanged;
  final String? hintText;
  final Widget? suffixIcon;
  final bool borderless;

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
    return SaleCompactFieldBox(
      child: TextField(
        controller: _controller,
        maxLines: 1,
        style: saleFieldTextStyle.copyWith(fontSize: 12, height: 1),
        textAlignVertical: TextAlignVertical.center,
        decoration: buildSaleFieldDecoration(
          hint: widget.hintText,
          compact: true,
          borderless: widget.borderless,
          suffixIcon: widget.suffixIcon,
        ),
        onChanged: widget.onChanged,
      ),
    );
  }
}

class _CompactNumberField extends StatefulWidget {
  const _CompactNumberField({
    required this.initialValue,
    required this.onChanged,
    this.hintText,
    this.borderless = false,
  });

  final String initialValue;
  final ValueChanged<String> onChanged;
  final String? hintText;
  final bool borderless;

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
    final field = TextField(
      controller: _controller,
      maxLines: 1,
      style: saleFieldTextStyle.copyWith(fontSize: 12, height: 1),
      textAlignVertical: TextAlignVertical.center,
      decoration: buildSaleFieldDecoration(
        hint: widget.hintText,
        compact: true,
        borderless: widget.borderless,
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
      ],
      onChanged: widget.onChanged,
    );

    return SaleCompactFieldBox(child: field);
  }
}
