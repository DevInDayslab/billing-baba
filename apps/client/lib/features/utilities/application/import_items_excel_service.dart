import 'package:billing_baba/features/inventory/application/inventory_error_mapper.dart';
import 'package:billing_baba/features/inventory/application/inventory_service.dart';
import 'package:billing_baba/features/inventory/models/add_item_form_model.dart';
import 'package:billing_baba/features/inventory/models/item_model.dart';
import 'package:billing_baba/features/inventory/models/unit_model.dart';
import 'package:billing_baba/features/utilities/application/import_items_excel_parser.dart';
import 'package:billing_baba/features/utilities/models/import_item_preview_row.dart';
import 'package:uuid/uuid.dart';

abstract final class ImportItemsExcelService {
  static const _uuid = Uuid();

  static List<ImportItemPreviewRow> buildPreviewRows({
    required List<ParsedImportExcelRow> parsedRows,
    required List<InventoryItem> existingItems,
    required List<InventoryUnit> units,
  }) {
    final existingNames = {
      for (final item in existingItems) item.name.trim().toLowerCase(),
    };
    final seenInFile = <String>{};

    return parsedRows.map((row) {
      final normalizedName = row.itemName.toLowerCase();
      final display = _displayValues(row);

      if (row.itemName.isEmpty) {
        return _previewRow(
          row: row,
          display: display,
          status: ImportRowStatus.error,
          issueMessage: 'Item name is required',
        );
      }

      if (seenInFile.contains(normalizedName)) {
        return _previewRow(
          row: row,
          display: display,
          status: ImportRowStatus.duplicate,
          issueMessage: 'Duplicate item name in file',
        );
      }
      seenInFile.add(normalizedName);

      if (existingNames.contains(normalizedName)) {
        return _previewRow(
          row: row,
          display: display,
          status: ImportRowStatus.duplicate,
          issueMessage: 'Item already exists in inventory',
        );
      }

      final itemType = _parseItemType(row.type);
      final defaultUnit = _defaultUnit(units);
      if (defaultUnit == null) {
        return _previewRow(
          row: row,
          display: display,
          status: ImportRowStatus.error,
          issueMessage: 'No units configured. Add a unit first.',
        );
      }

      final salePrice = _parseAmount(row.salePrice);
      final purchasePrice = _parseAmount(row.purchasePrice);
      final openingQty = itemType == ItemType.product
          ? _parseAmount(row.openingQty)
          : 0.0;

      final resolvedUnit = _resolveUnit(row.unit, units);
      final unitForImport = resolvedUnit ?? defaultUnit;

      final form = AddItemFormState(
        itemType: itemType,
        itemName: row.itemName,
        hsn: row.hsnSac,
        baseUnitId: unitForImport.id,
        salePrice: salePrice,
        atPrice: purchasePrice > 0 ? purchasePrice : 0,
        openingQty: openingQty,
      );

      final unitWarning = resolvedUnit == null && row.unit.trim().isNotEmpty
          ? 'Unit "${row.unit.trim().toUpperCase()}" not found — using ${unitForImport.shortName}'
          : null;

      return _previewRow(
        row: row,
        display: display,
        status: ImportRowStatus.valid,
        issueMessage: unitWarning,
        isSelected: true,
        importForm: form,
      );
    }).toList();
  }

  static Future<ImportItemsResult> importRows({
    required InventoryService service,
    required List<InventoryUnit> units,
    required List<ImportItemPreviewRow> rows,
    void Function(int completed, int total)? onProgress,
  }) async {
    final selected = rows.where((row) => row.canImport).toList();
    var successCount = 0;
    var failedCount = 0;
    final errors = <String>[];

    for (var i = 0; i < selected.length; i++) {
      final row = selected[i];
      onProgress?.call(i, selected.length);
      try {
        await service.createItemFromForm(row.importForm!, units);
        successCount++;
      } on Object catch (error) {
        failedCount++;
        errors.add('${row.itemName}: ${InventoryErrorMapper.messageFor(error)}');
      }
    }

    onProgress?.call(selected.length, selected.length);

    return ImportItemsResult(
      successCount: successCount,
      failedCount: failedCount,
      skippedCount: rows.length - selected.length,
      errors: errors,
    );
  }

  static ImportItemPreviewRow _previewRow({
    required ParsedImportExcelRow row,
    required _DisplayValues display,
    required ImportRowStatus status,
    required String? issueMessage,
    bool isSelected = false,
    AddItemFormState? importForm,
  }) {
    return ImportItemPreviewRow(
      id: _uuid.v4(),
      sheetRowNumber: row.sheetRowNumber,
      itemName: row.itemName,
      typeLabel: display.type,
      salePrice: display.salePrice,
      purchasePrice: display.purchasePrice,
      taxRate: display.taxRate,
      unit: display.unit,
      hsnSac: display.hsnSac,
      openingQty: display.openingQty,
      status: status,
      issueMessage: issueMessage,
      isSelected: isSelected,
      importForm: importForm,
    );
  }

  static _DisplayValues _displayValues(ParsedImportExcelRow row) {
    final type = row.type.trim().isEmpty
        ? 'product'
        : row.type.trim().toLowerCase();

    return _DisplayValues(
      type: type,
      salePrice: _formatDisplayAmount(row.salePrice),
      purchasePrice: _formatDisplayAmount(row.purchasePrice),
      taxRate: _formatDisplayAmount(row.taxRate),
      unit: row.unit.trim().isEmpty ? '-' : row.unit.trim().toUpperCase(),
      hsnSac: row.hsnSac.trim().isEmpty ? '-' : row.hsnSac.trim(),
      openingQty: _formatDisplayAmount(row.openingQty),
    );
  }

  static ItemType _parseItemType(String raw) {
    final value = raw.trim().toLowerCase();
    if (value.startsWith('service')) return ItemType.service;
    return ItemType.product;
  }

  static double _parseAmount(String raw) {
    if (raw.trim().isEmpty) return 0;
    return double.tryParse(raw.replaceAll(',', '').trim()) ?? 0;
  }

  static String _formatDisplayAmount(String raw) {
    if (raw.trim().isEmpty) return '-';
    final parsed = _parseAmount(raw);
    if (parsed == 0 && raw.trim() != '0') return raw;
    if (parsed == parsed.roundToDouble()) {
      return parsed.toStringAsFixed(0);
    }
    return parsed.toStringAsFixed(2);
  }

  static InventoryUnit? _resolveUnit(String unitLabel, List<InventoryUnit> units) {
    if (unitLabel.trim().isEmpty) return null;
    final normalized = unitLabel.trim().toLowerCase();

    for (final unit in units) {
      if (unit.shortName.toLowerCase() == normalized ||
          unit.fullName.toLowerCase() == normalized ||
          (unit.symbol?.toLowerCase() == normalized)) {
        return unit;
      }
    }

    for (final alias in _aliasesFor(normalized)) {
      for (final unit in units) {
        final shortName = unit.shortName.toLowerCase();
        final fullName = unit.fullName.toLowerCase();
        if (shortName == alias ||
            fullName == alias ||
            shortName.contains(alias) ||
            fullName.contains(alias)) {
          return unit;
        }
      }
    }

    return null;
  }

  static Iterable<String> _aliasesFor(String normalized) {
    return switch (normalized) {
      'nos' || 'no' || 'number' || 'numbers' => const ['pcs', 'piece', 'pieces'],
      'bag' || 'bags' => const ['bag', 'pcs'],
      'kg' || 'kgs' || 'kilogram' || 'kilograms' => const ['kg', 'kgs'],
      'gm' || 'gms' || 'gram' || 'grams' => const ['gm', 'gms', 'gram'],
      'ltr' || 'ltrs' || 'liter' || 'litre' => const ['ltr', 'liter', 'litre'],
      'box' || 'boxes' => const ['box', 'pcs'],
      'pkt' || 'pack' || 'packet' => const ['pkt', 'pack', 'pcs'],
      _ => const [],
    };
  }

  static InventoryUnit? _defaultUnit(List<InventoryUnit> units) {
    if (units.isEmpty) return null;
    for (final unit in units) {
      if (unit.shortName.toLowerCase() == 'pcs') return unit;
    }
    return units.first;
  }
}

class _DisplayValues {
  const _DisplayValues({
    required this.type,
    required this.salePrice,
    required this.purchasePrice,
    required this.taxRate,
    required this.unit,
    required this.hsnSac,
    required this.openingQty,
  });

  final String type;
  final String salePrice;
  final String purchasePrice;
  final String taxRate;
  final String unit;
  final String hsnSac;
  final String openingQty;
}
