// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_receipt_printer.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(posReceiptPrinter)
final posReceiptPrinterProvider = PosReceiptPrinterProvider._();

final class PosReceiptPrinterProvider
    extends
        $FunctionalProvider<
          PosReceiptPrinter,
          PosReceiptPrinter,
          PosReceiptPrinter
        >
    with $Provider<PosReceiptPrinter> {
  PosReceiptPrinterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'posReceiptPrinterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$posReceiptPrinterHash();

  @$internal
  @override
  $ProviderElement<PosReceiptPrinter> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PosReceiptPrinter create(Ref ref) {
    return posReceiptPrinter(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PosReceiptPrinter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PosReceiptPrinter>(value),
    );
  }
}

String _$posReceiptPrinterHash() => r'436b401f51f92f44942bf850f28d8eaf5e35f530';
