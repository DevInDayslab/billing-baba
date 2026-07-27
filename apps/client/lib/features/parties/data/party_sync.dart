import 'package:billing_baba/core/database/database.dart';
import 'package:drift/drift.dart';

/// Applies pull/ack updates for `entity_type: parties` into Drift.
class PartySync {
  PartySync(this._db);

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
    final existing = await (_db.select(_db.partiesLocal)
          ..where((t) => t.id.equals(entityId)))
        .getSingleOrNull();

    if (isDeleted) {
      await _db.into(_db.partiesLocal).insertOnConflictUpdate(
            PartiesLocalCompanion.insert(
              id: entityId,
              businessId: businessId,
              name: existing?.name ?? _str(payload, 'name') ?? '',
              legalName: Value(existing?.legalName),
              alias: Value(existing?.alias),
              mobile: Value(existing?.mobile),
              email: Value(existing?.email),
              partyGroup: Value(existing?.partyGroup),
              areaCode: Value(existing?.areaCode),
              partyType: Value(existing?.partyType ?? 'customer'),
              partyCategory: Value(existing?.partyCategory),
              pricingTier: Value(existing?.pricingTier ?? 'tier_1'),
              gstin: Value(existing?.gstin),
              stateCode: Value(existing?.stateCode),
              areaId: Value(existing?.areaId),
              creditLimit: Value(existing?.creditLimit ?? '0'),
              openingBalance: Value(existing?.openingBalance ?? '0'),
              hiddenLedgerBalance: Value(existing?.hiddenLedgerBalance ?? '0'),
              profileImageUrl: Value(existing?.profileImageUrl),
              profileMediaAssetId: Value(existing?.profileMediaAssetId),
              connectedSince: Value(existing?.connectedSince),
              notes: Value(existing?.notes),
              isActive: Value(existing?.isActive ?? true),
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

    final name = _str(payload, 'name');
    await _db.into(_db.partiesLocal).insertOnConflictUpdate(
          PartiesLocalCompanion.insert(
            id: entityId,
            businessId: businessId,
            name: (name != null && name.isNotEmpty)
                ? name
                : (existing?.name ?? ''),
            legalName: Value(_str(payload, 'legal_name') ?? existing?.legalName),
            alias: Value(_str(payload, 'alias') ?? existing?.alias),
            mobile: Value(_str(payload, 'mobile') ?? existing?.mobile),
            email: Value(_str(payload, 'email') ?? existing?.email),
            partyGroup:
                Value(_str(payload, 'party_group') ?? existing?.partyGroup),
            areaCode: Value(_str(payload, 'area_code') ?? existing?.areaCode),
            partyType: Value(
              _str(payload, 'party_type') ?? existing?.partyType ?? 'customer',
            ),
            partyCategory: Value(
              _str(payload, 'party_category') ?? existing?.partyCategory,
            ),
            pricingTier: Value(
              _str(payload, 'pricing_tier') ?? existing?.pricingTier ?? 'tier_1',
            ),
            gstin: Value(_str(payload, 'gstin') ?? existing?.gstin),
            stateCode: Value(_str(payload, 'state_code') ?? existing?.stateCode),
            areaId: Value(_str(payload, 'area_id') ?? existing?.areaId),
            creditLimit: Value(
              _str(payload, 'credit_limit') ?? existing?.creditLimit ?? '0',
            ),
            openingBalance: Value(
              _str(payload, 'opening_balance') ??
                  existing?.openingBalance ??
                  '0',
            ),
            hiddenLedgerBalance: Value(
              _str(payload, 'hidden_ledger_balance') ??
                  existing?.hiddenLedgerBalance ??
                  '0',
            ),
            profileImageUrl: Value(
              _str(payload, 'profile_image_url') ?? existing?.profileImageUrl,
            ),
            profileMediaAssetId: Value(
              _str(payload, 'profile_media_asset_id') ??
                  existing?.profileMediaAssetId,
            ),
            connectedSince: Value(
              _str(payload, 'connected_since') ?? existing?.connectedSince,
            ),
            notes: Value(_str(payload, 'notes') ?? existing?.notes),
            isActive: Value(
              _bool(payload, 'is_active') ?? existing?.isActive ?? true,
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

  Future<void> updateAckMeta({
    required String entityId,
    required int syncVersion,
    required DateTime updatedAt,
    String? deviceId,
  }) {
    return (_db.update(_db.partiesLocal)..where((t) => t.id.equals(entityId)))
        .write(
      PartiesLocalCompanion(
        syncVersion: Value(syncVersion),
        updatedAt: Value(updatedAt.toUtc()),
        deviceId: deviceId == null ? const Value.absent() : Value(deviceId),
      ),
    );
  }

  static String? _str(Map<String, dynamic>? payload, String key) {
    final value = payload?[key];
    if (value == null) return null;
    final text = value.toString();
    return text;
  }

  static bool? _bool(Map<String, dynamic>? payload, String key) {
    final value = payload?[key];
    if (value is bool) return value;
    if (value is String) {
      if (value == 'true') return true;
      if (value == 'false') return false;
    }
    return null;
  }
}
