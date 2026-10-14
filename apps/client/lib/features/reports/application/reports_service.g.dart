// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reports_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(reportsService)
final reportsServiceProvider = ReportsServiceProvider._();

final class ReportsServiceProvider
    extends
        $FunctionalProvider<
          AsyncValue<ReportsService>,
          ReportsService,
          FutureOr<ReportsService>
        >
    with $FutureModifier<ReportsService>, $FutureProvider<ReportsService> {
  ReportsServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'reportsServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$reportsServiceHash();

  @$internal
  @override
  $FutureProviderElement<ReportsService> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ReportsService> create(Ref ref) {
    return reportsService(ref);
  }
}

String _$reportsServiceHash() => r'2d4424bbe4bf9a1e009afa45b2b012355b9c0610';
