import 'package:billing_baba/core/network/api_validation_exception.dart';
import 'package:billing_baba/core/providers/data_refresh.dart';
import 'package:billing_baba/features/inventory/application/inventory_catalog.dart';
import 'package:billing_baba/features/inventory/default_inventory_units.dart';
import 'package:billing_baba/features/inventory/application/inventory_error_mapper.dart';
import 'package:billing_baba/features/inventory/application/inventory_service.dart';
import 'package:billing_baba/features/inventory/models/unit_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'inventory_units_provider.g.dart';

final unitBackendSearchProvider = NotifierProvider<UnitBackendSearch, String>(
  UnitBackendSearch.new,
);

class UnitBackendSearch extends Notifier<String> {
  @override
  String build() => '';

  String get query => state;
  set query(String value) => state = value;
}

class AddUnitResult {
  const AddUnitResult({this.unit, this.error});

  final InventoryUnit? unit;
  final String? error;

  bool get isSuccess => unit != null;
}

class AddConversionResult {
  const AddConversionResult({this.conversion, this.error});

  final UnitConversion? conversion;
  final String? error;

  bool get isSuccess => conversion != null;
}

/// Existing conversion shown as `1 [base] = [displayRate] [secondary]`.
class UnitPairConversionLookup {
  const UnitPairConversionLookup({
    required this.conversionId,
    required this.displayRate,
    required this.storedFromBase,
  });

  final String conversionId;
  final double displayRate;

  /// When false, API stores `1 secondary = factor base` (inverse of UI rate).
  final bool storedFromBase;

  double apiFactorForDisplayRate(double displayRate) {
    if (displayRate <= 0) return displayRate;
    return storedFromBase ? displayRate : 1 / displayRate;
  }
}

Future<List<InventoryUnit>> fetchInventoryUnitsWithFallback(
  Ref ref, {
  String? searchQuery,
}) async {
  try {
    final service = await ref.read(inventoryServiceProvider.future);
    final units = await service.fetchUnits(searchQuery: searchQuery);
    return _filterUnits(
      mergeUnitsWithCatalogDefaults(units),
      searchQuery: searchQuery,
    );
  } on Object {
    // Fall through to local catalog when API is empty or unavailable.
  }
  return _catalogUnits(searchQuery: searchQuery);
}

List<InventoryUnit> _filterUnits(
  List<InventoryUnit> units, {
  String? searchQuery,
}) {
  final query = searchQuery?.trim().toLowerCase() ?? '';
  if (query.isEmpty) return units;
  return units
      .where(
        (unit) =>
            unit.fullName.toLowerCase().contains(query) ||
            unit.shortName.toLowerCase().contains(query),
      )
      .toList();
}

List<InventoryUnit> _catalogUnits({String? searchQuery}) {
  final query = searchQuery?.trim().toLowerCase() ?? '';
  return InventoryCatalog.units
      .where(
        (unit) =>
            query.isEmpty ||
            unit.fullName.toLowerCase().contains(query) ||
            unit.shortName.toLowerCase().contains(query),
      )
      .toList();
}

@Riverpod(keepAlive: true)
class InventoryUnits extends _$InventoryUnits {
  @override
  Future<List<InventoryUnit>> build() async {
    return fetchInventoryUnitsWithFallback(ref);
  }

  Future<void> refresh({String? searchQuery}) async {
    final previous = state.value ?? const <InventoryUnit>[];
    state = await AsyncValue.guard(
      () => fetchInventoryUnitsWithFallback(
        ref,
        searchQuery: searchQuery ?? ref.read(unitBackendSearchProvider),
      ),
    );
    if (state.hasError && previous.isNotEmpty) {
      state = AsyncData(previous);
    }
  }

  Future<UnitPairConversionLookup?> lookupConversionForBaseSecondary({
    required String baseUnitId,
    required String secondaryUnitId,
  }) async {
    try {
      final service = await ref.read(inventoryServiceProvider.future);

      final forward = await service.fetchUnitConversions(
        fromUnitId: baseUnitId,
        toUnitId: secondaryUnitId,
        limit: 1,
      );
      if (forward.isNotEmpty) {
        final conversion = forward.first;
        return UnitPairConversionLookup(
          conversionId: conversion.id,
          displayRate: conversion.factor,
          storedFromBase: true,
        );
      }

      final reverse = await service.fetchUnitConversions(
        fromUnitId: secondaryUnitId,
        toUnitId: baseUnitId,
        limit: 1,
      );
      if (reverse.isNotEmpty) {
        final conversion = reverse.first;
        if (conversion.factor <= 0) return null;
        return UnitPairConversionLookup(
          conversionId: conversion.id,
          displayRate: 1 / conversion.factor,
          storedFromBase: false,
        );
      }

      final baseUnit = await loadUnitDetail(baseUnitId);
      final onBase = baseUnit?.conversions
          .where((conversion) => conversion.toUnitId == secondaryUnitId)
          .firstOrNull;
      if (onBase != null && onBase.factor > 0) {
        return UnitPairConversionLookup(
          conversionId: onBase.id,
          displayRate: onBase.factor,
          storedFromBase: true,
        );
      }

      final secondaryUnit = await loadUnitDetail(secondaryUnitId);
      final onSecondary = secondaryUnit?.conversions
          .where((conversion) => conversion.toUnitId == baseUnitId)
          .firstOrNull;
      if (onSecondary != null && onSecondary.factor > 0) {
        return UnitPairConversionLookup(
          conversionId: onSecondary.id,
          displayRate: 1 / onSecondary.factor,
          storedFromBase: false,
        );
      }

      return null;
    } on Object {
      return null;
    }
  }

  Future<InventoryUnit?> loadUnitDetail(String id) async {
    try {
      final service = await ref.read(inventoryServiceProvider.future);
      final unit = await service.getUnit(id);
      final current = state.value ?? [];
      state = AsyncData([
        for (final existing in current)
          if (existing.id == id) unit else existing,
      ]);
      return unit;
    } catch (error) {
      return null;
    }
  }

  Future<AddUnitResult> addUnit({
    required String fullName,
    required String shortName,
  }) async {
    final trimmedFullName = fullName.trim();
    final trimmedShortName = shortName.trim();

    if (trimmedFullName.isEmpty) {
      return const AddUnitResult(error: 'Unit name is required');
    }
    if (trimmedShortName.isEmpty) {
      return const AddUnitResult(error: 'Short name is required');
    }

    try {
      final service = await ref.read(inventoryServiceProvider.future);
      final unit = await service.createUnit(
        fullName: trimmedFullName,
        shortName: trimmedShortName,
      );
      await refresh();
      await refreshInventoryLists(ref);
      return AddUnitResult(unit: unit);
    } on ApiValidationException catch (error) {
      return AddUnitResult(
        error:
            error.fieldErrors['name'] ??
            error.fieldErrors['short_name'] ??
            error.message,
      );
    } on InventoryException catch (error) {
      return AddUnitResult(error: error.message);
    } catch (error) {
      return AddUnitResult(error: InventoryErrorMapper.messageFor(error));
    }
  }

  Future<AddUnitResult> updateUnit({
    required String id,
    required String fullName,
    required String shortName,
  }) async {
    try {
      final service = await ref.read(inventoryServiceProvider.future);
      final unit = await service.updateUnit(
        id: id,
        fullName: fullName.trim(),
        shortName: shortName.trim(),
      );
      await refresh();
      await refreshInventoryLists(ref);
      return AddUnitResult(unit: unit);
    } on ApiValidationException catch (error) {
      return AddUnitResult(
        error:
            error.fieldErrors['name'] ??
            error.fieldErrors['short_name'] ??
            error.message,
      );
    } on InventoryException catch (error) {
      return AddUnitResult(error: error.message);
    } catch (error) {
      return AddUnitResult(error: InventoryErrorMapper.messageFor(error));
    }
  }

  Future<String?> deleteUnit(String id) async {
    final previous = state;
    final current = state.value ?? [];
    state = AsyncData(current.where((unit) => unit.id != id).toList());

    try {
      final service = await ref.read(inventoryServiceProvider.future);
      await service.deleteUnit(id);
      await refresh();
      await refreshInventoryLists(ref);
      return null;
    } on InventoryException catch (error) {
      state = previous;
      return error.message;
    } catch (error) {
      state = previous;
      return InventoryErrorMapper.messageFor(error);
    }
  }

  Future<AddConversionResult> updateConversion({
    required String conversionId,
    required String baseUnitId,
    required double apiFactor,
  }) async {
    if (apiFactor <= 0) {
      return const AddConversionResult(
        error: 'Conversion rate must be positive',
      );
    }

    try {
      final service = await ref.read(inventoryServiceProvider.future);
      final conversion = await service.updateUnitConversion(
        id: conversionId,
        factor: apiFactor,
      );
      await loadUnitDetail(baseUnitId);
      return AddConversionResult(conversion: conversion);
    } on ApiValidationException catch (error) {
      return AddConversionResult(
        error:
            error.fieldErrors['conversion_factor'] ??
            error.message,
      );
    } on InventoryException catch (error) {
      return AddConversionResult(error: error.message);
    } catch (error) {
      return AddConversionResult(error: InventoryErrorMapper.messageFor(error));
    }
  }

  Future<AddConversionResult> addConversion({
    required String baseUnitId,
    required String secondaryUnitId,
    required double rate,
  }) async {
    if (baseUnitId == secondaryUnitId) {
      return const AddConversionResult(
        error: 'Base and secondary units must be different',
      );
    }

    if (rate <= 0) {
      return const AddConversionResult(
        error: 'Conversion rate must be positive',
      );
    }

    try {
      final service = await ref.read(inventoryServiceProvider.future);
      final conversion = await service.createUnitConversion(
        fromUnitId: baseUnitId,
        toUnitId: secondaryUnitId,
        factor: rate,
      );
      await loadUnitDetail(baseUnitId);
      return AddConversionResult(conversion: conversion);
    } on ApiValidationException catch (error) {
      return AddConversionResult(
        error:
            error.fieldErrors['conversion_factor'] ??
            error.fieldErrors['from_unit_id'] ??
            error.message,
      );
    } on InventoryException catch (error) {
      return AddConversionResult(error: error.message);
    } catch (error) {
      return AddConversionResult(error: InventoryErrorMapper.messageFor(error));
    }
  }

  Future<String?> deleteConversion(String conversionId, String unitId) async {
    try {
      final service = await ref.read(inventoryServiceProvider.future);
      await service.deleteUnitConversion(conversionId);
      await loadUnitDetail(unitId);
      return null;
    } on InventoryException catch (error) {
      return error.message;
    } catch (error) {
      return InventoryErrorMapper.messageFor(error);
    }
  }
}
