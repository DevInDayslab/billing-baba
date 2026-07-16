import 'package:billing_baba/shared/widgets/table_filters/filter_models.dart';
import 'package:billing_baba/shared/widgets/table_filters/table_filters.dart'
    show FilterController, FilterState;

/// Typed filter value stored in [FilterState] / [FilterController].
sealed class FilterResult {
  const FilterResult();

  bool get isActive;
  String get displayLabel;
}

final class TextFilterResult extends FilterResult {
  const TextFilterResult(this.filter);
  final TextColumnFilter filter;

  @override
  bool get isActive => filter.isActive;

  @override
  String get displayLabel => '${filter.operator.label}: ${filter.value}';
}

final class NumberFilterResult extends FilterResult {
  const NumberFilterResult(this.filter);
  final NumberColumnFilter filter;

  @override
  bool get isActive => filter.isActive;

  @override
  String get displayLabel => '${filter.operator.label}: ${filter.value}';
}

final class DateFilterResult extends FilterResult {
  const DateFilterResult(this.filter);
  final DateColumnFilter filter;

  @override
  bool get isActive => filter.isActive;

  @override
  String get displayLabel {
    if (filter.operator == DateColumnOperator.range) {
      return '${filter.startDate?.toIso8601String().split('T').first} – '
          '${filter.endDate?.toIso8601String().split('T').first}';
    }
    return '${filter.operator.label}: '
        '${filter.date?.toIso8601String().split('T').first}';
  }
}

final class SelectFilterResult extends FilterResult {
  const SelectFilterResult(this.filter);
  final SelectColumnFilter filter;

  @override
  bool get isActive => filter.isActive;

  @override
  String get displayLabel => filter.value ?? '';
}

final class MultiSelectFilterResult extends FilterResult {
  const MultiSelectFilterResult(this.filter);
  final MultiSelectColumnFilter filter;

  @override
  bool get isActive => filter.isActive;

  @override
  String get displayLabel => filter.values.join(', ');
}

final class BooleanFilterResult extends FilterResult {
  const BooleanFilterResult(this.filter);
  final BooleanColumnFilter filter;

  @override
  bool get isActive => filter.isActive;

  @override
  String get displayLabel => switch (filter.value) {
    true => 'Yes',
    false => 'No',
    null => 'All',
  };
}

final class RangeSliderFilterResult extends FilterResult {
  const RangeSliderFilterResult(this.filter);
  final RangeSliderColumnFilter filter;

  @override
  bool get isActive => filter.isActive;

  @override
  String get displayLabel => '${filter.min.round()} – ${filter.max.round()}';
}

/// @deprecated Use [NumberFilterResult].
typedef AmountFilterResult = NumberFilterResult;
