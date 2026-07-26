import 'package:billing_baba/core/database/database.dart';
import 'package:billing_baba/core/sync/models/sync_queue_enums.dart';
import 'package:billing_baba/core/sync/queue/drift_sync_queue_repository.dart';
import 'package:billing_baba/core/sync/queue/sync_queue_service.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late SyncQueueService queue;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    queue = SyncQueueService(DriftSyncQueueRepository(db));
  });

  tearDown(() async {
    await db.close();
  });

  test('enqueue → pendingCount == 1', () async {
    await queue.enqueueRowMutation(
      businessId: 'biz-1',
      entityType: 'parties',
      entityId: 'party-1',
      operation: SyncQueueOperation.create,
      payload: {'name': 'Acme'},
    );

    expect(await queue.pendingCount(), 1);
    expect(await queue.count(), 1);
  });

  test('nextPending respects priority (high before normal)', () async {
    await queue.enqueueRowMutation(
      businessId: 'biz-1',
      entityType: 'parties',
      entityId: 'normal',
      operation: SyncQueueOperation.create,
      payload: {'p': 1},
    );
    await queue.enqueueRowMutation(
      businessId: 'biz-1',
      entityType: 'parties',
      entityId: 'high',
      operation: SyncQueueOperation.update,
      payload: {'p': 0},
      priority: SyncQueuePriority.high,
    );

    final next = await queue.nextPending();
    expect(next, isNotNull);
    expect(next!.entityId, 'high');
    expect(next.priority, SyncQueuePriority.high);
  });

  test('markCompleted / markFailed / retry persistence', () async {
    final job = await queue.enqueueRowMutation(
      businessId: 'biz-1',
      entityType: 'leads',
      entityId: 'lead-1',
      operation: SyncQueueOperation.create,
      payload: {'name': 'Sam'},
    );

    await queue.markFailed(job.id, reason: 'network');
    var listed = await queue.listPending();
    expect(listed, isEmpty);

    await queue.retry(job.id);
    listed = await queue.listPending();
    expect(listed, hasLength(1));
    expect(listed.first.lastError, isNull);
    expect(listed.first.status, SyncQueueStatus.pending);

    await queue.markCompleted(job.id);
    expect(await queue.pendingCount(), 0);

    await queue.clearCompleted();
    expect(await queue.listPending(), isEmpty);
  });

  test('streamPendingCount emits', () async {
    final emissions = <int>[];
    final sub = queue.streamPendingCount().listen(emissions.add);

    await queue.enqueueRowMutation(
      businessId: 'biz-1',
      entityType: 'deals',
      entityId: 'deal-1',
      operation: SyncQueueOperation.create,
      payload: {'amount': 100},
    );

    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(emissions, contains(1));

    await sub.cancel();
  });

  test('enqueueCommand and enqueueMedia set kind/operation', () async {
    final cmd = await queue.enqueueCommand(
      businessId: 'biz-1',
      command: 'remap_document_number',
      commandId: 'cmd-1',
      payload: {'from': 'LOCAL-1'},
    );
    expect(cmd.kind, SyncQueueKind.command);
    expect(cmd.operation, SyncQueueOperation.command);
    expect(cmd.commandId, 'cmd-1');

    final media = await queue.enqueueMedia(
      businessId: 'biz-1',
      entityType: 'attachments',
      entityId: 'att-1',
      payload: {'path': '/tmp/a.jpg'},
    );
    expect(media.kind, SyncQueueKind.media);
    expect(media.operation, SyncQueueOperation.uploadMedia);
  });
}
