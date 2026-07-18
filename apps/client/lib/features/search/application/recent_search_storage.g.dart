// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recent_search_storage.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Persists recently visited page IDs for the search dialog.

@ProviderFor(recentSearchStorage)
final recentSearchStorageProvider = RecentSearchStorageProvider._();

/// Persists recently visited page IDs for the search dialog.

final class RecentSearchStorageProvider
    extends
        $FunctionalProvider<
          RecentSearchStorage,
          RecentSearchStorage,
          RecentSearchStorage
        >
    with $Provider<RecentSearchStorage> {
  /// Persists recently visited page IDs for the search dialog.
  RecentSearchStorageProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recentSearchStorageProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recentSearchStorageHash();

  @$internal
  @override
  $ProviderElement<RecentSearchStorage> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  RecentSearchStorage create(Ref ref) {
    return recentSearchStorage(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RecentSearchStorage value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RecentSearchStorage>(value),
    );
  }
}

String _$recentSearchStorageHash() =>
    r'ab9576d8c53089ed10ed65bbb889e2a63e899dad';
