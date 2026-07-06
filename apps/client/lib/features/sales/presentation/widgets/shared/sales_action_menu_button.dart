import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

const _menuHoverColor = Color(0xFFF5F5F5);

class SalesActionMenuItem {
  const SalesActionMenuItem({
    required this.label,
    required this.onSelected,
  });

  final String label;
  final Future<void> Function() onSelected;
}

/// Three-dot overflow menu anchored to the trigger icon (filter-dropdown style).
class SalesActionMenuButton extends StatefulWidget {
  const SalesActionMenuButton({
    required this.items,
    super.key,
  });

  final List<SalesActionMenuItem> items;

  @override
  State<SalesActionMenuButton> createState() => _SalesActionMenuButtonState();
}

class _SalesActionMenuButtonState extends State<SalesActionMenuButton> {
  final MenuController _menuController = MenuController();

  void _toggleMenu() {
    if (_menuController.isOpen) {
      _menuController.close();
    } else {
      _menuController.open();
    }
  }

  Future<void> _selectItem(SalesActionMenuItem item) async {
    _menuController.close();
    await item.onSelected();
  }

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      controller: _menuController,
      alignmentOffset: const Offset(0, 4),
      style: MenuStyle(
        alignment: AlignmentDirectional.topEnd,
        backgroundColor: const WidgetStatePropertyAll(AppColors.surface),
        elevation: const WidgetStatePropertyAll(4),
        shadowColor: const WidgetStatePropertyAll(Colors.black26),
        surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: AppRadius.mdBorder),
        ),
        padding: const WidgetStatePropertyAll(EdgeInsets.zero),
        minimumSize: const WidgetStatePropertyAll(Size(200, 0)),
      ),
      menuChildren: [
        for (final item in widget.items)
          MenuItemButton(
            onPressed: () => _selectItem(item),
            style: ButtonStyle(
              minimumSize: const WidgetStatePropertyAll(Size.fromHeight(44)),
              padding: const WidgetStatePropertyAll(
                EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: 12,
                ),
              ),
              overlayColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.hovered)) {
                  return _menuHoverColor;
                }
                return null;
              }),
              splashFactory: NoSplash.splashFactory,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                item.label,
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ),
          ),
      ],
      builder: (context, controller, child) {
        return IconButton(
          onPressed: _toggleMenu,
          icon: const Icon(Icons.more_vert, size: 18),
          color: AppColors.textSecondary,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          tooltip: 'Actions',
        );
      },
    );
  }
}
