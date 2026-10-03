// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leads_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Leads)
final leadsProvider = LeadsProvider._();

final class LeadsProvider extends $AsyncNotifierProvider<Leads, List<Lead>> {
  LeadsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'leadsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$leadsHash();

  @$internal
  @override
  Leads create() => Leads();
}

String _$leadsHash() => r'6c2e30e67a947cbfd572258446c52021390bac19';

abstract class _$Leads extends $AsyncNotifier<List<Lead>> {
  FutureOr<List<Lead>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Lead>>, List<Lead>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Lead>>, List<Lead>>,
              AsyncValue<List<Lead>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(filteredLeadsList)
final filteredLeadsListProvider = FilteredLeadsListProvider._();

final class FilteredLeadsListProvider
    extends $FunctionalProvider<List<Lead>, List<Lead>, List<Lead>>
    with $Provider<List<Lead>> {
  FilteredLeadsListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'filteredLeadsListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$filteredLeadsListHash();

  @$internal
  @override
  $ProviderElement<List<Lead>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<Lead> create(Ref ref) {
    return filteredLeadsList(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Lead> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Lead>>(value),
    );
  }
}

String _$filteredLeadsListHash() => r'94697e1d42dc0d9c6d57bc05f53df1a22eac6cc2';

@ProviderFor(sortedLeadsList)
final sortedLeadsListProvider = SortedLeadsListProvider._();

final class SortedLeadsListProvider
    extends $FunctionalProvider<List<Lead>, List<Lead>, List<Lead>>
    with $Provider<List<Lead>> {
  SortedLeadsListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sortedLeadsListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sortedLeadsListHash();

  @$internal
  @override
  $ProviderElement<List<Lead>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<Lead> create(Ref ref) {
    return sortedLeadsList(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Lead> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Lead>>(value),
    );
  }
}

String _$sortedLeadsListHash() => r'07a273623c2e300349275fdba79ffad1b9739444';

@ProviderFor(paginatedLeads)
final paginatedLeadsProvider = PaginatedLeadsProvider._();

final class PaginatedLeadsProvider
    extends $FunctionalProvider<PaginatedLeads, PaginatedLeads, PaginatedLeads>
    with $Provider<PaginatedLeads> {
  PaginatedLeadsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'paginatedLeadsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$paginatedLeadsHash();

  @$internal
  @override
  $ProviderElement<PaginatedLeads> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PaginatedLeads create(Ref ref) {
    return paginatedLeads(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PaginatedLeads value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PaginatedLeads>(value),
    );
  }
}

String _$paginatedLeadsHash() => r'50acc0c1a6a2038a5c35ee2c804f0ecd4076bd27';

@ProviderFor(leadsTotalCount)
final leadsTotalCountProvider = LeadsTotalCountProvider._();

final class LeadsTotalCountProvider extends $FunctionalProvider<int, int, int>
    with $Provider<int> {
  LeadsTotalCountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'leadsTotalCountProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$leadsTotalCountHash();

  @$internal
  @override
  $ProviderElement<int> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  int create(Ref ref) {
    return leadsTotalCount(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$leadsTotalCountHash() => r'd6fa5525e13bbcdae8da14cfe11ea207917a637a';
