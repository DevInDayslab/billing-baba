// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_settings_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(itemSettingsRepository)
final itemSettingsRepositoryProvider = ItemSettingsRepositoryProvider._();

final class ItemSettingsRepositoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<ItemSettingsRepository>,
          ItemSettingsRepository,
          FutureOr<ItemSettingsRepository>
        >
    with
        $FutureModifier<ItemSettingsRepository>,
        $FutureProvider<ItemSettingsRepository> {
  ItemSettingsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'itemSettingsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$itemSettingsRepositoryHash();

  @$internal
  @override
  $FutureProviderElement<ItemSettingsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ItemSettingsRepository> create(Ref ref) {
    return itemSettingsRepository(ref);
  }
}

String _$itemSettingsRepositoryHash() =>
    r'7d8d62268741a448f1c987fb095bca34178f46d7';

@ProviderFor(ItemSettingsNotifier)
final itemSettingsProvider = ItemSettingsNotifierProvider._();

final class ItemSettingsNotifierProvider
    extends $AsyncNotifierProvider<ItemSettingsNotifier, ItemSettings> {
  ItemSettingsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'itemSettingsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$itemSettingsNotifierHash();

  @$internal
  @override
  ItemSettingsNotifier create() => ItemSettingsNotifier();
}

String _$itemSettingsNotifierHash() =>
    r'a6576884e640e704181a4f81bf0795842d41bfee';

abstract class _$ItemSettingsNotifier extends $AsyncNotifier<ItemSettings> {
  FutureOr<ItemSettings> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<ItemSettings>, ItemSettings>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<ItemSettings>, ItemSettings>,
              AsyncValue<ItemSettings>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
