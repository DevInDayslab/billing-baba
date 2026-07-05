// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'export_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(exportService)
final exportServiceProvider = ExportServiceProvider._();

final class ExportServiceProvider
    extends $FunctionalProvider<ExportService, ExportService, ExportService>
    with $Provider<ExportService> {
  ExportServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'exportServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$exportServiceHash();

  @$internal
  @override
  $ProviderElement<ExportService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ExportService create(Ref ref) {
    return exportService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ExportService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ExportService>(value),
    );
  }
}

String _$exportServiceHash() => r'dfb4d7e6ee1997f24fcd129754cc99b6f674f4fd';

@ProviderFor(exportOutputService)
final exportOutputServiceProvider = ExportOutputServiceProvider._();

final class ExportOutputServiceProvider
    extends
        $FunctionalProvider<
          ExportOutputService,
          ExportOutputService,
          ExportOutputService
        >
    with $Provider<ExportOutputService> {
  ExportOutputServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'exportOutputServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$exportOutputServiceHash();

  @$internal
  @override
  $ProviderElement<ExportOutputService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ExportOutputService create(Ref ref) {
    return exportOutputService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ExportOutputService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ExportOutputService>(value),
    );
  }
}

String _$exportOutputServiceHash() =>
    r'c6b59d0e1d217ed14cae273c1ffdd3ab237482e3';
