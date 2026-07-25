// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Search dialog UI state: query text and keyboard highlight index.

@ProviderFor(SearchController)
final searchControllerProvider = SearchControllerProvider._();

/// Search dialog UI state: query text and keyboard highlight index.
final class SearchControllerProvider
    extends $NotifierProvider<SearchController, SearchUiState> {
  /// Search dialog UI state: query text and keyboard highlight index.
  SearchControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchControllerHash();

  @$internal
  @override
  SearchController create() => SearchController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SearchUiState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SearchUiState>(value),
    );
  }
}

String _$searchControllerHash() => r'72c48cc9313850aa1437c8e01b0ba8cb065c873d';

/// Search dialog UI state: query text and keyboard highlight index.

abstract class _$SearchController extends $Notifier<SearchUiState> {
  SearchUiState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<SearchUiState, SearchUiState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SearchUiState, SearchUiState>,
              SearchUiState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Sync results for non-empty queries against the static registry.

@ProviderFor(searchResults)
final searchResultsProvider = SearchResultsProvider._();

/// Sync results for non-empty queries against the static registry.

final class SearchResultsProvider
    extends
        $FunctionalProvider<
          List<SearchResultSection>,
          List<SearchResultSection>,
          List<SearchResultSection>
        >
    with $Provider<List<SearchResultSection>> {
  /// Sync results for non-empty queries against the static registry.
  SearchResultsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchResultsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchResultsHash();

  @$internal
  @override
  $ProviderElement<List<SearchResultSection>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<SearchResultSection> create(Ref ref) {
    return searchResults(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<SearchResultSection> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<SearchResultSection>>(value),
    );
  }
}

String _$searchResultsHash() => r'3c4defff04ff17330562c24ed4bf8edc721d69b1';

/// Async recent pages for an empty query (local storage only).

@ProviderFor(searchEmptySections)
final searchEmptySectionsProvider = SearchEmptySectionsProvider._();

/// Async recent pages for an empty query (local storage only).

final class SearchEmptySectionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SearchResultSection>>,
          List<SearchResultSection>,
          FutureOr<List<SearchResultSection>>
        >
    with
        $FutureModifier<List<SearchResultSection>>,
        $FutureProvider<List<SearchResultSection>> {
  /// Async recent pages for an empty query (local storage only).
  SearchEmptySectionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchEmptySectionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchEmptySectionsHash();

  @$internal
  @override
  $FutureProviderElement<List<SearchResultSection>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<SearchResultSection>> create(Ref ref) {
    return searchEmptySections(ref);
  }
}

String _$searchEmptySectionsHash() =>
    r'f64d25193bac22fe1daefb28e7d361df02bd3c22';
