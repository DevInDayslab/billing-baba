import 'dart:async';

import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/models/category_model.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/add_category_dialog.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_field_decoration.dart';
import 'package:billing_baba/shared/widgets/app_ellipsis_text.dart';
import 'package:billing_baba/shared/widgets/forms/form_spacing.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Category field for add item — search in the trigger and category list overlay.
class AddItemCategoryPickerField extends StatefulWidget {
  const AddItemCategoryPickerField({
    required this.categories,
    required this.selectedCategoryId,
    required this.selectedCategoryName,
    required this.onCategorySelected,
    this.borderless = false,
    this.triggerHeight,
    super.key,
  });

  final List<InventoryCategory> categories;
  final String? selectedCategoryId;
  final String? selectedCategoryName;
  final ValueChanged<String?> onCategorySelected;
  final bool borderless;
  final double? triggerHeight;

  @override
  State<AddItemCategoryPickerField> createState() =>
      _AddItemCategoryPickerFieldState();
}

class _AddItemCategoryPickerFieldState
    extends State<AddItemCategoryPickerField> {
  final LayerLink _layerLink = LayerLink();
  final GlobalKey _triggerKey = GlobalKey();
  OverlayEntry? _overlayEntry;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isOpen = false;

  @override
  void dispose() {
    _removeOverlay();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _searchController.clear();
    _searchFocusNode.unfocus();
    if (_isOpen) {
      setState(() => _isOpen = false);
    }
  }

  void _onSearchChanged(String _) {
    _overlayEntry?.markNeedsBuild();
  }

  Future<void> _createCategory() async {
    final dialogContext = context;
    _removeOverlay();
    final created = await showAddCategoryDialog(dialogContext);
    if (!mounted || created == null) return;
    widget.onCategorySelected(created.id);
  }

  List<InventoryCategory> _sortedCategories() {
    final copy = List<InventoryCategory>.from(widget.categories);
    copy.sort((a, b) {
      if (a.isUncategorized != b.isUncategorized) {
        return a.isUncategorized ? -1 : 1;
      }
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
    return copy;
  }

  List<InventoryCategory> _filterCategories(
    List<InventoryCategory> source,
    String query,
  ) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return source;
    return source
        .where((c) => c.name.toLowerCase().contains(normalized))
        .toList();
  }

  void _selectCategory(InventoryCategory category) {
    _removeOverlay();
    widget.onCategorySelected(category.id);
  }

  Future<void> _openOverlay() async {
    if (_overlayEntry != null) return;
    _searchController.clear();
    setState(() => _isOpen = true);
    if (!mounted) return;

    final renderBox =
        _triggerKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) {
      setState(() => _isOpen = false);
      return;
    }

    final triggerWidth = renderBox.size.width;
    final overlay = Overlay.of(context);

    _overlayEntry = OverlayEntry(
      builder: (overlayContext) {
        return StatefulBuilder(
          builder: (context, setOverlayState) {
            final query = _searchController.text;
            final all = _filterCategories(_sortedCategories(), query);
            final menuWidth = triggerWidth;

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
                  targetAnchor: Alignment.bottomLeft,
                  offset: const Offset(0, 4),
                  child: Material(
                    elevation: 8,
                    shadowColor: Colors.black26,
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    clipBehavior: Clip.antiAlias,
                    child: SizedBox(
                      width: menuWidth,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 420),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
                              child: _CreateNewOptionRow(
                                label: 'Add new category',
                                onTap: () => unawaited(_createCategory()),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.only(top: 4),
                              child: _SectionHeader(
                                icon: LucideIcons.layoutGrid,
                                title: 'All Categories',
                              ),
                            ),
                            Flexible(
                              child: all.isEmpty
                                  ? Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Text(
                                        'No categories found',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: AppColors.textSecondary,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    )
                                  : ListView.builder(
                                      shrinkWrap: true,
                                      padding: const EdgeInsets.fromLTRB(
                                        8,
                                        0,
                                        8,
                                        8,
                                      ),
                                      itemCount: all.length,
                                      itemBuilder: (context, index) {
                                        final category = all[index];
                                        final isSelected =
                                            category.id ==
                                            widget.selectedCategoryId;
                                        return _CategoryListTile(
                                          category: category,
                                          isSelected: isSelected,
                                          onTap: () =>
                                              _selectCategory(category),
                                        );
                                      },
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    overlay.insert(_overlayEntry!);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _isOpen) {
        _searchFocusNode.requestFocus();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final closedHeight =
        widget.triggerHeight ??
        (widget.borderless ? saleFieldHeight - 20 : saleFieldHeight);
    final display = widget.selectedCategoryName ?? '';

    return CompositedTransformTarget(
      link: _layerLink,
      child: SizedBox(
        key: _triggerKey,
        height: FormSpacing.inputHeight,
        width: double.infinity,
        child: _isOpen
            ? _CategorySearchBar(
                height: FormSpacing.inputHeight,
                controller: _searchController,
                focusNode: _searchFocusNode,
                onChanged: _onSearchChanged,
              )
            : Center(
                child: SizedBox(
                  height: closedHeight,
                  width: double.infinity,
                  child: SaleFieldTrigger(
                    onTap: _openOverlay,
                    borderless: widget.borderless,
                    child: Row(
                      children: [
                        Expanded(
                          child: AppEllipsisText(
                            display.isEmpty ? ' ' : display,
                            style: saleFieldTextStyle.copyWith(
                              color: display.isEmpty
                                  ? Colors.transparent
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.keyboard_arrow_down,
                          size: 18,
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

class _CategorySearchBar extends StatelessWidget {
  const _CategorySearchBar({
    required this.height,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  final double height;
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.35),
          ),
          color: AppColors.surface,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                LucideIcons.search,
                size: 16,
                color: AppColors.textSecondary.withValues(alpha: 0.8),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  style: saleFieldTextStyle.copyWith(
                    fontSize: 13,
                    height: 1.2,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    isCollapsed: true,
                    hintText: 'Search category...',
                    hintStyle: TextStyle(
                      fontSize: 13,
                      height: 1.2,
                      color: AppColors.textSecondary.withValues(alpha: 0.75),
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: onChanged,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CreateNewOptionRow extends StatelessWidget {
  const _CreateNewOptionRow({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Row(
            children: [
              Icon(
                LucideIcons.plus,
                size: 16,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon,
    required this.title,
  });

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 8, 6),
      child: Row(
        children: [
          Icon(
            icon,
            size: 14,
            color: AppColors.textSecondary.withValues(alpha: 0.85),
          ),
          const SizedBox(width: 6),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryListTile extends StatelessWidget {
  const _CategoryListTile({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  final InventoryCategory category;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Material(
        color: isSelected
            ? AppColors.primary.withValues(alpha: 0.08)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
            child: Text(
              category.name,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: AppColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }
}
