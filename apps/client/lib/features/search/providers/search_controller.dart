import 'package:billing_baba/features/search/application/search_repository.dart';
import 'package:billing_baba/features/search/domain/search_item.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'search_controller.g.dart';

/// Search dialog UI state: query text and keyboard highlight index.
@riverpod
class SearchController extends _$SearchController {
  @override
  SearchUiState build() => const SearchUiState();

  void setQuery(String query) {
    state = state.copyWith(query: query, highlightedIndex: 0);
    ref.invalidate(searchResultsProvider);
    ref.invalidate(searchEmptySectionsProvider);
  }

  void setHighlightedIndex(int index) {
    if (index == state.highlightedIndex) return;
    state = state.copyWith(highlightedIndex: index);
  }

  void moveHighlight(int delta, int itemCount) {
    if (itemCount == 0) {
      state = state.copyWith(highlightedIndex: 0);
      return;
    }
    final next = (state.highlightedIndex + delta) % itemCount;
    final wrapped = next < 0 ? next + itemCount : next;
    state = state.copyWith(highlightedIndex: wrapped);
  }

  void reset() {
    state = const SearchUiState();
    ref.invalidate(searchResultsProvider);
    ref.invalidate(searchEmptySectionsProvider);
  }
}

@immutable
class SearchUiState {
  const SearchUiState({
    this.query = '',
    this.highlightedIndex = 0,
  });

  final String query;
  final int highlightedIndex;

  SearchUiState copyWith({
    String? query,
    int? highlightedIndex,
  }) {
    return SearchUiState(
      query: query ?? this.query,
      highlightedIndex: highlightedIndex ?? this.highlightedIndex,
    );
  }
}

/// Sync results for non-empty queries against the static registry.
@riverpod
List<SearchResultSection> searchResults(Ref ref) {
  final query = ref.watch(searchControllerProvider).query.trim();
  if (query.isEmpty) return const [];

  return ref.watch(searchRepositoryProvider).filteredSections(query);
}

/// Async recent pages for an empty query (local storage only).
@riverpod
Future<List<SearchResultSection>> searchEmptySections(Ref ref) async {
  return ref.watch(searchRepositoryProvider).emptyQuerySections();
}
