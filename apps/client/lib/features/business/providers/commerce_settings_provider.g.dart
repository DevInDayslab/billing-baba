// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'commerce_settings_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(commerceSettingsRemoteDataSource)
final commerceSettingsRemoteDataSourceProvider =
    CommerceSettingsRemoteDataSourceProvider._();

final class CommerceSettingsRemoteDataSourceProvider
    extends
        $FunctionalProvider<
          AsyncValue<CommerceSettingsRemoteDataSource>,
          CommerceSettingsRemoteDataSource,
          FutureOr<CommerceSettingsRemoteDataSource>
        >
    with
        $FutureModifier<CommerceSettingsRemoteDataSource>,
        $FutureProvider<CommerceSettingsRemoteDataSource> {
  CommerceSettingsRemoteDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'commerceSettingsRemoteDataSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$commerceSettingsRemoteDataSourceHash();

  @$internal
  @override
  $FutureProviderElement<CommerceSettingsRemoteDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<CommerceSettingsRemoteDataSource> create(Ref ref) {
    return commerceSettingsRemoteDataSource(ref);
  }
}

String _$commerceSettingsRemoteDataSourceHash() =>
    r'93855fd02180d2619fa141f4b9fb6a355cc01036';

@ProviderFor(CommerceSettings)
final commerceSettingsProvider = CommerceSettingsProvider._();

final class CommerceSettingsProvider
    extends $AsyncNotifierProvider<CommerceSettings, CommerceSettingsModel> {
  CommerceSettingsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'commerceSettingsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$commerceSettingsHash();

  @$internal
  @override
  CommerceSettings create() => CommerceSettings();
}

String _$commerceSettingsHash() => r'8b58cceadbdb6208dd6840adc9d71a35675211f5';

abstract class _$CommerceSettings
    extends $AsyncNotifier<CommerceSettingsModel> {
  FutureOr<CommerceSettingsModel> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<CommerceSettingsModel>, CommerceSettingsModel>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<CommerceSettingsModel>,
                CommerceSettingsModel
              >,
              AsyncValue<CommerceSettingsModel>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
