import 'package:billing_baba/features/inventory/models/inventory_movement_type.dart';
import 'package:flutter/material.dart';

/// Narrow colored dot indicating stock movement direction/type (Vyapar-style).
class InventoryMovementIndicator extends StatelessWidget {
  const InventoryMovementIndicator({
    required this.movementType,
    super.key,
  });

  final String movementType;

  @override
  Widget build(BuildContext context) {
    final type = InventoryMovementTypeMapper.fromRaw(movementType);
    final color = InventoryMovementTypeMapper.indicatorColor(type);

    return Center(
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
