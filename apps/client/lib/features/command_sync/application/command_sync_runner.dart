import 'dart:convert';

import 'package:billing_baba/core/constants/storage_keys.dart';
import 'package:billing_baba/core/services/storage_service.dart';
import 'package:billing_baba/core/sync/engine/device_identity.dart';
import 'package:billing_baba/core/sync/engine/sync_pause_gate.dart';
import 'package:billing_baba/core/sync/models/sync_job.dart';
import 'package:billing_baba/core/sync/models/sync_result.dart';
import 'package:billing_baba/core/sync/network/sync_api.dart';
import 'package:billing_baba/core/sync/queue/sync_queue.dart';
import 'package:billing_baba/features/command_sync/application/command_ack_applier.dart';
import 'package:uuid/uuid.dart';

/// Pushes pending command SyncJobs after row sync completes.
class CommandSyncRunner {
  CommandSyncRunner({
    required this._api,
    required this._queue,
    required this._identity,
    required this._ackApplier,
    required this._storage,
    this.onCommandConflict,
    this.maxPushMutations = 100,
    Uuid? uuid,
  })  : _uuid = uuid ?? const Uuid();

  final SyncApi _api;
  final SyncQueue _queue;
  final SyncDeviceIdentity _identity;
  final CommandAckApplier _ackApplier;
  final StorageService _storage;
  final Future<void> Function(SyncJob job, String? code)? onCommandConflict;
  final int maxPushMutations;
  final Uuid _uuid;

  Future<SyncResult> runPending({int? maxPushMutations}) async {
    if (SyncPauseGate.instance.isPaused) {
      return SyncResult.noop(message: 'Command sync paused during business switch');
    }

    final businessId = _storage.read(StorageKeys.lastOpenedBusinessId);
    if (businessId == null || businessId.isEmpty) {
      return SyncResult.noop(message: 'No business selected');
    }

    final syncGeneration = SyncPauseGate.instance.generation;

    await _queue.resetRunningToPending(businessId: businessId);
    await _queue.requeueRetryableFailures(businessId: businessId);

    final pending = await _queue.listPending(businessId: businessId);
    final commandJobs = pending
        .where(
          (job) =>
              job.kind == SyncQueueKind.command &&
              job.businessId == businessId &&
              job.status == SyncQueueStatus.pending,
        )
        .toList();

    if (commandJobs.isEmpty) {
      return SyncResult.noop(message: 'No pending command jobs');
    }

    final batchLimit = maxPushMutations ?? this.maxPushMutations;
    final deviceId = await _identity.deviceId();
    final appVersion = await _identity.appVersion();

    var uploaded = 0;
    var conflicts = 0;
    var failures = 0;

    for (var offset = 0; offset < commandJobs.length; offset += batchLimit) {
      if (SyncPauseGate.instance.isStale(syncGeneration)) {
        return SyncResult.noop(message: 'Command sync aborted during business switch');
      }

      final chunkEnd = (offset + batchLimit).clamp(0, commandJobs.length);
      final chunk = commandJobs.sublist(offset, chunkEnd);

      final mutations = <Map<String, dynamic>>[];
      for (final job in chunk) {
        await _queue.markRunning(job.id);
        final command = job.payload['command']?.toString() ?? '';
        mutations.add({
          'mutation_id': job.mutationId,
          'kind': 'command',
          'command': command,
          'command_id': job.commandId ?? job.mutationId,
          'payload': _commandPayload(job.payload),
          'client_updated_at': job.createdAt.toUtc().toIso8601String(),
        });
      }

      final response = await _api.push(
        deviceId: deviceId,
        appVersion: appVersion,
        body: {
          'device_id': deviceId,
          'client_batch_id': _uuid.v4(),
          'mutations': mutations,
        },
      );

      final byMutation = {for (final job in chunk) job.mutationId: job};

      for (final item in _asList(response['accepted'])) {
        await _handleAccepted(item, byMutation);
        uploaded += 1;
      }
      for (final item in _asList(response['replayed'])) {
        await _handleAccepted(item, byMutation, replayed: true);
        uploaded += 1;
      }
      for (final item in _asList(response['conflicts'])) {
        await _handleConflict(item, byMutation);
        conflicts += 1;
      }
      for (final item in _asList(response['errors'])) {
        await _handleError(item, byMutation);
        failures += 1;
      }
    }

    return SyncResult(
      success: failures == 0,
      completedAt: DateTime.now().toUtc(),
      message:
          'Command sync (push=$uploaded, conflicts=$conflicts, failures=$failures)',
      acceptedCount: uploaded,
      conflictCount: conflicts,
      errorCount: failures,
    );
  }

  Map<String, dynamic> _commandPayload(Map<String, dynamic> payload) {
    final copy = Map<String, dynamic>.from(payload);
    copy.remove('command');
    return copy;
  }

  Future<void> _handleAccepted(
    Map<String, dynamic> item,
    Map<String, SyncJob> byMutation, {
    bool replayed = false,
  }) async {
    final mutationId = item['mutation_id']?.toString();
    final job = mutationId == null ? null : byMutation[mutationId];
    if (job == null) return;

    final command = item['command']?.toString() ??
        job.payload['command']?.toString() ??
        '';
    final result = item['result'];
    final resultMap = result is Map<String, dynamic>
        ? result
        : (result is Map ? Map<String, dynamic>.from(result) : <String, dynamic>{});

    final syncVersion = _readInt(item['sync_version']) ?? 0;
    final updatedAt = DateTime.tryParse(
          item['server_updated_at']?.toString() ?? '',
        )?.toUtc() ??
        DateTime.now().toUtc();

    await _ackApplier.apply(
      command: command,
      result: resultMap,
      syncVersion: syncVersion,
      updatedAt: updatedAt,
    );

    await _queue.markCompleted(job.id);
    if (replayed) {
      // Replay still counts as success.
    }
  }

  Future<void> _handleConflict(
    Map<String, dynamic> item,
    Map<String, SyncJob> byMutation,
  ) async {
    final mutationId = item['mutation_id']?.toString();
    final job = mutationId == null ? null : byMutation[mutationId];
    if (job == null) return;
    await _queue.markConflict(
      job.id,
      reason: item['code']?.toString() ?? 'COMMAND_CONFLICT',
    );
    final code = item['code']?.toString();
    if (onCommandConflict != null) {
      await onCommandConflict!(job, code);
    }
  }

  Future<void> _handleError(
    Map<String, dynamic> item,
    Map<String, SyncJob> byMutation,
  ) async {
    final mutationId = item['mutation_id']?.toString();
    final job = mutationId == null ? null : byMutation[mutationId];
    if (job == null) return;
    final code = item['code']?.toString() ?? 'ERROR';
    if (code == 'IDEMPOTENCY_PAYLOAD_MISMATCH') {
      await _queue.markFailed(
        job.id,
        reason: item['message']?.toString() ?? code,
      );
      return;
    }
    await _queue.markFailed(
      job.id,
      reason: item['message']?.toString() ?? jsonEncode(item),
    );
  }

  List<Map<String, dynamic>> _asList(Object? value) {
    if (value is! List) return const [];
    return value
        .whereType<Map>()
        .map(Map<String, dynamic>.from)
        .toList();
  }

  int? _readInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }
}
