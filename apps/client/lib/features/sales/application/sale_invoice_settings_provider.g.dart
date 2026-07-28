// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sale_invoice_settings_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(saleInvoiceSettingsRepository)
final saleInvoiceSettingsRepositoryProvider =
    SaleInvoiceSettingsRepositoryProvider._();

final class SaleInvoiceSettingsRepositoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<SaleInvoiceSettingsRepository>,
          SaleInvoiceSettingsRepository,
          FutureOr<SaleInvoiceSettingsRepository>
        >
    with
        $FutureModifier<SaleInvoiceSettingsRepository>,
        $FutureProvider<SaleInvoiceSettingsRepository> {
  SaleInvoiceSettingsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'saleInvoiceSettingsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$saleInvoiceSettingsRepositoryHash();

  @$internal
  @override
  $FutureProviderElement<SaleInvoiceSettingsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SaleInvoiceSettingsRepository> create(Ref ref) {
    return saleInvoiceSettingsRepository(ref);
  }
}

String _$saleInvoiceSettingsRepositoryHash() =>
    r'e9ddbb96ccb65c5122977cd32c58a6b728f17f32';

@ProviderFor(SaleInvoiceSettingsNotifier)
final saleInvoiceSettingsProvider = SaleInvoiceSettingsNotifierProvider._();

final class SaleInvoiceSettingsNotifierProvider
    extends
        $AsyncNotifierProvider<
          SaleInvoiceSettingsNotifier,
          SaleInvoiceSettings
        > {
  SaleInvoiceSettingsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'saleInvoiceSettingsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$saleInvoiceSettingsNotifierHash();

  @$internal
  @override
  SaleInvoiceSettingsNotifier create() => SaleInvoiceSettingsNotifier();
}

String _$saleInvoiceSettingsNotifierHash() =>
    r'e8c8d99bb43378163104934284934f31a61907f5';

abstract class _$SaleInvoiceSettingsNotifier
    extends $AsyncNotifier<SaleInvoiceSettings> {
  FutureOr<SaleInvoiceSettings> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<SaleInvoiceSettings>, SaleInvoiceSettings>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<SaleInvoiceSettings>, SaleInvoiceSettings>,
              AsyncValue<SaleInvoiceSettings>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
