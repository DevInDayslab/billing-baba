// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_items_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PosItemSearchQuery)
final posItemSearchQueryProvider = PosItemSearchQueryProvider._();

final class PosItemSearchQueryProvider
    extends $NotifierProvider<PosItemSearchQuery, String> {
  PosItemSearchQueryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'posItemSearchQueryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$posItemSearchQueryHash();

  @$internal
  @override
  PosItemSearchQuery create() => PosItemSearchQuery();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$posItemSearchQueryHash() =>
    r'c3d4e5f678901234567890abcdef0123456789012';

abstract class _$PosItemSearchQuery extends $Notifier<String> {
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

@ProviderFor(posItems)
final posItemsProvider = PosItemsProvider._();

final class PosItemsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PosItem>>,
          List<PosItem>,
          FutureOr<List<PosItem>>
        >
    with $FutureModifier<List<PosItem>>, $FutureProvider<List<PosItem>> {
  PosItemsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'posItemsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$posItemsHash();

  @$internal
  @override
  $FutureProviderElement<List<PosItem>> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<PosItem>> create(Ref ref) {
    return posItems(ref);
  }
}

String _$posItemsHash() => r'b2c3d4e5f6789012345678abcdef9012345678901';

@ProviderFor(posItemSearch)
final posItemSearchProvider = PosItemSearchFamily._();

final class PosItemSearchProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PosItem>>,
          List<PosItem>,
          FutureOr<List<PosItem>>
        >
    with $FutureModifier<List<PosItem>>, $FutureProvider<List<PosItem>> {
  PosItemSearchProvider._({
    required PosItemSearchFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'posItemSearchProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$posItemSearchHash();

  @override
  String toString() {
    return r'posItemSearchProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<PosItem>> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<PosItem>> create(Ref ref) {
    final argument = this.argument as String;
    return posItemSearch(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PosItemSearchProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$posItemSearchHash() => r'a1b2c3d4e5f6789012345678abcdef9012345678';

final class PosItemSearchFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<PosItem>>, String> {
  PosItemSearchFamily._()
    : super(
        retry: null,
        name: r'posItemSearchProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PosItemSearchProvider call(String query) =>
      PosItemSearchProvider._(argument: query, from: this);

  @override
  String toString() => r'posItemSearchProvider';
}

@ProviderFor(posCustomerSearch)
final posCustomerSearchProvider = PosCustomerSearchFamily._();

final class PosCustomerSearchProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PosCustomer>>,
          List<PosCustomer>,
          FutureOr<List<PosCustomer>>
        >
    with
        $FutureModifier<List<PosCustomer>>,
        $FutureProvider<List<PosCustomer>> {
  PosCustomerSearchProvider._({
    required PosCustomerSearchFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'posCustomerSearchProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$posCustomerSearchHash();

  @override
  String toString() {
    return r'posCustomerSearchProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<PosCustomer>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<PosCustomer>> create(Ref ref) {
    final argument = this.argument as String;
    return posCustomerSearch(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PosCustomerSearchProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$posCustomerSearchHash() =>
    r'd4e5f678901234567890abcdef0123456789012345';

final class PosCustomerSearchFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<PosCustomer>>, String> {
  PosCustomerSearchFamily._()
    : super(
        retry: null,
        name: r'posCustomerSearchProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PosCustomerSearchProvider call(String query) =>
      PosCustomerSearchProvider._(argument: query, from: this);

  @override
  String toString() => r'posCustomerSearchProvider';
}
