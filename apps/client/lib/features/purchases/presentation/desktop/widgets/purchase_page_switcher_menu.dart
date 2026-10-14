import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/purchases/models/purchase_sub_route.dart';
import 'package:billing_baba/features/settings/application/general_settings_provider.dart';
import 'package:billing_baba/features/settings/models/general_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

const _menuHoverColor = Color(0xFFF5F5F5);
const _itemVerticalPadding = 12.0;
const _leadingWidth = 20.0;
const _dotSize = 7.0;

/// Dropdown menu for switching between purchase sub-pages.
class PurchasePageSwitcherMenu extends ConsumerWidget {
  const PurchasePageSwitcherMenu({
    required this.currentRoute,
    required this.child,
    super.key,
  });

  final String currentRoute;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final general =
        ref.watch(generalSettingsProvider).value ?? GeneralSettings.defaults();
    final visibleRoutes = PurchaseSubRoutes.items
        .where((item) => general.isNavRouteVisible(item.route))
        .toList();

    return MenuAnchor(
      alignmentOffset: const Offset(0, 4),
      style: MenuStyle(
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
        for (final item in visibleRoutes)
          _PageSwitcherMenuItem(
            label: item.label,
            isSelected: item.route == currentRoute,
            onSelected: () {
              if (item.route != currentRoute) {
                context.go(item.route);
              }
            },
          ),
      ],
      builder: (context, controller, child) {
        return GestureDetector(
          onTap: () {
            if (controller.isOpen) {
              controller.close();
            } else {
              controller.open();
            }
          },
          behavior: HitTestBehavior.opaque,
          child: this.child,
        );
      },
    );
  }
}

class _PageSwitcherMenuItem extends StatelessWidget {
  const _PageSwitcherMenuItem({
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onSelected;

  static const _labelStyle = TextStyle(
    fontSize: 14,
    color: Colors.black87,
  );

  @override
  Widget build(BuildContext context) {
    return MenuItemButton(
      onPressed: onSelected,
      style: ButtonStyle(
        minimumSize: const WidgetStatePropertyAll(Size.fromHeight(44)),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: _itemVerticalPadding,
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
    );
  }
}
