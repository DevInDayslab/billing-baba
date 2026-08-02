import 'package:billing_baba/core/database/database.dart';
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
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'sales invoice command repository enqueues row + finalize command',
    () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);

      final queue = SyncQueue(db);
      final repo = SalesInvoiceCommandRepository(
        local: SalesLocalDataSource(db),
        syncQueue: queue,
        numbering: LocalDocumentNumberService(db),
        businessIdReader: () => 'business-1',
        deviceIdReader: () => 'device-1',
      );

      const lineId = 'line-1';
      final draft = await repo.saveDraft(
        const SalesDocumentDraftInput(
          documentType: SalesDocumentType.taxInvoice,
          documentSeries: SalesConstants.defaultDocumentSeries,
          partyId: 'party-1',
          items: [
            SaleLineItem(
              id: lineId,
              itemId: 'item-1',
              itemName: 'Widget',
              qty: 2,
              unit: 'PCS',
              pricePerUnit: 50,
            ),
          ],
        ),
        itemNameToId: const {'Widget': 'item-1'},
      );

      expect(draft.documentNumber, startsWith('LOCAL-'));
      expect(draft.status, 'draft');

      await repo.finalize(
        documentId: draft.id,
        localDocumentNumber: draft.documentNumber,
      );

      final pending = await queue.listPending();
      expect(
        pending.any((job) => job.kind == SyncQueueKind.row),
        isTrue,
      );
      expect(
        pending.any(
          (job) =>
              job.kind == SyncQueueKind.command &&
              job.payload['command'] == 'finalize_sale',
        ),
        isTrue,
      );

      final ackApplier = CommandAckApplier(db: db);
      await ackApplier.apply(
        command: 'finalize_sale',
        result: {
          'document_id': draft.id,
          'status': 'finalized',
          'document_number_remap': {
            'local_document_number': draft.documentNumber,
            'server_document_number': 'INV-2026-000001',
          },
        },
        syncVersion: 2,
        updatedAt: DateTime.now().toUtc(),
      );

      final updated = await repo.getDocument(draft.id);
      expect(updated?.status, 'finalized');
      expect(updated?.documentNumber, 'INV-2026-000001');
    },
  );
}
