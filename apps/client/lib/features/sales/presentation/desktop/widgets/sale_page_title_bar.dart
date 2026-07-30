import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/collaboration/application/permission_service_provider.dart';
import 'package:billing_baba/features/sales/application/sales_document_scope_permissions.dart';
import 'package:billing_baba/features/sales/models/sale_sub_route.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_page_switcher_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Page header with a dropdown to switch between sale sub-pages.
class SalePageTitleBar extends ConsumerStatefulWidget {
  const SalePageTitleBar({
    required this.currentRoute,
    this.onSettingsTap,
    this.onBack,
    this.addButtonLabel,
    this.onAddTap,
    this.addButtonColor,
    super.key,
  });

  final String currentRoute;
  final VoidCallback? onSettingsTap;
  final VoidCallback? onBack;
  final String? addButtonLabel;
  final VoidCallback? onAddTap;
  final Color? addButtonColor;

  @override
  ConsumerState<SalePageTitleBar> createState() => _SalePageTitleBarState();
}

class _SalePageTitleBarState extends ConsumerState<SalePageTitleBar> {
  static const Color _hoverColor = AppColors.primary;
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
    final currentLabel = SaleSubRoutes.labelForRoute(widget.currentRoute);

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 480;
        final module = permissionModuleForSaleRoute(widget.currentRoute);
        final showAddButton =
            widget.addButtonLabel != null &&
            widget.onAddTap != null &&
            ref.watch(
              permissionServiceProvider.select(
                (service) => service.canCreate(module),
              ),
            );
        final addButtonColor = widget.addButtonColor ?? AppColors.primary;

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
            Expanded(
              child: SalePageSwitcherMenu(
                currentRoute: widget.currentRoute,
                child: MouseRegion(
                  onEnter: (_) => _setHovered(true),
                  onExit: (_) => _setHovered(false),
                  cursor: SystemMouseCursors.click,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.xs,
                    ),
                    child: Row(
                      children: [
                        Flexible(
                          child: Text(
                            currentLabel,
                            style: _titleStyle.copyWith(color: _contentColor),
                            overflow: TextOverflow.ellipsis,
                          ),
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
            if (showAddButton) ...[
              if (compact)
                IconButton.filled(
                  onPressed: widget.onAddTap,
                  style: IconButton.styleFrom(
                    backgroundColor: addButtonColor,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.add, size: 20),
                  tooltip: widget.addButtonLabel,
                )
              else
                FilledButton.icon(
                  onPressed: widget.onAddTap,
                  style: FilledButton.styleFrom(
                    backgroundColor: addButtonColor,
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
            if (widget.onSettingsTap != null)
              IconButton(
                onPressed: widget.onSettingsTap,
                icon: const Icon(Icons.settings_outlined),
                color: AppColors.textSecondary,
                tooltip: 'Settings',
                visualDensity: VisualDensity.compact,
              ),
          ],
        );
      },
    );
  }
}
