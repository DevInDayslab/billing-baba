// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lead_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(leadService)
final leadServiceProvider = LeadServiceProvider._();

final class LeadServiceProvider
    extends
        $FunctionalProvider<
          AsyncValue<LeadService>,
          LeadService,
          FutureOr<LeadService>
        >
    with $FutureModifier<LeadService>, $FutureProvider<LeadService> {
  LeadServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'leadServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$leadServiceHash();

  @$internal
  @override
  $FutureProviderElement<LeadService> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<LeadService> create(Ref ref) {
    return leadService(ref);
  }
}

String _$leadServiceHash() => r'8a3b842a46f1fb5a690941d3b6481facf6a1d093';
