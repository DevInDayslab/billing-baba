import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/models/inventory_item_filters.dart';
import 'package:flutter/material.dart';

const _clearButtonBg = Color(0xFFEEEEEE);
const _popoverWidth = 240.0;

/// Inventory list filter trigger — same overlay/popover pattern as Sales column
/// filters, with multi-select checkboxes and Apply/Clear actions.
class InventoryItemsFilterTrigger extends StatefulWidget {
  const InventoryItemsFilterTrigger({
    required this.initialFilters,
    required this.onApply,
    this.compact = false,
    super.key,
  });

  final InventoryItemFiltersState initialFilters;
  final ValueChanged<InventoryItemFiltersState> onApply;
  final bool compact;

  @override
  State<InventoryItemsFilterTrigger> createState() =>
      _InventoryItemsFilterTriggerState();
}

class _InventoryItemsFilterTriggerState
    extends State<InventoryItemsFilterTrigger> {
  final LayerLink _layerLink = LayerLink();
  final GlobalKey _triggerKey = GlobalKey();
  OverlayEntry? _overlayEntry;

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _togglePopover() {
    if (_overlayEntry != null) {
      _removeOverlay();
      return;
    }
    _showPopover();
  }

  void _showPopover() {
    final renderBox =
        _triggerKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) return;

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
              targetAnchor: Alignment.bottomRight,
              followerAnchor: Alignment.topRight,
              offset: const Offset(0, 4),
              child: _InventoryItemsFilterPopover(
                initialFilters: widget.initialFilters,
                onApply: (filters) {
                  _removeOverlay();
                  widget.onApply(filters);
                },
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
    final isActive = widget.initialFilters.hasActiveFilters;
    final iconSize = widget.compact ? 14.0 : 20.0;

    return CompositedTransformTarget(
      link: _layerLink,
      child: IconButton(
        key: _triggerKey,
        onPressed: _togglePopover,
        icon: Icon(
          Icons.filter_list,
          size: iconSize,
          color: isActive ? AppColors.error : AppColors.textSecondary,
        ),
        tooltip: 'Filter items',
        padding: EdgeInsets.zero,
        constraints: BoxConstraints(
          minWidth: widget.compact ? 24 : 36,
          minHeight: widget.compact ? 24 : 36,
        ),
        visualDensity: widget.compact ? VisualDensity.compact : VisualDensity.standard,
      ),
    );
  }
}

class _InventoryItemsFilterPopover extends StatefulWidget {
  const _InventoryItemsFilterPopover({
    required this.initialFilters,
    required this.onApply,
  });

  final InventoryItemFiltersState initialFilters;
  final ValueChanged<InventoryItemFiltersState> onApply;

  @override
  State<_InventoryItemsFilterPopover> createState() =>
      _InventoryItemsFilterPopoverState();
}

class _InventoryItemsFilterPopoverState
    extends State<_InventoryItemsFilterPopover> {
  late Set<InventoryItemFilterOption> _selected;

  @override
  void initState() {
    super.initState();
    _selected = Set<InventoryItemFilterOption>.from(widget.initialFilters.selected);
  }

  void _toggle(InventoryItemFilterOption option) {
    setState(() {
      if (_selected.contains(option)) {
        _selected.remove(option);
        return;
      }

      if (option == InventoryItemFilterOption.showRawMaterialsOnly) {
        _selected.remove(InventoryItemFilterOption.hideRawMaterials);
      } else if (option == InventoryItemFilterOption.hideRawMaterials) {
        _selected.remove(InventoryItemFilterOption.showRawMaterialsOnly);
      }

      _selected.add(option);
    });
  }

  void _apply() {
    widget.onApply(InventoryItemFiltersState(selected: _selected));
  }

  void _clear() {
    widget.onApply(const InventoryItemFiltersState());
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      shadowColor: Colors.black26,
      color: AppColors.surface,
      borderRadius: AppRadius.mdBorder,
      child: SizedBox(
        width: _popoverWidth,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 220),
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    for (final option in inventoryListFilterOptions)
                      _FilterCheckboxTile(
                        label: option.label,
                        isSelected: _selected.contains(option),
                        onChanged: () => _toggle(option),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _FilterActionButton(
                      label: 'Clear',
                      backgroundColor: _clearButtonBg,
                      foregroundColor: AppColors.textPrimary,
                      onPressed: _clear,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    _FilterActionButton(
                      label: 'Apply',
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.surface,
                      onPressed: _apply,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterCheckboxTile extends StatelessWidget {
  const _FilterCheckboxTile({
    required this.label,
    required this.isSelected,
    required this.onChanged,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onChanged;

  static const _hoverColor = Color(0xFFF5F5F5);

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onChanged,
        hoverColor: _hoverColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xs,
            vertical: 6,
          ),
          child: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: Checkbox(
                  value: isSelected,
                  onChanged: (_) => onChanged(),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterActionButton extends StatelessWidget {
  const _FilterActionButton({
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.onPressed,
  });

  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: foregroundColor,
            ),
          ),
        ),
      ),
    );
  }
}
