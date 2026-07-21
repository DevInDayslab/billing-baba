// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_repository_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(posRepository)
final posRepositoryProvider = PosRepositoryProvider._();

final class PosRepositoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<PosRepository>,
          PosRepository,
          FutureOr<PosRepository>
        >
    with $FutureModifier<PosRepository>, $FutureProvider<PosRepository> {
  PosRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'posRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$posRepositoryHash();

  @$internal
  @override
  $FutureProviderElement<PosRepository> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<PosRepository> create(Ref ref) {
    return posRepository(ref);
  }
}

String _$posRepositoryHash() => r'f3f22cdbe480de106ad5b5c3572788ed596f2c59';

@ProviderFor(activePosBusinessId)
final activePosBusinessIdProvider = ActivePosBusinessIdProvider._();

final class ActivePosBusinessIdProvider
    extends $FunctionalProvider<String?, String?, String?>
    with $Provider<String?> {
  ActivePosBusinessIdProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activePosBusinessIdProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activePosBusinessIdHash();

  @$internal
  @override
  $ProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String? create(Ref ref) {
    return activePosBusinessId(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$activePosBusinessIdHash() =>
    r'1090a1e0715bc08211291572071a9792bb49fc75';
