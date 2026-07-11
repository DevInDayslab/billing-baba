// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sale_fa_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SaleFaSearchQuery)
final saleFaSearchQueryProvider = SaleFaSearchQueryProvider._();

final class SaleFaSearchQueryProvider
    extends $NotifierProvider<SaleFaSearchQuery, String> {
  SaleFaSearchQueryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'saleFaSearchQueryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$saleFaSearchQueryHash();

  @$internal
  @override
  SaleFaSearchQuery create() => SaleFaSearchQuery();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$saleFaSearchQueryHash() => r'32d93920755915a23b12c54da5ad241fdfb553dc';

abstract class _$SaleFaSearchQuery extends $Notifier<String> {
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

@ProviderFor(SaleFa)
final saleFaProvider = SaleFaProvider._();

final class SaleFaProvider
    extends $AsyncNotifierProvider<SaleFa, PaginatedSaleFaRecords> {
  SaleFaProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'saleFaProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$saleFaHash();

  @$internal
  @override
  SaleFa create() => SaleFa();
}

String _$saleFaHash() => r'b5006ba8b3b484819597773e88018de13a6dc035';

abstract class _$SaleFa extends $AsyncNotifier<PaginatedSaleFaRecords> {
  FutureOr<PaginatedSaleFaRecords> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<PaginatedSaleFaRecords>, PaginatedSaleFaRecords>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<PaginatedSaleFaRecords>,
                PaginatedSaleFaRecords
              >,
              AsyncValue<PaginatedSaleFaRecords>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(SaleFaFilters)
final saleFaFiltersProvider = SaleFaFiltersProvider._();

final class SaleFaFiltersProvider
    extends $NotifierProvider<SaleFaFilters, SaleFaFiltersState> {
  SaleFaFiltersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'saleFaFiltersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$saleFaFiltersHash();

  @$internal
  @override
  SaleFaFilters create() => SaleFaFilters();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SaleFaFiltersState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SaleFaFiltersState>(value),
    );
  }
}

String _$saleFaFiltersHash() => r'ceb3d5285b0958743c25b59d521f7e5cb4744f71';

abstract class _$SaleFaFilters extends $Notifier<SaleFaFiltersState> {
  SaleFaFiltersState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<SaleFaFiltersState, SaleFaFiltersState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SaleFaFiltersState, SaleFaFiltersState>,
              SaleFaFiltersState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(paginatedSaleFaRecords)
final paginatedSaleFaRecordsProvider = PaginatedSaleFaRecordsProvider._();

final class PaginatedSaleFaRecordsProvider
    extends
        $FunctionalProvider<
          PaginatedSaleFaRecords,
          PaginatedSaleFaRecords,
          PaginatedSaleFaRecords
        >
    with $Provider<PaginatedSaleFaRecords> {
  PaginatedSaleFaRecordsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'paginatedSaleFaRecordsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$paginatedSaleFaRecordsHash();

  @$internal
  @override
  $ProviderElement<PaginatedSaleFaRecords> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PaginatedSaleFaRecords create(Ref ref) {
    return paginatedSaleFaRecords(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PaginatedSaleFaRecords value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PaginatedSaleFaRecords>(value),
    );
  }
}

String _$paginatedSaleFaRecordsHash() =>
    r'342fdc3c7654823b6880334a91691b381526ec28';

@ProviderFor(saleFaSummary)
final saleFaSummaryProvider = SaleFaSummaryProvider._();

final class SaleFaSummaryProvider
    extends
        $FunctionalProvider<
          SaleFaSummaryData,
          SaleFaSummaryData,
          SaleFaSummaryData
        >
    with $Provider<SaleFaSummaryData> {
  SaleFaSummaryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'saleFaSummaryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$saleFaSummaryHash();

  @$internal
  @override
  $ProviderElement<SaleFaSummaryData> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SaleFaSummaryData create(Ref ref) {
    return saleFaSummary(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SaleFaSummaryData value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SaleFaSummaryData>(value),
    );
  }
}

String _$saleFaSummaryHash() => r'e05f3ec502be9461d605bcdf71192be31eb48785';

@ProviderFor(saleFaFirmFilterOptions)
final saleFaFirmFilterOptionsProvider = SaleFaFirmFilterOptionsProvider._();

final class SaleFaFirmFilterOptionsProvider
    extends $FunctionalProvider<List<String>, List<String>, List<String>>
    with $Provider<List<String>> {
  SaleFaFirmFilterOptionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'saleFaFirmFilterOptionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$saleFaFirmFilterOptionsHash();

  @$internal
  @override
  $ProviderElement<List<String>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<String> create(Ref ref) {
    return saleFaFirmFilterOptions(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<String>>(value),
    );
  }
}

String _$saleFaFirmFilterOptionsHash() =>
    r'776d02dfc9cc2e198ff45618b454f40998eb2522';

@ProviderFor(saleFaUserFilterOptions)
final saleFaUserFilterOptionsProvider = SaleFaUserFilterOptionsProvider._();

final class SaleFaUserFilterOptionsProvider
    extends $FunctionalProvider<List<String>, List<String>, List<String>>
    with $Provider<List<String>> {
  SaleFaUserFilterOptionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'saleFaUserFilterOptionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$saleFaUserFilterOptionsHash();

  @$internal
  @override
  $ProviderElement<List<String>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<String> create(Ref ref) {
    return saleFaUserFilterOptions(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<String>>(value),
    );
  }
}

String _$saleFaUserFilterOptionsHash() =>
    r'fc6c4d1dde311db54270f234d75d14e097fb7c6e';

@ProviderFor(saleFaGodownFilterOptions)
final saleFaGodownFilterOptionsProvider = SaleFaGodownFilterOptionsProvider._();

final class SaleFaGodownFilterOptionsProvider
    extends $FunctionalProvider<List<String>, List<String>, List<String>>
    with $Provider<List<String>> {
  SaleFaGodownFilterOptionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'saleFaGodownFilterOptionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$saleFaGodownFilterOptionsHash();

  @$internal
  @override
  $ProviderElement<List<String>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<String> create(Ref ref) {
    return saleFaGodownFilterOptions(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<String>>(value),
    );
  }
}

String _$saleFaGodownFilterOptionsHash() =>
    r'fbbf2012f042ca1954962b0291975abfa06c2841';
