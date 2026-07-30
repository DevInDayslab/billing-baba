import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_filterable_sync_table.dart';
import 'package:billing_baba/shared/widgets/table_filters/filter_models.dart';
import 'package:billing_baba/shared/widgets/table_filters/filter_types.dart';
import 'package:billing_baba/shared/widgets/table_filters/filter_utils.dart';

bool reportMatchesColumnFilters<T>({
  required T row,
  required List<ReportColumnSpec<T>> columns,
  required Map<String, Object?> filters,
}) {
  for (final column in columns) {
    if (!column.showFilter) continue;

    final rawFilter = filters[column.id];
    if (rawFilter == null) continue;
    if (!FilterUtils.isFilterActive(column.filterType, rawFilter)) continue;

    final value = column.filterValue(row);
    if (!_matchesFilter(column.filterType, rawFilter, value)) {
      return false;
    }
  }
  return true;
}

bool _matchesFilter(FilterType type, Object? rawFilter, Object? value) {
  return switch (type) {
    FilterType.text => rawFilter is TextColumnFilter &&
        rawFilter.matches(_asString(value)),
    FilterType.number => rawFilter is NumberColumnFilter &&
        rawFilter.matches(_asDouble(value)),
    FilterType.date => rawFilter is DateColumnFilter &&
        value is DateTime &&
        rawFilter.matches(value),
    FilterType.singleSelect => rawFilter is SelectColumnFilter &&
        rawFilter.matches(_asString(value)),
    FilterType.multiSelect => rawFilter is MultiSelectColumnFilter &&
        rawFilter.matches(_asString(value)),
    FilterType.boolean => rawFilter is BooleanColumnFilter &&
        value is bool &&
        rawFilter.matches(value),
    FilterType.rangeSlider => rawFilter is RangeSliderColumnFilter &&
        rawFilter.matches(_asDouble(value)),
  };
}

String _asString(Object? value) => switch (value) {
  null => '',
  String s => s,
  num n => n.toString(),
  DateTime d => d.toIso8601String(),
  _ => value.toString(),
};

double _asDouble(Object? value) => switch (value) {
  null => 0,
  num n => n.toDouble(),
  String s => double.tryParse(s) ?? 0,
  _ => 0,
};
