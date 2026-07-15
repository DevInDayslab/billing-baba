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

String _$leadServiceHash() => r'6cb602b8f2426d116d9348c95ad5b6a9ac0ef1af';
