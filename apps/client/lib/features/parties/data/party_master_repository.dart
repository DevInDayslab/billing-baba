import 'package:billing_baba/core/database/database.dart';
import 'package:billing_baba/core/sync/models/sync_job.dart';
import 'package:billing_baba/core/sync/queue/sync_queue.dart';
import 'package:billing_baba/features/parties/data/party_local_source.dart';
import 'package:billing_baba/features/parties/data/party_repository.dart';
import 'package:billing_baba/features/parties/models/create_party_request.dart';
import 'package:billing_baba/features/parties/models/party_dto.dart';
import 'package:billing_baba/features/parties/models/party_list_query.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();
const _partiesEntity = 'parties';

/// Local-first party master writes + SyncQueue enqueue (Categories pattern).
class PartyMasterRepository {
  PartyMasterRepository({
    required this._local,
    required this._syncQueue,
    required this._remote,
    required this._businessIdReader,
    this._deviceIdReader,
  });

  final PartyLocalSource _local;
  final SyncQueue _syncQueue;
  final PartyRepository _remote;
  final String Function() _businessIdReader;
  final String? Function()? _deviceIdReader;

  PartyLocalSource get local => _local;

  String _requireBusinessId() {
    final id = _businessIdReader().trim();
    if (id.isEmpty) {
      throw StateError('No business selected for party operations');
    }
    return id;
  }

  Future<List<PartyDto>> listActive({String? searchQuery}) async {
    final businessId = _requireBusinessId();
    await _hydrateIfEmpty(businessId);
    return _local.listActive(businessId, searchQuery: searchQuery);
  }

  Future<PartyDto?> getActive(String id) async {
    final local = await _local.getActiveDto(id);
    if (local != null) return local;
    try {
      final remote = await _remote.getParty(id);
      final businessId = _requireBusinessId();
      await _local.upsertFromDto(businessId, remote);
      return remote;
    } on Object {
      return null;
    }
  }

  Future<PartyDto> create(CreatePartyRequest request) async {
    final businessId = _requireBusinessId();
    final now = DateTime.now().toUtc();
    final id = _uuid.v4();
    final row = _rowFromCreate(request);
    await _local.upsertRow(
      id: id,
      businessId: businessId,
      syncVersion: 0,
      createdAt: now,
      updatedAt: now,
      deviceId: _deviceIdReader?.call(),
      name: row.name,
      legalName: row.legalName,
      alias: row.alias,
      mobile: row.mobile,
      email: row.email,
      partyGroup: row.partyGroup,
      areaCode: row.areaCode,
      partyType: row.partyType,
      partyCategory: row.partyCategory,
      pricingTier: row.pricingTier,
      gstin: row.gstin,
      stateCode: row.stateCode,
      areaId: row.areaId,
      creditLimit: row.creditLimit,
      openingBalance: row.openingBalance,
      notes: row.notes,
      isActive: row.isActive,
    );
    await _syncQueue.enqueueRowMutation(
      businessId: businessId,
      deviceId: _deviceIdReader?.call(),
      entityType: _partiesEntity,
      entityId: id,
      operation: SyncQueueOperation.create,
      payload: _domainPayload(row),
      clientUpdatedAt: now,
    );
    return _local.getActiveDto(id).then((dto) => dto!);
  }

  Future<PartyDto> update(String id, UpdatePartyRequest request) async {
    final businessId = _requireBusinessId();
    final existing = await _local.getById(id);
    if (existing == null || existing.isDeleted) {
      throw StateError('Party not found locally');
    }
    final now = DateTime.now().toUtc();
    final baseVersion = existing.syncVersion;
    final merged = _mergeUpdate(existing, request);
    await _local.upsertRow(
      id: id,
      businessId: businessId,
      syncVersion: baseVersion,
      createdAt: existing.createdAt,
      updatedAt: now,
      deviceId: _deviceIdReader?.call() ?? existing.deviceId,
      name: merged.name,
      legalName: merged.legalName,
      alias: merged.alias,
      mobile: merged.mobile,
      email: merged.email,
      partyGroup: merged.partyGroup,
      areaCode: merged.areaCode,
      partyType: merged.partyType,
      partyCategory: merged.partyCategory,
      pricingTier: merged.pricingTier,
      gstin: merged.gstin,
      stateCode: merged.stateCode,
      areaId: merged.areaId,
      creditLimit: merged.creditLimit,
      openingBalance: merged.openingBalance,
      hiddenLedgerBalance: merged.hiddenLedgerBalance,
      profileImageUrl: merged.profileImageUrl,
      profileMediaAssetId: merged.profileMediaAssetId,
      connectedSince: merged.connectedSince,
      notes: merged.notes,
      isActive: merged.isActive,
    );
    await _syncQueue.enqueueRowMutation(
      businessId: businessId,
      deviceId: _deviceIdReader?.call(),
      entityType: _partiesEntity,
      entityId: id,
      operation: SyncQueueOperation.update,
      payload: _domainPayload(merged),
      baseSyncVersion: baseVersion,
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
      entityType: _partiesEntity,
      entityId: id,
      operation: SyncQueueOperation.delete,
      payload: const {},
      baseSyncVersion: existing.syncVersion,
      clientUpdatedAt: now,
    );
  }

  Future<void> _hydrateIfEmpty(String businessId) async {
    final count = await _local.countActive(businessId);
    if (count > 0) return;
    try {
      var page = 1;
      while (true) {
        final response = await _remote.listParties(
          PartyListQuery(page: page),
        );
        for (final dto in response.parties) {
          await _local.upsertFromDto(businessId, dto);
        }
        if (response.parties.length < 100) break;
        if (page * 100 >= response.total) break;
        page += 1;
      }
    } on Object {
      // Offline / first launch with empty local — leave empty.
    }
  }

  static _PartyFields _rowFromCreate(CreatePartyRequest request) {
    return _PartyFields(
      name: request.name.trim(),
      legalName: _emptyToNull(request.legalName),
      alias: _emptyToNull(request.alias),
      mobile: _emptyToNull(request.mobile),
      email: _emptyToNull(request.email),
      partyGroup: _emptyToNull(request.partyGroup),
      areaCode: _emptyToNull(request.areaCode),
      partyType: request.partyType,
      partyCategory: request.partyCategory,
      pricingTier: request.pricingTier,
      gstin: _emptyToNull(request.gstin),
      stateCode: _emptyToNull(request.stateCode),
      areaId: request.areaId,
      creditLimit: request.creditLimit ?? '0',
      openingBalance: request.openingBalance ?? '0',
      notes: _emptyToNull(request.notes),
      isActive: request.isActive,
    );
  }

  static _PartyFields _mergeUpdate(
    PartyTableData existing,
    UpdatePartyRequest request,
  ) {
    return _PartyFields(
      name: request.name?.trim() ?? existing.name,
      legalName: request.legalName ?? existing.legalName,
      alias: request.alias ?? existing.alias,
      mobile: request.mobile ?? existing.mobile,
      email: request.email ?? existing.email,
      partyGroup: request.partyGroup ?? existing.partyGroup,
      areaCode: request.areaCode ?? existing.areaCode,
      partyType: request.partyType ?? existing.partyType,
      partyCategory: request.partyCategory ?? existing.partyCategory,
      pricingTier: request.pricingTier ?? existing.pricingTier,
      gstin: request.gstin ?? existing.gstin,
      stateCode: request.stateCode ?? existing.stateCode,
      areaId: request.areaId ?? existing.areaId,
      creditLimit: request.creditLimit ?? existing.creditLimit,
      openingBalance: request.openingBalance ?? existing.openingBalance,
      hiddenLedgerBalance: existing.hiddenLedgerBalance,
      profileImageUrl: existing.profileImageUrl,
      profileMediaAssetId: existing.profileMediaAssetId,
      connectedSince: existing.connectedSince,
      notes: request.notes ?? existing.notes,
      isActive: request.isActive ?? existing.isActive,
    );
  }

  static Map<String, dynamic> _domainPayload(_PartyFields row) {
    return {
      'name': row.name,
      'legal_name': row.legalName,
      'alias': row.alias,
      'mobile': row.mobile,
      'email': row.email,
      'party_group': row.partyGroup,
      'area_code': row.areaCode,
      'party_type': row.partyType,
      'party_category': row.partyCategory,
      'pricing_tier': row.pricingTier,
      'gstin': row.gstin,
      'state_code': row.stateCode,
      'area_id': row.areaId,
      'credit_limit': row.creditLimit,
      'opening_balance': row.openingBalance,
      'hidden_ledger_balance': row.hiddenLedgerBalance,
      'profile_image_url': row.profileImageUrl,
      'profile_media_asset_id': row.profileMediaAssetId,
      'connected_since': row.connectedSince,
      'notes': row.notes,
      'is_active': row.isActive,
    };
  }

  static String? _emptyToNull(String? value) {
    if (value == null) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}

class _PartyFields {
  const _PartyFields({
    required this.name,
    required this.partyType,
    required this.pricingTier,
    required this.creditLimit,
    required this.openingBalance,
    required this.isActive,
    this.legalName,
    this.alias,
    this.mobile,
    this.email,
    this.partyGroup,
    this.areaCode,
    this.partyCategory,
    this.gstin,
    this.stateCode,
    this.areaId,
    this.hiddenLedgerBalance = '0',
    this.profileImageUrl,
    this.profileMediaAssetId,
    this.connectedSince,
    this.notes,
  });

  final String name;
  final String? legalName;
  final String? alias;
  final String? mobile;
  final String? email;
  final String? partyGroup;
  final String? areaCode;
  final String partyType;
  final String? partyCategory;
  final String pricingTier;
  final String? gstin;
  final String? stateCode;
  final String? areaId;
  final String creditLimit;
  final String openingBalance;
  final String hiddenLedgerBalance;
  final String? profileImageUrl;
  final String? profileMediaAssetId;
  final String? connectedSince;
  final String? notes;
  final bool isActive;
}
