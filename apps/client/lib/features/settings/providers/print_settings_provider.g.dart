// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'print_settings_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(printSettingsRepository)
final printSettingsRepositoryProvider = PrintSettingsRepositoryProvider._();

final class PrintSettingsRepositoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<PrintSettingsRepository>,
          PrintSettingsRepository,
          FutureOr<PrintSettingsRepository>
        >
    with
        $FutureModifier<PrintSettingsRepository>,
        $FutureProvider<PrintSettingsRepository> {
  PrintSettingsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'printSettingsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$printSettingsRepositoryHash();

  @$internal
  @override
  $FutureProviderElement<PrintSettingsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<PrintSettingsRepository> create(Ref ref) {
    return printSettingsRepository(ref);
  }
}

String _$printSettingsRepositoryHash() =>
    r'c8f3a1b2d4e5f60718293a4b5c6d7e8f90123456';

@ProviderFor(PrintSettingsNotifier)
final printSettingsNotifierProvider = PrintSettingsNotifierProvider._();

final class PrintSettingsNotifierProvider
    extends $AsyncNotifierProvider<PrintSettingsNotifier, PrintSettings> {
  PrintSettingsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'printSettingsNotifierProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$printSettingsNotifierHash();

  @$internal
  @override
  PrintSettingsNotifier create() => PrintSettingsNotifier();
}

String _$printSettingsNotifierHash() =>
    r'a1b2c3d4e5f60718293a4b5c6d7e8f90123456789';

abstract class _$PrintSettingsNotifier extends $AsyncNotifier<PrintSettings> {
  FutureOr<PrintSettings> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<PrintSettings>, PrintSettings>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<PrintSettings>, PrintSettings>,
              AsyncValue<PrintSettings>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
