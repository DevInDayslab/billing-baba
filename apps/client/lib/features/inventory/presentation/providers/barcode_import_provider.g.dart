// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'barcode_import_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(inventoryRepository)
final inventoryRepositoryProvider = InventoryRepositoryProvider._();

final class InventoryRepositoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<InventoryRepository>,
          InventoryRepository,
          FutureOr<InventoryRepository>
        >
    with
        $FutureModifier<InventoryRepository>,
        $FutureProvider<InventoryRepository> {
  InventoryRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'inventoryRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$inventoryRepositoryHash();

  @$internal
  @override
  $FutureProviderElement<InventoryRepository> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<InventoryRepository> create(Ref ref) {
    return inventoryRepository(ref);
  }
}

String _$inventoryRepositoryHash() =>
    r'a1b2c3d4e5f60718293a4b5c6d7e8f9a0b1c2d3';

@ProviderFor(barcodeLookupService)
final barcodeLookupServiceProvider = BarcodeLookupServiceProvider._();

final class BarcodeLookupServiceProvider
    extends
        $FunctionalProvider<
          AsyncValue<BarcodeLookupService>,
          BarcodeLookupService,
          FutureOr<BarcodeLookupService>
        >
    with
        $FutureModifier<BarcodeLookupService>,
        $FutureProvider<BarcodeLookupService> {
  BarcodeLookupServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'barcodeLookupServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$barcodeLookupServiceHash();

  @$internal
  @override
  $FutureProviderElement<BarcodeLookupService> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<BarcodeLookupService> create(Ref ref) {
    return barcodeLookupService(ref);
  }
}

String _$barcodeLookupServiceHash() =>
    r'b2c3d4e5f60718293a4b5c6d7e8f9a0b1c2d3e4';

@ProviderFor(BarcodeImportLookupError)
final barcodeImportLookupErrorProvider = BarcodeImportLookupErrorProvider._();

final class BarcodeImportLookupErrorProvider
    extends $NotifierProvider<BarcodeImportLookupError, bool> {
  BarcodeImportLookupErrorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'barcodeImportLookupErrorProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$barcodeImportLookupErrorHash();

  @$internal
  @override
  BarcodeImportLookupError create() => BarcodeImportLookupError();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$barcodeImportLookupErrorHash() =>
    r'c3d4e5f60718293a4b5c6d7e8f9a0b1c2d3e4f5';

abstract class _$BarcodeImportLookupError extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(BarcodeImport)
final barcodeImportProvider = BarcodeImportProvider._();

final class BarcodeImportProvider
    extends $NotifierProvider<BarcodeImport, List<BarcodeImportRow>> {
  BarcodeImportProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'barcodeImportProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$barcodeImportHash();

  @$internal
  @override
  BarcodeImport create() => BarcodeImport();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<BarcodeImportRow> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<BarcodeImportRow>>(value),
    );
  }
}

String _$barcodeImportHash() => r'8f3c2a1b9d4e5f60718293a4b5c6d7e8f9a0b1c2';

abstract class _$BarcodeImport extends $Notifier<List<BarcodeImportRow>> {
  List<BarcodeImportRow> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<List<BarcodeImportRow>, List<BarcodeImportRow>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<BarcodeImportRow>, List<BarcodeImportRow>>,
              List<BarcodeImportRow>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
