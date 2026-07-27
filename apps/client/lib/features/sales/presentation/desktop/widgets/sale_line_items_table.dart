import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/out_of_stock_dialog.dart';
import 'package:billing_baba/features/sales/application/add_sale_form_provider.dart';
import 'package:billing_baba/features/sales/application/sale_line_item_column_visibility_provider.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_form_model.dart';
import 'package:billing_baba/features/sales/models/sale_line_item_columns.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/compact_number_field.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/item_name_autocomplete_field.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_dropdown_options.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_field_decoration.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_generic_select_dropdown.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_item_serial_no_dialog.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_line_item_column_picker.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_line_items_table_layout.dart';
import 'package:billing_baba/shared/forms/transaction_form_validation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

const Color _addRowColor = AppColors.primary;
const _gridBorderless = true;

/// Full Vyapar-style line items grid for the Add Sale page.
class SaleLineItemsTable extends ConsumerStatefulWidget {
  const SaleLineItemsTable({
    this.sessionKey = 'default',
    this.embedded = false,
    super.key,
  });

  final String sessionKey;
  final bool embedded;

  static final _amountFormat = NumberFormat('#,##0.00', 'en_IN');

  @override
  ConsumerState<SaleLineItemsTable> createState() => _SaleLineItemsTableState();
}

class _SaleLineItemsTableState extends ConsumerState<SaleLineItemsTable> {
  int _activeRowIndex = 0;

  @override
  Widget build(BuildContext context) {
    final form = ref.watch(
      addSaleFormProvider(sessionKey: widget.sessionKey),
    );
    final notifier = ref.read(
      addSaleFormProvider(sessionKey: widget.sessionKey).notifier,
    );
    final columnVisibility = ref.watch(
      saleLineItemColumnVisibilityStateProvider,
    );
    final columnVisibilityNotifier = ref.read(
      saleLineItemColumnVisibilityStateProvider.notifier,
    );
    final items = form.items;

    if (_activeRowIndex >= items.length) {
      _activeRowIndex = items.isEmpty ? 0 : items.length - 1;
    }

    final totalQty = items.fold<double>(0, (sum, item) => sum + item.qty);
    final totalTax = form.totalTax;
    final totalAmount = form.rawGrandTotal;

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final minTableWidth = SaleLineItemTableLayout.minimumVisibleWidth(
              columnVisibility,
            );
            final tableWidth = constraints.maxWidth < minTableWidth
                ? minTableWidth
                : constraints.maxWidth;
            final widths = SaleLineItemTableLayout.columnWidthsFor(
              tableWidth,
              visibility: columnVisibility,
            );

            final grid = DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(
                  color: SaleLineItemTableLayout.gridBorderColor,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _LineItemsHeader(
                    widths: widths,
                    visibility: columnVisibility,
                    onToggleColumn: columnVisibilityNotifier.toggleColumn,
                  ),
                  for (var i = 0; i < items.length; i++)
                    _LineItemRow(
                      index: i,
                      item: items[i],
                      sessionKey: widget.sessionKey,
                      widths: widths,
                      visibility: columnVisibility,
                      isActive: i == _activeRowIndex,
                      onActivate: () => setState(() => _activeRowIndex = i),
                      onConfirm: () {
                        notifier.confirmLineItem(i);
                        setState(() => _activeRowIndex = i + 1);
                      },
                      onRemove: () {
                        notifier.removeLineItem(i);
                        setState(() {
                          final newLength = ref
                              .read(
                                addSaleFormProvider(
                                  sessionKey: widget.sessionKey,
                                ),
                              )
                              .items
                              .length;
                          if (_activeRowIndex >= newLength) {
                            _activeRowIndex = newLength - 1;
                          } else if (_activeRowIndex > i) {
                            _activeRowIndex--;
                          }
                        });
                      },
                      onItemSelected: (catalogItem) => _handleItemSelected(i, catalogItem),
                    ),
                  _TotalsRow(
                    widths: widths,
                    visibility: columnVisibility,
                    totalQty: totalQty,
                    totalTax: totalTax,
                    totalAmount: totalAmount,
                  ),
                ],
              ),
            );

            if (constraints.maxWidth < minTableWidth) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: widths.visibleTotalWithGaps(columnVisibility),
                  child: grid,
                ),
              );
            }

            return grid;
          },
        ),
        if (form.lineItemsHasError)
          const Padding(
            padding: EdgeInsets.fromLTRB(12, 4, 12, 0),
            child: Text(
              kLineItemsValidationMessage,
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
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

  Future<void> _handleItemSelected(
    int index,
    SaleItemOption catalogItem,
  ) async {
    final notifier = ref.read(addSaleFormProvider(sessionKey: widget.sessionKey).notifier);
    
    // Check if item is out of stock
    if (catalogItem.stock == 0) {
      if (!mounted) return;
      
      await showDialog<void>(
        context: context,
        builder: (context) => OutOfStockDialog(
          itemId: catalogItem.id,
          itemName: catalogItem.name,
          onSelectAlternative: (alternative) {
            notifier.selectCatalogItem(
              index,
              SaleItemOption(
                id: alternative.id,
                name: alternative.name,
                salePrice: alternative.salePrice,
                purchasePrice: 0,
                mfgCost: 0,
                stock: alternative.stockQuantity,
              ),
            );
          },
          onContinueAnyway: () {
            notifier.selectCatalogItem(index, catalogItem);
          },
        ),
      );
    } else {
      // Item has stock, proceed normally
      notifier.selectCatalogItem(index, catalogItem);
    }
  }
}

class _LineItemsHeader extends StatelessWidget{
  const _LineItemsHeader({
    required this.widths,
    required this.visibility,
    required this.onToggleColumn,
  });

  final SaleLineItemColumnWidths widths;
  final SaleLineItemColumnVisibility visibility;
  final ValueChanged<SaleLineItemColumn> onToggleColumn;

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
            SaleLineItemOptionalHeaderCell(
              column: SaleLineItemColumn.serialNo,
              visibility: visibility,
              width: widths.serial,
              label: 'SERIAL NO.',
            ),
            SaleLineItemOptionalHeaderCell(
              column: SaleLineItemColumn.description,
              visibility: visibility,
              width: widths.description,
              label: 'DESCRIPTION',
            ),
            SaleLineItemOptionalHeaderCell(
              column: SaleLineItemColumn.batch,
              visibility: visibility,
              width: widths.batch,
              label: 'BATCH NO.',
            ),
            SaleLineItemOptionalHeaderCell(
              column: SaleLineItemColumn.model,
              visibility: visibility,
              width: widths.model,
              label: 'MODEL NO.',
            ),
            SaleLineItemOptionalHeaderCell(
              column: SaleLineItemColumn.expDate,
              visibility: visibility,
              width: widths.expDate,
              label: 'EXP. DATE',
            ),
            SaleLineItemOptionalHeaderCell(
              column: SaleLineItemColumn.mfgDate,
              visibility: visibility,
              width: widths.mfgDate,
              label: 'MFG. DATE',
            ),
            SaleLineItemOptionalHeaderCell(
              column: SaleLineItemColumn.mrp,
              visibility: visibility,
              width: widths.mrp,
              label: 'MRP',
            ),
            SaleLineItemOptionalHeaderCell(
              column: SaleLineItemColumn.size,
              visibility: visibility,
              width: widths.size,
              label: 'SIZE',
            ),
            SaleLineItemGridHeaderCell(label: 'QTY', width: widths.qty),
            SaleLineItemOptionalHeaderCell(
              column: SaleLineItemColumn.unit,
              visibility: visibility,
              width: widths.unit,
              label: 'UNIT',
            ),
            SaleLineItemOptionalHeaderCell(
              column: SaleLineItemColumn.price,
              visibility: visibility,
              width: widths.price,
              label: 'PRICE/UNIT',
            ),
            SaleLineItemOptionalHeaderCell(
              column: SaleLineItemColumn.discount,
              visibility: visibility,
              width: widths.discount,
              label: 'DISCOUNT',
            ),
            SaleLineItemOptionalHeaderCell(
              column: SaleLineItemColumn.taxPercent,
              visibility: visibility,
              width: widths.taxPercent,
              label: 'TAX %',
            ),
            SaleLineItemOptionalHeaderCell(
              column: SaleLineItemColumn.taxAmount,
              visibility: visibility,
              width: widths.taxAmount,
              label: 'TAX AMOUNT',
            ),
            SaleLineItemGridHeaderCell(
              label: 'AMOUNT',
              width: widths.amount,
              alignRight: true,
            ),
            SaleLineItemGridCell(
              width: widths.actions,
              alignment: Alignment.center,
              child: SaleLineItemColumnPickerButton(
                visibility: visibility,
                onToggle: onToggleColumn,
                onMoreSettings: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Invoice column settings coming soon'),
                    ),
                  );
                },
              ),
            ),
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
    required this.onRemove,
    required this.widths,
    required this.visibility,
    required this.onItemSelected,
    this.sessionKey = 'default',
  });

  final int index;
  final SaleLineItem item;
  final bool isActive;
  final VoidCallback onActivate;
  final VoidCallback onConfirm;
  final VoidCallback onRemove;
  final SaleLineItemColumnWidths widths;
  final SaleLineItemColumnVisibility visibility;
  final void Function(SaleItemOption) onItemSelected;
  final String sessionKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(
      addSaleFormProvider(sessionKey: sessionKey).notifier,
    );

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
              bottom: BorderSide(
                color: SaleLineItemTableLayout.gridBorderColor,
              ),
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
                  child: SaleLineItemIndexCell(
                    rowNumber: index + 1,
                    isActive: isActive,
                    onDelete: onRemove,
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
                            onItemSelected: onItemSelected,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SaleLineItemOptionalCell(
                  column: SaleLineItemColumn.serialNo,
                  visibility: visibility,
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
                SaleLineItemOptionalCell(
                  column: SaleLineItemColumn.description,
                  visibility: visibility,
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
                SaleLineItemOptionalCell(
                  column: SaleLineItemColumn.batch,
                  visibility: visibility,
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
                SaleLineItemOptionalCell(
                  column: SaleLineItemColumn.model,
                  visibility: visibility,
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
                SaleLineItemOptionalCell(
                  column: SaleLineItemColumn.expDate,
                  visibility: visibility,
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
                SaleLineItemOptionalCell(
                  column: SaleLineItemColumn.mfgDate,
                  visibility: visibility,
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
                SaleLineItemOptionalCell(
                  column: SaleLineItemColumn.mrp,
                  visibility: visibility,
                  width: widths.mrp,
                  child: CompactNumberField(
                    value: item.mrp,
                    hintText: '0',
                    borderless: _gridBorderless,
                    onChanged: (value) => notifier.updateLineItem(
                      index,
                      item.copyWith(mrp: value),
                    ),
                  ),
                ),
                SaleLineItemOptionalCell(
                  column: SaleLineItemColumn.size,
                  visibility: visibility,
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
                  child: CompactNumberField(
                    value: item.qty,
                    hintText: '0',
                    borderless: _gridBorderless,
                    integerOnly: true,
                    onChanged: (value) => notifier.updateLineItem(
                      index,
                      item.copyWith(qty: value),
                    ),
                  ),
                ),
                SaleLineItemOptionalCell(
                  column: SaleLineItemColumn.unit,
                  visibility: visibility,
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
                SaleLineItemOptionalCell(
                  column: SaleLineItemColumn.price,
                  visibility: visibility,
                  width: widths.price,
                  child: CompactNumberField(
                    value: item.pricePerUnit,
                    hintText: '0',
                    borderless: _gridBorderless,
                    onChanged: (value) => notifier.updateLineItem(
                      index,
                      item.copyWith(
                        pricePerUnit: value,
                        priceManuallyOverridden: true,
                      ),
                    ),
                  ),
                ),
                SaleLineItemOptionalCell(
                  column: SaleLineItemColumn.discount,
                  visibility: visibility,
                  width: widths.discount,
                  child: CompactNumberField(
                    value: item.discountPercent,
                    hintText: '0',
                    borderless: _gridBorderless,
                    onChanged: (value) => notifier.updateLineItem(
                      index,
                      item.copyWith(discountPercent: value),
                    ),
                  ),
                ),
                SaleLineItemOptionalCell(
                  column: SaleLineItemColumn.taxPercent,
                  visibility: visibility,
                  width: widths.taxPercent,
                  child: SaleGenericSelectDropdown(
                    value: taxLabelForPercent(item.taxPercent),
                    options: SaleDropdownOptions.taxSlabs,
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
                SaleLineItemOptionalCell(
                  column: SaleLineItemColumn.taxAmount,
                  visibility: visibility,
                  width: widths.taxAmount,
                  child: Text(
                    SaleLineItemsTable._amountFormat.format(item.lineTax),
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
                    SaleLineItemsTable._amountFormat.format(item.amount),
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
    required this.visibility,
    required this.totalQty,
    required this.totalTax,
    required this.totalAmount,
  });

  final SaleLineItemColumnWidths widths;
  final SaleLineItemColumnVisibility visibility;
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
            SaleLineItemOptionalCell(
              column: SaleLineItemColumn.serialNo,
              visibility: visibility,
              width: widths.serial,
              child: const SizedBox(),
            ),
            SaleLineItemOptionalCell(
              column: SaleLineItemColumn.description,
              visibility: visibility,
              width: widths.description,
              child: const SizedBox(),
            ),
            SaleLineItemOptionalCell(
              column: SaleLineItemColumn.batch,
              visibility: visibility,
              width: widths.batch,
              child: const SizedBox(),
            ),
            SaleLineItemOptionalCell(
              column: SaleLineItemColumn.model,
              visibility: visibility,
              width: widths.model,
              child: const SizedBox(),
            ),
            SaleLineItemOptionalCell(
              column: SaleLineItemColumn.expDate,
              visibility: visibility,
              width: widths.expDate,
              child: const SizedBox(),
            ),
            SaleLineItemOptionalCell(
              column: SaleLineItemColumn.mfgDate,
              visibility: visibility,
              width: widths.mfgDate,
              child: const SizedBox(),
            ),
            SaleLineItemOptionalCell(
              column: SaleLineItemColumn.mrp,
              visibility: visibility,
              width: widths.mrp,
              child: const SizedBox(),
            ),
            SaleLineItemOptionalCell(
              column: SaleLineItemColumn.size,
              visibility: visibility,
              width: widths.size,
              child: const SizedBox(),
            ),
            SaleLineItemGridCell(
              width: widths.qty,
              child: Text(
                totalQty == totalQty.roundToDouble()
                    ? totalQty.toInt().toString()
                    : totalQty.toStringAsFixed(2),
                style: _valueStyle,
              ),
            ),
            SaleLineItemOptionalCell(
              column: SaleLineItemColumn.unit,
              visibility: visibility,
              width: widths.unit,
              child: const SizedBox(),
            ),
            SaleLineItemOptionalCell(
              column: SaleLineItemColumn.price,
              visibility: visibility,
              width: widths.price,
              child: const SizedBox(),
            ),
            SaleLineItemOptionalCell(
              column: SaleLineItemColumn.discount,
              visibility: visibility,
              width: widths.discount,
              child: const SizedBox(),
            ),
            SaleLineItemOptionalCell(
              column: SaleLineItemColumn.taxPercent,
              visibility: visibility,
              width: widths.taxPercent,
              child: const SizedBox(),
            ),
            SaleLineItemOptionalCell(
              column: SaleLineItemColumn.taxAmount,
              visibility: visibility,
              width: widths.taxAmount,
              child: Text(
                SaleLineItemsTable._amountFormat.format(totalTax),
                style: _valueStyle,
              ),
            ),
            SaleLineItemGridCell(
              width: widths.amount,
              alignment: Alignment.centerRight,
              child: Text(
                SaleLineItemsTable._amountFormat.format(totalAmount),
                style: _valueStyle,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SaleLineItemGridCell(
              width: widths.actions,
              child: const SizedBox(),
            ),
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
