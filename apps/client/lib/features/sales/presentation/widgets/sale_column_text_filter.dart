import 'package:billing_baba/shared/widgets/table_filters/table_filters.dart';
import 'package:flutter/material.dart';

export 'package:billing_baba/shared/widgets/table_filters/filter_models.dart'
    show TextColumnFilter, TextColumnOperator;

/// Column header text filter — popover with operator dropdown, text field, Clear/Apply.
class SaleColumnTextFilterTrigger extends StatefulWidget {
  const SaleColumnTextFilterTrigger({
    required this.label,
    required this.initialFilter,
    required this.onApply,
    this.alignment = Alignment.centerLeft,
    this.headerStyle,
    this.hintText = 'Enter value',
    this.iconOnly = false,
    super.key,
  });

  final String label;
  final TextColumnFilter? initialFilter;
  final ValueChanged<TextColumnFilter?> onApply;
  final Alignment alignment;
  final TextStyle? headerStyle;
  final String hintText;
  final bool iconOnly;

  @override
  State<SaleColumnTextFilterTrigger> createState() =>
      _SaleColumnTextFilterTriggerState();
}

class _SaleColumnTextFilterTriggerState
    extends State<SaleColumnTextFilterTrigger> {
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
      estimatedSize: FilterPopoverSize.forType(FilterType.text),
      popover: TextFilterWidget(
        title: widget.label,
        initialFilter: widget.initialFilter,
        hintText: widget.hintText,
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
