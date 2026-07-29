import 'package:billing_baba/core/constants/storage_keys.dart';
import 'package:billing_baba/core/database/database.dart';
import 'package:billing_baba/core/services/storage_service.dart';
import 'package:billing_baba/core/sync/models/sync_job.dart';
import 'package:billing_baba/core/sync/queue/sync_queue.dart';
import 'package:billing_baba/features/documents/data/local_document_number_service.dart';
import 'package:billing_baba/features/pos/application/pos_cart_state.dart';
import 'package:billing_baba/features/pos/application/pos_sale_mapper.dart';
import 'package:billing_baba/features/pos/models/cart_item.dart';
import 'package:billing_baba/features/pos/models/payment_entry.dart';
import 'package:billing_baba/features/pos/models/pos_item.dart';
import 'package:billing_baba/features/sales/data/sales_invoice_command_repository.dart';
import 'package:billing_baba/features/sales/data/sales_local_data_source.dart';
import 'package:billing_baba/features/sales/sales_constants.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late AppDatabase db;
  late SyncQueue queue;
  late SalesLocalDataSource local;
  late SalesInvoiceCommandRepository repo;

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      StorageKeys.lastOpenedBusinessId: 'biz-pos-1',
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
      deviceIdReader: () => 'device-pos-test',
    );
  });

  tearDown(() async {
    await db.close();
  });

  test('POS draft save uses pos document type and omits local session id',
      () async {
    const cart = PosCartState(
      items: [
        CartItem(
          item: PosItem(
            id: 'item-1',
            name: 'Tea',
            sku: 'TEA-1',
            price: 50,
            stock: 10,
          ),
          quantity: 2,
        ),
      ],
      payments: [
        PaymentEntry(mode: PaymentMode.cash, amount: 118),
      ],
    );

    final draftInput = mapPosCartToDraftInput(
      cart: cart,
      posSessionId: 'local-pos-test-session',
    );

    final draft = await repo.saveDraft(
      draftInput,
      itemNameToId: {'Tea': 'item-1'},
    );

    expect(draft.documentType, SalesDocumentType.pos.apiValue);

    final pending = await queue.listPending();
    final headerJob = pending.firstWhere(
      (job) => job.entityType == 'sales_documents',
    );
    expect(headerJob.payload['document_type'], 'pos');
    expect(headerJob.payload.containsKey('pos_session_id'), isFalse);
  });

  test('POS finalize enqueues finalize_sale command with payment', () async {
    const cart = PosCartState(
      items: [
        CartItem(
          item: PosItem(
            id: 'item-1',
            name: 'Tea',
            sku: 'TEA-1',
            price: 100,
            stock: 5,
          ),
          quantity: 1,
        ),
      ],
      payments: [
        PaymentEntry(mode: PaymentMode.cash, amount: 118),
      ],
    );

    final draft = await repo.saveDraft(
      mapPosCartToDraftInput(
        cart: cart,
        posSessionId: 'server-session-id',
      ),
      itemNameToId: {'Tea': 'item-1'},
    );

    final payment = mapPosPaymentsToFinalizeCommand(
      payments: cart.payments,
      totalPayable: cart.totalPayable,
    );

    await repo.finalize(
      documentId: draft.id,
      localDocumentNumber: draft.documentNumber,
      payment: payment,
    );

    final stored = await local.getDocument(draft.id);
    expect(stored?.status, 'finalized');
    expect(stored?.documentType, SalesDocumentType.pos.apiValue);

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
}
