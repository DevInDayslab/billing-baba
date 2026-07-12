import 'package:billing_baba/shared/widgets/table_filters/table_filters.dart';
import 'package:flutter/material.dart';

export 'package:billing_baba/shared/widgets/table_filters/filter_models.dart'
    show SelectColumnFilter;

/// Column header select filter — Vyapar-style dropdown.
class SaleColumnSelectFilterTrigger extends StatefulWidget {
  const SaleColumnSelectFilterTrigger({
    required this.label,
    required this.options,
    required this.initialFilter,
    required this.onApply,
    this.alignment = Alignment.centerLeft,
    this.headerStyle,
    this.iconOnly = false,
    super.key,
  });

  final String label;
  final List<String> options;
  final SelectColumnFilter? initialFilter;
  final ValueChanged<SelectColumnFilter?> onApply;
  final Alignment alignment;
  final TextStyle? headerStyle;
  final bool iconOnly;

  @override
  State<SaleColumnSelectFilterTrigger> createState() =>
      _SaleColumnSelectFilterTriggerState();
}

class _SaleColumnSelectFilterTriggerState
    extends State<SaleColumnSelectFilterTrigger> {
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

  void _togglePopover() {
    _anchor.toggle(
      context: context,
      estimatedSize: FilterPopoverSize.forType(FilterType.singleSelect),
      popover: SingleSelectFilterWidget(
        title: widget.label,
        options: widget.options,
        initialFilter: widget.initialFilter,
        onApply: widget.onApply,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isActive = widget.initialFilter?.isActive ?? false;

    return FilterColumnHeaderTrigger(
      label: widget.label,
      isActive: isActive,
      onTap: _togglePopover,
      layerLink: _layerLink,
      triggerKey: _triggerKey,
      alignment: widget.alignment,
      headerStyle: widget.headerStyle,
      iconOnly: widget.iconOnly,
    );
  }
}
