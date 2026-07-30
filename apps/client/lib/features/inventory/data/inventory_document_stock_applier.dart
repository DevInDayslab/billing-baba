import 'package:billing_baba/features/inventory/data/inventory_stock_local_data_source.dart';
import 'package:billing_baba/features/purchases/data/purchase_local_data_source.dart';
import 'package:billing_baba/features/sales/data/sales_local_data_source.dart';

/// Applies optimistic stock movements when sales/purchase documents finalize.
class InventoryDocumentStockApplier {
  InventoryDocumentStockApplier({
    required this._stockLocal,
    required this._salesLocal,
    required this._purchaseLocal,
  });

  final InventoryStockLocalDataSource _stockLocal;
  final SalesLocalDataSource _salesLocal;
  final PurchaseLocalDataSource _purchaseLocal;

  static const _outboundSaleTypes = {
    'tax_invoice',
    'bill_of_supply',
    'normal_invoice',
    'pos',
  };

  Future<void> applySalesDocument({
    required String businessId,
    required String documentId,
    String? godownId,
    String? deviceId,
  }) async {
    final document = await _salesLocal.getDocument(documentId);
    if (document == null || document.status != 'finalized') return;

    final movementType = _saleMovementType(document.documentType);
    if (movementType == null) return;

    final resolvedGodown = godownId ??
        await _salesLocal.getDocumentGodownId(documentId) ??
        'default';
    final now = DateTime.now().toUtc();

    for (final line in document.lines) {
      final qty = double.tryParse(line.quantity) ?? 0;
      if (qty == 0) continue;

      await _stockLocal.recordDocumentMovement(
        movementId: 'doc-sale-${line.id}',
        businessId: businessId,
        itemId: line.itemId,
        godownId: resolvedGodown,
        movementType: movementType,
        quantityDelta: _signedQuantity(
          movementType: movementType,
          quantity: qty,
        ),
        documentId: documentId,
        documentType: document.documentType,
        referenceType: 'sales_documents',
        referenceNumber: document.documentNumber,
        costPerUnit: line.unitPrice,
        unit: line.unit,
        notes: document.notes,
        createdAt: now,
        deviceId: deviceId,
      );
    }
  }

  Future<void> applyPurchaseDocument({
    required String businessId,
    required String documentId,
    String? godownId,
    String? deviceId,
  }) async {
    final document = await _purchaseLocal.getDocument(documentId);
    if (document == null || document.status != 'finalized') return;

    final movementType = _purchaseMovementType(document.documentType);
    if (movementType == null) return;

    final resolvedGodown = godownId ??
        await _purchaseLocal.getDocumentGodownId(documentId) ??
        'default';
    final now = DateTime.now().toUtc();

    for (final line in document.lines) {
      final qty = double.tryParse(line.quantity) ?? 0;
      if (qty == 0) continue;

      await _stockLocal.recordDocumentMovement(
        movementId: 'doc-purchase-${line.id}',
        businessId: businessId,
        itemId: line.itemId,
        godownId: resolvedGodown,
        movementType: movementType,
        quantityDelta: _signedQuantity(
          movementType: movementType,
          quantity: qty,
        ),
        documentId: documentId,
        documentType: document.documentType,
        referenceType: 'purchase_documents',
        referenceNumber: document.documentNumber,
        costPerUnit: line.unitPrice,
        unit: line.unit,
        notes: document.notes,
        createdAt: now,
        deviceId: deviceId,
      );
    }
  }

  /// Backfills stock movements from finalized local documents (one-time migration).
  Future<void> backfillBusinessStock({
    required String businessId,
    String? deviceId,
  }) async {
    final salesDocIds = await _salesLocal.listFinalizedDocumentIds(businessId);
    for (final documentId in salesDocIds) {
      await applySalesDocument(
        businessId: businessId,
        documentId: documentId,
        deviceId: deviceId,
      );
    }

    final purchaseDocIds =
        await _purchaseLocal.listFinalizedDocumentIds(businessId);
    for (final documentId in purchaseDocIds) {
      await applyPurchaseDocument(
        businessId: businessId,
        documentId: documentId,
        deviceId: deviceId,
      );
    }
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
}
