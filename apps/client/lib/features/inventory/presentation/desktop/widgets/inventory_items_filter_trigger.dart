import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/models/inventory_item_filters.dart';
import 'package:billing_baba/shared/widgets/filter_icon.dart';
import 'package:billing_baba/shared/widgets/table_filters/table_filters.dart';
import 'package:flutter/material.dart';

/// Inventory list filter trigger — multi-select checkboxes with Apply/Clear.
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
  late final FilterOverlayAnchor _anchor = FilterOverlayAnchor(
    layerLink: _layerLink,
    triggerKey: _triggerKey,
  );

  static final Map<String, InventoryItemFilterOption> _optionByLabel = {
    for (final option in inventoryListFilterOptions) option.label: option,
  };

  @override
  void dispose() {
    _anchor.dispose();
    super.dispose();
  }

  void _togglePopover() {
    final options = inventoryListFilterOptions
        .map((o) => o.label)
        .toList(growable: false);
    _anchor.toggle(
      context: context,
      estimatedSize: FilterPopoverSize.forType(FilterType.multiSelect),
      popover: FilterPopup(
        config: ColumnFilter(
          id: 'inventoryItems',
          title: 'Filter items',
          type: FilterType.multiSelect,
          values: options,
          searchable: false,
          exclusivePairs: const [
            ('Show Raw Materials Only', "Don't Show Raw Materials"),
          ],
        ),
        initialValue: widget.initialFilters.hasActiveFilters
            ? MultiSelectColumnFilter(
                values: widget.initialFilters.selected
                    .map((o) => o.label)
                    .toSet(),
              )
            : null,
        onApply: (result) {
          _anchor.removeOverlay();
          final filter =
              FilterUtils.fromResult(result) as MultiSelectColumnFilter?;
          if (filter == null || filter.values.isEmpty) {
            widget.onApply(
              InventoryItemFiltersState(
                brandIds: widget.initialFilters.brandIds,
                categoryIds: widget.initialFilters.categoryIds,
              ),
            );
            return;
          }
          final selected = <InventoryItemFilterOption>{};
          for (final label in filter.values) {
            final match = _optionByLabel[label];
            if (match != null) selected.add(match);
          }
          widget.onApply(
            InventoryItemFiltersState(
              selected: selected,
              brandIds: widget.initialFilters.brandIds,
              categoryIds: widget.initialFilters.categoryIds,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isActive = widget.initialFilters.hasActiveFilters;
    final iconSize = widget.compact ? 14.0 : 20.0;
    final iconColor = isActive ? AppColors.error : AppColors.textSecondary;

    if (widget.compact) {
      return CompositedTransformTarget(
        link: _layerLink,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: InkWell(
            key: _triggerKey,
            onTap: _togglePopover,
            mouseCursor: SystemMouseCursors.click,
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: Tooltip(
              message: 'Filter items',
              child: SizedBox(
                width: 22,
                height: 22,
                child: Center(
                  child: AppFilterIcon(color: iconColor, size: iconSize),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return CompositedTransformTarget(
      link: _layerLink,
      child: IconButton(
        key: _triggerKey,
        onPressed: _togglePopover,
        icon: AppFilterIcon(color: iconColor, size: iconSize),
        tooltip: 'Filter items',
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
      ),
    );
  }
}
