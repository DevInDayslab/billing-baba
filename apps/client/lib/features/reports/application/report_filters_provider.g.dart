// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_filters_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ReportFilters)
final reportFiltersProvider = ReportFiltersProvider._();

final class ReportFiltersProvider
    extends $NotifierProvider<ReportFilters, ReportFiltersState> {
  ReportFiltersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'reportFiltersProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$reportFiltersHash();

  @$internal
  @override
  ReportFilters create() => ReportFilters();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReportFiltersState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReportFiltersState>(value),
    );
  }
}

String _$reportFiltersHash() => r'4d65ccda774f3845c5d7fa64603dea71f4a743d3';

abstract class _$ReportFilters extends $Notifier<ReportFiltersState> {
  ReportFiltersState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ReportFiltersState, ReportFiltersState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ReportFiltersState, ReportFiltersState>,
              ReportFiltersState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
