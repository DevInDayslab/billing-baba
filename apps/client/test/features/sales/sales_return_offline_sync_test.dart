import 'package:billing_baba/core/constants/storage_keys.dart';
import 'package:billing_baba/core/database/database.dart';
import 'package:billing_baba/core/services/storage_service.dart';
import 'package:billing_baba/core/sync/models/sync_job.dart';
import 'package:billing_baba/core/sync/queue/sync_queue.dart';
import 'package:billing_baba/features/command_sync/application/command_ack_applier.dart';
import 'package:billing_baba/features/documents/data/local_document_number_service.dart';
import 'package:billing_baba/features/sales/data/sales_invoice_command_repository.dart';
import 'package:billing_baba/features/sales/data/sales_local_data_source.dart';
import 'package:billing_baba/features/sales/data/sales_return_command_repository.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_form_model.dart';
import 'package:billing_baba/features/sales/models/sales_document_draft_input.dart';
import 'package:billing_baba/features/sales/sales_constants.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late AppDatabase db;
  late SyncQueue queue;
  late SalesLocalDataSource local;
  late SalesReturnCommandRepository repo;

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      StorageKeys.lastOpenedBusinessId: 'biz-sales-return-1',
    });
    final prefs = await SharedPreferences.getInstance();
    final storage = StorageService(preferences: prefs);

    db = AppDatabase(NativeDatabase.memory());
    queue = SyncQueue(db);
    local = SalesLocalDataSource(db);
    final numbering = LocalDocumentNumberService(db);

    repo = SalesReturnCommandRepository(
      local: local,
      syncQueue: queue,
      numbering: numbering,
      businessIdReader: () =>
          storage.read(StorageKeys.lastOpenedBusinessId) ?? '',
      deviceIdReader: () => 'device-sales-return-test',
    );
  });

  tearDown(() async {
    await db.close();
  });

  test('saveDraft enqueues sales return row mutations', () async {
    final draft = await repo.saveDraft(
      SalesDocumentDraftInput(
        documentType: SalesDocumentType.salesReturn,
        documentSeries: SalesConstants.creditNoteSeries,
        partyId: 'party-1',
        documentDate: DateTime(2026, 7, 27),
        items: [
          SaleLineItem.empty(id: 'line-1').copyWith(
            itemId: 'item-1',
            itemName: 'Widget',
            qty: 2,
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
  });

  test('finalize enqueues finalize_credit_note command', () async {
    final draft = await repo.saveDraft(
      SalesDocumentDraftInput(
        documentType: SalesDocumentType.salesReturn,
        documentSeries: SalesConstants.creditNoteSeries,
        partyId: 'party-1',
        documentDate: DateTime(2026, 7, 27),
        items: [
          SaleLineItem.empty(id: 'line-1').copyWith(
            itemId: 'item-1',
            itemName: 'Widget',
            qty: 1,
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
        paymentMode: 'cash',
      ),
    );

    final stored = await local.getDocument(draft.id);
    expect(stored?.status, 'finalized');

    final commandJobs = await queue.listPending();
    expect(
      commandJobs.any(
        (job) =>
            job.kind == SyncQueueKind.command &&
            job.payload['command'] == 'finalize_credit_note',
      ),
      isTrue,
    );
  });

  test('finalize_credit_note ack applies document number remap', () async {
    final draft = await repo.saveDraft(
      SalesDocumentDraftInput(
        documentType: SalesDocumentType.salesReturn,
        documentSeries: SalesConstants.creditNoteSeries,
        partyId: 'party-1',
        documentDate: DateTime(2026, 7, 27),
        items: [
          SaleLineItem.empty(id: 'line-1').copyWith(
            itemId: 'item-1',
            itemName: 'Widget',
            qty: 1,
            pricePerUnit: 100,
          ),
        ],
      ),
      itemNameToId: {'Widget': 'item-1'},
    );

    await repo.finalize(
      documentId: draft.id,
      localDocumentNumber: draft.documentNumber,
    );

    final ackApplier = CommandAckApplier(db: db, salesLocal: local);
    await ackApplier.apply(
      command: 'finalize_credit_note',
      result: {
        'document_id': draft.id,
        'status': 'finalized',
        'document_number_remap': {
          'local_document_number': draft.documentNumber,
          'server_document_number': 'CN-2026-000001',
        },
      },
      syncVersion: 3,
      updatedAt: DateTime.utc(2026, 7, 27),
    );

    final updated = await local.getDocument(draft.id);
    expect(updated?.documentNumber, 'CN-2026-000001');
  });
}
