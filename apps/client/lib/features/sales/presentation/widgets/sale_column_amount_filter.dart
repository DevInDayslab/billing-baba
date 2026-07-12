import 'package:billing_baba/shared/widgets/table_filters/table_filters.dart';
import 'package:flutter/material.dart';

export 'package:billing_baba/shared/widgets/table_filters/filter_models.dart'
    show AmountColumnFilter, NumberColumnFilter, NumberColumnOperator;

/// Column header amount filter — single numeric input (Vyapar-style).
class SaleColumnAmountFilterTrigger extends StatefulWidget {
  const SaleColumnAmountFilterTrigger({
    required this.label,
    required this.initialFilter,
    required this.onApply,
    this.alignment = Alignment.centerLeft,
    this.headerStyle,
    this.prefixText = '₹ ',
    this.iconOnly = false,
    super.key,
  });

  final String label;
  final AmountColumnFilter? initialFilter;
  final ValueChanged<AmountColumnFilter?> onApply;
  final Alignment alignment;
  final TextStyle? headerStyle;
  final String prefixText;
  final bool iconOnly;

  @override
  State<SaleColumnAmountFilterTrigger> createState() =>
      _SaleColumnAmountFilterTriggerState();
}

class _SaleColumnAmountFilterTriggerState
    extends State<SaleColumnAmountFilterTrigger> {
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
      estimatedSize: FilterPopoverSize.forType(FilterType.number),
      popover: NumberFilterWidget(
        title: widget.label,
        initialFilter: widget.initialFilter,
        prefixText: widget.prefixText,
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
