// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gstin_verification_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(gstinVerificationService)
final gstinVerificationServiceProvider = GstinVerificationServiceProvider._();

final class GstinVerificationServiceProvider
    extends
        $FunctionalProvider<
          AsyncValue<GstinVerificationService>,
          GstinVerificationService,
          FutureOr<GstinVerificationService>
        >
    with
        $FutureModifier<GstinVerificationService>,
        $FutureProvider<GstinVerificationService> {
  GstinVerificationServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'gstinVerificationServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$gstinVerificationServiceHash();

  @$internal
  @override
  $FutureProviderElement<GstinVerificationService> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<GstinVerificationService> create(Ref ref) {
    return gstinVerificationService(ref);
  }
}

String _$gstinVerificationServiceHash() =>
    r'1e055163660ae547e005def7ae2341392c5c6fe5';
