// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'party_detail_pane_ratio_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Persisted height ratio for the party detail upper pane (header)
/// versus the transactions table on desktop.

@ProviderFor(PartyDetailPaneRatio)
final partyDetailPaneRatioProvider = PartyDetailPaneRatioProvider._();

/// Persisted height ratio for the party detail upper pane (header)
/// versus the transactions table on desktop.
final class PartyDetailPaneRatioProvider
    extends $NotifierProvider<PartyDetailPaneRatio, double> {
  /// Persisted height ratio for the party detail upper pane (header)
  /// versus the transactions table on desktop.
  PartyDetailPaneRatioProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'partyDetailPaneRatioProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$partyDetailPaneRatioHash();

  @$internal
  @override
  PartyDetailPaneRatio create() => PartyDetailPaneRatio();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(double value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<double>(value),
    );
  }
}

String _$partyDetailPaneRatioHash() =>
    r'0cb652e3a619ee31c6c7568f8a303c6894f39cf1';

/// Persisted height ratio for the party detail upper pane (header)
/// versus the transactions table on desktop.

abstract class _$PartyDetailPaneRatio extends $Notifier<double> {
  double build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<double, double>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<double, double>,
              double,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
