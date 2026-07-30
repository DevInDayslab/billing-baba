// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'purchase_fa_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(purchaseFaService)
final purchaseFaServiceProvider = PurchaseFaServiceProvider._();

final class PurchaseFaServiceProvider
    extends
        $FunctionalProvider<
          AsyncValue<PurchaseFaService>,
          PurchaseFaService,
          FutureOr<PurchaseFaService>
        >
    with
        $FutureModifier<PurchaseFaService>,
        $FutureProvider<PurchaseFaService> {
  PurchaseFaServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'purchaseFaServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$purchaseFaServiceHash();

  @$internal
  @override
  $FutureProviderElement<PurchaseFaService> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<PurchaseFaService> create(Ref ref) {
    return purchaseFaService(ref);
  }
}

String _$purchaseFaServiceHash() => r'5d528b6a832bfb12b7648eb1bc7ad474bd366156';
