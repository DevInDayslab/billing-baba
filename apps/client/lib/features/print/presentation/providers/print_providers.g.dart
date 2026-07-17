// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'print_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(printRepository)
final printRepositoryProvider = PrintRepositoryProvider._();

final class PrintRepositoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<PrintRepository>,
          PrintRepository,
          FutureOr<PrintRepository>
        >
    with $FutureModifier<PrintRepository>, $FutureProvider<PrintRepository> {
  PrintRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'printRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$printRepositoryHash();

  @$internal
  @override
  $FutureProviderElement<PrintRepository> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<PrintRepository> create(Ref ref) {
    return printRepository(ref);
  }
}

String _$printRepositoryHash() => r'31e1c555de09e7a3f7105176aa5737ebb9a76159';

@ProviderFor(printImageCache)
final printImageCacheProvider = PrintImageCacheProvider._();

final class PrintImageCacheProvider
    extends
        $FunctionalProvider<
          AsyncValue<PrintImageCache>,
          PrintImageCache,
          FutureOr<PrintImageCache>
        >
    with $FutureModifier<PrintImageCache>, $FutureProvider<PrintImageCache> {
  PrintImageCacheProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'printImageCacheProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$printImageCacheHash();

  @$internal
  @override
  $FutureProviderElement<PrintImageCache> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<PrintImageCache> create(Ref ref) {
    return printImageCache(ref);
  }
}

String _$printImageCacheHash() => r'e0376849c34e6fbe8958cae2c731dcc07acf147a';

@ProviderFor(templateRegistry)
final templateRegistryProvider = TemplateRegistryProvider._();

final class TemplateRegistryProvider
    extends
        $FunctionalProvider<
          TemplateRegistry,
          TemplateRegistry,
          TemplateRegistry
        >
    with $Provider<TemplateRegistry> {
  TemplateRegistryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'templateRegistryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$templateRegistryHash();

  @$internal
  @override
  $ProviderElement<TemplateRegistry> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TemplateRegistry create(Ref ref) {
    return templateRegistry(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TemplateRegistry value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TemplateRegistry>(value),
    );
  }
}

String _$templateRegistryHash() => r'039f2ae892cadf9f2fe539303780cd2a0a513f64';

@ProviderFor(printOutputService)
final printOutputServiceProvider = PrintOutputServiceProvider._();

final class PrintOutputServiceProvider
    extends
        $FunctionalProvider<
          PrintOutputService,
          PrintOutputService,
          PrintOutputService
        >
    with $Provider<PrintOutputService> {
  PrintOutputServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'printOutputServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$printOutputServiceHash();

  @$internal
  @override
  $ProviderElement<PrintOutputService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PrintOutputService create(Ref ref) {
    return printOutputService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PrintOutputService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PrintOutputService>(value),
    );
  }
}

String _$printOutputServiceHash() =>
    r'a4d57de6f7a810dc01c00ec48fee14df6b8c8d77';

@ProviderFor(printDataService)
final printDataServiceProvider = PrintDataServiceProvider._();

final class PrintDataServiceProvider
    extends
        $FunctionalProvider<
          AsyncValue<PrintDataService>,
          PrintDataService,
          FutureOr<PrintDataService>
        >
    with $FutureModifier<PrintDataService>, $FutureProvider<PrintDataService> {
  PrintDataServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'printDataServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$printDataServiceHash();

  @$internal
  @override
  $FutureProviderElement<PrintDataService> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<PrintDataService> create(Ref ref) {
    return printDataService(ref);
  }
}

String _$printDataServiceHash() => r'3417c474398bd91227bfc8f24cef176b4fb752ef';

@ProviderFor(printService)
final printServiceProvider = PrintServiceProvider._();

final class PrintServiceProvider
    extends
        $FunctionalProvider<
          AsyncValue<PrintService>,
          PrintService,
          FutureOr<PrintService>
        >
    with $FutureModifier<PrintService>, $FutureProvider<PrintService> {
  PrintServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'printServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$printServiceHash();

  @$internal
  @override
  $FutureProviderElement<PrintService> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<PrintService> create(Ref ref) {
    return printService(ref);
  }
}

String _$printServiceHash() => r'04044d5ea9274ca8384d7062f7699059761b14df';

@ProviderFor(printableDocument)
final printableDocumentProvider = PrintableDocumentFamily._();

final class PrintableDocumentProvider
    extends
        $FunctionalProvider<
          AsyncValue<PrintableDocument>,
          PrintableDocument,
          FutureOr<PrintableDocument>
        >
    with
        $FutureModifier<PrintableDocument>,
        $FutureProvider<PrintableDocument> {
  PrintableDocumentProvider._({
    required PrintableDocumentFamily super.from,
    required PrintRequest super.argument,
  }) : super(
         retry: null,
         name: r'printableDocumentProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$printableDocumentHash();

  @override
  String toString() {
    return r'printableDocumentProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<PrintableDocument> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<PrintableDocument> create(Ref ref) {
    final argument = this.argument as PrintRequest;
    return printableDocument(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PrintableDocumentProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$printableDocumentHash() => r'8d1e41c470ee74d3f50ae36235413eaf65fcee94';

final class PrintableDocumentFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<PrintableDocument>, PrintRequest> {
  PrintableDocumentFamily._()
    : super(
        retry: null,
        name: r'printableDocumentProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PrintableDocumentProvider call(PrintRequest request) =>
      PrintableDocumentProvider._(argument: request, from: this);

  @override
  String toString() => r'printableDocumentProvider';
}
