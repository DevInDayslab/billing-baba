import 'package:billing_baba/shared/widgets/table_filters/filter_models.dart';
import 'package:billing_baba/shared/widgets/table_filters/filter_result.dart';
import 'package:billing_baba/shared/widgets/table_filters/filter_types.dart';

abstract final class FilterUtils {
  static bool isFilterActive(FilterType type, Object? value) {
    return switch (value) {
      final TextColumnFilter f => f.isActive,
      final NumberColumnFilter f => f.isActive,
      final DateColumnFilter f => f.isActive,
      final SelectColumnFilter f => f.isActive,
      final MultiSelectColumnFilter f => f.isActive,
      final BooleanColumnFilter f => f.isActive,
      final RangeSliderColumnFilter f => f.isActive,
      _ => value != null,
    };
  }

  static FilterResult? toResult(Object? value) {
    return switch (value) {
      final TextColumnFilter f => TextFilterResult(f),
      final NumberColumnFilter f => NumberFilterResult(f),
      final DateColumnFilter f => DateFilterResult(f),
      final SelectColumnFilter f => SelectFilterResult(f),
      final MultiSelectColumnFilter f => MultiSelectFilterResult(f),
      final BooleanColumnFilter f => BooleanFilterResult(f),
      final RangeSliderColumnFilter f => RangeSliderFilterResult(f),
      _ => null,
    };
  }

  static Object? fromResult(FilterResult? result) {
    return switch (result) {
      final TextFilterResult f => f.filter,
      final NumberFilterResult f => f.filter,
      final DateFilterResult f => f.filter,
      final SelectFilterResult f => f.filter,
      final MultiSelectFilterResult f => f.filter,
      final BooleanFilterResult f => f.filter,
      final RangeSliderFilterResult f => f.filter,
      null => null,
    };
  }
}
