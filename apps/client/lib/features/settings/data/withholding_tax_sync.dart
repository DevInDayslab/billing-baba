import 'package:billing_baba/core/database/database.dart';
import 'package:billing_baba/core/sync/engine/sync_apply_guard.dart';
import 'package:drift/drift.dart';

class WithholdingTaxSectionSync {
  WithholdingTaxSectionSync(this._db);

  final AppDatabase _db;

  Future<void> applyChange({
    required String businessId,
    required String entityId,
    required int syncVersion,
    required DateTime updatedAt,
    required bool isDeleted,
    DateTime? deletedAt,
    String? deviceId,
    Map<String, dynamic>? payload,
  }) async {
    final existing = await (_db.select(_db.withholdingTaxSectionsLocal)
          ..where((t) => t.id.equals(entityId)))
        .getSingleOrNull();

    if (!shouldApplyPullChange(
      incomingSyncVersion: syncVersion,
      existingSyncVersion: existing?.syncVersion,
      isDeleted: isDeleted,
    )) {
      return;
    }

    if (isDeleted) {
      await _db.into(_db.withholdingTaxSectionsLocal).insertOnConflictUpdate(
            WithholdingTaxSectionsLocalCompanion.insert(
              id: entityId,
              businessId: businessId,
              kind: existing?.kind ?? _str(payload, 'kind') ?? 'tds',
              code: existing?.code ?? _str(payload, 'code') ?? '',
              description:
                  existing?.description ?? _str(payload, 'description') ?? '',
              rate: existing?.rate ?? _str(payload, 'rate') ?? '0',
              applicableOn: existing?.applicableOn ??
                  _str(payload, 'applicable_on') ??
                  'sale',
              syncVersion: Value(syncVersion),
              createdAt: (existing?.createdAt ?? updatedAt).toUtc(),
              updatedAt: updatedAt.toUtc(),
              deletedAt: Value((deletedAt ?? updatedAt).toUtc()),
              isDeleted: const Value(true),
              deviceId: Value(deviceId),
            ),
          );
      return;
    }

    await _db.into(_db.withholdingTaxSectionsLocal).insertOnConflictUpdate(
          WithholdingTaxSectionsLocalCompanion.insert(
            id: entityId,
            businessId: businessId,
            kind: _str(payload, 'kind') ?? existing?.kind ?? 'tds',
            code: _str(payload, 'code') ?? existing?.code ?? '',
            description:
                _str(payload, 'description') ?? existing?.description ?? '',
            rate: _str(payload, 'rate') ?? existing?.rate ?? '0',
            applicableOn: _str(payload, 'applicable_on') ??
                existing?.applicableOn ??
                'sale',
            isActive: Value(
              _bool(payload, 'is_active') ?? existing?.isActive ?? true,
            ),
            isPreloaded: Value(
              _bool(payload, 'is_preloaded') ?? existing?.isPreloaded ?? false,
            ),
            syncVersion: Value(syncVersion),
            createdAt: (existing?.createdAt ?? updatedAt).toUtc(),
            updatedAt: updatedAt.toUtc(),
            isDeleted: const Value(false),
            deletedAt: const Value(null),
            deviceId: Value(deviceId),
          ),
        );
  }
}

class WithholdingTaxEntrySync {
  WithholdingTaxEntrySync(this._db);

  final AppDatabase _db;

  Future<void> applyChange({
    required String businessId,
    required String entityId,
    required int syncVersion,
    required DateTime updatedAt,
    required bool isDeleted,
    DateTime? deletedAt,
    String? deviceId,
    Map<String, dynamic>? payload,
  }) async {
    final existing = await (_db.select(_db.withholdingTaxEntriesLocal)
          ..where((t) => t.id.equals(entityId)))
        .getSingleOrNull();

    if (!shouldApplyPullChange(
      incomingSyncVersion: syncVersion,
      existingSyncVersion: existing?.syncVersion,
      isDeleted: isDeleted,
    )) {
      return;
    }

    final companion = WithholdingTaxEntriesLocalCompanion.insert(
      id: entityId,
      businessId: businessId,
      kind: _str(payload, 'kind') ?? existing?.kind ?? 'tds',
      direction: _str(payload, 'direction') ?? existing?.direction ?? 'payable',
      sectionId: Value(_str(payload, 'section_id') ?? existing?.sectionId),
      sectionCode: _str(payload, 'section_code') ?? existing?.sectionCode ?? '',
      rate: _str(payload, 'rate') ?? existing?.rate ?? '0',
      baseAmount: _str(payload, 'base_amount') ?? existing?.baseAmount ?? '0',
      taxAmount: _str(payload, 'tax_amount') ?? existing?.taxAmount ?? '0',
      partyId: Value(_str(payload, 'party_id') ?? existing?.partyId),
      partyPan: Value(_str(payload, 'party_pan') ?? existing?.partyPan),
      partyName: Value(_str(payload, 'party_name') ?? existing?.partyName),
      sourceType: _str(payload, 'source_type') ?? existing?.sourceType ?? '',
      sourceId: _str(payload, 'source_id') ?? existing?.sourceId ?? entityId,
      entryDate: _str(payload, 'entry_date') ?? existing?.entryDate ?? '',
      depositId: Value(_str(payload, 'deposit_id') ?? existing?.depositId),
      syncVersion: Value(syncVersion),
      createdAt: (existing?.createdAt ?? updatedAt).toUtc(),
      updatedAt: updatedAt.toUtc(),
      isDeleted: Value(isDeleted),
      deletedAt: Value(isDeleted ? (deletedAt ?? updatedAt).toUtc() : null),
      deviceId: Value(deviceId),
    );

    await _db
        .into(_db.withholdingTaxEntriesLocal)
        .insertOnConflictUpdate(companion);
  }
}

class TaxDepositSync {
  TaxDepositSync(this._db);

  final AppDatabase _db;

  Future<void> applyChange({
    required String businessId,
    required String entityId,
    required int syncVersion,
    required DateTime updatedAt,
    required bool isDeleted,
    DateTime? deletedAt,
    String? deviceId,
    Map<String, dynamic>? payload,
  }) async {
    final existing = await (_db.select(_db.taxDepositsLocal)
          ..where((t) => t.id.equals(entityId)))
        .getSingleOrNull();

    if (!shouldApplyPullChange(
      incomingSyncVersion: syncVersion,
      existingSyncVersion: existing?.syncVersion,
      isDeleted: isDeleted,
    )) {
      return;
    }

    await _db.into(_db.taxDepositsLocal).insertOnConflictUpdate(
          TaxDepositsLocalCompanion.insert(
            id: entityId,
            businessId: businessId,
            kind: _str(payload, 'kind') ?? existing?.kind ?? 'tds',
            bsrCode: _str(payload, 'bsr_code') ?? existing?.bsrCode ?? '',
            challanSerial:
                _str(payload, 'challan_serial') ?? existing?.challanSerial ?? '',
            depositDate:
                _str(payload, 'deposit_date') ?? existing?.depositDate ?? '',
            amount: _str(payload, 'amount') ?? existing?.amount ?? '0',
            notes: Value(_str(payload, 'notes') ?? existing?.notes),
            syncVersion: Value(syncVersion),
            createdAt: (existing?.createdAt ?? updatedAt).toUtc(),
            updatedAt: updatedAt.toUtc(),
            isDeleted: Value(isDeleted),
            deletedAt: Value(isDeleted ? (deletedAt ?? updatedAt).toUtc() : null),
            deviceId: Value(deviceId),
          ),
        );
  }
}

String? _str(Map<String, dynamic>? payload, String key) {
  final value = payload?[key];
  if (value == null) return null;
  final s = value.toString();
  return s.isEmpty ? null : s;
}

bool? _bool(Map<String, dynamic>? payload, String key) {
  final value = payload?[key];
  if (value == null) return null;
  if (value is bool) return value;
  if (value == true || value == 'true' || value == 1) return true;
  if (value == false || value == 'false' || value == 0) return false;
  return null;
}
