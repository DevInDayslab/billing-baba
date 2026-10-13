import 'dart:math' as math;

import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/models/opening_stock_batch_row.dart';
import 'package:billing_baba/features/inventory/utils/item_batch_tracking_config.dart';
import 'package:billing_baba/features/inventory/utils/item_quantity_input.dart';
import 'package:billing_baba/features/inventory/models/item_vyapar_settings.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_field_decoration.dart';
import 'package:billing_baba/shared/widgets/forms/forms.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

Future<List<OpeningStockBatchRow>?> showAddOpeningStockBatchesDialog(
  BuildContext context, {
  required String itemName,
  required String categoryLabel,
  required ItemVyaparExtension vyapar,
  required List<OpeningStockBatchRow> initialRows,
  required int quantityDecimalPlaces,
}) {
  return showDialog<List<OpeningStockBatchRow>>(
    context: context,
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.lg,
      ),
      child: AddOpeningStockBatchesDialog(
        itemName: itemName,
        categoryLabel: categoryLabel,
        vyapar: vyapar,
        initialRows: initialRows,
        quantityDecimalPlaces: quantityDecimalPlaces,
      ),
    ),
  );
}

class AddOpeningStockBatchesDialog extends StatefulWidget {
  const AddOpeningStockBatchesDialog({
    required this.itemName,
    required this.categoryLabel,
    required this.vyapar,
    required this.initialRows,
    required this.quantityDecimalPlaces,
    super.key,
  });

  final String itemName;
  final String categoryLabel;
  final ItemVyaparExtension vyapar;
  final List<OpeningStockBatchRow> initialRows;
  final int quantityDecimalPlaces;

  @override
  State<AddOpeningStockBatchesDialog> createState() =>
      _AddOpeningStockBatchesDialogState();
}

class _AddOpeningStockBatchesDialogState
    extends State<AddOpeningStockBatchesDialog> {
  late List<OpeningStockBatchRow> _rows;

  List<ItemBatchTrackingColumn> get _columns =>
      widget.vyapar.openingStockBatchColumns();

  @override
  void initState() {
    super.initState();
    _rows = widget.initialRows.isEmpty
        ? [_emptyRow()]
        : List<OpeningStockBatchRow>.from(widget.initialRows);
  }

  OpeningStockBatchRow _emptyRow() =>
      OpeningStockBatchRow(id: _uuid.v4());

  double get _totalQty => OpeningStockBatchRow.totalQty(_rows);

  void _updateRow(int index, OpeningStockBatchRow row) {
    setState(() => _rows[index] = row);
  }

  void _removeRow(int index) {
    setState(() {
      _rows.removeAt(index);
      if (_rows.isEmpty) _rows.add(_emptyRow());
    });
  }

  void _addRow() {
    setState(() => _rows.add(_emptyRow()));
  }

  Future<void> _pickDate({
    required int rowIndex,
    required bool isMfg,
    required String? formatId,
  }) async {
    final row = _rows[rowIndex];
    final initial = isMfg ? row.mfgDate : row.expDate;
    final monthYearOnly = ItemFieldCatalog.batchDateFormatIsMonthYear(formatId);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDatePickerMode: monthYearOnly
          ? DatePickerMode.year
          : DatePickerMode.day,
      helpText: ItemFieldCatalog.resolveBatchDateFormatId(formatId),
    );
    if (picked == null) return;
    final stored = monthYearOnly
        ? DateTime(picked.year, picked.month)
        : DateTime(picked.year, picked.month, picked.day);
    _updateRow(
      rowIndex,
      isMfg
          ? row.copyWith(mfgDate: stored)
          : row.copyWith(expDate: stored),
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final maxWidth = math.min(media.size.width * 0.92, 960.0);
    final maxHeight = media.size.height * 0.85;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: maxWidth.toDouble(),
        maxHeight: maxHeight,
      ),
      child: Material(
        color: AppColors.surface,
        borderRadius: AppRadius.lgBorder,
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Add Stock - Batches',
                      style: AppTypography.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, size: 22),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: _metaBlock('Item Name', widget.itemName),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: _metaBlock('Category', widget.categoryLabel),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _BatchTable(
                  columns: _columns,
                  rows: _rows,
                  quantityDecimalPlaces: widget.quantityDecimalPlaces,
                  onChanged: _updateRow,
                  onRemove: _removeRow,
                  onPickDate: _pickDate,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Row(
                children: [
                  TextButton(
                    onPressed: _addRow,
                    child: const Text('Add row'),
                  ),
                  const Spacer(),
                  Text(
                    'Total ${_formatQty(_totalQty)}',
                    style: AppTypography.inter(
                      fontSize: AppTypography.bodyMediumSize,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 16),
                  FilledButton(
                    onPressed: () {
                      final cleaned = _rows
                          .where((r) => _rowHasData(r))
                          .toList();
                      Navigator.of(context).pop(cleaned);
                    },
                    child: const Text('Save'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _rowHasData(OpeningStockBatchRow row) {
    if (row.openingQty > 0) return true;
    if (row.batchNo.trim().isNotEmpty) return true;
    if (row.modelNo.trim().isNotEmpty) return true;
    if (row.size.trim().isNotEmpty) return true;
    if (row.mfgDate != null || row.expDate != null) return true;
    return false;
  }

  String _formatQty(double value) {
    return ItemQuantityInput.formatDisplay(value, widget.quantityDecimalPlaces);
  }

  Widget _metaBlock(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.inter(
            fontSize: AppTypography.captionSize,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value.isEmpty ? '—' : value,
          style: AppTypography.inter(
            fontSize: AppTypography.bodyMediumSize,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _BatchTable extends StatelessWidget {
  const _BatchTable({
    required this.columns,
    required this.rows,
    required this.quantityDecimalPlaces,
    required this.onChanged,
    required this.onRemove,
    required this.onPickDate,
  });

  final List<ItemBatchTrackingColumn> columns;
  final List<OpeningStockBatchRow> rows;
  final int quantityDecimalPlaces;
  final void Function(int index, OpeningStockBatchRow row) onChanged;
  final void Function(int index) onRemove;
  final Future<void> Function({
    required int rowIndex,
    required bool isMfg,
    required String? formatId,
  }) onPickDate;

  @override
  Widget build(BuildContext context) {
    return Table(
      columnWidths: {
        for (var i = 0; i < columns.length; i++)
          i: const FlexColumnWidth(1.2),
        columns.length: const FixedColumnWidth(44),
      },
      border: TableBorder.all(color: AppColors.divider),
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        TableRow(
          decoration: const BoxDecoration(color: Color(0xFFF5F5F5)),
          children: [
            for (final col in columns)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                child: Text(
                  col.label,
                  style: AppTypography.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            const SizedBox.shrink(),
          ],
        ),
        for (var i = 0; i < rows.length; i++)
          TableRow(
            children: [
              for (final col in columns)
                Padding(
                  padding: const EdgeInsets.all(6),
                  child: _cellForColumn(
                    column: col,
                    row: rows[i],
                    rowIndex: i,
                  ),
                ),
              IconButton(
                onPressed: () => onRemove(i),
                icon: const Icon(Icons.delete_outline, size: 20),
                color: AppColors.textSecondary,
              ),
            ],
          ),
      ],
    );
  }

  Widget _cellForColumn({
    required ItemBatchTrackingColumn column,
    required OpeningStockBatchRow row,
    required int rowIndex,
  }) {
    return switch (column.field) {
      ItemBatchTrackingField.batchNo => _textCell(
        fieldKey: '${row.id}-batchNo',
        value: row.batchNo,
        onChanged: (v) => onChanged(rowIndex, row.copyWith(batchNo: v)),
      ),
      ItemBatchTrackingField.modelNo => _textCell(
        fieldKey: '${row.id}-modelNo',
        value: row.modelNo,
        onChanged: (v) => onChanged(rowIndex, row.copyWith(modelNo: v)),
      ),
      ItemBatchTrackingField.size => _textCell(
        fieldKey: '${row.id}-size',
        value: row.size,
        onChanged: (v) => onChanged(rowIndex, row.copyWith(size: v)),
      ),
      ItemBatchTrackingField.mfgDate => _dateCell(
        value: formatItemBatchDate(row.mfgDate, column.dateFormatId),
        onTap: () => onPickDate(
          rowIndex: rowIndex,
          isMfg: true,
          formatId: column.dateFormatId,
        ),
      ),
      ItemBatchTrackingField.expDate => _dateCell(
        value: formatItemBatchDate(row.expDate, column.dateFormatId),
        onTap: () => onPickDate(
          rowIndex: rowIndex,
          isMfg: false,
          formatId: column.dateFormatId,
        ),
      ),
      ItemBatchTrackingField.openingQty => _qtyCell(
        fieldKey: '${row.id}-qty',
        value: row.openingQty,
        onChanged: (v) => onChanged(rowIndex, row.copyWith(openingQty: v)),
      ),
    };
  }

  Widget _textCell({
    required String value,
    required ValueChanged<String> onChanged,
    required String fieldKey,
  }) {
    return TextFormField(
      key: ValueKey(fieldKey),
      initialValue: value,
      style: saleFieldTextStyle,
      decoration: buildFormControlDecoration(),
      onChanged: onChanged,
    );
  }

  Widget _qtyCell({
    required double value,
    required ValueChanged<double> onChanged,
    required String fieldKey,
  }) {
    final text = value == 0
        ? ''
        : ItemQuantityInput.formatDisplay(value, quantityDecimalPlaces);
    return TextFormField(
      key: ValueKey(fieldKey),
      initialValue: text,
      style: saleFieldTextStyle,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: ItemQuantityInput.formatters(quantityDecimalPlaces),
      decoration: buildFormControlDecoration(),
      onChanged: (v) {
        final parsed = double.tryParse(v) ?? 0;
        onChanged(
          ItemQuantityInput.roundToPlaces(parsed, quantityDecimalPlaces),
        );
      },
    );
  }

  Widget _dateCell({required String value, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: buildFormControlDecoration(
          suffixIcon: const Icon(Icons.calendar_today, size: 16),
        ),
        child: Text(
          value.isEmpty ? ' ' : value,
          style: saleFieldTextStyle,
        ),
      ),
    );
  }
}
