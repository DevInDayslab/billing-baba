import 'package:billing_baba/core/constants/storage_keys.dart';
import 'package:billing_baba/core/database/database.dart';
import 'package:billing_baba/core/services/storage_service.dart';
import 'package:billing_baba/core/sync/queue/sync_queue.dart';
import 'package:billing_baba/features/parties/data/party_cache.dart';
import 'package:billing_baba/features/parties/data/party_local_source.dart';
import 'package:billing_baba/features/parties/data/party_master_repository.dart';
import 'package:billing_baba/features/parties/data/party_repository.dart';
import 'package:billing_baba/features/parties/models/add_party_result.dart';
import 'package:billing_baba/features/parties/models/party_model.dart';
import 'package:billing_baba/features/parties/application/party_service.dart';
import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('PartyService.updateParty persists merged party and extensions', () async {
    SharedPreferences.setMockInitialValues({
      StorageKeys.lastOpenedBusinessId: 'biz-1',
    });
    final prefs = await SharedPreferences.getInstance();
    final storage = StorageService(preferences: prefs);
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    final local = PartyLocalSource(db);
    final master = PartyMasterRepository(
      local: local,
      syncQueue: SyncQueue(db),
      remote: PartyRepository(Dio()),
      businessIdReader: () => 'biz-1',
    );
    final service = PartyService(
      cache: PartyCache(storage),
      master: master,
      businessIdReader: () => 'biz-1',
    );

    final created = await service.createParty(
      const AddPartyResult(
        partyName: 'Acme',
        phone: '9876543210',
        partyGroup: 'General',
      ),
    );

    final updated = await service.updateParty(
      created.id,
      const AddPartyResult(
        partyName: 'Acme Updated',
        phone: '9876543210',
        partyGroup: 'General',
        legalName: 'Acme Pvt Ltd',
        openingBalance: '-150.00',
      ),
      isActive: true,
    );

    expect(updated.name, 'Acme Updated');
    expect(updated.legalName, 'Acme Pvt Ltd');

    final row = await local.getById(created.id);
    expect(row, isNotNull);
    expect(row!.name, 'Acme Updated');
    expect(row.openingBalance, '-150.00');
  });

  test('updateParty throws when party row is missing locally', () async {
    SharedPreferences.setMockInitialValues({
      StorageKeys.lastOpenedBusinessId: 'biz-1',
    });
    final prefs = await SharedPreferences.getInstance();
    final storage = StorageService(preferences: prefs);
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    final service = PartyService(
      cache: PartyCache(storage),
      master: PartyMasterRepository(
        local: PartyLocalSource(db),
        syncQueue: SyncQueue(db),
        remote: PartyRepository(Dio()),
        businessIdReader: () => 'biz-1',
      ),
      businessIdReader: () => 'biz-1',
    );

    expect(
      () => service.updateParty(
        'missing-party-id',
        const AddPartyResult(partyName: 'Ghost', phone: '9876543210'),
      ),
      throwsA(isA<PartyException>()),
    );
  });

  test('updateParty throws when party belongs to another business', () async {
    SharedPreferences.setMockInitialValues({
      StorageKeys.lastOpenedBusinessId: 'biz-1',
    });
    final prefs = await SharedPreferences.getInstance();
    final storage = StorageService(preferences: prefs);
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    final local = PartyLocalSource(db);
    const partyId = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa';
    await local.upsertRow(
      id: partyId,
      businessId: 'biz-2',
      name: 'Other Biz Party',
      mobile: '9876543210',
      syncVersion: 1,
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    );

    final service = PartyService(
      cache: PartyCache(storage),
      master: PartyMasterRepository(
        local: local,
        syncQueue: SyncQueue(db),
        remote: PartyRepository(Dio()),
        businessIdReader: () => 'biz-1',
      ),
      businessIdReader: () => 'biz-1',
    );

    expect(
      () => service.updateParty(
        partyId,
        const AddPartyResult(
          partyName: 'Other Biz Party',
          phone: '9876543210',
          partyGroup: 'General',
        ),
      ),
      throwsA(isA<PartyBusinessNotSelectedException>()),
    );
  });

  test('updateParty hydrates missing local row from remote cache path', () async {
    SharedPreferences.setMockInitialValues({
      StorageKeys.lastOpenedBusinessId: 'biz-1',
    });
    final prefs = await SharedPreferences.getInstance();
    final storage = StorageService(preferences: prefs);
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    final local = PartyLocalSource(db);
    const partyId = 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb';
    await local.upsertRow(
      id: partyId,
      businessId: 'biz-1',
      name: 'Hydrated Party',
      mobile: '9876543210',
      syncVersion: 1,
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    );
    await local.softDelete(
      id: partyId,
      deletedAt: DateTime.utc(2026, 1, 2),
    );

    final service = PartyService(
      cache: PartyCache(storage),
      master: PartyMasterRepository(
        local: local,
        syncQueue: SyncQueue(db),
        remote: PartyRepository(Dio()),
        businessIdReader: () => 'biz-1',
      ),
      businessIdReader: () => 'biz-1',
    );

    expect(
      () => service.updateParty(
        partyId,
        const AddPartyResult(
          partyName: 'Hydrated Party',
          phone: '9876543210',
          partyGroup: 'General',
        ),
      ),
      throwsA(isA<PartyException>()),
    );
  });
}
