import 'package:billing_baba/core/network/api_validation_exception.dart';
import 'package:billing_baba/features/inventory/application/inventory_error_mapper.dart';
import 'package:billing_baba/features/inventory/models/unit_model.dart';
import 'package:billing_baba/features/inventory/providers/inventory_items_provider.dart';
import 'package:billing_baba/features/inventory/providers/inventory_units_provider.dart';
import 'package:billing_baba/features/utilities/application/import_items_excel_parser.dart';
import 'package:billing_baba/features/utilities/application/import_items_excel_service.dart';
import 'package:billing_baba/features/utilities/models/import_item_preview_row.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ImportItemsExcelState {
  const ImportItemsExcelState({
    this.fileName,
    this.isParsing = false,
    this.isImporting = false,
    this.rows = const [],
    this.importCompleted = 0,
    this.importTotal = 0,
    this.parseError,
    this.importError,
  });

  final String? fileName;
  final bool isParsing;
  final bool isImporting;
  final List<ImportItemPreviewRow> rows;
  final int importCompleted;
  final int importTotal;
  final String? parseError;
  final String? importError;

  bool get showParseSuccess =>
      !isParsing && rows.isNotEmpty && parseError == null;

  int get validCount =>
      rows.where((row) => row.status == ImportRowStatus.valid).length;

  int get duplicateCount =>
      rows.where((row) => row.status == ImportRowStatus.duplicate).length;

  int get errorCount =>
      rows.where((row) => row.status == ImportRowStatus.error).length;

  int get selectedCount => rows.where((row) => row.canImport).length;

  bool get canImport => selectedCount > 0 && !isImporting && !isParsing;

  ImportItemsExcelState copyWith({
    String? fileName,
    bool? isParsing,
    bool? isImporting,
    List<ImportItemPreviewRow>? rows,
    int? importCompleted,
    int? importTotal,
    String? parseError,
    String? importError,
    bool clearParseError = false,
    bool clearRows = false,
    bool clearImportError = false,
  }) {
    return ImportItemsExcelState(
      fileName: fileName ?? this.fileName,
      isParsing: isParsing ?? this.isParsing,
      isImporting: isImporting ?? this.isImporting,
      rows: clearRows ? const [] : (rows ?? this.rows),
      importCompleted: importCompleted ?? this.importCompleted,
      importTotal: importTotal ?? this.importTotal,
      parseError: clearParseError ? null : (parseError ?? this.parseError),
      importError: clearImportError ? null : (importError ?? this.importError),
    );
  }
}

final importItemsExcelProvider =
    NotifierProvider<ImportItemsExcelNotifier, ImportItemsExcelState>(
      ImportItemsExcelNotifier.new,
    );

class ImportItemsExcelNotifier extends Notifier<ImportItemsExcelState> {
  @override
  ImportItemsExcelState build() => const ImportItemsExcelState();

  void beginParsing(String fileName) {
    state = state.copyWith(
      fileName: fileName,
      isParsing: true,
      clearRows: true,
      clearParseError: true,
      clearImportError: true,
    );
  }

  void cancelParsing({String? error}) {
    state = state.copyWith(
      isParsing: false,
      parseError: error,
    );
  }

  Future<void> parseBytes(List<int> bytes) async {
    if (!state.isParsing) {
      state = state.copyWith(isParsing: true, clearParseError: true);
    }

    try {
      // Yield so the loading overlay can paint before heavy parse work.
      await Future<void>.delayed(Duration.zero);

      final parsed = ImportItemsExcelParser.parse(bytes);
      final existingItems = await ref.read(inventoryItemsProvider.future);
      final units = await _loadUnitsForImport();

      if (units.isEmpty) {
        state = state.copyWith(
          isParsing: false,
          parseError:
              'No units found in your business. Add at least one unit under '
              'Inventory → Units, then upload the file again.',
        );
        return;
      }

      final rows = ImportItemsExcelService.buildPreviewRows(
        parsedRows: parsed,
        existingItems: existingItems,
        units: units,
      );

      if (rows.isEmpty) {
        state = state.copyWith(
          isParsing: false,
          parseError: 'No items found in the uploaded file.',
        );
        return;
      }

      state = state.copyWith(
        isParsing: false,
        rows: rows,
        clearParseError: true,
      );
    } on Object catch (error) {
      state = state.copyWith(
        isParsing: false,
        parseError: 'Failed to read file: $error',
      );
    }
  }

  void toggleRowSelection(String rowId, {required bool selected}) {
    state = state.copyWith(
      rows: [
        for (final row in state.rows)
          if (row.id == rowId && row.status == ImportRowStatus.valid)
            row.copyWith(isSelected: selected)
          else
            row,
      ],
    );
  }

  void selectAllValid({required bool selected}) {
    state = state.copyWith(
      rows: [
        for (final row in state.rows)
          row.status == ImportRowStatus.valid
              ? row.copyWith(isSelected: selected)
              : row,
      ],
    );
  }

  Future<ImportItemsResult?> confirmImport() async {
    final rowsToImport = state.rows.where((row) => row.canImport).toList();
    if (rowsToImport.isEmpty || state.isImporting || state.isParsing) {
      return null;
    }

    state = state.copyWith(
      isImporting: true,
      importCompleted: 0,
      importTotal: rowsToImport.length,
      clearImportError: true,
    );

    var successCount = 0;
    var failedCount = 0;
    final errors = <String>[];

    try {
      await ref.read(inventoryUnitsProvider.future);
      final itemsNotifier = ref.read(inventoryItemsProvider.notifier);

      for (var i = 0; i < rowsToImport.length; i++) {
        final row = rowsToImport[i];
        state = state.copyWith(
          importCompleted: i,
          importTotal: rowsToImport.length,
        );

        try {
          final form = row.importForm;
          if (form == null) {
            throw const InventoryException('Item data is incomplete.');
          }
          await itemsNotifier.addItemFromForm(form);
          successCount++;
        } on ApiValidationException catch (error) {
          failedCount++;
          final nameError = error.fieldErrors['name'];
          errors.add(
            '${row.itemName}: ${nameError ?? error.message}',
          );
        } on InventoryException catch (error) {
          failedCount++;
          errors.add('${row.itemName}: ${error.message}');
        } on Object catch (error) {
          failedCount++;
          errors.add(
            '${row.itemName}: ${InventoryErrorMapper.messageFor(error)}',
          );
        }

        state = state.copyWith(
          importCompleted: i + 1,
          importTotal: rowsToImport.length,
        );
      }

      state = state.copyWith(isImporting: false);
      return ImportItemsResult(
        successCount: successCount,
        failedCount: failedCount,
        skippedCount: state.rows.length - rowsToImport.length,
        errors: errors,
      );
    } on Object catch (error) {
      state = state.copyWith(
        isImporting: false,
        importError: InventoryErrorMapper.messageFor(error),
      );
      rethrow;
    }
  }

  void reset() => state = const ImportItemsExcelState();

  Future<List<InventoryUnit>> _loadUnitsForImport() async {
    ref.read(unitBackendSearchProvider.notifier).query = '';
    await ref.read(inventoryUnitsProvider.notifier).refresh(searchQuery: '');
    final units = await ref.read(inventoryUnitsProvider.future);

    if (units.isNotEmpty) return units;

    final created = await ref.read(inventoryUnitsProvider.notifier).addUnit(
          fullName: 'Pieces',
          shortName: 'PCS',
        );
    if (created.unit != null) {
      return [created.unit!];
    }

    return ref.read(inventoryUnitsProvider.future);
  }
}
