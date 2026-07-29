import 'package:billing_baba/features/purchases/models/dto/purchase_document_dto.dart';
import 'package:billing_baba/features/purchases/models/purchase_bill_form_model.dart';
import 'package:billing_baba/features/sales/models/dto/sales_document_dto.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_form_model.dart';

/// Resolves the server line id when the local form has not yet bound one.
String? resolveServerLineId({
  required String? localServerLineId,
  required int sortOrder,
  required String itemId,
  required List<({String id, String itemId, int sortOrder})> existingLines,
  required Set<String> keptServerIds,
}) {
  if (localServerLineId != null) {
    return localServerLineId;
  }

  final unmatched = existingLines
      .where((line) => !keptServerIds.contains(line.id))
      .toList(growable: false);

  final bySortOrder = unmatched
      .where((line) => line.sortOrder == sortOrder)
      .toList();
  if (bySortOrder.length == 1) {
    return bySortOrder.first.id;
  }

  final byItemId = unmatched.where((line) => line.itemId == itemId).toList();
  if (byItemId.length == 1) {
    return byItemId.first.id;
  }

  return null;
}

List<({String id, String itemId, int sortOrder})> _saleLineRefs(
  List<SalesDocumentLineDto> lines,
) {
  return [
    for (final line in lines)
      (id: line.id, itemId: line.itemId, sortOrder: line.sortOrder),
  ];
}

List<({String id, String itemId, int sortOrder})> _purchaseLineRefs(
  List<PurchaseDocumentLineDto> lines,
) {
  return [
    for (final line in lines)
      (id: line.id, itemId: line.itemId, sortOrder: line.sortOrder),
  ];
}

String? resolveSaleServerLineId({
  required String? localServerLineId,
  required int sortOrder,
  required String itemId,
  required List<SalesDocumentLineDto> existingLines,
  required Set<String> keptServerIds,
}) {
  return resolveServerLineId(
    localServerLineId: localServerLineId,
    sortOrder: sortOrder,
    itemId: itemId,
    existingLines: _saleLineRefs(existingLines),
    keptServerIds: keptServerIds,
  );
}

String? resolvePurchaseServerLineId({
  required String? localServerLineId,
  required int sortOrder,
  required String itemId,
  required List<PurchaseDocumentLineDto> existingLines,
  required Set<String> keptServerIds,
}) {
  return resolveServerLineId(
    localServerLineId: localServerLineId,
    sortOrder: sortOrder,
    itemId: itemId,
    existingLines: _purchaseLineRefs(existingLines),
    keptServerIds: keptServerIds,
  );
}

/// Binds server line ids onto local sale form lines after a draft sync.
List<SaleLineItem> bindSaleServerLineIds(
  List<SaleLineItem> items,
  List<SalesDocumentLineDto> serverLines,
) {
  final sortedServer = [...serverLines]
    ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  var filledIndex = 0;

  return [
    for (final line in items)
      if (line.itemName.trim().isEmpty && line.qty <= 0)
        line
      else ...[
        () {
          final server = filledIndex < sortedServer.length
              ? sortedServer[filledIndex]
              : null;
          filledIndex++;
          if (server == null) return line;
          return line.copyWith(
            serverLineId: server.id,
            itemId: server.itemId,
          );
        }(),
      ],
  ];
}

/// Binds server line ids onto local purchase form lines after a draft sync.
List<PurchaseLineItem> bindPurchaseServerLineIds(
  List<PurchaseLineItem> items,
  List<PurchaseDocumentLineDto> serverLines,
) {
  final sortedServer = [...serverLines]
    ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  var filledIndex = 0;

  return [
    for (final line in items)
      if (line.itemName.trim().isEmpty && line.qty <= 0)
        line
      else ...[
        () {
          final server = filledIndex < sortedServer.length
              ? sortedServer[filledIndex]
              : null;
          filledIndex++;
          if (server == null) return line;
          return line.copyWith(
            serverLineId: server.id,
            itemId: server.itemId,
          );
        }(),
      ],
  ];
}
