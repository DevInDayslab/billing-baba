// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pending_purchase_document_parse_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PendingPurchaseDocumentParse)
final pendingPurchaseDocumentParseProvider =
    PendingPurchaseDocumentParseProvider._();

final class PendingPurchaseDocumentParseProvider
    extends
        $NotifierProvider<
          PendingPurchaseDocumentParse,
          PurchaseDocumentParseDto?
        > {
  PendingPurchaseDocumentParseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pendingPurchaseDocumentParseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pendingPurchaseDocumentParseHash();

  @$internal
  @override
  PendingPurchaseDocumentParse create() => PendingPurchaseDocumentParse();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PurchaseDocumentParseDto? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PurchaseDocumentParseDto?>(value),
    );
  }
}

String _$pendingPurchaseDocumentParseHash() =>
    r'bb368cffe06a94504efbf0776bef53c7160a4623';

abstract class _$PendingPurchaseDocumentParse
    extends $Notifier<PurchaseDocumentParseDto?> {
  PurchaseDocumentParseDto? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<PurchaseDocumentParseDto?, PurchaseDocumentParseDto?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PurchaseDocumentParseDto?, PurchaseDocumentParseDto?>,
              PurchaseDocumentParseDto?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
