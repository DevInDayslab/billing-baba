// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_session_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(posSessionService)
final posSessionServiceProvider = PosSessionServiceProvider._();

final class PosSessionServiceProvider
    extends
        $FunctionalProvider<
          AsyncValue<PosSessionService>,
          PosSessionService,
          FutureOr<PosSessionService>
        >
    with
        $FutureModifier<PosSessionService>,
        $FutureProvider<PosSessionService> {
  PosSessionServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'posSessionServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$posSessionServiceHash();

  @$internal
  @override
  $FutureProviderElement<PosSessionService> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<PosSessionService> create(Ref ref) {
    return posSessionService(ref);
  }
}

String _$posSessionServiceHash() => r'e11422c3ed3fd686bb02a8b179fc8fac6e9744c1';
