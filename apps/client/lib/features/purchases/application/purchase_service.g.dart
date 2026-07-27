// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'purchase_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(purchaseService)
final purchaseServiceProvider = PurchaseServiceProvider._();

final class PurchaseServiceProvider
    extends
        $FunctionalProvider<
          AsyncValue<PurchaseService>,
          PurchaseService,
          FutureOr<PurchaseService>
        >
    with $FutureModifier<PurchaseService>, $FutureProvider<PurchaseService> {
  PurchaseServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'purchaseServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$purchaseServiceHash();

  @$internal
  @override
  $FutureProviderElement<PurchaseService> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<PurchaseService> create(Ref ref) {
    return purchaseService(ref);
  }
}

String _$purchaseServiceHash() => r'574b899c24efd31654bf38b02d3361b4403754b6';
