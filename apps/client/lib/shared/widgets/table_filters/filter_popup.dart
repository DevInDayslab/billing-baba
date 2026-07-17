import 'package:billing_baba/shared/widgets/table_filters/filter_models.dart';
import 'package:billing_baba/shared/widgets/table_filters/filter_result.dart';
import 'package:billing_baba/shared/widgets/table_filters/filter_types.dart';
import 'package:billing_baba/shared/widgets/table_filters/filter_utils.dart';
import 'package:billing_baba/shared/widgets/table_filters/widgets/boolean_filter_widget.dart';
import 'package:billing_baba/shared/widgets/table_filters/widgets/date_filter_widget.dart';
import 'package:billing_baba/shared/widgets/table_filters/widgets/multi_select_filter_widget.dart';
import 'package:billing_baba/shared/widgets/table_filters/widgets/number_filter_widget.dart';
import 'package:billing_baba/shared/widgets/table_filters/widgets/range_slider_filter_widget.dart';
import 'package:billing_baba/shared/widgets/table_filters/widgets/single_select_filter_widget.dart';
import 'package:billing_baba/shared/widgets/table_filters/widgets/text_filter_widget.dart';
import 'package:flutter/material.dart';

typedef FilterApplyCallback = void Function(FilterResult? result);

/// Renders the correct filter popover from a [ColumnFilter] config.
class FilterPopup extends StatelessWidget {
  const FilterPopup({
    required this.config,
    required this.initialValue,
    required this.onApply,
    super.key,
  });

  final ColumnFilter config;
  final Object? initialValue;
  final FilterApplyCallback onApply;

  void _applyResult(Object? value) {
    onApply(FilterUtils.toResult(value));
  }

  @override
  Widget build(BuildContext context) {
    if (config.disabled) {
      return Opacity(
        opacity: 0.5,
        child: IgnorePointer(child: _buildContent()),
      );
    }
    return _buildContent();
  }

  Widget _buildContent() {
    if (config.customBuilder != null) {
      return config.customBuilder!(
        config: config,
        initialValue: initialValue,
        onApply: _applyResult,
      );
    }

    return switch (config.type) {
      FilterType.text => TextFilterWidget(
          title: config.title,
          initialFilter: initialValue as TextColumnFilter?,
          hintText: config.hintText ?? 'Enter value',
          onApply: _applyResult,
        ),
      FilterType.number => NumberFilterWidget(
          title: config.title,
          initialFilter: initialValue as NumberColumnFilter?,
          prefixText: config.prefixText ?? '₹ ',
          hintText: config.hintText ?? 'Enter amount',
          onApply: _applyResult,
        ),
      FilterType.date => DateFilterWidget(
          title: config.title,
          initialFilter: initialValue as DateColumnFilter?,
          onApply: _applyResult,
        ),
      FilterType.singleSelect => SingleSelectFilterWidget(
          title: config.title,
          options: config.values,
          initialFilter: initialValue as SelectColumnFilter?,
          searchable: config.searchable,
          onApply: _applyResult,
        ),
      FilterType.multiSelect => MultiSelectFilterWidget(
          title: config.title,
          options: config.values,
          initialFilter: initialValue as MultiSelectColumnFilter?,
          searchable: config.searchable,
          exclusivePairs: config.exclusivePairs,
          onApply: _applyResult,
        ),
      FilterType.boolean => BooleanFilterWidget(
          title: config.title,
          initialFilter: initialValue as BooleanColumnFilter?,
          onApply: _applyResult,
        ),
      FilterType.rangeSlider => RangeSliderFilterWidget(
          title: config.title,
          initialFilter: initialValue as RangeSliderColumnFilter?,
          maxValue: config.maxValue ?? RangeSliderColumnFilter.defaultCeiling,
          rangeLabel: config.rangeLabel ?? 'Range',
          onApply: _applyResult,
        ),
    };
  }
}
