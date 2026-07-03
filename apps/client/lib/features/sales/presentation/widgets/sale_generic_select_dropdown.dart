import 'dart:math' as math;

import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_field_decoration.dart';
import 'package:flutter/material.dart';

enum SaleDropdownHighlight { neutral, red, blue }

/// Reusable select dropdown backed by [MenuAnchor] for smooth open/scroll behavior.
class SaleGenericSelectDropdown extends StatefulWidget {
  const SaleGenericSelectDropdown({
    required this.value,
    required this.options,
    required this.onSelected,
    this.hintText = 'Select',
    this.highlight = SaleDropdownHighlight.neutral,
    this.maxMenuHeight = 250,
    this.minMenuWidth,
    this.hasError = false,
    this.compact = false,
    super.key,
  });

  final String value;
  final List<String> options;
  final ValueChanged<String> onSelected;
  final String hintText;
  final SaleDropdownHighlight highlight;
  final double maxMenuHeight;
  final double? minMenuWidth;
  final bool hasError;
  final bool compact;

  @override
  State<SaleGenericSelectDropdown> createState() =>
      SaleGenericSelectDropdownState();
}

class SaleGenericSelectDropdownState extends State<SaleGenericSelectDropdown> {
  final MenuController _menuController = MenuController();

  void closeMenu() {
    if (_menuController.isOpen) {
      _menuController.close();
    }
  }

  Color get _highlightColor => switch (widget.highlight) {
    SaleDropdownHighlight.red => const Color(0xFFD32F2F),
    SaleDropdownHighlight.blue => AppColors.primary,
    SaleDropdownHighlight.neutral => const Color(0xFFEEEEEE),
  };

  Color get _highlightTextColor => switch (widget.highlight) {
    SaleDropdownHighlight.red => const Color(0xFFD32F2F),
    SaleDropdownHighlight.blue => AppColors.primary,
    SaleDropdownHighlight.neutral => AppColors.textPrimary,
  };

  bool get _showCheckmark => widget.highlight != SaleDropdownHighlight.neutral;

  static const _defaultMinMenuWidth = 100.0;

  @override
  Widget build(BuildContext context) {
    final displayText = widget.value.isEmpty ? widget.hintText : widget.value;
    final isPlaceholder = widget.value.isEmpty;

    return LayoutBuilder(
      builder: (context, constraints) {
        final triggerWidth =
            constraints.maxWidth.isFinite && constraints.maxWidth > 0
            ? constraints.maxWidth
            : _defaultMinMenuWidth;
        final menuWidth = math.max(
          widget.minMenuWidth ?? triggerWidth,
          triggerWidth,
        );

        return MenuAnchor(
          controller: _menuController,
          alignmentOffset: Offset(0, widget.compact ? 2 : 4),
          style: MenuStyle(
            backgroundColor: const WidgetStatePropertyAll(AppColors.surface),
            elevation: const WidgetStatePropertyAll(4),
            shadowColor: const WidgetStatePropertyAll(Colors.black26),
            surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(borderRadius: AppRadius.mdBorder),
            ),
            padding: const WidgetStatePropertyAll(EdgeInsets.zero),
            minimumSize: WidgetStatePropertyAll(Size(menuWidth, 0)),
            maximumSize: WidgetStatePropertyAll(
              Size(menuWidth, widget.maxMenuHeight),
            ),
          ),
          menuChildren: [
            for (final option in widget.options) _buildMenuItem(option),
          ],
          builder: (context, controller, child) {
            return SaleFieldTrigger(
              onTap: () {
                if (controller.isOpen) {
                  controller.close();
                } else {
                  controller.open();
                }
              },
              hasError: widget.hasError,
              compact: widget.compact,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      displayText,
                      style: TextStyle(
                        fontSize: widget.compact ? 13 : 14,
                        color: isPlaceholder
                            ? Colors.grey.shade400
                            : AppColors.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(
                    Icons.keyboard_arrow_down,
                    size: widget.compact ? 16 : 18,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  MenuItemButton _buildMenuItem(String option) {
    final isSelected = option == widget.value;

    return MenuItemButton(
      onPressed: () => widget.onSelected(option),
      style: ButtonStyle(
        minimumSize: const WidgetStatePropertyAll(Size.fromHeight(40)),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
        overlayColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.hovered) && !isSelected) {
            return const Color(0xFFF5F5F5);
          }
          return null;
        }),
        backgroundColor: WidgetStatePropertyAll(
          isSelected ? _highlightColor.withValues(alpha: 0.08) : null,
        ),
        splashFactory: NoSplash.splashFactory,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              option,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? _highlightTextColor : AppColors.textPrimary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (isSelected && _showCheckmark) ...[
            const SizedBox(width: 8),
            Icon(Icons.check, size: 16, color: _highlightTextColor),
          ],
        ],
      ),
    );
  }
}
