import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/sales/models/sale_sub_route.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_page_switcher_menu.dart';
import 'package:flutter/material.dart';

/// Page header with a dropdown to switch between sale sub-pages.
class SalePageTitleBar extends StatefulWidget {
  const SalePageTitleBar({
    required this.currentRoute,
    this.onSettingsTap,
    super.key,
  });

  final String currentRoute;
  final VoidCallback? onSettingsTap;

  @override
  State<SalePageTitleBar> createState() => _SalePageTitleBarState();
}

class _SalePageTitleBarState extends State<SalePageTitleBar> {
  static const _hoverColor = Color(0xFFD32F2F);
  static const Color _defaultColor = Colors.black87;

  static const _titleStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );

  bool _isHovered = false;

  Color get _contentColor => _isHovered ? _hoverColor : _defaultColor;

  @override
  Widget build(BuildContext context) {
    final currentLabel = SaleSubRoutes.labelForRoute(widget.currentRoute);

    return Row(
      children: [
        SalePageSwitcherMenu(
          currentRoute: widget.currentRoute,
          child: MouseRegion(
            onEnter: (_) => setState(() => _isHovered = true),
            onExit: (_) => setState(() => _isHovered = false),
            cursor: SystemMouseCursors.click,
            child: Listener(
              onPointerDown: (_) => setState(() => _isHovered = false),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      currentLabel,
                      style: _titleStyle.copyWith(color: _contentColor),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.xs),
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        size: 22,
                        color: _contentColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const Spacer(),
        IconButton(
          onPressed: widget.onSettingsTap,
          icon: const Icon(Icons.settings_outlined),
          color: AppColors.textSecondary,
          tooltip: 'Settings',
        ),
      ],
    );
  }
}
