import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/presentation/providers/barcode_import_provider.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/barcode_items_grid.dart';
import 'package:flutter/material.dart';

const _kCategories = [
  'Grocery',
  'Dairy',
  'Beverages',
  'Personal Care',
  'Household',
  'Electronics',
  'Clothing',
  'Stationery',
  'Medicine',
  'Other',
];

const _kTaxOptions = ['0', '0.25', '3', '5', '12', '18', '28'];

const _kBaseUnits = [
  'Pieces',
  'Grams',
  'Kilograms',
  'Millilitres',
  'Litres',
  'Metres',
  'Box',
  'Dozen',
  'Pack',
];

/// Single data row in the barcode import spreadsheet grid.
class BarcodeGridRow extends StatelessWidget {
  const BarcodeGridRow({
    required this.row,
    required this.rowNumber,
    required this.isActive,
    required this.columnWidths,
    this.onFieldChanged,
    this.onSetManualEntry,
    this.onDelete,
    super.key,
  });

  final BarcodeImportRow row;
  final int rowNumber;
  final bool isActive;
  final BarcodeGridColumnWidths columnWidths;
  final void Function(int rowIndex, String field, String value)? onFieldChanged;
  final void Function(int rowIndex)? onSetManualEntry;
  final VoidCallback? onDelete;

  static const _indexStyle = TextStyle(
    fontFamily: AppTypography.fontFamily,
    fontSize: AppTypography.bodySmallSize,
    color: AppColors.textSecondary,
  );

  static const _placeholderStyle = TextStyle(
    fontFamily: AppTypography.fontFamily,
    fontSize: AppTypography.bodySmallSize,
    color: BarcodeGridLayout.placeholderColor,
  );

  static const _cellTextStyle = TextStyle(
    fontFamily: AppTypography.fontFamily,
    fontSize: AppTypography.bodySmallSize,
    color: AppColors.textPrimary,
  );

  static const _greyedTextStyle = TextStyle(
    fontFamily: AppTypography.fontFamily,
    fontSize: AppTypography.bodySmallSize,
    color: BarcodeGridLayout.placeholderColor,
  );

  static const _fieldDecoration = InputDecoration(
    isDense: true,
    contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 8),
    border: InputBorder.none,
    enabledBorder: InputBorder.none,
    focusedBorder: InputBorder.none,
  );

  bool get _isEditableRow =>
      row.status == BarcodeRowStatus.found ||
      row.status == BarcodeRowStatus.manualEntry;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: isActive ? BarcodeGridLayout.activeRowBackground : Colors.white,
        border: Border(
          left: BorderSide(
            color: isActive
                ? BarcodeGridLayout.activeRowBorderColor
                : Colors.transparent,
            width: 3,
          ),
          bottom: const BorderSide(color: BarcodeGridLayout.gridBorderColor),
        ),
      ),
      child: SizedBox(
        height: BarcodeGridLayout.rowHeight,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            BarcodeGridCell(
              width: columnWidths.index,
              alignment: Alignment.center,
              padding: EdgeInsets.zero,
              child: _IndexCell(
                rowNumber: rowNumber,
                onDelete: onDelete,
              ),
            ),
            BarcodeGridCell(
              width: columnWidths.itemCode,
              child: _buildItemCodeCell(),
            ),
            BarcodeGridCell(
              width: columnWidths.itemName,
              child: _buildItemNameCell(),
            ),
            BarcodeGridCell(
              width: columnWidths.category,
              child: _buildCategoryCell(),
            ),
            BarcodeGridCell(
              width: columnWidths.hsnCode,
              child: _buildEditableDataCell('hsnCode', row.hsnCode),
            ),
            BarcodeGridCell(
              width: columnWidths.defaultMrp,
              child: _buildEditableDataCell('defaultMrp', row.defaultMrp),
            ),
            BarcodeGridCell(
              width: columnWidths.salePrice,
              child: _buildEditableDataCell('salePrice', row.salePrice),
            ),
            BarcodeGridCell(
              width: columnWidths.incTax,
              alignment: Alignment.center,
              child: _buildIncTaxCell(),
            ),
            BarcodeGridCell(
              width: columnWidths.taxPercent,
              child: _buildTaxCell(),
            ),
            SizedBox(
              width: columnWidths.baseUnit,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: _buildBaseUnitCell(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemCodeCell() {
    return switch (row.status) {
      BarcodeRowStatus.loading => const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
      BarcodeRowStatus.found => Text(
        row.barcode,
        style: _cellTextStyle,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
      BarcodeRowStatus.notFound => Row(
        children: [
          Expanded(
            child: Text(
              row.barcode,
              style: _greyedTextStyle,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          TextButton(
            onPressed: () => onSetManualEntry?.call(row.index),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'Assign Code',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      BarcodeRowStatus.manualEntry => _ManualEntryField(
        fieldKey: '${row.index}_barcode',
        value: row.barcode,
        onChanged: (value) => onFieldChanged?.call(row.index, 'barcode', value),
      ),
      BarcodeRowStatus.empty when isActive =>
        row.barcode.isNotEmpty
            ? Text(
                row.barcode,
                style: _cellTextStyle,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              )
            : _buildBarcodePlaceholder(),
      BarcodeRowStatus.empty => const SizedBox.shrink(),
    };
  }

  Widget _buildItemNameCell() {
    return switch (row.status) {
      BarcodeRowStatus.notFound => const SizedBox.shrink(),
      BarcodeRowStatus.found => Text(
        row.itemName,
        style: _cellTextStyle,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
      BarcodeRowStatus.manualEntry => _ManualEntryField(
        fieldKey: '${row.index}_itemName',
        value: row.itemName,
        onChanged: (value) => onFieldChanged?.call(row.index, 'itemName', value),
      ),
      BarcodeRowStatus.empty when isActive => const Text(
        'E.g. India Gate Basmati Rice, 10kg',
        style: _placeholderStyle,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
      _ => const SizedBox.shrink(),
    };
  }

  Widget _buildCategoryCell() {
    if (!_isEditableRow) return const SizedBox.shrink();
    return _CategoryAutocompleteCell(
      fieldKey: '${row.index}_category',
      value: row.category,
      onChanged: (value) => onFieldChanged?.call(row.index, 'category', value),
    );
  }

  Widget _buildTaxCell() {
    if (!_isEditableRow) return const SizedBox.shrink();
    return _TaxDropdownCell(
      value: row.taxPercent,
      onChanged: (value) => onFieldChanged?.call(row.index, 'taxPercent', value),
    );
  }

  Widget _buildBaseUnitCell() {
    if (!_isEditableRow) return const SizedBox.shrink();
    return _BaseUnitDropdownCell(
      value: row.baseUnit,
      onChanged: (value) => onFieldChanged?.call(row.index, 'baseUnit', value),
    );
  }

  Widget _buildEditableDataCell(String field, String value) {
    if (row.status == BarcodeRowStatus.manualEntry ||
        row.status == BarcodeRowStatus.found) {
      return _ManualEntryField(
        fieldKey: '${row.index}_$field',
        value: value,
        onChanged: (text) => onFieldChanged?.call(row.index, field, text),
      );
    }
    return _buildDataCell(field, value);
  }

  Widget _buildDataCell(String field, String value) {
    if (row.status == BarcodeRowStatus.manualEntry) {
      return _ManualEntryField(
        fieldKey: '${row.index}_$field',
        value: value,
        onChanged: (text) => onFieldChanged?.call(row.index, field, text),
      );
    }
    if (row.status == BarcodeRowStatus.found && value.isNotEmpty) {
      return Text(
        value,
        style: _cellTextStyle,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildIncTaxCell() {
    return switch (row.status) {
      BarcodeRowStatus.found ||
      BarcodeRowStatus.notFound ||
      BarcodeRowStatus.manualEntry => Checkbox(
        value: row.incTax,
        onChanged: (checked) => onFieldChanged?.call(
          row.index,
          'incTax',
          (checked ?? false).toString(),
        ),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      ),
      BarcodeRowStatus.empty || BarcodeRowStatus.loading => const SizedBox.shrink(),
    };
  }

  Widget _buildBarcodePlaceholder() {
    return const Row(
      children: [
        Icon(
          Icons.qr_code_scanner_outlined,
          size: 16,
          color: BarcodeGridLayout.placeholderColor,
        ),
        SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            'Enter Barcode',
            style: _placeholderStyle,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }
}

class _CategoryAutocompleteCell extends StatefulWidget {
  const _CategoryAutocompleteCell({
    required this.fieldKey,
    required this.value,
    required this.onChanged,
  });

  final String fieldKey;
  final String value;
  final ValueChanged<String> onChanged;

  @override
  State<_CategoryAutocompleteCell> createState() =>
      _CategoryAutocompleteCellState();
}

class _CategoryAutocompleteCellState extends State<_CategoryAutocompleteCell> {
  TextEditingController? _textController;

  @override
  void didUpdateWidget(covariant _CategoryAutocompleteCell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value &&
        _textController != null &&
        _textController!.text != widget.value) {
      _textController!.text = widget.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Autocomplete<String>(
      key: ValueKey(widget.fieldKey),
      optionsBuilder: (textEditingValue) {
        final query = textEditingValue.text.trim().toLowerCase();
        if (query.isEmpty) return _kCategories;
        return _kCategories.where(
          (category) => category.toLowerCase().contains(query),
        );
      },
      onSelected: widget.onChanged,
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        _textController = controller;
        if (controller.text.isEmpty && widget.value.isNotEmpty) {
          controller.text = widget.value;
        }
        return TextField(
          controller: controller,
          focusNode: focusNode,
          style: BarcodeGridRow._cellTextStyle,
          decoration: BarcodeGridRow._fieldDecoration,
          onChanged: widget.onChanged,
        );
      },
    );
  }
}

class _TaxDropdownCell extends StatelessWidget {
  const _TaxDropdownCell({
    required this.value,
    required this.onChanged,
  });

  final String value;
  final ValueChanged<String> onChanged;

  static String _normalizeTax(String raw) => raw.replaceAll('%', '').trim();

  static String? _canonicalTax(String raw) {
    final normalized = _normalizeTax(raw);
    if (normalized.isEmpty) return null;
    if (_kTaxOptions.contains(normalized)) return normalized;
    return normalized;
  }

  List<String> get _options {
    final canonical = _canonicalTax(value);
    if (canonical != null && !_kTaxOptions.contains(canonical)) {
      return [..._kTaxOptions, canonical];
    }
    return _kTaxOptions;
  }

  @override
  Widget build(BuildContext context) {
    final selected = _canonicalTax(value);
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        isExpanded: true,
        isDense: true,
        value: selected != null && _options.contains(selected) ? selected : null,
        hint: const SizedBox.shrink(),
        style: BarcodeGridRow._cellTextStyle,
        items: _options
            .map(
              (tax) => DropdownMenuItem<String>(
                value: tax,
                child: Text('$tax%'),
              ),
            )
            .toList(),
        onChanged: (selectedTax) {
          if (selectedTax != null) onChanged(selectedTax);
        },
      ),
    );
  }
}

class _BaseUnitDropdownCell extends StatelessWidget {
  const _BaseUnitDropdownCell({
    required this.value,
    required this.onChanged,
  });

  final String value;
  final ValueChanged<String> onChanged;

  static String? _canonicalUnit(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;
    for (final unit in _kBaseUnits) {
      if (unit.toLowerCase() == trimmed.toLowerCase()) return unit;
    }
    return trimmed;
  }

  List<String> get _options {
    final canonical = _canonicalUnit(value);
    if (canonical != null && !_kBaseUnits.contains(canonical)) {
      return [..._kBaseUnits, canonical];
    }
    return _kBaseUnits;
  }

  @override
  Widget build(BuildContext context) {
    final selected = _canonicalUnit(value);
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        isExpanded: true,
        isDense: true,
        value: selected != null && _options.contains(selected) ? selected : null,
        hint: const SizedBox.shrink(),
        style: BarcodeGridRow._cellTextStyle,
        items: _options
            .map(
              (unit) => DropdownMenuItem<String>(
                value: unit,
                child: Text(unit),
              ),
            )
            .toList(),
        onChanged: (selectedUnit) {
          if (selectedUnit != null) onChanged(selectedUnit);
        },
      ),
    );
  }
}

class _IndexCell extends StatefulWidget {
  const _IndexCell({
    required this.rowNumber,
    this.onDelete,
  });

  final int rowNumber;
  final VoidCallback? onDelete;

  @override
  State<_IndexCell> createState() => _IndexCellState();
}

class _IndexCellState extends State<_IndexCell> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: _isHovered && widget.onDelete != null
          ? IconButton(
              icon: const Icon(
                Icons.delete_outline,
                size: 16,
                color: Colors.red,
              ),
              onPressed: widget.onDelete,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            )
          : Text('${widget.rowNumber}', style: BarcodeGridRow._indexStyle),
    );
  }
}

class _ManualEntryField extends StatefulWidget {
  const _ManualEntryField({
    required this.fieldKey,
    required this.value,
    required this.onChanged,
  });

  final String fieldKey;
  final String value;
  final ValueChanged<String> onChanged;

  @override
  State<_ManualEntryField> createState() => _ManualEntryFieldState();
}

class _ManualEntryFieldState extends State<_ManualEntryField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(covariant _ManualEntryField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value && widget.value != _controller.text) {
      _controller.text = widget.value;
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
      style: BarcodeGridRow._cellTextStyle,
      decoration: BarcodeGridRow._fieldDecoration,
      onChanged: widget.onChanged,
    );
  }
}
