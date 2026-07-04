// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'global_search_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(GlobalSearchQuery)
final globalSearchQueryProvider = GlobalSearchQueryProvider._();

final class GlobalSearchQueryProvider
    extends $NotifierProvider<GlobalSearchQuery, String> {
  GlobalSearchQueryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'globalSearchQueryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$globalSearchQueryHash();

  @$internal
  @override
  GlobalSearchQuery create() => GlobalSearchQuery();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$globalSearchQueryHash() => r'ae4501293e5b7e65772cbdd6bd7c380be6f24af0';

abstract class _$GlobalSearchQuery extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String, String>,
              String,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(globalSearchResults)
final globalSearchResultsProvider = GlobalSearchResultsProvider._();

final class GlobalSearchResultsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<GlobalSearchResult>>,
          List<GlobalSearchResult>,
          FutureOr<List<GlobalSearchResult>>
        >
    with
        $FutureModifier<List<GlobalSearchResult>>,
        $FutureProvider<List<GlobalSearchResult>> {
  GlobalSearchResultsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'globalSearchResultsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$globalSearchResultsHash();

  @$internal
  @override
  $FutureProviderElement<List<GlobalSearchResult>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<GlobalSearchResult>> create(Ref ref) {
    return globalSearchResults(ref);
  }
}

String _$globalSearchResultsHash() =>
    r'2cdeffec198337c579efc4752b180187f0c77b4c';
