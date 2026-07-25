import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/utilities/models/utilities_sub_route.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

const _menuHoverColor = Color(0xFFF5F5F5);

/// Page header with a dropdown to switch between utilities sub-pages.
class UtilitiesPageTitleBar extends StatefulWidget {
  const UtilitiesPageTitleBar({
    required this.currentRoute,
    this.trailing,
    super.key,
  });

  final String currentRoute;
  final Widget? trailing;

  @override
  State<UtilitiesPageTitleBar> createState() => _UtilitiesPageTitleBarState();
}

class _UtilitiesPageTitleBarState extends State<UtilitiesPageTitleBar> {
  static const _titleStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final currentLabel = UtilitiesSubRoutes.labelForRoute(widget.currentRoute);

    return Row(
      children: [
        MenuAnchor(
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
            minimumSize: const WidgetStatePropertyAll(Size(220, 0)),
          ),
          menuChildren: [
            for (final item in UtilitiesSubRoutes.items)
              MenuItemButton(
                onPressed: item.route == widget.currentRoute
                    ? null
                    : () => context.go(item.route),
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.resolveWith((states) {
                    if (item.route == widget.currentRoute) {
                      return const Color(0xFFE8EAF6);
                    }
                    if (states.contains(WidgetState.hovered)) {
                      return _menuHoverColor;
                    }
                    return Colors.transparent;
                  }),
                  padding: const WidgetStatePropertyAll(
                    EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    item.label,
                    style: TextStyle(
                      fontWeight: item.route == widget.currentRoute
                          ? FontWeight.w600
                          : FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
          ],
          builder: (context, controller, child) {
            return MouseRegion(
              onEnter: (_) => setState(() => _isHovered = true),
              onExit: (_) => setState(() => _isHovered = false),
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  if (controller.isOpen) {
                    controller.close();
                  } else {
                    controller.open();
                  }
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      currentLabel,
                      style: _titleStyle.copyWith(
                        color: _isHovered
                            ? AppColors.primary
                            : AppColors.textPrimary,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.all(AppSpacing.xs),
                      child: Icon(Icons.keyboard_arrow_down, size: 22),
                    ),
                    const SizedBox(width: 4),
                    Tooltip(
                      message: 'Help',
                      child: Icon(
                        Icons.info_outline,
                        size: 18,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const Spacer(),
        if (widget.trailing != null) widget.trailing!,
      ],
    );
  }
}
