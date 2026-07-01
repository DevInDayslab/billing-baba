import 'package:billing_baba/features/inventory/models/unit_model.dart';
import 'package:billing_baba/features/inventory/providers/inventory_catalog.dart';
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

final inventoryUnitsProvider =
    NotifierProvider<InventoryUnits, List<InventoryUnit>>(
      InventoryUnits.new,
    );

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

class InventoryUnits extends Notifier<List<InventoryUnit>> {
  @override
  List<InventoryUnit> build() => List.of(InventoryCatalog.units);

  AddUnitResult addUnit({
    required String fullName,
    required String shortName,
  }) {
    final trimmedFullName = fullName.trim();
    final trimmedShortName = shortName.trim();

    if (trimmedFullName.isEmpty) {
      return const AddUnitResult(error: 'Unit name is required');
    }
    if (trimmedShortName.isEmpty) {
      return const AddUnitResult(error: 'Short name is required');
    }

    final normalizedFullName = trimmedFullName.toLowerCase();
    final normalizedShortName = trimmedShortName.toLowerCase();

    final fullNameExists = state.any(
      (unit) => unit.fullName.toLowerCase() == normalizedFullName,
    );
    if (fullNameExists) {
      return const AddUnitResult(
        error: 'A unit with this name already exists',
      );
    }

    final shortNameExists = state.any(
      (unit) => unit.shortName.toLowerCase() == normalizedShortName,
    );
    if (shortNameExists) {
      return const AddUnitResult(
        error: 'A unit with this short name already exists',
      );
    }

    final unit = InventoryUnit(
      id: 'unit-${_uuid.v4()}',
      fullName: trimmedFullName.toUpperCase(),
      shortName: trimmedShortName,
    );
    state = [...state, unit];
    return AddUnitResult(unit: unit);
  }

  AddConversionResult addConversion({
    required String baseUnitId,
    required String secondaryUnitId,
    required double rate,
  }) {
    if (baseUnitId == secondaryUnitId) {
      return const AddConversionResult(
        error: 'Base and secondary units must be different',
      );
    }

    final baseUnitIndex = state.indexWhere((unit) => unit.id == baseUnitId);
    if (baseUnitIndex == -1) {
      return const AddConversionResult(error: 'Base unit not found');
    }

    final secondaryUnit = state
        .where((unit) => unit.id == secondaryUnitId)
        .firstOrNull;
    if (secondaryUnit == null) {
      return const AddConversionResult(error: 'Secondary unit not found');
    }

    final baseUnit = state[baseUnitIndex];
    final duplicateExists = baseUnit.conversions.any(
      (conversion) =>
          conversion.label.contains(secondaryUnit.fullName) &&
          conversion.factor == rate,
    );
    if (duplicateExists) {
      return const AddConversionResult(
        error: 'This conversion already exists',
      );
    }

    final label =
        '1 ${baseUnit.fullName} = ${rate == rate.roundToDouble() ? rate.toInt() : rate} ${secondaryUnit.fullName}';
    final conversion = UnitConversion(
      id: 'conv-${_uuid.v4()}',
      label: label,
      factor: rate,
    );

    final updatedUnit = InventoryUnit(
      id: baseUnit.id,
      fullName: baseUnit.fullName,
      shortName: baseUnit.shortName,
      conversions: [...baseUnit.conversions, conversion],
    );

    state = [
      for (var i = 0; i < state.length; i++)
        if (i == baseUnitIndex) updatedUnit else state[i],
    ];

    return AddConversionResult(conversion: conversion);
  }
}
