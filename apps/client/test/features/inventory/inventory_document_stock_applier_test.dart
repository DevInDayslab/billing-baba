import 'package:billing_baba/core/constants/storage_keys.dart';
import 'package:billing_baba/core/database/database.dart';
import 'package:billing_baba/core/services/storage_service.dart';
import 'package:billing_baba/features/inventory/data/godown_local_source.dart';
import 'package:billing_baba/features/inventory/data/inventory_document_stock_applier.dart';
import 'package:billing_baba/features/inventory/data/inventory_stock_local_data_source.dart';
import 'package:billing_baba/features/inventory/models/requests/movement_requests.dart';
import 'package:billing_baba/features/purchases/data/purchase_local_data_source.dart';
import 'package:billing_baba/features/sales/data/sales_local_data_source.dart';
import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('applySalesDocument deducts stock on finalize', () async {
    SharedPreferences.setMockInitialValues({
      StorageKeys.lastOpenedBusinessId: 'biz-stock-1',
    });

    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    final salesLocal = SalesLocalDataSource(db);
    final stockLocal = InventoryStockLocalDataSource(db);
    final applier = InventoryDocumentStockApplier(
      stockLocal: stockLocal,
      salesLocal: salesLocal,
      purchaseLocal: PurchaseLocalDataSource(db),
      godowns: GodownLocalSource(db),
    );

    const businessId = 'biz-stock-1';
    const documentId = 'sale-doc-1';
    const lineId = 'line-1';
    final now = DateTime.utc(2026, 1, 15);

    await stockLocal.recordAdjustment(
      movementId: 'opening-1',
      businessId: businessId,
      request: const CreateMovementRequest(
        itemId: 'item-1',
        godownId: 'godown-1',
        movementType: 'opening',
        quantityDelta: '10',
      ),
      now: now,
    );

    await salesLocal.upsertDocument(
      id: documentId,
      businessId: businessId,
      documentType: 'tax_invoice',
      status: 'finalized',
      documentNumber: 'INV-001',
      documentSeries: 'INV',
      partyId: 'party-1',
      isGstFormal: true,
      subtotal: '100',
      discountTotal: '0',
      taxAmount: '0',
      totalAmount: '100',
      documentDate: '2026-01-15',
      godownId: 'godown-1',
      syncVersion: 0,
      createdAt: now,
      updatedAt: now,
    );

    await salesLocal.replaceLines(
      businessId: businessId,
      salesDocumentId: documentId,
      lines: [
        SalesDocumentLineLocalData(
          id: lineId,
          businessId: businessId,
          salesDocumentId: documentId,
          itemId: 'item-1',
          quantity: '3',
          unit: 'pcs',
          unitPrice: '100',
          discountAmount: '0',
          taxType: 'gst',
          taxRate: '0',
          cgstAmount: '0',
          sgstAmount: '0',
          igstAmount: '0',
          lineTotal: '300',
          sortOrder: 0,
          createdAt: now,
          updatedAt: now,
          syncVersion: 0,
          isDeleted: false,
        ),
      ],
    );

    await applier.applySalesDocument(
      businessId: businessId,
      documentId: documentId,
    );

    final qty = await stockLocal.currentQuantity(
      businessId: businessId,
      itemId: 'item-1',
      godownId: 'godown-1',
    );
    expect(qty, 7);

    await applier.applySalesDocument(
      businessId: businessId,
      documentId: documentId,
    );
    final qtyAfterReplay = await stockLocal.currentQuantity(
      businessId: businessId,
      itemId: 'item-1',
      godownId: 'godown-1',
    );
    expect(qtyAfterReplay, 7);
  });

  test('applySalesDocument uses default godown uuid when document has none',
      () async {
    SharedPreferences.setMockInitialValues({
      StorageKeys.lastOpenedBusinessId: 'biz-stock-2',
    });

    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    const businessId = 'biz-stock-2';
    const defaultGodownId = 'e9aaef60-1fc6-411a-99fb-c7d25806089e';
    const documentId = 'sale-doc-2';
    final now = DateTime.utc(2026, 1, 15);

    final godowns = GodownLocalSource(db);
    await godowns.upsertRow(
      id: defaultGodownId,
      businessId: businessId,
      name: 'Main Warehouse',
      isDefault: true,
      syncVersion: 1,
      createdAt: now,
      updatedAt: now,
    );

    final salesLocal = SalesLocalDataSource(db);
    final stockLocal = InventoryStockLocalDataSource(db);
    final applier = InventoryDocumentStockApplier(
      stockLocal: stockLocal,
      salesLocal: salesLocal,
      purchaseLocal: PurchaseLocalDataSource(db),
      godowns: godowns,
    );

    await stockLocal.recordAdjustment(
      movementId: 'opening-2',
      businessId: businessId,
      request: const CreateMovementRequest(
        itemId: 'item-2',
        godownId: defaultGodownId,
        movementType: 'opening',
        quantityDelta: '5',
      ),
      now: now,
    );

    await salesLocal.upsertDocument(
      id: documentId,
      businessId: businessId,
      documentType: 'tax_invoice',
      status: 'finalized',
      documentNumber: 'INV-002',
      documentSeries: 'INV',
      partyId: 'party-1',
      isGstFormal: true,
      subtotal: '100',
      discountTotal: '0',
      taxAmount: '0',
      totalAmount: '100',
      documentDate: '2026-01-15',
      syncVersion: 0,
      createdAt: now,
      updatedAt: now,
    );

    await salesLocal.replaceLines(
      businessId: businessId,
      salesDocumentId: documentId,
      lines: [
        SalesDocumentLineLocalData(
          id: 'line-2',
          businessId: businessId,
          salesDocumentId: documentId,
          itemId: 'item-2',
          quantity: '2',
          unit: 'pcs',
          unitPrice: '100',
          discountAmount: '0',
          taxType: 'gst',
          taxRate: '0',
          cgstAmount: '0',
          sgstAmount: '0',
          igstAmount: '0',
          lineTotal: '200',
          sortOrder: 0,
          createdAt: now,
          updatedAt: now,
          syncVersion: 0,
          isDeleted: false,
        ),
      ],
    );

    await applier.applySalesDocument(
      businessId: businessId,
      documentId: documentId,
    );

    final defaultRows = await (db.select(db.stockLevelsLocal)
          ..where(
            (t) =>
                t.businessId.equals(businessId) &
                t.godownId.equals('default'),
          ))
        .get();
    expect(defaultRows, isEmpty);

    final qty = await stockLocal.currentQuantity(
      businessId: businessId,
      itemId: 'item-2',
      godownId: defaultGodownId,
    );
    expect(qty, 3);
  });
}
