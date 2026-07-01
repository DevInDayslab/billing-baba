// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parties_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Parties)
final partiesProvider = PartiesProvider._();

final class PartiesProvider extends $NotifierProvider<Parties, List<String>> {
  PartiesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'partiesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$partiesHash();

  @$internal
  @override
  Parties create() => Parties();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<String>>(value),
    );
  }
}

String _$partiesHash() => r'parties_provider_hash_placeholder';

abstract class _$Parties extends $Notifier<List<String>> {
  List<String> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<List<String>, List<String>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<String>, List<String>>,
              List<String>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
