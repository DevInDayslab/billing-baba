// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_return_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(posReturnService)
final posReturnServiceProvider = PosReturnServiceProvider._();

final class PosReturnServiceProvider
    extends
        $FunctionalProvider<
          AsyncValue<PosReturnService>,
          PosReturnService,
          FutureOr<PosReturnService>
        >
    with $FutureModifier<PosReturnService>, $FutureProvider<PosReturnService> {
  PosReturnServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'posReturnServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$posReturnServiceHash();

  @$internal
  @override
  $FutureProviderElement<PosReturnService> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<PosReturnService> create(Ref ref) {
    return posReturnService(ref);
  }
}

String _$posReturnServiceHash() => r'f54484c11c166337272568e0cd7b7452b0d93d2c';

@ProviderFor(processPosReturn)
final processPosReturnProvider = ProcessPosReturnFamily._();

final class ProcessPosReturnProvider
    extends $FunctionalProvider<AsyncValue<PosSale>, PosSale, FutureOr<PosSale>>
    with $FutureModifier<PosSale>, $FutureProvider<PosSale> {
  ProcessPosReturnProvider._({
    required ProcessPosReturnFamily super.from,
    required ({
      PosSale originalSale,
      List<ReturnItem> returnItems,
      PaymentMode refundMode,
    })
    super.argument,
  }) : super(
         retry: null,
         name: r'processPosReturnProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$processPosReturnHash();

  @override
  String toString() {
    return r'processPosReturnProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<PosSale> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<PosSale> create(Ref ref) {
    final argument =
        this.argument
            as ({
              PosSale originalSale,
              List<ReturnItem> returnItems,
              PaymentMode refundMode,
            });
    return processPosReturn(
      ref,
      originalSale: argument.originalSale,
      returnItems: argument.returnItems,
      refundMode: argument.refundMode,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ProcessPosReturnProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$processPosReturnHash() => r'da1814de7a69519c92f3dc37cdf913b8c1189f7a';

final class ProcessPosReturnFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<PosSale>,
          ({
            PosSale originalSale,
            List<ReturnItem> returnItems,
            PaymentMode refundMode,
          })
        > {
  ProcessPosReturnFamily._()
    : super(
        retry: null,
        name: r'processPosReturnProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ProcessPosReturnProvider call({
    required PosSale originalSale,
    required List<ReturnItem> returnItems,
    required PaymentMode refundMode,
  }) => ProcessPosReturnProvider._(
    argument: (
      originalSale: originalSale,
      returnItems: returnItems,
      refundMode: refundMode,
    ),
    from: this,
  );

  @override
  String toString() => r'processPosReturnProvider';
}
