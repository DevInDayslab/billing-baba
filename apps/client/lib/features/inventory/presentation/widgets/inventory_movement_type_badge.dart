import 'package:billing_baba/features/inventory/models/inventory_movement_type.dart';
import 'package:flutter/material.dart';

class InventoryMovementTypeBadge extends StatelessWidget {
  const InventoryMovementTypeBadge({
    required this.movementType,
    this.label,
    super.key,
  });

  final String movementType;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final type = InventoryMovementTypeMapper.fromRaw(movementType);
    final (background, foreground) =
        InventoryMovementTypeMapper.badgeColors(type);
    final text = label ?? InventoryMovementTypeMapper.label(type);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: foreground,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
