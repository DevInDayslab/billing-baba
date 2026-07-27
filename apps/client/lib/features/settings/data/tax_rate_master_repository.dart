import 'package:billing_baba/core/sync/models/sync_job.dart';
import 'package:billing_baba/core/sync/queue/sync_queue.dart';
import 'package:billing_baba/features/settings/data/tax_rate_local_source.dart';
import 'package:billing_baba/features/settings/models/tax_rate_models.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();
const _taxRatesEntity = 'tax_rates';

/// Local-first tax rate writes + SyncQueue enqueue.
class TaxRateMasterRepository {
  TaxRateMasterRepository({
    required this._local,
    required this._syncQueue,
    required this._businessIdReader,
    this._deviceIdReader,
  });

  final TaxRateLocalSource _local;
  final SyncQueue _syncQueue;
  final String Function() _businessIdReader;
  final String? Function()? _deviceIdReader;

  TaxRateLocalSource get local => _local;

  String _requireBusinessId() {
    final id = _businessIdReader().trim();
    if (id.isEmpty) {
      throw StateError('No business selected for tax rate operations');
    }
    return id;
  }

  Future<List<TaxRateDto>> listActive() async {
    return _local.listActive(_requireBusinessId());
  }

  Future<TaxRateDto> create(CreateTaxRateRequest request) async {
    final businessId = _requireBusinessId();
    final now = DateTime.now().toUtc();
    final id = _uuid.v4();
    final name = request.name.trim();
    final rate = request.rate.trim();
    await _local.upsertRow(
      id: id,
      businessId: businessId,
      name: name,
      rate: rate,
      isDefault: request.isDefault,
      syncVersion: 0,
      createdAt: now,
      updatedAt: now,
      deviceId: _deviceIdReader?.call(),
    );
    await _syncQueue.enqueueRowMutation(
      businessId: businessId,
      deviceId: _deviceIdReader?.call(),
      entityType: _taxRatesEntity,
      entityId: id,
      operation: SyncQueueOperation.create,
      payload: {
        'name': name,
        'rate': rate,
        'is_default': request.isDefault,
      },
      clientUpdatedAt: now,
    );
    return (await _local.getActiveDto(id))!;
  }

  Future<TaxRateDto> update(String id, UpdateTaxRateRequest request) async {
    final businessId = _requireBusinessId();
    final existing = await _local.getById(id);
    if (existing == null || existing.isDeleted) {
      throw StateError('Tax rate not found locally');
    }
    final now = DateTime.now().toUtc();
    final name = (request.name ?? existing.name).trim();
    final rate = (request.rate ?? existing.rate).trim();
    final isDefault = request.isDefault ?? existing.isDefault;
    await _local.upsertRow(
      id: id,
      businessId: businessId,
      name: name,
      rate: rate,
      isDefault: isDefault,
      syncVersion: existing.syncVersion,
      createdAt: existing.createdAt,
      updatedAt: now,
      deviceId: _deviceIdReader?.call() ?? existing.deviceId,
    );
    await _syncQueue.enqueueRowMutation(
      businessId: businessId,
      deviceId: _deviceIdReader?.call(),
      entityType: _taxRatesEntity,
      entityId: id,
      operation: SyncQueueOperation.update,
      payload: {
        'name': name,
        'rate': rate,
        'is_default': isDefault,
      },
      baseSyncVersion: existing.syncVersion,
      clientUpdatedAt: now,
    );
    return (await _local.getActiveDto(id))!;
  }

  Future<void> softDelete(String id) async {
    final businessId = _requireBusinessId();
    final existing = await _local.getById(id);
    if (existing == null || existing.isDeleted) return;
    final now = DateTime.now().toUtc();
    await _local.softDelete(id: id, deletedAt: now);
    await _syncQueue.enqueueRowMutation(
      businessId: businessId,
      deviceId: _deviceIdReader?.call(),
      entityType: _taxRatesEntity,
      entityId: id,
      operation: SyncQueueOperation.delete,
      payload: const {},
      baseSyncVersion: existing.syncVersion,
      clientUpdatedAt: now,
    );
  }
}
