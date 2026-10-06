import 'dart:math' as math;

import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_field_decoration.dart';
import 'package:billing_baba/shared/widgets/app_ellipsis_text.dart';
import 'package:flutter/material.dart';

/// Select field that opens a menu and uses the trigger as an inline search bar.
class SaleSearchableSelectDropdown extends StatefulWidget {
  const SaleSearchableSelectDropdown({
    required this.value,
    required this.options,
    required this.onSelected,
    this.borderless = false,
    this.triggerHeight,
    this.searchHint = 'Search',
    this.hasError = false,
    super.key,
  });

  final String value;
  final List<String> options;
  final ValueChanged<String> onSelected;
  final bool borderless;
  final double? triggerHeight;
  final String searchHint;
  final bool hasError;

  @override
  State<SaleSearchableSelectDropdown> createState() =>
      _SaleSearchableSelectDropdownState();
}

class _SaleSearchableSelectDropdownState
    extends State<SaleSearchableSelectDropdown> {
  final MenuController _menuController = MenuController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  List<String> _filteredOptions() {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return widget.options;
    return widget.options
        .where((option) => option.toLowerCase().contains(query))
        .toList();
  }

  void _openMenu(MenuController controller) {
    _searchController.clear();
    controller.open();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _searchFocusNode.requestFocus();
    });
  }

  void _closeMenu(MenuController controller) {
    controller.close();
    _searchController.clear();
    _searchFocusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final triggerWidth =
            constraints.maxWidth.isFinite && constraints.maxWidth > 0
            ? constraints.maxWidth
            : 100.0;
        final menuWidth = math.max(triggerWidth, triggerWidth);
        final height =
            widget.triggerHeight ??
            (widget.borderless ? saleFieldHeight - 20 : saleFieldHeight);

        return MenuAnchor(
          controller: _menuController,
          useRootOverlay: true,
          consumeOutsideTap: true,
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
            minimumSize: WidgetStatePropertyAll(Size(menuWidth, 0)),
            maximumSize: WidgetStatePropertyAll(Size(menuWidth, 250)),
          ),
          menuChildren: _buildMenuChildren(),
          builder: (context, controller, child) {
            final isOpen = controller.isOpen;
            if (isOpen) {
              return SizedBox(
                height: height,
                width: double.infinity,
                child: Container(
                  width: double.infinity,
                  height: height,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F4F5),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: const Color(0xFFE4E4E7)),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Row(
                    children: [
                      Icon(
                        Icons.search,
                        size: 15,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          focusNode: _searchFocusNode,
                          style: saleFieldTextStyle.copyWith(
                            height: 1,
                            fontSize: 13,
                          ),
                          decoration: InputDecoration(
                            isDense: true,
                            isCollapsed: true,
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            hintText: widget.searchHint,
                            hintStyle: TextStyle(
                              fontSize: 13,
                              height: 1,
                              color: Colors.grey.shade500,
                            ),
                            contentPadding: EdgeInsets.zero,
                          ),
                          onChanged: (_) => setState(() {}),
                          onSubmitted: (_) => _closeMenu(controller),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _closeMenu(controller),
                        child: const Padding(
                          padding: EdgeInsets.only(left: 2),
                          child: Icon(
                            Icons.keyboard_arrow_down,
                            size: 18,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            final row = Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: AppEllipsisText(
                    widget.value.isEmpty ? ' ' : widget.value,
                    style: saleFieldTextStyle.copyWith(
                      color: widget.value.isEmpty
                          ? Colors.transparent
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => _openMenu(controller),
                  child: const Icon(
                    Icons.keyboard_arrow_down,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            );

            return SizedBox(
              height: height,
              width: double.infinity,
              child: SaleFieldTrigger(
                onTap: () => _openMenu(controller),
                borderless: widget.borderless,
                hasError: widget.hasError,
                child: row,
              ),
            );
          },
        );
      },
    );
  }

  List<Widget> _buildMenuChildren() {
    final filtered = _filteredOptions();
    if (filtered.isEmpty) {
      return [
        MenuItemButton(
          child: Text(
            'No matches',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
          ),
        ),
      ];
    }

    return filtered.map((option) {
      final isSelected = option == widget.value;
      return MenuItemButton(
        onPressed: () {
          widget.onSelected(option);
          _closeMenu(_menuController);
          setState(() {});
        },
        style: const ButtonStyle(
          minimumSize: WidgetStatePropertyAll(Size.fromHeight(40)),
          padding: WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                option,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              const Icon(Icons.check, size: 16, color: AppColors.primary),
            ],
          ],
        ),
      );
    }).toList();
  }
}
