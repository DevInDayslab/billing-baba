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

String _$globalSearchQueryHash() => r'0a3d92cb82ac503d10b7a727b2983fdf3391889f';

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
