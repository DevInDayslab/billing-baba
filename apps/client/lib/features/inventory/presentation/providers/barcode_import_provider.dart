import 'dart:async';
import 'dart:convert';

import 'package:billing_baba/core/constants/storage_keys.dart';
import 'package:billing_baba/core/network/api_error_parser.dart';
import 'package:billing_baba/core/providers/api_client_provider.dart';
import 'package:billing_baba/core/providers/storage_service_provider.dart';
import 'package:billing_baba/features/inventory/application/barcode_lookup_service.dart';
import 'package:billing_baba/features/inventory/application/inventory_error_mapper.dart';
import 'package:billing_baba/features/inventory/data/inventory_remote_data_source.dart';
import 'package:billing_baba/features/inventory/data/inventory_repository.dart';
import 'package:billing_baba/features/inventory/models/category_model.dart';
import 'package:billing_baba/features/inventory/models/mappers/category_mapper.dart';
import 'package:billing_baba/features/inventory/models/requests/item_requests.dart';
import 'package:billing_baba/features/inventory/models/unit_model.dart';
import 'package:billing_baba/features/inventory/providers/inventory_units_provider.dart';
import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'barcode_import_provider.g.dart';

@Riverpod(keepAlive: true)
Future<InventoryRepository> inventoryRepository(Ref ref) async {
  final api = await ref.watch(apiClientProvider.future);
  return InventoryRepository(
    remote: InventoryRemoteDataSource(api.dio),
  );
}

@riverpod
Future<BarcodeLookupService> barcodeLookupService(Ref ref) async {
  final repository = await ref.watch(inventoryRepositoryProvider.future);
  return BarcodeLookupService(
    repository: repository,
    remoteDataSource: repository.remoteDataSource,
  );
}

@riverpod
class BarcodeImportLookupError extends _$BarcodeImportLookupError {
  @override
  bool build() => false;

  void report() {
    state = true;
    Future<void>.delayed(const Duration(seconds: 3), () {
      if (!ref.mounted) return;
      state = false;
    });
  }
}

enum BarcodeRowStatus { empty, loading, found, notFound, manualEntry }

class BarcodeImportRow {
  const BarcodeImportRow({
    required this.index,
    required this.barcode,
    required this.itemName,
    required this.category,
    required this.hsnCode,
    required this.defaultMrp,
    required this.salePrice,
    this.incTax = true,
    required this.taxPercent,
    required this.baseUnit,
    required this.status,
  });

  final int index;
  final String barcode;
  final String itemName;
  final String category;
  final String hsnCode;
  final String defaultMrp;
  final String salePrice;
  final bool incTax;
  final String taxPercent;
  final String baseUnit;
  final BarcodeRowStatus status;

  factory BarcodeImportRow.empty(int index) {
    return BarcodeImportRow(
      index: index,
      barcode: '',
      itemName: '',
      category: '',
      hsnCode: '',
      defaultMrp: '',
      salePrice: '',
      taxPercent: '',
      baseUnit: '',
      status: BarcodeRowStatus.empty,
    );
  }

  bool get hasData => status != BarcodeRowStatus.empty;

  bool get isEmpty => status == BarcodeRowStatus.empty;

  /// First six data columns: item code through sale price.
  bool get hasLeadingColumnsEmpty =>
      barcode.trim().isEmpty &&
      itemName.trim().isEmpty &&
      category.trim().isEmpty &&
      hsnCode.trim().isEmpty &&
      defaultMrp.trim().isEmpty &&
      salePrice.trim().isEmpty;

  BarcodeImportRow copyWith({
    int? index,
    String? barcode,
    String? itemName,
    String? category,
    String? hsnCode,
    String? defaultMrp,
    String? salePrice,
    bool? incTax,
    String? taxPercent,
    String? baseUnit,
    BarcodeRowStatus? status,
  }) {
    return BarcodeImportRow(
      index: index ?? this.index,
      barcode: barcode ?? this.barcode,
      itemName: itemName ?? this.itemName,
      category: category ?? this.category,
      hsnCode: hsnCode ?? this.hsnCode,
      defaultMrp: defaultMrp ?? this.defaultMrp,
      salePrice: salePrice ?? this.salePrice,
      incTax: incTax ?? this.incTax,
      taxPercent: taxPercent ?? this.taxPercent,
      baseUnit: baseUnit ?? this.baseUnit,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toJson() => {
    'index': index,
    'barcode': barcode,
    'itemName': itemName,
    'category': category,
    'hsnCode': hsnCode,
    'defaultMrp': defaultMrp,
    'salePrice': salePrice,
    'incTax': incTax,
    'taxPercent': taxPercent,
    'baseUnit': baseUnit,
    'status': status.name,
  };

  factory BarcodeImportRow.fromJson(Map<String, dynamic> json) {
    final rawStatus = json['status'] as String? ?? BarcodeRowStatus.empty.name;
    final status = rawStatus == BarcodeRowStatus.loading.name
        ? BarcodeRowStatus.notFound
        : BarcodeRowStatus.values.byName(rawStatus);

    return BarcodeImportRow(
      index: json['index'] as int? ?? 0,
      barcode: json['barcode'] as String? ?? '',
      itemName: json['itemName'] as String? ?? '',
      category: json['category'] as String? ?? '',
      hsnCode: json['hsnCode'] as String? ?? '',
      defaultMrp: json['defaultMrp'] as String? ?? '',
      salePrice: json['salePrice'] as String? ?? '',
      incTax: json['incTax'] as bool? ?? true,
      taxPercent: json['taxPercent'] as String? ?? '',
      baseUnit: json['baseUnit'] as String? ?? '',
      status: status,
    );
  }
}

@Riverpod(keepAlive: false)
class BarcodeImport extends _$BarcodeImport {
  static const _initialRowCount = 20;
  static const _rowsToAppend = 5;

  Future<void>? _initialization;

  @override
  List<BarcodeImportRow> build() {
    ref.onDispose(() {
      unawaited(_persistDraft());
    });
    _initialization ??= _restoreDraft();
    return _createInitialRows();
  }

  Future<void> ensureInitialized() => _initialization ??= _restoreDraft();

  static List<BarcodeImportRow> _createInitialRows() {
    return List.generate(_initialRowCount, BarcodeImportRow.empty);
  }

  int get nextEmptyRowIndex => resolveActiveRowIndex(state);

  static int resolveActiveRowIndex(List<BarcodeImportRow> rows) {
    final inProgress = rows.indexWhere(
      (r) => r.status == BarcodeRowStatus.empty && r.barcode.trim().isNotEmpty,
    );
    if (inProgress != -1) return inProgress;

    final idx = rows.indexWhere(
      (r) =>
          r.status != BarcodeRowStatus.loading && r.hasLeadingColumnsEmpty,
    );
    return idx == -1 ? rows.length - 1 : idx;
  }

  List<BarcodeImportRow> _normalizeRows(List<BarcodeImportRow> rows) {
    return normalizeRows(rows);
  }

  static List<BarcodeImportRow> normalizeRows(List<BarcodeImportRow> rows) {
    return [
      for (final row in rows)
        if (row.status != BarcodeRowStatus.empty &&
            row.status != BarcodeRowStatus.loading &&
            row.hasLeadingColumnsEmpty)
          BarcodeImportRow.empty(row.index)
        else
          row,
    ];
  }

  static bool needsNormalization(List<BarcodeImportRow> rows) {
    return rows.any(
      (row) =>
          row.status != BarcodeRowStatus.empty &&
          row.status != BarcodeRowStatus.loading &&
          row.hasLeadingColumnsEmpty,
    );
  }

  void ensureNormalized() {
    final normalized = normalizeRows(state);
    if (!listEquals(normalized, state)) {
      state = normalized;
    }
  }

  void _commitState(List<BarcodeImportRow> rows) {
    state = _normalizeRows(rows);
    unawaited(_persistDraft());
  }

  Future<String?> _draftStorageKey() async {
    final storage = await ref.read(storageServiceProvider.future);
    final businessId = storage.read(StorageKeys.lastOpenedBusinessId);
    if (businessId == null || businessId.isEmpty) return null;
    return '${StorageKeys.barcodeImportDraft}_$businessId';
  }

  List<BarcodeImportRow> _draftRows(List<BarcodeImportRow> rows) {
    return rows
        .where((row) => !row.isEmpty || row.barcode.trim().isNotEmpty)
        .toList();
  }

  Future<void> _restoreDraft() async {
    try {
      final key = await _draftStorageKey();
      if (key == null) return;

      final storage = await ref.read(storageServiceProvider.future);
      final raw = storage.read(key);
      if (raw == null || raw.isEmpty) return;

      final decoded = jsonDecode(raw);
      if (decoded is! List || decoded.isEmpty) return;

      final restored = <BarcodeImportRow>[
        for (final item in decoded)
          BarcodeImportRow.fromJson(Map<String, dynamic>.from(item as Map)),
      ];

      final reIndexed = [
        for (var i = 0; i < restored.length; i++)
          restored[i].copyWith(index: i),
      ];
      while (reIndexed.length < _initialRowCount) {
        reIndexed.add(BarcodeImportRow.empty(reIndexed.length));
      }

      if (!ref.mounted) return;
      state = normalizeRows(reIndexed);
    } on Object catch (_) {
      // Ignore corrupt drafts.
    }
  }

  Future<void> _persistDraft() async {
    if (!ref.mounted) return;

    try {
      final key = await _draftStorageKey();
      if (key == null) return;

      final storage = await ref.read(storageServiceProvider.future);
      final draftRows = _draftRows(state);
      if (draftRows.isEmpty) {
        await storage.remove(key);
        return;
      }

      await storage.write(
        key,
        jsonEncode(draftRows.map((row) => row.toJson()).toList()),
      );
    } on Object catch (_) {
      // Ignore persistence failures.
    }
  }

  Future<void> clearDraft() async {
    try {
      final key = await _draftStorageKey();
      if (key == null) return;
      final storage = await ref.read(storageServiceProvider.future);
      await storage.remove(key);
    } on Object catch (_) {
      // Ignore persistence failures.
    }
  }

  void resetToEmpty() {
    state = _createInitialRows();
    unawaited(clearDraft());
  }

  static String _digitsOnly(String value) =>
      value.replaceAll(RegExp(r'\D'), '');

  void updateLiveInput(int rowIndex, String currentBuffer) {
    final sanitized = _digitsOnly(currentBuffer);
    _commitState([
      for (final r in state)
        if (r.index == rowIndex) r.copyWith(barcode: sanitized) else r,
    ]);
  }

  Future<void> startLookup(int rowIndex, String barcode) async {
    debugPrint(
      '[BarcodeImport] startLookup called for row $rowIndex with barcode: $barcode',
    );

    if (barcode.trim().isEmpty) return;
    if (barcode.trim().length < 3) return;
    if (rowIndex < 0 || rowIndex >= state.length) return;

    final trimmed = barcode.trim();

    _updateRow(
      rowIndex,
      state[rowIndex].copyWith(
        barcode: trimmed,
        status: BarcodeRowStatus.loading,
      ),
    );

    try {
      final service = await ref.read(barcodeLookupServiceProvider.future);
      final result = await service.lookup(trimmed);
      debugPrint('[BarcodeImport] lookup result: found=${result.found}');
      if (!ref.mounted) return;

      if (result.found) {
        debugPrint('[BarcodeImport] populateRow called: ${result.itemName}');
        final defaultMrp = result.defaultMrp ?? '';
        final salePrice = result.salePrice ?? defaultMrp;
        populateRow(
          rowIndex,
          BarcodeImportRow(
            index: rowIndex,
            barcode: trimmed,
            itemName: result.itemName ?? '',
            category: result.category ?? '',
            hsnCode: result.hsnCode ?? '',
            defaultMrp: defaultMrp,
            salePrice: salePrice,
            incTax: result.incTax,
            taxPercent: result.taxPercent ?? '',
            baseUnit: result.baseUnit ?? '',
            status: BarcodeRowStatus.found,
          ),
        );
        return;
      }

      if (result.hadError) {
        ref.read(barcodeImportLookupErrorProvider.notifier).report();
      }
      markNotFound(rowIndex);
    } catch (_) {
      if (!ref.mounted) return;
      ref.read(barcodeImportLookupErrorProvider.notifier).report();
      markNotFound(rowIndex);
    }
  }

  void populateRow(int rowIndex, BarcodeImportRow data) {
    if (rowIndex < 0 || rowIndex >= state.length) return;
    _updateRow(
      rowIndex,
      data.copyWith(
        index: rowIndex,
        status: BarcodeRowStatus.found,
      ),
    );
    addNewRowIfNeeded();
  }

  void markNotFound(int rowIndex) {
    if (rowIndex < 0 || rowIndex >= state.length) return;
    _updateRow(
      rowIndex,
      state[rowIndex].copyWith(status: BarcodeRowStatus.notFound),
    );
    addNewRowIfNeeded();
  }

  void setManualEntry(int rowIndex) {
    if (rowIndex < 0 || rowIndex >= state.length) return;
    _updateRow(
      rowIndex,
      state[rowIndex].copyWith(status: BarcodeRowStatus.manualEntry),
    );
  }

  void updateField(int rowIndex, String field, String value) {
    if (rowIndex < 0 || rowIndex >= state.length) return;
    final row = state[rowIndex];
    final updated = switch (field) {
      'barcode' => row.copyWith(barcode: _digitsOnly(value)),
      'itemName' => row.copyWith(itemName: value),
      'category' => row.copyWith(category: value),
      'hsnCode' => row.copyWith(hsnCode: value),
      'defaultMrp' => row.copyWith(defaultMrp: value),
      'salePrice' => row.copyWith(salePrice: value),
      'incTax' => row.copyWith(incTax: value == 'true'),
      'taxPercent' => row.copyWith(taxPercent: value),
      'baseUnit' => row.copyWith(baseUnit: value),
      _ => row,
    };
    _updateRow(rowIndex, updated);
  }

  void deleteRow(int rowIndex) {
    final newRows = state.where((r) => r.index != rowIndex).toList();
    final reIndexed = newRows
        .asMap()
        .entries
        .map((e) => e.value.copyWith(index: e.key))
        .toList();
    while (reIndexed.length < _initialRowCount) {
      reIndexed.add(BarcodeImportRow.empty(reIndexed.length));
    }
    _commitState(reIndexed);
  }

  void addNewRowIfNeeded() {
    if (state.isEmpty || !state.last.hasData) return;
    final nextIndex = state.length;
    _commitState([
      ...state,
      for (var i = 0; i < _rowsToAppend; i++)
        BarcodeImportRow.empty(nextIndex + i),
    ]);
  }

  void _updateRow(int rowIndex, BarcodeImportRow row) {
    _commitState([
      for (var i = 0; i < state.length; i++)
        if (i == rowIndex) row else state[i],
    ]);
  }

  List<BarcodeImportRow> getRowsWithErrors() {
    return state
        .where((row) => !row.isEmpty && row.itemName.trim().isEmpty)
        .toList();
  }

  /// Returns `null` on success, or an error message on failure.
  Future<String?> saveItems({
    bool ignoreErrors = false,
    required List<InventoryCategory> categories,
    required List<InventoryUnit> units,
  }) async {
    final rowsToSave = state.where((row) => !row.isEmpty).toList();
    if (rowsToSave.isEmpty) return 'No items to save';

    if (!ignoreErrors) {
      final errors = getRowsWithErrors();
      if (errors.isNotEmpty) return 'Some rows are missing item names';
    }

    final validRows = ignoreErrors
        ? rowsToSave.where((row) => row.itemName.trim().isNotEmpty).toList()
        : rowsToSave;

    if (validRows.isEmpty) return 'No valid items to save';

    try {
      final repository = await ref.read(inventoryRepositoryProvider.future);
      final resolvedUnits = await _loadUnitsForSave();
      if (resolvedUnits.isEmpty) {
        debugPrint('[BarcodeImport] saveItems failed: no units configured');
        return 'No units configured. Add a unit and try again.';
      }

      for (final row in validRows) {
        final request = _toCreateRequest(
          row,
          categories: categories,
          units: resolvedUnits,
        );
        debugPrint(
          '[BarcodeImport] Saving payload: ${jsonEncode(request.toJson())}',
        );
        try {
          await repository.createItem(request);
        } catch (error, stackTrace) {
          debugPrint('[BarcodeImport] Save error: $error');
          debugPrint('[BarcodeImport] Stack: $stackTrace');
          if (error is DioException) {
            debugPrint(
              '[BarcodeImport] Response status: ${error.response?.statusCode}',
            );
            debugPrint(
              '[BarcodeImport] Response body: ${error.response?.data}',
            );
            final validation = ApiErrorParser.parseValidation(error);
            if (validation != null) {
              debugPrint(
                '[BarcodeImport] Validation errors: ${validation.fieldErrors}',
              );
            }
          }
          rethrow;
        }
      }
      await clearDraft();
      return null;
    } catch (error, stackTrace) {
      debugPrint('[BarcodeImport] Save error: $error');
      debugPrint('[BarcodeImport] Stack: $stackTrace');
      if (error is DioException) {
        final validation = ApiErrorParser.parseValidation(error);
        if (validation != null) {
          final detail = validation.fieldErrors.entries
              .map((entry) => '${entry.key}: ${entry.value}')
              .join('; ');
          debugPrint('[BarcodeImport] saveItems failed: $detail');
          return detail.isNotEmpty ? detail : validation.message;
        }
        final apiMessage = ApiErrorParser.errorMessage(error);
        if (apiMessage != null && apiMessage.isNotEmpty) {
          debugPrint('[BarcodeImport] saveItems failed: $apiMessage');
          return apiMessage;
        }
      }
      final message = InventoryErrorMapper.messageFor(error);
      debugPrint('[BarcodeImport] saveItems failed: $message');
      debugPrintStack(stackTrace: stackTrace);
      return message;
    }
  }

  Future<List<InventoryUnit>> _loadUnitsForSave() async {
    ref.read(unitBackendSearchProvider.notifier).query = '';
    await ref.read(inventoryUnitsProvider.notifier).refresh(searchQuery: '');
    final units = await ref.read(inventoryUnitsProvider.future);
    if (units.isNotEmpty) return units;

    final created = await ref
        .read(inventoryUnitsProvider.notifier)
        .addUnit(
          fullName: 'Pieces',
          shortName: 'Pcs',
        );
    if (created.unit != null) {
      return [created.unit!];
    }

    return ref.read(inventoryUnitsProvider.future);
  }

  CreateItemRequest _toCreateRequest(
    BarcodeImportRow row, {
    required List<InventoryCategory> categories,
    required List<InventoryUnit> units,
  }) {
    final trimmedSalePrice = _normalizeMoneyField(row.salePrice);
    final trimmedMrp = _normalizeMoneyField(row.defaultMrp);
    final salePrice = trimmedSalePrice.isNotEmpty
        ? trimmedSalePrice
        : (trimmedMrp.isNotEmpty ? trimmedMrp : '0');

    final categoryId = categories
        .firstWhereOrNull((c) => c.name == row.category.trim())
        ?.id;

    final hsnCode = row.hsnCode.trim();

    return CreateItemRequest(
      name: row.itemName.trim(),
      baseUnit: _resolveBaseUnitShortName(row, units),
      barcode: row.barcode.trim().isNotEmpty ? row.barcode.trim() : null,
      hsnCode: hsnCode.isNotEmpty ? hsnCode : null,
      categoryId: CategoryMapper.toApiCategoryId(categoryId),
      salePrice: salePrice,
      mrp: trimmedMrp.isNotEmpty ? trimmedMrp : null,
    );
  }

  static String _normalizeMoneyField(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return '';
    final numeric = trimmed.replaceAll(RegExp(r'[^\d.]'), '');
    if (numeric.isEmpty) return '';
    if (RegExp(r'^\d+(\.\d{1,4})?$').hasMatch(numeric)) {
      return numeric;
    }
    return numeric.split('.').first;
  }

  String _resolveBaseUnitShortName(
    BarcodeImportRow row,
    List<InventoryUnit> units,
  ) {
    final defaultUnit = _defaultUnit(units);
    final fallback = defaultUnit?.shortName ??
        (units.isNotEmpty ? units.first.shortName : 'Pcs');

    final trimmed = row.baseUnit.trim();
    if (trimmed.isEmpty) return fallback;

    final quantityUnit = _parseQuantityUnit(trimmed);
    if (quantityUnit != null) {
      final resolved = _resolveUnit(quantityUnit, units);
      if (resolved != null) return resolved.shortName;
    }

    final resolved = _resolveUnit(trimmed, units);
    if (resolved != null) return resolved.shortName;

    return fallback;
  }

  static InventoryUnit? _defaultUnit(List<InventoryUnit> units) {
    if (units.isEmpty) return null;

    for (final unit in units) {
      if (unit.shortName.toLowerCase() == 'pcs') return unit;
    }

    for (final unit in units) {
      if (unit.fullName.toLowerCase() == 'piece') return unit;
    }

    return units.first;
  }

  static String? _parseQuantityUnit(String label) {
    final match = RegExp(
      r'^[\d.,]+\s*(.+)$',
      caseSensitive: false,
    ).firstMatch(label.trim());
    return match?.group(1)?.trim();
  }

  static InventoryUnit? _resolveUnit(
    String unitLabel,
    List<InventoryUnit> units,
  ) {
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
      'nos' ||
      'no' ||
      'number' ||
      'numbers' ||
      'piece' ||
      'pieces' => const ['pcs', 'piece', 'pieces'],
      'bag' || 'bags' => const ['bag', 'pcs'],
      'kg' || 'kgs' || 'kilogram' || 'kilograms' => const ['kg', 'kgs'],
      'g' ||
      'gm' ||
      'gms' ||
      'gram' ||
      'grams' => const ['gm', 'gms', 'gram'],
      'ml' ||
      'millilitre' ||
      'milliliter' ||
      'millilitres' ||
      'milliliters' => const ['ml', 'millilitre'],
      'ltr' || 'ltrs' || 'liter' || 'litre' => const ['ltr', 'liter', 'litre'],
      'box' || 'boxes' => const ['box', 'pcs'],
      'pkt' || 'pack' || 'packet' => const ['pkt', 'pack', 'pcs'],
      _ => const [],
    };
  }
}
