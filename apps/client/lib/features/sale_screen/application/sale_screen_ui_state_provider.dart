import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sale_screen_ui_state_provider.g.dart';

class SaleScreenTabUiState {
  const SaleScreenTabUiState({
    this.searchText = '',
    this.categoryId,
    this.highlightIndex = 0,
  });

  final String searchText;
  final String? categoryId;
  final int highlightIndex;

  SaleScreenTabUiState copyWith({
    String? searchText,
    String? categoryId,
    int? highlightIndex,
    bool clearCategoryId = false,
  }) {
    return SaleScreenTabUiState(
      searchText: searchText ?? this.searchText,
      categoryId: clearCategoryId ? null : (categoryId ?? this.categoryId),
      highlightIndex: highlightIndex ?? this.highlightIndex,
    );
  }
}

/// Per POS-tab product pane state (search, category filter) across minimize/restore.
@Riverpod(keepAlive: true)
class SaleScreenUiState extends _$SaleScreenUiState {
  @override
  Map<String, SaleScreenTabUiState> build() => const {};

  SaleScreenTabUiState uiFor(String sessionKey) =>
      state[sessionKey] ?? const SaleScreenTabUiState();

  void save(String sessionKey, SaleScreenTabUiState ui) {
    state = {...state, sessionKey: ui};
  }

  void clearAll() => state = const {};
}
