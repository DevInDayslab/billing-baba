import 'package:billing_baba/shared/widgets/table_filters/filter_models.dart' show ColumnFilter;
import 'package:billing_baba/shared/widgets/table_filters/filter_result.dart';
import 'package:billing_baba/shared/widgets/table_filters/table_filters.dart' show ColumnFilter;

/// Immutable snapshot of active column filters keyed by [ColumnFilter.id].
class FilterState {
  const FilterState({this.filters = const {}});

  final Map<String, FilterResult> filters;

  bool get hasActiveFilters => filters.values.any((f) => f.isActive);

  FilterResult? operator [](String id) => filters[id];

  FilterState copyWith({
    Map<String, FilterResult>? filters,
    String? removeId,
    bool clearAll = false,
  }) {
    if (clearAll) return const FilterState();
    if (removeId != null) {
      final next = Map<String, FilterResult>.from(filters ?? this.filters);
      next.remove(removeId);
      return FilterState(filters: next);
    }
    return FilterState(filters: filters ?? this.filters);
  }
}
