import 'package:billing_baba/core/database/database.dart';
import 'package:billing_baba/features/parties/models/party_dto.dart';
import 'package:drift/drift.dart';

/// Drift-backed local store for party masters. Does not enqueue SyncJobs.
class PartyLocalSource {
  PartyLocalSource(this._db);

  final AppDatabase _db;

  Future<int> countActive(String businessId) async {
    final rows = await (_db.select(_db.partiesLocal)
          ..where(
            (t) =>
                t.businessId.equals(businessId) & t.isDeleted.equals(false),
          ))
        .get();
    return rows.length;
  }

  Future<List<PartyDto>> listActive(
    String businessId, {
    String? searchQuery,
  }) async {
    final query = _db.select(_db.partiesLocal)
      ..where(
        (t) => t.businessId.equals(businessId) & t.isDeleted.equals(false),
      )
      ..orderBy([(t) => OrderingTerm.asc(t.name)]);
    final rows = await query.get();
    final q = searchQuery?.trim().toLowerCase();
    final filtered = q == null || q.isEmpty
        ? rows
        : rows.where((r) {
            final hay = '${r.name} ${r.mobile ?? ''} ${r.email ?? ''}'
                .toLowerCase();
            return hay.contains(q);
          }).toList();
    return filtered.map(_toDto).toList();
  }

  Stream<List<PartyDto>> watchActive(String businessId) {
    return (_db.select(_db.partiesLocal)
          ..where(
            (t) =>
                t.businessId.equals(businessId) & t.isDeleted.equals(false),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .watch()
        .map((rows) => rows.map(_toDto).toList());
  }

  Future<PartyTableData?> getById(String id) {
    return (_db.select(_db.partiesLocal)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  Future<PartyDto?> getActiveDto(String id) async {
    final row = await getById(id);
    if (row == null || row.isDeleted) return null;
    return _toDto(row);
  }

  Future<void> upsertRow({
    required String id,
    required String businessId,
    required String name,
    required int syncVersion,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? legalName,
    String? alias,
    String? mobile,
    String? email,
    String? partyGroup,
    String? areaCode,
    String partyType = 'customer',
    String? partyCategory,
    String pricingTier = 'tier_1',
    String? gstin,
    String? stateCode,
    String? areaId,
    String creditLimit = '0',
    String openingBalance = '0',
    String hiddenLedgerBalance = '0',
    String? profileImageUrl,
    String? profileMediaAssetId,
    String? connectedSince,
    String? notes,
    bool isActive = true,
    DateTime? deletedAt,
    bool isDeleted = false,
    String? deviceId,
  }) {
    return _db.into(_db.partiesLocal).insertOnConflictUpdate(
          PartiesLocalCompanion.insert(
            id: id,
            businessId: businessId,
            name: name,
            legalName: Value(legalName),
            alias: Value(alias),
            mobile: Value(mobile),
            email: Value(email),
            partyGroup: Value(partyGroup),
            areaCode: Value(areaCode),
            partyType: Value(partyType),
            partyCategory: Value(partyCategory),
            pricingTier: Value(pricingTier),
            gstin: Value(gstin),
            stateCode: Value(stateCode),
            areaId: Value(areaId),
            creditLimit: Value(creditLimit),
            openingBalance: Value(openingBalance),
            hiddenLedgerBalance: Value(hiddenLedgerBalance),
            profileImageUrl: Value(profileImageUrl),
            profileMediaAssetId: Value(profileMediaAssetId),
            connectedSince: Value(connectedSince),
            notes: Value(notes),
            isActive: Value(isActive),
            syncVersion: Value(syncVersion),
            createdAt: createdAt.toUtc(),
            updatedAt: updatedAt.toUtc(),
            deletedAt: Value(deletedAt?.toUtc()),
            isDeleted: Value(isDeleted),
            deviceId: Value(deviceId),
          ),
        );
  }

  Future<void> upsertFromDto(String businessId, PartyDto dto) {
    final created =
        DateTime.tryParse(dto.createdAt)?.toUtc() ?? DateTime.now().toUtc();
    final updated =
        DateTime.tryParse(dto.updatedAt)?.toUtc() ?? created;
    return upsertRow(
      id: dto.id,
      businessId: businessId,
      name: dto.name,
      legalName: dto.legalName,
      alias: dto.alias,
      mobile: dto.mobile,
      email: dto.email,
      partyGroup: dto.partyGroup,
      areaCode: dto.areaCode,
      partyType: dto.partyType,
      partyCategory: dto.partyCategory,
      pricingTier: dto.pricingTier,
      gstin: dto.gstin,
      stateCode: dto.stateCode,
      areaId: dto.areaId,
      creditLimit: dto.creditLimit,
      openingBalance: dto.openingBalance,
      hiddenLedgerBalance: dto.unrecoveredAmount.toString(),
      profileImageUrl: dto.profileImageUrl,
      profileMediaAssetId: dto.profileMediaAssetId,
      notes: dto.notes,
      isActive: dto.isActive,
      syncVersion: 1,
      createdAt: created,
      updatedAt: updated,
    );
  }

  Future<void> softDelete({
    required String id,
    required DateTime deletedAt,
  }) {
    return (_db.update(_db.partiesLocal)..where((t) => t.id.equals(id)))
        .write(
      PartiesLocalCompanion(
        isDeleted: const Value(true),
        deletedAt: Value(deletedAt.toUtc()),
        updatedAt: Value(deletedAt.toUtc()),
      ),
    );
  }

  PartyDto _toDto(PartyTableData row) {
    return PartyDto(
      id: row.id,
      name: row.name,
      legalName: row.legalName,
      alias: row.alias,
      mobile: row.mobile,
      email: row.email,
      partyType: row.partyType,
      partyCategory: row.partyCategory,
      partyGroup: row.partyGroup,
      areaCode: row.areaCode,
      pricingTier: row.pricingTier,
      gstin: row.gstin,
      stateCode: row.stateCode,
      areaId: row.areaId,
      creditLimit: row.creditLimit,
      openingBalance: row.openingBalance,
      balance: row.openingBalance,
      unrecoveredAmount: double.tryParse(row.hiddenLedgerBalance) ?? 0,
      isActive: row.isActive,
      notes: row.notes,
      profileImageUrl: row.profileImageUrl,
      profileMediaAssetId: row.profileMediaAssetId,
      createdAt: row.createdAt.toUtc().toIso8601String(),
      updatedAt: row.updatedAt.toUtc().toIso8601String(),
    );
  }
}
