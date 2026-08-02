import 'package:billing_baba/core/database/database.dart';
import 'package:billing_baba/features/inventory/models/dto/movement_dto.dart';
import 'package:drift/drift.dart';

/// Projects stock movements from finalized local sales/purchase documents.
class InventoryMovementProjector {
  InventoryMovementProjector(this._db);

  final AppDatabase _db;

  static const _outboundSaleTypes = {
    'tax_invoice',
    'bill_of_supply',
    'normal_invoice',
    'pos',
  };

  Future<List<MovementDto>> projectForItem({
    required String businessId,
    required String itemId,
  }) async {
    final movements = <MovementDto>[];

    final saleHeaders =
        await (_db.select(_db.salesDocumentsLocal)..where(
              (t) =>
                  t.businessId.equals(businessId) &
                  t.status.equals('finalized') &
                  t.isDeleted.equals(false),
            ))
            .get();

    for (final header in saleHeaders) {
      final lines =
          await (_db.select(_db.salesDocumentLinesLocal)
                ..where(
                  (t) =>
                      t.salesDocumentId.equals(header.id) &
                      t.itemId.equals(itemId) &
                      t.isDeleted.equals(false),
                )
                ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
              .get();
      if (lines.isEmpty) continue;

      final movementType = _saleMovementType(header.documentType);
      if (movementType == null) continue;

      for (final line in lines) {
        final qty = double.tryParse(line.quantity) ?? 0;
        if (qty == 0) continue;
        final signedQty = _signedQuantity(
          movementType: movementType,
          quantity: qty,
        );

        movements.add(
          MovementDto(
            id: 'proj-sale-${line.id}',
            itemId: line.itemId,
            itemName: line.itemId,
            godownId: header.godownId ?? 'default',
            godownName: header.godownId ?? 'Main',
            movementType: movementType,
            quantityDelta: _formatQty(signedQty),
            createdAt: header.updatedAt.toUtc().toIso8601String(),
            costPerUnit: line.unitPrice,
            unit: line.unit,
            referenceId: header.id,
            referenceType: 'sales_documents',
            referenceNumber: header.documentNumber,
            notes: header.notes,
          ),
        );
      }
    }

    final purchaseHeaders =
        await (_db.select(_db.purchaseDocumentsLocal)..where(
              (t) =>
                  t.businessId.equals(businessId) &
                  t.status.equals('finalized') &
                  t.isDeleted.equals(false),
            ))
            .get();

    for (final header in purchaseHeaders) {
      final lines =
          await (_db.select(_db.purchaseDocumentLinesLocal)
                ..where(
                  (t) =>
                      t.purchaseDocumentId.equals(header.id) &
                      t.itemId.equals(itemId) &
                      t.isDeleted.equals(false),
                )
                ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
              .get();
      if (lines.isEmpty) continue;

      final movementType = _purchaseMovementType(header.documentType);
      if (movementType == null) continue;

      for (final line in lines) {
        final qty = double.tryParse(line.quantity) ?? 0;
        if (qty == 0) continue;
        final signedQty = _signedQuantity(
          movementType: movementType,
          quantity: qty,
        );

        movements.add(
          MovementDto(
            id: 'proj-purchase-${line.id}',
            itemId: line.itemId,
            itemName: line.itemId,
            godownId: header.godownId ?? 'default',
            godownName: header.godownId ?? 'Main',
            movementType: movementType,
            quantityDelta: _formatQty(signedQty),
            createdAt: header.updatedAt.toUtc().toIso8601String(),
            costPerUnit: line.unitPrice,
            unit: line.unit,
            referenceId: header.id,
            referenceType: 'purchase_documents',
            referenceNumber: header.documentNumber,
            notes: header.notes,
          ),
        );
      }
    }

    return movements;
  }

  static String? _saleMovementType(String documentType) {
    if (_outboundSaleTypes.contains(documentType)) return 'sale';
    return switch (documentType) {
      'sales_return' => 'sales_return',
      'delivery_challan' => 'challan',
      _ => null,
    };
  }

  static String? _purchaseMovementType(String documentType) {
    return switch (documentType) {
      'purchase_bill' => 'purchase',
      'purchase_return' => 'purchase_return',
      _ => null,
    };
  }

  static double _signedQuantity({
    required String movementType,
    required double quantity,
  }) {
    return switch (movementType) {
      'purchase' || 'sales_return' || 'opening' => quantity.abs(),
      'sale' || 'purchase_return' || 'challan' => -quantity.abs(),
      'adjustment' => quantity,
      _ => quantity,
    };
  }

  static String _formatQty(double value) {
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0);
    }
    return value.toStringAsFixed(4);
  }
}
