import 'package:billing_baba/core/constants/storage_keys.dart';
import 'package:billing_baba/core/database/database.dart';
import 'package:billing_baba/core/services/storage_service.dart';
import 'package:billing_baba/core/sync/models/sync_job.dart';
import 'package:billing_baba/core/sync/queue/sync_queue.dart';
import 'package:billing_baba/features/command_sync/application/command_ack_applier.dart';
import 'package:billing_baba/features/documents/data/local_document_number_service.dart';
import 'package:billing_baba/features/sales/data/sales_invoice_command_repository.dart';
import 'package:billing_baba/features/sales/data/sales_local_data_source.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_form_model.dart';
import 'package:billing_baba/features/sales/models/sales_document_draft_input.dart';
import 'package:billing_baba/features/sales/sales_constants.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late AppDatabase db;
  late SyncQueue queue;
  late SalesLocalDataSource local;
  late SalesInvoiceCommandRepository repo;

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      StorageKeys.lastOpenedBusinessId: 'biz-sales-1',
    });
    final prefs = await SharedPreferences.getInstance();
    final storage = StorageService(preferences: prefs);

    db = AppDatabase(NativeDatabase.memory());
    queue = SyncQueue(db);
    local = SalesLocalDataSource(db);
    final numbering = LocalDocumentNumberService(db);

    repo = SalesInvoiceCommandRepository(
      local: local,
      syncQueue: queue,
      numbering: numbering,
      businessIdReader: () =>
          storage.read(StorageKeys.lastOpenedBusinessId) ?? '',
      deviceIdReader: () => 'device-sales-test',
    );
  });

  tearDown(() async {
    await db.close();
  });

  test('saveDraft enqueues document and line row mutations', () async {
    final draft = await repo.saveDraft(
      SalesDocumentDraftInput(
        documentType: SalesDocumentType.taxInvoice,
        documentSeries: SalesConstants.defaultDocumentSeries,
        partyId: 'party-1',
        documentDate: DateTime(2026, 7, 27),
        documentTime: const TimeOfDay(hour: 10, minute: 30),
        items: [
          const SaleLineItem(
            id: 'line-1',
            itemId: 'item-1',
            itemName: 'Widget',
            qty: 2,
            unit: 'Pcs',
            pricePerUnit: 50,
          ),
        ],
      ),
      itemNameToId: {'Widget': 'item-1'},
    );

    expect(draft.documentNumber?.startsWith('LOCAL-'), isTrue);

    final pending = await queue.listPending();
    expect(pending.length, 2);
    expect(
      pending.where((job) => job.entityType == 'sales_documents'),
      hasLength(1),
    );
    expect(
      pending.where((job) => job.entityType == 'sales_document_lines'),
      hasLength(1),
    );
  });

  test('finalize stores payment locally and enqueues finalize_sale command',
      () async {
    final draft = await repo.saveDraft(
      SalesDocumentDraftInput(
        documentType: SalesDocumentType.taxInvoice,
        documentSeries: SalesConstants.defaultDocumentSeries,
        partyId: 'party-1',
        documentDate: DateTime(2026, 7, 27),
        items: [
          const SaleLineItem(
            id: 'line-1',
            itemId: 'item-1',
            itemName: 'Widget',
            qty: 1,
            unit: 'Pcs',
            pricePerUnit: 100,
          ),
        ],
      ),
      itemNameToId: {'Widget': 'item-1'},
    );

    await repo.finalize(
      documentId: draft.id,
      localDocumentNumber: draft.documentNumber,
      payment: const FinalizeSalePaymentCommand(
        amount: '100.0000',
        paymentMode: 'cash',
      ),
    );

    final stored = await local.getDocument(draft.id);
    expect(stored?.status, 'finalized');
    expect(stored?.paidAmount, '100.0000');
    expect(stored?.paymentMode, 'cash');

    final commandJobs = await queue.listPending();
    expect(
      commandJobs.any(
        (job) =>
            job.kind == SyncQueueKind.command &&
            job.payload['command'] == 'finalize_sale',
      ),
      isTrue,
    );
  });

  test('command ack applies document number remap and paid_amount', () async {
    final draft = await repo.saveDraft(
      SalesDocumentDraftInput(
        documentType: SalesDocumentType.taxInvoice,
        documentSeries: SalesConstants.defaultDocumentSeries,
        partyId: 'party-1',
        documentDate: DateTime(2026, 7, 27),
        items: [
          const SaleLineItem(
            id: 'line-1',
            itemId: 'item-1',
            itemName: 'Widget',
            qty: 1,
            unit: 'Pcs',
            pricePerUnit: 100,
          ),
        ],
      ),
      itemNameToId: {'Widget': 'item-1'},
    );

    await repo.finalize(
      documentId: draft.id,
      localDocumentNumber: draft.documentNumber,
      payment: const FinalizeSalePaymentCommand(
        amount: '50.0000',
        paymentMode: 'upi',
      ),
    );

    final ackApplier = CommandAckApplier(db: db, salesLocal: local);
    await ackApplier.apply(
      command: 'finalize_sale',
      result: {
        'document_id': draft.id,
        'status': 'finalized',
        'paid_amount': '50.0000',
        'payment_mode': 'upi',
        'document_number_remap': {
          'local_document_number': draft.documentNumber,
          'server_document_number': 'INV-2026-000099',
        },
      },
      syncVersion: 4,
      updatedAt: DateTime.utc(2026, 7, 27),
    );

    final updated = await local.getDocument(draft.id);
    expect(updated?.documentNumber, 'INV-2026-000099');
    expect(updated?.paidAmount, '50.0000');
    expect(updated?.paymentMode, 'upi');
    expect(await local.getHeaderSyncVersion(draft.id), 4);
  });

  test('local getDocument returns saved draft', () async {
    final draft = await repo.saveDraft(
      SalesDocumentDraftInput(
        documentType: SalesDocumentType.taxInvoice,
        documentSeries: SalesConstants.defaultDocumentSeries,
        partyId: 'party-1',
        documentDate: DateTime(2026, 7, 27),
        items: [
          const SaleLineItem(
            id: 'line-1',
            itemId: 'item-1',
            itemName: 'Widget',
            qty: 3,
            unit: 'Pcs',
            pricePerUnit: 10,
          ),
        ],
      ),
      itemNameToId: {'Widget': 'item-1'},
    );

    final loaded = await repo.getDocument(draft.id);
    expect(loaded?.id, draft.id);
    expect(loaded?.lines.first.quantity, '3.00');
    expect(loaded?.documentNumber?.startsWith('LOCAL-'), isTrue);
  });

  test('removed lines enqueue delete mutations on edit', () async {
    final draft = await repo.saveDraft(
      SalesDocumentDraftInput(
        documentType: SalesDocumentType.taxInvoice,
        documentSeries: SalesConstants.defaultDocumentSeries,
        partyId: 'party-1',
        documentDate: DateTime(2026, 7, 27),
        items: [
          const SaleLineItem(
            id: 'line-a',
            itemId: 'item-1',
            itemName: 'Widget',
            qty: 1,
            unit: 'Pcs',
            pricePerUnit: 10,
          ),
          const SaleLineItem(
            id: 'line-b',
            itemId: 'item-2',
            itemName: 'Bolt',
            qty: 1,
            unit: 'Pcs',
            pricePerUnit: 5,
          ),
        ],
      ),
      itemNameToId: {'Widget': 'item-1', 'Bolt': 'item-2'},
    );

    expect(draft.lines, hasLength(2));
    final keptLineId = draft.lines.firstWhere((l) => l.itemId == 'item-1').id;
    final removedLineId = draft.lines.firstWhere((l) => l.itemId == 'item-2').id;

    await repo.saveDraft(
      SalesDocumentDraftInput(
        documentId: draft.id,
        documentType: SalesDocumentType.taxInvoice,
        documentSeries: SalesConstants.defaultDocumentSeries,
        partyId: 'party-1',
        documentDate: DateTime(2026, 7, 27),
        items: [
          SaleLineItem(
            id: keptLineId,
            serverLineId: keptLineId,
            itemId: 'item-1',
            itemName: 'Widget',
            qty: 1,
            unit: 'Pcs',
            pricePerUnit: 10,
          ),
        ],
      ),
      itemNameToId: {'Widget': 'item-1', 'Bolt': 'item-2'},
    );

    final pending = await queue.listPending();
    expect(
      pending.any(
        (job) =>
            job.entityType == 'sales_document_lines' &&
            job.entityId == removedLineId &&
            job.operation == SyncQueueOperation.delete,
      ),
      isTrue,
    );
  });
}
