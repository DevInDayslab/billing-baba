import 'package:billing_baba/shared/widgets/table_filters/table_filters.dart';
import 'package:flutter/material.dart';

export 'package:billing_baba/shared/widgets/table_filters/filter_models.dart'
    show RangeSliderColumnFilter;

/// Column header range slider filter — loyalty points, ratings, percentages.
class SaleColumnRangeSliderFilterTrigger extends StatefulWidget {
  const SaleColumnRangeSliderFilterTrigger({
    required this.label,
    required this.initialFilter,
    required this.onApply,
    this.alignment = Alignment.centerLeft,
    this.headerStyle,
    this.maxValue = RangeSliderColumnFilter.defaultCeiling,
    this.rangeLabel = 'Range',
    this.iconOnly = false,
    super.key,
  });

  final String label;
  final RangeSliderColumnFilter? initialFilter;
  final ValueChanged<RangeSliderColumnFilter?> onApply;
  final Alignment alignment;
  final TextStyle? headerStyle;
  final double maxValue;
  final String rangeLabel;
  final bool iconOnly;

  @override
  State<SaleColumnRangeSliderFilterTrigger> createState() =>
      _SaleColumnRangeSliderFilterTriggerState();
}

class _SaleColumnRangeSliderFilterTriggerState
    extends State<SaleColumnRangeSliderFilterTrigger> {
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
      estimatedSize: FilterPopoverSize.forType(FilterType.rangeSlider),
      popover: RangeSliderFilterWidget(
        title: widget.label,
        initialFilter: widget.initialFilter,
        maxValue: widget.maxValue,
        rangeLabel: widget.rangeLabel,
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
