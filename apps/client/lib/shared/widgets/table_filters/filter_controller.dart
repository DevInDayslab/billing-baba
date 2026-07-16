import 'package:billing_baba/shared/widgets/table_filters/filter_result.dart';
import 'package:billing_baba/shared/widgets/table_filters/filter_state.dart';
import 'package:flutter/foundation.dart';

/// Generic filter controller for table column filters.
///
/// Feature providers can continue using Riverpod; this controller powers the
/// developer playground and any table that opts into config-driven filters.
class FilterController extends ChangeNotifier {
  FilterController({FilterState? initialState})
    : _state = initialState ?? const FilterState();

  FilterState _state;

  FilterState get state => _state;

  Map<String, FilterResult> get filters => _state.filters;

  bool get hasActiveFilters => _state.hasActiveFilters;

  void apply(String id, FilterResult? result) {
    final next = Map<String, FilterResult>.from(_state.filters);
    if (result == null || !result.isActive) {
      next.remove(id);
    } else {
      next[id] = result;
    }
    _state = FilterState(filters: next);
    notifyListeners();
  }

  void clear(String id) {
    removeFilter(id);
  }

  void removeFilter(String id) {
    if (!_state.filters.containsKey(id)) return;
    _state = _state.copyWith(removeId: id);
    notifyListeners();
  }

  void clearAll() {
    if (_state.filters.isEmpty) return;
    _state = const FilterState();
    notifyListeners();
  }
}
