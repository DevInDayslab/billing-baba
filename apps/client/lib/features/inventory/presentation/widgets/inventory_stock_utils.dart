import 'package:billing_baba/features/inventory/models/item_model.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/inventory_styles.dart';
import 'package:flutter/material.dart';

const inventoryZeroColor = Color(0xFF757575);
const inventoryLowStockColor = Color(0xFFE65100);
const inventoryEmDash = '—';

Color stockQuantityColor({
  required double? quantity,
  double? reorderLevel,
}) {
  return listQuantityColor(quantity, reorderLevel: reorderLevel);
}

/// List quantity colors: green positive, orange low stock, gray zero, red negative.
Color listQuantityColor(double? quantity, {double? reorderLevel}) {
  if (quantity == null) return inventoryZeroColor;
  if (quantity < 0) return inventoryNegativeColor;
  if (quantity == 0) return inventoryZeroColor;
  if (reorderLevel != null && quantity <= reorderLevel) {
    return inventoryLowStockColor;
  }
  return inventoryPositiveColor;
}

String displayOrDash(String? value) {
  if (value == null || value.trim().isEmpty) return inventoryEmDash;
  return value;
}

String formatQuantity(double? value, String unit) {
  if (value == null) return inventoryEmDash;
  return '${formatQuantityValue(value)} $unit';
}

String formatQuantityValue(double value) {
  if (value == value.roundToDouble()) {
    return value.toInt().toString();
  }
  return value.toStringAsFixed(2).replaceAll(RegExp(r'\.?0+$'), '');
}

String stockStatusLabel(InventoryItem item) {
  final quantity = item.quantity;
  if (quantity == null || quantity <= 0) return 'Out of Stock';
  final reorder = item.reorderLevel;
  if (reorder != null && quantity <= reorder) return 'Low Stock';
  return 'In Stock';
}

Color stockStatusColor(InventoryItem item) {
  final quantity = item.quantity;
  if (quantity == null || quantity <= 0) return inventoryZeroColor;
  final reorder = item.reorderLevel;
  if (reorder != null && quantity <= reorder) return inventoryLowStockColor;
  return inventoryPositiveColor;
}

double? parseDecimal(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  return double.tryParse(value);
}
