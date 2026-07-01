// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saved_sale_documents_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SavedSaleDocuments)
final savedSaleDocumentsProvider = SavedSaleDocumentsProvider._();

final class SavedSaleDocumentsProvider
    extends $NotifierProvider<SavedSaleDocuments, List<SavedSaleDocument>> {
  SavedSaleDocumentsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'savedSaleDocumentsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$savedSaleDocumentsHash();

  @$internal
  @override
  SavedSaleDocuments create() => SavedSaleDocuments();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<SavedSaleDocument> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<SavedSaleDocument>>(value),
    );
  }
}

String _$savedSaleDocumentsHash() =>
    r'652d85261ac779e42137c99dd9dc18ec8fda6ec4';

abstract class _$SavedSaleDocuments extends $Notifier<List<SavedSaleDocument>> {
  List<SavedSaleDocument> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<List<SavedSaleDocument>, List<SavedSaleDocument>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<SavedSaleDocument>, List<SavedSaleDocument>>,
              List<SavedSaleDocument>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
