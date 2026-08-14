import 'package:billing_baba/core/database/database.dart';
import 'package:billing_baba/features/parties/application/party_projection_service.dart';
import 'package:billing_baba/features/parties/data/party_ledger_local_data_source.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'buildProjection computes outstanding from opening balance and sales',
    () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);

      const businessId = 'biz-party-1';
      const partyId = 'party-1';

      await db
          .into(db.partiesLocal)
          .insert(
            PartiesLocalCompanion.insert(
              id: partyId,
              businessId: businessId,
              name: 'Acme Retail',
              openingBalance: const Value('100'),
              creditLimit: const Value('0'),
              partyType: const Value('customer'),
              syncVersion: const Value(1),
              createdAt: DateTime.utc(2026),
              updatedAt: DateTime.utc(2026),
            ),
          );

      await db
          .into(db.salesDocumentsLocal)
          .insert(
            SalesDocumentsLocalCompanion.insert(
              id: 'sale-1',
              businessId: businessId,
              documentType: 'tax_invoice',
              status: const Value('finalized'),
              documentNumber: const Value('INV-1'),
              documentSeries: 'INV',
              partyId: const Value(partyId),
              totalAmount: const Value('500'),
              paidAmount: const Value('200'),
              documentDate: '2026-01-15',
              syncVersion: const Value(1),
              createdAt: DateTime.utc(2026, 1, 15),
              updatedAt: DateTime.utc(2026, 1, 15),
            ),
          );

      final service = PartyProjectionService(PartyLedgerLocalDataSource(db));
      final projection = await service.buildProjection(
        businessId: businessId,
        partyId: partyId,
      );

      // opening 100 + sale debit 500 - payment credit 200 = 400
      expect(projection.outstanding, 400);
      expect(projection.receivable, 400);
      expect(projection.summary.totalSales, 500);
      expect(projection.summary.totalPayments, 200);
      expect(projection.transactions, hasLength(1));
      expect(projection.transactions.first.referenceNumber, 'INV-1');
      expect(projection.transactions.first.balance, 300);
    },
  );

  test(
    'buildProjection includes purchase bills for supplier parties',
    () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);

      const businessId = 'biz-party-2';
      const partyId = 'supplier-1';

      await db
          .into(db.partiesLocal)
          .insert(
            PartiesLocalCompanion.insert(
              id: partyId,
              businessId: businessId,
              name: 'Supplier Co',
              openingBalance: const Value('0'),
              partyType: const Value('supplier'),
              syncVersion: const Value(1),
              createdAt: DateTime.utc(2026),
              updatedAt: DateTime.utc(2026),
            ),
          );

      await db
          .into(db.purchaseDocumentsLocal)
          .insert(
            PurchaseDocumentsLocalCompanion.insert(
              id: 'pb-1',
              businessId: businessId,
              documentType: 'purchase_bill',
              status: const Value('finalized'),
              documentNumber: const Value('PB-1'),
              documentSeries: 'PB',
              partyId: partyId,
              totalAmount: const Value('1000'),
              paidAmount: const Value('400'),
              documentDate: '2026-02-01',
              syncVersion: const Value(1),
              createdAt: DateTime.utc(2026, 2),
              updatedAt: DateTime.utc(2026, 2),
            ),
          );

      final service = PartyProjectionService(PartyLedgerLocalDataSource(db));
      final projection = await service.buildProjection(
        businessId: businessId,
        partyId: partyId,
      );

      // payable: purchase credit 1000 - payment debit 400 = -600 outstanding
      expect(projection.outstanding, -600);
      expect(projection.payable, 600);
      expect(projection.summary.totalPurchases, 1000);
      expect(projection.transactions.first.source, 'purchase_documents');
    },
  );

  test(
    'buildProjection includes payable opening balance',
    () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);

      const businessId = 'biz-party-3';
      const partyId = 'supplier-2';

      await db
          .into(db.partiesLocal)
          .insert(
            PartiesLocalCompanion.insert(
              id: partyId,
              businessId: businessId,
              name: 'Payable Supplier',
              openingBalance: const Value('-300'),
              partyType: const Value('supplier'),
              syncVersion: const Value(1),
              createdAt: DateTime.utc(2026),
              updatedAt: DateTime.utc(2026),
            ),
          );

      final service = PartyProjectionService(PartyLedgerLocalDataSource(db));
      final projection = await service.buildProjection(
        businessId: businessId,
        partyId: partyId,
      );

      expect(projection.outstanding, -300);
      expect(projection.payable, 300);
      expect(projection.receivable, 0);
    },
  );
}
