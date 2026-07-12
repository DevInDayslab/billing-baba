import 'package:billing_baba/shared/widgets/table_filters/table_filters.dart';
import 'package:flutter/material.dart';

export 'package:billing_baba/shared/widgets/table_filters/filter_models.dart'
    show DateColumnFilter, DateColumnOperator;

/// Column header date filter — popover with operator dropdown, date field, Clear/Apply.
class SaleColumnDateFilterTrigger extends StatefulWidget {
  const SaleColumnDateFilterTrigger({
    required this.label,
    required this.initialFilter,
    required this.onApply,
    this.alignment = Alignment.centerLeft,
    this.headerStyle,
    this.iconOnly = false,
    super.key,
  });

  final String label;
  final DateColumnFilter? initialFilter;
  final ValueChanged<DateColumnFilter?> onApply;
  final Alignment alignment;
  final TextStyle? headerStyle;
  final bool iconOnly;

  @override
  State<SaleColumnDateFilterTrigger> createState() =>
      _SaleColumnDateFilterTriggerState();
}

class _SaleColumnDateFilterTriggerState
    extends State<SaleColumnDateFilterTrigger> {
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
      estimatedSize: FilterPopoverSize.forType(FilterType.date),
      popover: DateFilterWidget(
        title: widget.label,
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
