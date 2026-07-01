import 'package:billing_baba/features/inventory/presentation/widgets/inventory_styles.dart';
import 'package:flutter/material.dart';

class InventoryPrimaryButton extends StatelessWidget {
  const InventoryPrimaryButton({
    required this.label,
    this.onPressed,
    this.showDropdown = false,
    this.onDropdownTap,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool showDropdown;
  final VoidCallback? onDropdownTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Row(
        children: [
          Expanded(
            child: FilledButton.icon(
              onPressed: onPressed,
              style: FilledButton.styleFrom(
                backgroundColor: inventoryPrimaryOrange,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(6),
                    bottomLeft: Radius.circular(6),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              icon: const Icon(Icons.add, size: 18),
              label: Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          if (showDropdown) ...[
            Container(width: 1, height: 40, color: Colors.white.withValues(alpha: 0.4)),
            Material(
              color: inventoryPrimaryOrange,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(6),
                bottomRight: Radius.circular(6),
              ),
              child: InkWell(
                onTap: onDropdownTap,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(6),
                  bottomRight: Radius.circular(6),
                ),
                child: const SizedBox(
                  width: 36,
                  height: 40,
                  child: Icon(Icons.arrow_drop_down, color: Colors.white),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class InventorySecondaryButton extends StatelessWidget {
  const InventorySecondaryButton({
    required this.label,
    this.onPressed,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: inventoryTabActiveColor,
        backgroundColor: const Color(0xFFE3F2FD),
        side: const BorderSide(color: Color(0xFF90CAF9)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
    );
  }
}
