// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_alternatives_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(itemAlternativesRepository)
final itemAlternativesRepositoryProvider =
    ItemAlternativesRepositoryProvider._();

final class ItemAlternativesRepositoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<ItemAlternativesRepository>,
          ItemAlternativesRepository,
          FutureOr<ItemAlternativesRepository>
        >
    with
        $FutureModifier<ItemAlternativesRepository>,
        $FutureProvider<ItemAlternativesRepository> {
  ItemAlternativesRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'itemAlternativesRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$itemAlternativesRepositoryHash();

  @$internal
  @override
  $FutureProviderElement<ItemAlternativesRepository> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ItemAlternativesRepository> create(Ref ref) {
    return itemAlternativesRepository(ref);
  }
}

String _$itemAlternativesRepositoryHash() =>
    r'5fd5eeba1650e74e97befc4b23ae09f97e16f807';

@ProviderFor(ItemAlternativesNotifier)
final itemAlternativesProvider = ItemAlternativesNotifierFamily._();

final class ItemAlternativesNotifierProvider
    extends
        $AsyncNotifierProvider<
          ItemAlternativesNotifier,
          List<ItemAlternativeDto>
        > {
  ItemAlternativesNotifierProvider._({
    required ItemAlternativesNotifierFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'itemAlternativesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$itemAlternativesNotifierHash();

  @override
  String toString() {
    return r'itemAlternativesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ItemAlternativesNotifier create() => ItemAlternativesNotifier();

  @override
  bool operator ==(Object other) {
    return other is ItemAlternativesNotifierProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$itemAlternativesNotifierHash() =>
    r'11ea26be6a176acd54c3a2afebf53f73b2628f87';

final class ItemAlternativesNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
          ItemAlternativesNotifier,
          AsyncValue<List<ItemAlternativeDto>>,
          List<ItemAlternativeDto>,
          FutureOr<List<ItemAlternativeDto>>,
          String
        > {
  ItemAlternativesNotifierFamily._()
    : super(
        retry: null,
        name: r'itemAlternativesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ItemAlternativesNotifierProvider call(String itemId) =>
      ItemAlternativesNotifierProvider._(argument: itemId, from: this);

  @override
  String toString() => r'itemAlternativesProvider';
}

abstract class _$ItemAlternativesNotifier
    extends $AsyncNotifier<List<ItemAlternativeDto>> {
  late final _$args = ref.$arg as String;
  String get itemId => _$args;

  FutureOr<List<ItemAlternativeDto>> build(String itemId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<List<ItemAlternativeDto>>,
              List<ItemAlternativeDto>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<ItemAlternativeDto>>,
                List<ItemAlternativeDto>
              >,
              AsyncValue<List<ItemAlternativeDto>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

@ProviderFor(itemRecommendations)
final itemRecommendationsProvider = ItemRecommendationsFamily._();

final class ItemRecommendationsProvider
    extends
        $FunctionalProvider<
          AsyncValue<ItemRecommendationsDto>,
          ItemRecommendationsDto,
          FutureOr<ItemRecommendationsDto>
        >
    with
        $FutureModifier<ItemRecommendationsDto>,
        $FutureProvider<ItemRecommendationsDto> {
  ItemRecommendationsProvider._({
    required ItemRecommendationsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'itemRecommendationsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$itemRecommendationsHash();

  @override
  String toString() {
    return r'itemRecommendationsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<ItemRecommendationsDto> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ItemRecommendationsDto> create(Ref ref) {
    final argument = this.argument as String;
    return itemRecommendations(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ItemRecommendationsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$itemRecommendationsHash() =>
    r'6b791eb114dae6500deba34f342118c4f9833a27';

final class ItemRecommendationsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<ItemRecommendationsDto>, String> {
  ItemRecommendationsFamily._()
    : super(
        retry: null,
        name: r'itemRecommendationsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ItemRecommendationsProvider call(String itemId) =>
      ItemRecommendationsProvider._(argument: itemId, from: this);

  @override
  String toString() => r'itemRecommendationsProvider';
}
