// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_alternatives_index_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ItemAlternativesIndex)
final itemAlternativesIndexProvider = ItemAlternativesIndexProvider._();

final class ItemAlternativesIndexProvider
    extends
        $AsyncNotifierProvider<
          ItemAlternativesIndex,
          Map<String, List<String>>
        > {
  ItemAlternativesIndexProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'itemAlternativesIndexProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$itemAlternativesIndexHash();

  @$internal
  @override
  ItemAlternativesIndex create() => ItemAlternativesIndex();
}

String _$itemAlternativesIndexHash() =>
    r'9c90c4fe1d09a209ef90eec02b61745696c30d47';

abstract class _$ItemAlternativesIndex
    extends $AsyncNotifier<Map<String, List<String>>> {
  FutureOr<Map<String, List<String>>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<Map<String, List<String>>>,
              Map<String, List<String>>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<Map<String, List<String>>>,
                Map<String, List<String>>
              >,
              AsyncValue<Map<String, List<String>>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
