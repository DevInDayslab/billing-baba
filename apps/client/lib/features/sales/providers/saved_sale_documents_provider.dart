import 'package:billing_baba/features/sales/models/sale_document_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

part 'saved_sale_documents_provider.g.dart';

@riverpod
class SavedSaleDocuments extends _$SavedSaleDocuments {
  @override
  List<SavedSaleDocument> build() => [];

  void addDocument(SavedSaleDocument document) {
    state = [...state, document];
  }

  void removeDocument(String id) {
    state = state.where((doc) => doc.id != id).toList();
  }

  void updateDocument(SavedSaleDocument updated) {
    state = [
      for (final doc in state)
        if (doc.id == updated.id) updated else doc,
    ];
  }

  List<SavedSaleDocument> forType(SaleDocumentType type) {
    return state.where((doc) => doc.documentType == type).toList();
  }
}

String nextSavedSaleDocumentId() => const Uuid().v4();
