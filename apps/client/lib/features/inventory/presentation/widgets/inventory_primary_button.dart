import 'package:billing_baba/features/inventory/presentation/widgets/inventory_styles.dart';
import 'package:flutter/material.dart';

class InventoryPrimaryButton extends StatelessWidget {
  const InventoryPrimaryButton({
    required this.label,
    this.onPressed,
    this.showDropdown = false,
    this.dropdownMenuItems,
    this.onDropdownSelected,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool showDropdown;
  final List<PopupMenuEntry<String>>? dropdownMenuItems;
  final ValueChanged<String>? onDropdownSelected;

  static final _mainButtonStyle = FilledButton.styleFrom(
    backgroundColor: inventoryPrimaryOrange,
    foregroundColor: Colors.white,
    elevation: 0,
    minimumSize: const Size(0, inventoryButtonHeight),
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(6),
        bottomLeft: Radius.circular(6),
      ),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 12),
  );

  static final _soloButtonStyle = FilledButton.styleFrom(
    backgroundColor: inventoryPrimaryOrange,
    foregroundColor: Colors.white,
    elevation: 0,
    minimumSize: const Size(0, inventoryButtonHeight),
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
    padding: const EdgeInsets.symmetric(horizontal: 12),
  );

  @override
  Widget build(BuildContext context) {
    if (!showDropdown) {
      return SizedBox(
        height: inventoryButtonHeight,
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: onPressed,
          style: _soloButtonStyle,
          icon: const Icon(Icons.add, size: 18),
          label: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: inventoryButtonHeight,
      width: double.infinity,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: FilledButton.icon(
              onPressed: onPressed,
              style: _mainButtonStyle,
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
          _DropdownTrigger(
            onSelected: onDropdownSelected ??
                (value) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$value coming soon')),
                  );
                },
            menuItems: dropdownMenuItems ?? _defaultDropdownMenuItems,
          ),
        ],
      ),
    );
  }
}

class _DropdownTrigger extends StatelessWidget {
  const _DropdownTrigger({
    required this.onSelected,
    required this.menuItems,
  });

  final ValueChanged<String> onSelected;
  final List<PopupMenuEntry<String>> menuItems;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: inventoryPrimaryOrange,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(6),
          bottomRight: Radius.circular(6),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 1,
            height: inventoryButtonHeight,
            color: Colors.white.withValues(alpha: 0.4),
          ),
          InventoryPopupMenuButton<String>(
            onSelected: onSelected,
            tooltip: 'More actions',
            itemBuilder: (context) => menuItems,
            child: const SizedBox(
              width: inventoryDropdownWidth,
              height: inventoryButtonHeight,
              child: Center(
                child: Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

const _defaultDropdownMenuItems = <PopupMenuEntry<String>>[
  PopupMenuItem(
    value: 'Import Items',
    child: Row(
      children: [
        Icon(Icons.description_outlined, size: 18),
        SizedBox(width: 8),
        Text('Import Items'),
      ],
    ),
  ),
];

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
