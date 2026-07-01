import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/sales/models/sale_sub_route.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

const _menuHoverColor = Color(0xFFF5F5F5);
const _itemVerticalPadding = 12.0;
const _leadingWidth = 20.0;
const _dotSize = 7.0;

/// Dropdown menu for switching between sale sub-pages.
class SalePageSwitcherMenu extends StatefulWidget {
  const SalePageSwitcherMenu({
    required this.currentRoute,
    required this.child,
    super.key,
  });

  final String currentRoute;
  final Widget child;

  @override
  State<SalePageSwitcherMenu> createState() => _SalePageSwitcherMenuState();
}

class _SalePageSwitcherMenuState extends State<SalePageSwitcherMenu> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _toggleMenu() {
    if (_overlayEntry != null) {
      _removeOverlay();
    } else {
      _showOverlay();
    }
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _selectRoute(String route) {
    _removeOverlay();
    if (route != widget.currentRoute) {
      context.go(route);
    }
  }

  void _showOverlay() {
    final overlay = Overlay.of(context);

    _overlayEntry = OverlayEntry(
      builder: (overlayContext) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _removeOverlay,
              ),
            ),
            CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: const Offset(0, 36),
              child: PhysicalModel(
                elevation: 4,
                shadowColor: Colors.black26,
                color: AppColors.surface,
                borderRadius: AppRadius.mdBorder,
                clipBehavior: Clip.antiAlias,
                child: IntrinsicWidth(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final item in SaleSubRoutes.items)
                        _SalePageSwitcherMenuItem(
                          label: item.label,
                          isSelected: item.route == widget.currentRoute,
                          onTap: () => _selectRoute(item.route),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    overlay.insert(_overlayEntry!);
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: _toggleMenu,
        behavior: HitTestBehavior.opaque,
        child: widget.child,
      ),
    );
  }
}

class _SalePageSwitcherMenuItem extends StatelessWidget {
  const _SalePageSwitcherMenuItem({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  static const _labelStyle = TextStyle(
    fontSize: 14,
    color: Colors.black87,
  );

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        hoverColor: _menuHoverColor,
        mouseCursor: SystemMouseCursors.click,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: _itemVerticalPadding,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: _leadingWidth,
                child: isSelected
                    ? Center(
                        child: Container(
                          width: _dotSize,
                          height: _dotSize,
                          decoration: const BoxDecoration(
                            color: Colors.black87,
                            shape: BoxShape.circle,
                          ),
                        ),
                      )
                    : null,
              ),
              Text(label, style: _labelStyle),
            ],
          ),
        ),
      ),
    );
  }
}
