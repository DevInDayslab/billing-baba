import 'package:billing_baba/shared/widgets/table_filters/filter_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Column-level filters keyed by report scope (e.g. `sale`, `stock_summary`).
class ReportTableColumnFilters
    extends Notifier<Map<String, Map<String, Object?>>> {
  @override
  Map<String, Map<String, Object?>> build() => {};

  Map<String, Object?> filtersFor(String reportScope) =>
      state[reportScope] ?? const {};

  bool hasActiveFilters(String reportScope) {
    final filters = filtersFor(reportScope);
    for (final filter in filters.values) {
      if (_isActiveValue(filter)) return true;
    }
    return false;
  }

  void setFilter(String reportScope, String columnId, Object? value) {
    final scope = Map<String, Object?>.from(filtersFor(reportScope));
    if (value == null || !_isActiveValue(value)) {
      scope.remove(columnId);
    } else {
      scope[columnId] = value;
    }

    if (scope.isEmpty) {
      final next = Map<String, Map<String, Object?>>.from(state)
        ..remove(reportScope);
      state = next;
      return;
    }

    state = {...state, reportScope: scope};
  }

  void resetScope(String reportScope) {
    if (!state.containsKey(reportScope)) return;
    final next = Map<String, Map<String, Object?>>.from(state)
      ..remove(reportScope);
    state = next;
  }

  void resetAll() {
    state = {};
  }

  bool _isActiveValue(Object? value) {
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
}

final reportTableColumnFiltersProvider =
    NotifierProvider<
      ReportTableColumnFilters,
      Map<String, Map<String, Object?>>
    >(ReportTableColumnFilters.new);
