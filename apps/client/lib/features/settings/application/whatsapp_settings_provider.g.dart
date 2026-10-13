// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'whatsapp_settings_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(whatsappSettingsRepository)
final whatsappSettingsRepositoryProvider =
    WhatsappSettingsRepositoryProvider._();

final class WhatsappSettingsRepositoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<WhatsAppSettingsRepository>,
          WhatsAppSettingsRepository,
          FutureOr<WhatsAppSettingsRepository>
        >
    with
        $FutureModifier<WhatsAppSettingsRepository>,
        $FutureProvider<WhatsAppSettingsRepository> {
  WhatsappSettingsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'whatsappSettingsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$whatsappSettingsRepositoryHash();

  @$internal
  @override
  $FutureProviderElement<WhatsAppSettingsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<WhatsAppSettingsRepository> create(Ref ref) {
    return whatsappSettingsRepository(ref);
  }
}

String _$whatsappSettingsRepositoryHash() =>
    r'cd3713f48f452c26801092b717d4ea5a5c84f166';

@ProviderFor(WhatsAppSettingsNotifier)
final whatsAppSettingsProvider = WhatsAppSettingsNotifierProvider._();

final class WhatsAppSettingsNotifierProvider
    extends $AsyncNotifierProvider<WhatsAppSettingsNotifier, WhatsAppSettings> {
  WhatsAppSettingsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'whatsAppSettingsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$whatsAppSettingsNotifierHash();

  @$internal
  @override
  WhatsAppSettingsNotifier create() => WhatsAppSettingsNotifier();
}

String _$whatsAppSettingsNotifierHash() =>
    r'899e7a9425b5a74140db2d3afccdd848159a0450';

abstract class _$WhatsAppSettingsNotifier
    extends $AsyncNotifier<WhatsAppSettings> {
  FutureOr<WhatsAppSettings> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<WhatsAppSettings>, WhatsAppSettings>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<WhatsAppSettings>, WhatsAppSettings>,
              AsyncValue<WhatsAppSettings>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
