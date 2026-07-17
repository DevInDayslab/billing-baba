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

String _$searchControllerHash() => r'737ff52217ac3e085b7b5f0695309c345511a27c';

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

@ProviderFor(searchResults)
final searchResultsProvider = SearchResultsProvider._();

final class SearchResultsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SearchResultSection>>,
          List<SearchResultSection>,
          FutureOr<List<SearchResultSection>>
        >
    with
        $FutureModifier<List<SearchResultSection>>,
        $FutureProvider<List<SearchResultSection>> {
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
  $FutureProviderElement<List<SearchResultSection>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<SearchResultSection>> create(Ref ref) {
    return searchResults(ref);
  }
}

String _$searchResultsHash() => r'52a824037bfe1fc2a7f82324ae7a6ffab00c8d4b';
