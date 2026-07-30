// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sales_documents_by_type_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(salesDocumentsByType)
final salesDocumentsByTypeProvider = SalesDocumentsByTypeFamily._();

final class SalesDocumentsByTypeProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SaleInvoiceModel>>,
          List<SaleInvoiceModel>,
          FutureOr<List<SaleInvoiceModel>>
        >
    with
        $FutureModifier<List<SaleInvoiceModel>>,
        $FutureProvider<List<SaleInvoiceModel>> {
  SalesDocumentsByTypeProvider._({
    required SalesDocumentsByTypeFamily super.from,
    required SalesDocumentType super.argument,
  }) : super(
         retry: null,
         name: r'salesDocumentsByTypeProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$salesDocumentsByTypeHash();

  @override
  String toString() {
    return r'salesDocumentsByTypeProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<SaleInvoiceModel>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<SaleInvoiceModel>> create(Ref ref) {
    final argument = this.argument as SalesDocumentType;
    return salesDocumentsByType(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SalesDocumentsByTypeProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$salesDocumentsByTypeHash() =>
    r'1112e7bba6abb72d7e0756073be620f0250b1664';

final class SalesDocumentsByTypeFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<SaleInvoiceModel>>,
          SalesDocumentType
        > {
  SalesDocumentsByTypeFamily._()
    : super(
        retry: null,
        name: r'salesDocumentsByTypeProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SalesDocumentsByTypeProvider call(SalesDocumentType documentType) =>
      SalesDocumentsByTypeProvider._(argument: documentType, from: this);

  @override
  String toString() => r'salesDocumentsByTypeProvider';
}
