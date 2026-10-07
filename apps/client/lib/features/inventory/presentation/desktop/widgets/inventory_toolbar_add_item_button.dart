import 'package:billing_baba/features/collaboration/domain/models/permission_action.dart';
import 'package:billing_baba/features/collaboration/domain/models/permission_module.dart';
import 'package:billing_baba/features/collaboration/permissions/permission_gate.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/inventory_styles.dart';
import 'package:flutter/material.dart';

const _toolbarControlHeight = 36.0;
const _importItemsMenuValue = 'import_items';

/// Compact split [Add Item] control for the inventory list toolbar.
class InventoryToolbarAddItemButton extends StatelessWidget {
  const InventoryToolbarAddItemButton({
    required this.label,
    required this.onAddPressed,
    required this.onImportItems,
    this.iconOnly = false,
    super.key,
  });

  final String label;
  final VoidCallback onAddPressed;
  final VoidCallback onImportItems;
  final bool iconOnly;

  static final ButtonStyle _mainStyle = FilledButton.styleFrom(
    backgroundColor: inventoryPrimaryOrange,
    foregroundColor: Colors.white,
    elevation: 0,
    minimumSize: const Size(0, _toolbarControlHeight),
    maximumSize: const Size(double.infinity, _toolbarControlHeight),
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    padding: const EdgeInsets.symmetric(horizontal: 10),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(6),
        bottomLeft: Radius.circular(6),
      ),
    ),
  );

  static final ButtonStyle _soloStyle = FilledButton.styleFrom(
    backgroundColor: inventoryPrimaryOrange,
    foregroundColor: Colors.white,
    elevation: 0,
    minimumSize: const Size(_toolbarControlHeight, _toolbarControlHeight),
    maximumSize: const Size(_toolbarControlHeight, _toolbarControlHeight),
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    padding: EdgeInsets.zero,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
  );

  void _onMenuSelected(String value) {
    if (value == _importItemsMenuValue) {
      onImportItems();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PermissionGate(
      module: PermissionModule.item,
      action: PermissionAction.create,
      child: iconOnly
          ? Tooltip(
              message: label,
              child: FilledButton(
                onPressed: onAddPressed,
                style: _soloStyle,
                child: const Icon(Icons.add, size: 18),
              ),
            )
          : SizedBox(
              height: _toolbarControlHeight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Tooltip(
                    message: label,
                    child: FilledButton(
                      onPressed: onAddPressed,
                      style: _mainStyle,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.add, size: 18),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  DecoratedBox(
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
                          height: _toolbarControlHeight,
                          color: Colors.white.withValues(alpha: 0.4),
                        ),
                        InventoryPopupMenuButton<String>(
                          tooltip: 'More add options',
                          onSelected: _onMenuSelected,
                          itemBuilder: (context) => const [
                            PopupMenuItem(
                              value: _importItemsMenuValue,
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.description_outlined,
                                    size: 18,
                                    color: inventoryTabActiveColor,
                                  ),
                                  SizedBox(width: 8),
                                  Text('Import Items'),
                                ],
                              ),
                            ),
                          ],
                          child: const SizedBox(
                            width: inventoryDropdownWidth,
                            height: _toolbarControlHeight,
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
                  ),
                ],
              ),
            ),
    );
  }
}
