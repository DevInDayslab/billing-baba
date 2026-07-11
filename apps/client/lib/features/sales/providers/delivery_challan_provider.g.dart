// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delivery_challan_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(deliveryChallanFirmFilterOptions)
final deliveryChallanFirmFilterOptionsProvider =
    DeliveryChallanFirmFilterOptionsProvider._();

final class DeliveryChallanFirmFilterOptionsProvider
    extends $FunctionalProvider<List<String>, List<String>, List<String>>
    with $Provider<List<String>> {
  DeliveryChallanFirmFilterOptionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deliveryChallanFirmFilterOptionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deliveryChallanFirmFilterOptionsHash();

  @$internal
  @override
  $ProviderElement<List<String>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<String> create(Ref ref) {
    return deliveryChallanFirmFilterOptions(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<String>>(value),
    );
  }
}

String _$deliveryChallanFirmFilterOptionsHash() =>
    r'390bc264e96f74d835391f4ebf5521938368e23d';

@ProviderFor(deliveryChallanUserFilterOptions)
final deliveryChallanUserFilterOptionsProvider =
    DeliveryChallanUserFilterOptionsProvider._();

final class DeliveryChallanUserFilterOptionsProvider
    extends $FunctionalProvider<List<String>, List<String>, List<String>>
    with $Provider<List<String>> {
  DeliveryChallanUserFilterOptionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deliveryChallanUserFilterOptionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deliveryChallanUserFilterOptionsHash();

  @$internal
  @override
  $ProviderElement<List<String>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<String> create(Ref ref) {
    return deliveryChallanUserFilterOptions(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<String>>(value),
    );
  }
}

String _$deliveryChallanUserFilterOptionsHash() =>
    r'72784a95939b3d448f7f47eb25e5dd6fe7c51262';

@ProviderFor(deliveryChallanGodownFilterOptions)
final deliveryChallanGodownFilterOptionsProvider =
    DeliveryChallanGodownFilterOptionsProvider._();

final class DeliveryChallanGodownFilterOptionsProvider
    extends $FunctionalProvider<List<String>, List<String>, List<String>>
    with $Provider<List<String>> {
  DeliveryChallanGodownFilterOptionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deliveryChallanGodownFilterOptionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() =>
      _$deliveryChallanGodownFilterOptionsHash();

  @$internal
  @override
  $ProviderElement<List<String>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<String> create(Ref ref) {
    return deliveryChallanGodownFilterOptions(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<String>>(value),
    );
  }
}

String _$deliveryChallanGodownFilterOptionsHash() =>
    r'931a25eaefa36953fe56f5e4f47c5781c2813e3d';

@ProviderFor(DeliveryChallanSearchQuery)
final deliveryChallanSearchQueryProvider =
    DeliveryChallanSearchQueryProvider._();

final class DeliveryChallanSearchQueryProvider
    extends $NotifierProvider<DeliveryChallanSearchQuery, String> {
  DeliveryChallanSearchQueryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deliveryChallanSearchQueryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deliveryChallanSearchQueryHash();

  @$internal
  @override
  DeliveryChallanSearchQuery create() => DeliveryChallanSearchQuery();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$deliveryChallanSearchQueryHash() =>
    r'fa6c2ea14895b51d78dddcbe7d8737a51d582fcc';

abstract class _$DeliveryChallanSearchQuery extends $Notifier<String> {
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

@ProviderFor(SelectedDeliveryChallanIds)
final selectedDeliveryChallanIdsProvider =
    SelectedDeliveryChallanIdsProvider._();

final class SelectedDeliveryChallanIdsProvider
    extends $NotifierProvider<SelectedDeliveryChallanIds, Set<String>> {
  SelectedDeliveryChallanIdsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedDeliveryChallanIdsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedDeliveryChallanIdsHash();

  @$internal
  @override
  SelectedDeliveryChallanIds create() => SelectedDeliveryChallanIds();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Set<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Set<String>>(value),
    );
  }
}

String _$selectedDeliveryChallanIdsHash() =>
    r'422c603078b6f08e04fd4dd21ff58286dc51c3d8';

abstract class _$SelectedDeliveryChallanIds extends $Notifier<Set<String>> {
  Set<String> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<Set<String>, Set<String>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Set<String>, Set<String>>,
              Set<String>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(DeliveryChallans)
final deliveryChallansProvider = DeliveryChallansProvider._();

final class DeliveryChallansProvider
    extends $AsyncNotifierProvider<DeliveryChallans, PaginatedSaleInvoices> {
  DeliveryChallansProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deliveryChallansProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deliveryChallansHash();

  @$internal
  @override
  DeliveryChallans create() => DeliveryChallans();
}

String _$deliveryChallansHash() => r'fdf1f92606f30b2a640ad45919e205cd00600c9f';

abstract class _$DeliveryChallans
    extends $AsyncNotifier<PaginatedSaleInvoices> {
  FutureOr<PaginatedSaleInvoices> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<PaginatedSaleInvoices>, PaginatedSaleInvoices>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<PaginatedSaleInvoices>,
                PaginatedSaleInvoices
              >,
              AsyncValue<PaginatedSaleInvoices>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(DeliveryChallanFilters)
final deliveryChallanFiltersProvider = DeliveryChallanFiltersProvider._();

final class DeliveryChallanFiltersProvider
    extends
        $NotifierProvider<DeliveryChallanFilters, DeliveryChallanFiltersState> {
  DeliveryChallanFiltersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deliveryChallanFiltersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deliveryChallanFiltersHash();

  @$internal
  @override
  DeliveryChallanFilters create() => DeliveryChallanFilters();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DeliveryChallanFiltersState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DeliveryChallanFiltersState>(value),
    );
  }
}

String _$deliveryChallanFiltersHash() =>
    r'64489ea62220931fc1c4a88067155c748736e58b';

abstract class _$DeliveryChallanFilters
    extends $Notifier<DeliveryChallanFiltersState> {
  DeliveryChallanFiltersState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<DeliveryChallanFiltersState, DeliveryChallanFiltersState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                DeliveryChallanFiltersState,
                DeliveryChallanFiltersState
              >,
              DeliveryChallanFiltersState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(paginatedDeliveryChallans)
final paginatedDeliveryChallansProvider = PaginatedDeliveryChallansProvider._();

final class PaginatedDeliveryChallansProvider
    extends
        $FunctionalProvider<
          PaginatedSaleInvoices,
          PaginatedSaleInvoices,
          PaginatedSaleInvoices
        >
    with $Provider<PaginatedSaleInvoices> {
  PaginatedDeliveryChallansProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'paginatedDeliveryChallansProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$paginatedDeliveryChallansHash();

  @$internal
  @override
  $ProviderElement<PaginatedSaleInvoices> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PaginatedSaleInvoices create(Ref ref) {
    return paginatedDeliveryChallans(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PaginatedSaleInvoices value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PaginatedSaleInvoices>(value),
    );
  }
}

String _$paginatedDeliveryChallansHash() =>
    r'84beae184fc071ce3246415e7813152f143704ea';

@ProviderFor(deliveryChallanSummary)
final deliveryChallanSummaryProvider = DeliveryChallanSummaryProvider._();

final class DeliveryChallanSummaryProvider
    extends
        $FunctionalProvider<
          DeliveryChallanSummaryData,
          DeliveryChallanSummaryData,
          DeliveryChallanSummaryData
        >
    with $Provider<DeliveryChallanSummaryData> {
  DeliveryChallanSummaryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deliveryChallanSummaryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deliveryChallanSummaryHash();

  @$internal
  @override
  $ProviderElement<DeliveryChallanSummaryData> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DeliveryChallanSummaryData create(Ref ref) {
    return deliveryChallanSummary(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DeliveryChallanSummaryData value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DeliveryChallanSummaryData>(value),
    );
  }
}

String _$deliveryChallanSummaryHash() =>
    r'186d3f536ca651b0f372e012d4dd886ac14dbdee';
