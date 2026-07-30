// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tax_rate_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TaxRates)
final taxRatesProvider = TaxRatesProvider._();

final class TaxRatesProvider
    extends $AsyncNotifierProvider<TaxRates, List<TaxRateDto>> {
  TaxRatesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'taxRatesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$taxRatesHash();

  @$internal
  @override
  TaxRates create() => TaxRates();
}

String _$taxRatesHash() => r'53e93219fd8a54f9e32697d489db6b8509a652d9';

abstract class _$TaxRates extends $AsyncNotifier<List<TaxRateDto>> {
  FutureOr<List<TaxRateDto>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<TaxRateDto>>, List<TaxRateDto>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<TaxRateDto>>, List<TaxRateDto>>,
              AsyncValue<List<TaxRateDto>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
