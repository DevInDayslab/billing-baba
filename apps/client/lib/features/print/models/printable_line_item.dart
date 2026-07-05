import 'package:billing_baba/features/inventory/models/dto/item_dto.dart';
import 'package:billing_baba/features/sales/models/dto/sales_document_dto.dart';

/// A document line enriched with optional inventory item details.
class PrintableLineItem {
  const PrintableLineItem({
    required this.line,
    this.item,
  });

  final SalesDocumentLineDto line;
  final ItemDetailDto? item;

  String get itemId => line.itemId;
  String get displayName => item?.name ?? line.itemId;
  String? get hsnCode => item?.hsnCode;
  String? get description => item?.description;
}
