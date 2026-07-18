// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Resolves grouped search results for the command palette.

@ProviderFor(searchRepository)
final searchRepositoryProvider = SearchRepositoryProvider._();

/// Resolves grouped search results for the command palette.

final class SearchRepositoryProvider
    extends
        $FunctionalProvider<
          SearchRepository,
          SearchRepository,
          SearchRepository
        >
    with $Provider<SearchRepository> {
  /// Resolves grouped search results for the command palette.
  SearchRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchRepositoryHash();

  @$internal
  @override
  $ProviderElement<SearchRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SearchRepository create(Ref ref) {
    return searchRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SearchRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SearchRepository>(value),
    );
  }
}

String _$searchRepositoryHash() => r'cdd49966ac6a721616aa370a76ec5060f6ed1f1b';
