import 'package:billing_baba/shared/widgets/table_filters/filter_models.dart';
import 'package:billing_baba/shared/widgets/table_filters/filter_overlay.dart';
import 'package:billing_baba/shared/widgets/table_filters/filter_popup.dart';
import 'package:billing_baba/shared/widgets/table_filters/filter_result.dart';
import 'package:billing_baba/shared/widgets/table_filters/filter_utils.dart';
import 'package:flutter/material.dart';

typedef TableFilterApplyCallback = void Function(FilterResult? result);

/// Config-driven column filter trigger — tables supply [ColumnFilter] config only.
class TableColumnFilterTrigger extends StatefulWidget {
  const TableColumnFilterTrigger({
    required this.config,
    required this.initialValue,
    required this.onApply,
    this.alignment = Alignment.centerLeft,
    this.headerStyle,
    this.iconOnly = false,
    super.key,
  });

  final ColumnFilter config;
  final Object? initialValue;
  final TableFilterApplyCallback onApply;
  final Alignment alignment;
  final TextStyle? headerStyle;
  final bool iconOnly;

  @override
  State<TableColumnFilterTrigger> createState() =>
      _TableColumnFilterTriggerState();
}

class _TableColumnFilterTriggerState extends State<TableColumnFilterTrigger> {
  final LayerLink _layerLink = LayerLink();
  final GlobalKey _triggerKey = GlobalKey();
  late final FilterOverlayAnchor _anchor = FilterOverlayAnchor(
    layerLink: _layerLink,
    triggerKey: _triggerKey,
  );

  @override
  void dispose() {
    _anchor.dispose();
    super.dispose();
  }

  bool get _isActive => FilterUtils.isFilterActive(
    widget.config.type,
    widget.initialValue,
  );

  void _togglePopover() {
    if (widget.config.disabled) return;

    _anchor.toggle(
      context: context,
      estimatedSize: FilterPopoverSize.forType(widget.config.type),
      popover: FilterPopup(
        config: widget.config,
        initialValue: widget.initialValue,
        onApply: (result) {
          _anchor.removeOverlay();
          widget.onApply(result);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FilterColumnHeaderTrigger(
      label: widget.config.title,
      isActive: _isActive,
      onTap: _togglePopover,
      layerLink: _layerLink,
      triggerKey: _triggerKey,
      alignment: widget.alignment,
      headerStyle: widget.headerStyle,
      iconOnly: widget.iconOnly,
    );
  }
}

/// Displays active filters as removable chips (developer playground + future tables).
class ActiveFilterChips extends StatelessWidget {
  const ActiveFilterChips({
    required this.filters,
    required this.configs,
    required this.onRemove,
    required this.onClearAll,
    super.key,
  });

  final Map<String, FilterResult> filters;
  final List<ColumnFilter> configs;
  final ValueChanged<String> onRemove;
  final VoidCallback onClearAll;

  @override
  Widget build(BuildContext context) {
    final active = configs
        .where((c) => filters[c.id]?.isActive ?? false)
        .toList();

    if (active.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (final config in active)
          InputChip(
            label: Text('${config.title}: ${filters[config.id]!.displayLabel}'),
            onDeleted: () => onRemove(config.id),
          ),
        TextButton(onPressed: onClearAll, child: const Text('Clear all')),
      ],
    );
  }
}
