import 'package:billing_baba/features/purchases/models/dto/purchase_document_parse_dto.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'pending_purchase_document_parse_provider.g.dart';

@Riverpod(keepAlive: true)
class PendingPurchaseDocumentParse extends _$PendingPurchaseDocumentParse {
  @override
  PurchaseDocumentParseDto? build() => null;

  void set(PurchaseDocumentParseDto? value) {
    state = value;
  }

  PurchaseDocumentParseDto? take() {
    final current = state;
    state = null;
    return current;
  }
}
