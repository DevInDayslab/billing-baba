import 'package:billing_baba/features/inventory/models/unit_model.dart';
import 'package:collection/collection.dart';

/// `1 [base] = [rate] [secondary]` (same as unit picker / conversions UI).
double? resolveBaseToSecondaryRate({
  required List<InventoryUnit> units,
  required String baseUnitId,
  required String? secondaryUnitId,
}) {
  if (secondaryUnitId == null || secondaryUnitId == baseUnitId) return null;

  final baseUnit = units.where((u) => u.id == baseUnitId).firstOrNull;
  final forward = baseUnit?.conversions
      .where((c) => c.toUnitId == secondaryUnitId)
      .firstOrNull;
  if (forward != null && forward.factor > 0) return forward.factor;

  final secondaryUnit = units.where((u) => u.id == secondaryUnitId).firstOrNull;
  final reverse = secondaryUnit?.conversions
      .where((c) => c.toUnitId == baseUnitId)
      .firstOrNull;
  if (reverse != null && reverse.factor > 0) return 1 / reverse.factor;

  return null;
}

double qtyInBaseUnit({
  required double qty,
  required String qtyUnitId,
  required String baseUnitId,
  String? secondaryUnitId,
  double? baseToSecondaryRate,
}) {
  if (qtyUnitId == baseUnitId) return qty;
  if (secondaryUnitId != null &&
      qtyUnitId == secondaryUnitId &&
      baseToSecondaryRate != null &&
      baseToSecondaryRate > 0) {
    return qty / baseToSecondaryRate;
  }
  return qty;
}

double qtyFromBaseUnit({
  required double baseQty,
  required String displayUnitId,
  required String baseUnitId,
  String? secondaryUnitId,
  double? baseToSecondaryRate,
}) {
  if (displayUnitId == baseUnitId) return baseQty;
  if (secondaryUnitId != null &&
      displayUnitId == secondaryUnitId &&
      baseToSecondaryRate != null &&
      baseToSecondaryRate > 0) {
    return baseQty * baseToSecondaryRate;
  }
  return baseQty;
}

String formatItemQtyFieldValue(double value) {
  if (value == 0) return '';
  if (value == value.roundToDouble()) {
    return value.toInt().toString();
  }
  final text = value.toStringAsFixed(4);
  return text.replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
}
