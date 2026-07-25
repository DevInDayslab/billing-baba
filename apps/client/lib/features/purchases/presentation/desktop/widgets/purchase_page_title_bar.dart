import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/purchases/models/purchase_sub_route.dart';
import 'package:billing_baba/features/purchases/presentation/desktop/widgets/purchase_page_switcher_menu.dart';
import 'package:flutter/material.dart';

/// Page header with a dropdown to switch between purchase sub-pages.
class PurchasePageTitleBar extends StatefulWidget {
  const PurchasePageTitleBar({
    required this.currentRoute,
    this.onSettingsTap,
    this.onBack,
    this.addButtonLabel,
    this.onAddTap,
    super.key,
  });

  final String currentRoute;
  final VoidCallback? onSettingsTap;
  final VoidCallback? onBack;
  final String? addButtonLabel;
  final VoidCallback? onAddTap;

  @override
  State<PurchasePageTitleBar> createState() => _PurchasePageTitleBarState();
}

class _PurchasePageTitleBarState extends State<PurchasePageTitleBar> {
  static const _hoverColor = Color(0xFFD32F2F);
  static const _addButtonRed = Color(0xFFD32F2F);
  static const Color _defaultColor = Colors.black87;

  static const _titleStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );

  bool _isHovered = false;

  Color get _contentColor => _isHovered ? _hoverColor : _defaultColor;

  void _setHovered(bool hovered) {
    if (_isHovered == hovered) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _isHovered != hovered) {
        setState(() => _isHovered = hovered);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentLabel = PurchaseSubRoutes.labelForRoute(widget.currentRoute);

    return Row(
      children: [
        if (widget.onBack != null) ...[
          IconButton(
            onPressed: widget.onBack,
            icon: const Icon(Icons.arrow_back),
            color: AppColors.textSecondary,
            tooltip: 'Back',
            visualDensity: VisualDensity.compact,
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
        PurchasePageSwitcherMenu(
          currentRoute: widget.currentRoute,
          child: MouseRegion(
            onEnter: (_) => _setHovered(true),
            onExit: (_) => _setHovered(false),
            cursor: SystemMouseCursors.click,
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
        const Spacer(),
        if (widget.addButtonLabel != null && widget.onAddTap != null) ...[
          FilledButton.icon(
            onPressed: widget.onAddTap,
            style: FilledButton.styleFrom(
              backgroundColor: _addButtonRed,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
            ),
            icon: const Icon(Icons.add, size: 18),
            label: Text(
              widget.addButtonLabel!,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
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
