import 'package:billing_baba/core/network/api_validation_exception.dart';
import 'package:billing_baba/core/providers/data_refresh.dart';
import 'package:billing_baba/features/inventory/application/inventory_error_mapper.dart';
import 'package:billing_baba/features/inventory/application/inventory_service.dart';
import 'package:billing_baba/features/inventory/models/unit_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'inventory_units_provider.g.dart';

final unitBackendSearchProvider =
    NotifierProvider<UnitBackendSearch, String>(UnitBackendSearch.new);

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

@Riverpod(keepAlive: true)
class InventoryUnits extends _$InventoryUnits {
  @override
  Future<List<InventoryUnit>> build() async {
    final service = await ref.watch(inventoryServiceProvider.future);
    return service.fetchUnits();
  }

  Future<void> refresh({String? searchQuery}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final service = await ref.read(inventoryServiceProvider.future);
      return service.fetchUnits(
        searchQuery: searchQuery ?? ref.read(unitBackendSearchProvider),
      );
    });
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
      invalidateInventoryLists(ref);
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
      invalidateInventoryLists(ref);
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
      invalidateInventoryLists(ref);
      return null;
    } on InventoryException catch (error) {
      state = previous;
      return error.message;
    } catch (error) {
      state = previous;
      return InventoryErrorMapper.messageFor(error);
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
      return const AddConversionResult(error: 'Conversion rate must be positive');
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
