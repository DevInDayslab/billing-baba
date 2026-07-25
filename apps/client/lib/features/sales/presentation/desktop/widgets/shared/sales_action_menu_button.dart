import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

const _menuHoverBackground = Color(0xFFF5F5F5);
const Color _menuHoverForeground = AppColors.textPrimary;
const _menuDestructiveHoverBackground = Color(0xFFFFF5F5);
const Color _menuDestructiveHoverForeground = AppColors.error;
const _menuBorderColor = Color(0xFFE0E0E0);
const _menuMinWidth = 220.0;

class SalesActionMenuItem {
  const SalesActionMenuItem({
    required this.label,
    required this.onSelected,
    this.dividerBefore = false,
    this.isDestructive = false,
  });

  final String label;
  final Future<void> Function() onSelected;
  final bool dividerBefore;
  final bool isDestructive;
}

/// Three-dot overflow menu anchored to the trigger icon (filter-dropdown style).
class SalesActionMenuButton extends StatefulWidget {
  const SalesActionMenuButton({
    required this.items,
    this.iconButtonConstraints,
    super.key,
  });

  final List<SalesActionMenuItem> items;
  final BoxConstraints? iconButtonConstraints;

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
          RoundedRectangleBorder(
            borderRadius: AppRadius.mdBorder,
            side: const BorderSide(color: _menuBorderColor),
          ),
        ),
        padding: const WidgetStatePropertyAll(EdgeInsets.zero),
        minimumSize: const WidgetStatePropertyAll(Size(_menuMinWidth, 0)),
      ),
      menuChildren: [
        for (final item in widget.items) ...[
          if (item.dividerBefore)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Divider(height: 1, thickness: 1, color: _menuBorderColor),
            ),
          MenuItemButton(
            onPressed: () => _selectItem(item),
            style: _menuItemStyle(item.isDestructive),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                item.label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ],
      builder: (context, controller, child) {
        return IconButton(
          onPressed: _toggleMenu,
          icon: const Icon(Icons.more_vert, size: 18),
          color: AppColors.textSecondary,
          padding: EdgeInsets.zero,
          constraints:
              widget.iconButtonConstraints ??
              const BoxConstraints(minWidth: 32, minHeight: 32),
          tooltip: 'Actions',
        );
      },
    );
  }

  ButtonStyle _menuItemStyle(bool isDestructive) {
    return ButtonStyle(
      minimumSize: const WidgetStatePropertyAll(Size.fromHeight(44)),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 12,
        ),
      ),
      mouseCursor: const WidgetStatePropertyAll(SystemMouseCursors.click),
      overlayColor: const WidgetStatePropertyAll(Colors.transparent),
      splashFactory: NoSplash.splashFactory,
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        final isHovered = states.contains(WidgetState.hovered) ||
            states.contains(WidgetState.focused);
        if (!isHovered) return Colors.transparent;
        return isDestructive
            ? _menuDestructiveHoverBackground
            : _menuHoverBackground;
      }),
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        final isHovered = states.contains(WidgetState.hovered) ||
            states.contains(WidgetState.focused);
        if (!isHovered) {
          return isDestructive ? AppColors.error : AppColors.textPrimary;
        }
        return isDestructive
            ? _menuDestructiveHoverForeground
            : _menuHoverForeground;
      }),
    );
  }
}
