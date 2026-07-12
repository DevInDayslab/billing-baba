import 'package:flutter/material.dart';

enum InventoryMovementType {
  purchase,
  sale,
  opening,
  adjustment,
  transfer,
  return_,
  manufacturing,
  other,
}

abstract final class InventoryMovementTypeMapper {
  static InventoryMovementType fromRaw(String? raw) {
    return switch (raw) {
      'purchase' || 'purchase_document' => InventoryMovementType.purchase,
      'sale' || 'sales_document' || 'challan' => InventoryMovementType.sale,
      'opening' => InventoryMovementType.opening,
      'adjustment' || 'manual_adjustment' => InventoryMovementType.adjustment,
      'transfer' => InventoryMovementType.transfer,
      'sales_return' || 'purchase_return' => InventoryMovementType.return_,
      'manufacturing' || 'manufacture' => InventoryMovementType.manufacturing,
      _ => InventoryMovementType.other,
    };
  }

  static String label(InventoryMovementType type) {
    return switch (type) {
      InventoryMovementType.purchase => 'Purchase',
      InventoryMovementType.sale => 'Sale',
      InventoryMovementType.opening => 'Opening Stock',
      InventoryMovementType.adjustment => 'Adjustment',
      InventoryMovementType.transfer => 'Transfer',
      InventoryMovementType.return_ => 'Return',
      InventoryMovementType.manufacturing => 'Manufacturing',
      InventoryMovementType.other => 'Other',
    };
  }

  static Color badgeColor(InventoryMovementType type) {
    return switch (type) {
      InventoryMovementType.purchase => const Color(0xFF1565C0),
      InventoryMovementType.sale => const Color(0xFF2E7D32),
      InventoryMovementType.opening => const Color(0xFF6A1B9A),
      InventoryMovementType.adjustment => const Color(0xFFE65100),
      InventoryMovementType.transfer => const Color(0xFF1565C0),
      InventoryMovementType.return_ => const Color(0xFF00838F),
      InventoryMovementType.manufacturing => const Color(0xFF5D4037),
      InventoryMovementType.other => const Color(0xFF616161),
    };
  }

  /// Ledger row indicator dot — Vyapar-style movement colors.
  static Color indicatorColor(InventoryMovementType type) {
    return switch (type) {
      InventoryMovementType.purchase => const Color(0xFF2E7D32),
      InventoryMovementType.sale => const Color(0xFFC62828),
      InventoryMovementType.adjustment => const Color(0xFFE65100),
      InventoryMovementType.opening => const Color(0xFF6A1B9A),
      InventoryMovementType.transfer => const Color(0xFF1565C0),
      InventoryMovementType.return_ => const Color(0xFF00838F),
      InventoryMovementType.manufacturing => const Color(0xFF5D4037),
      InventoryMovementType.other => const Color(0xFF9E9E9E),
    };
  }

  static (Color background, Color foreground) badgeColors(
    InventoryMovementType type,
  ) {
    return switch (type) {
      InventoryMovementType.purchase => (
        const Color(0xFFE3F2FD),
        const Color(0xFF1565C0),
      ),
      InventoryMovementType.sale => (
        const Color(0xFFE8F5E9),
        const Color(0xFF2E7D32),
      ),
      InventoryMovementType.opening => (
        const Color(0xFFF3E5F5),
        const Color(0xFF6A1B9A),
      ),
      InventoryMovementType.adjustment => (
        const Color(0xFFFFF3E0),
        const Color(0xFFE65100),
      ),
      InventoryMovementType.transfer => (
        const Color(0xFFE3F2FD),
        const Color(0xFF1565C0),
      ),
      InventoryMovementType.return_ => (
        const Color(0xFFE0F7FA),
        const Color(0xFF00838F),
      ),
      InventoryMovementType.manufacturing => (
        const Color(0xFFEFEBE9),
        const Color(0xFF5D4037),
      ),
      InventoryMovementType.other => (
        const Color(0xFFF5F5F5),
        const Color(0xFF616161),
      ),
    };
  }
}
