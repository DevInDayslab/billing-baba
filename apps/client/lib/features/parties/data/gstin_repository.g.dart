// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gstin_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(gstinRepository)
final gstinRepositoryProvider = GstinRepositoryProvider._();

final class GstinRepositoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<GstinRepository>,
          GstinRepository,
          FutureOr<GstinRepository>
        >
    with $FutureModifier<GstinRepository>, $FutureProvider<GstinRepository> {
  GstinRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'gstinRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$gstinRepositoryHash();

  @$internal
  @override
  $FutureProviderElement<GstinRepository> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<GstinRepository> create(Ref ref) {
    return gstinRepository(ref);
  }
}

String _$gstinRepositoryHash() => r'269a657eda5ab67bc8c28ea764bbb906465243f2';
