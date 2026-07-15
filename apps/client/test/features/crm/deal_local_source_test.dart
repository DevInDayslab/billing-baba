import 'package:billing_baba/core/constants/storage_keys.dart';
import 'package:billing_baba/core/database/database.dart';
import 'package:billing_baba/core/services/storage_service.dart';
import 'package:billing_baba/features/crm/data/deal_mock_data.dart';
import 'package:billing_baba/features/crm/data/repositories/deal_repository.dart';
import 'package:billing_baba/features/crm/data/sources/deal_local_source.dart';
import 'package:billing_baba/features/crm/data/sources/deal_remote_source.dart';
import 'package:billing_baba/features/crm/domain/models/deal.dart';
import 'package:billing_baba/features/crm/domain/services/deal_service.dart';
import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeStorage extends StorageService {
  _FakeStorage(this._values);

  final Map<String, String> _values;

  @override
  String? read(String key) => _values[key];

  @override
  Future<void> write(String key, String value) async {
    _values[key] = value;
  }
}

void main() {
  test('moveDealToStage persists stage change locally', () async {
    const businessId = 'b234a35a-f0b1-4fcc-915b-dbf2c46328fa';
    final storage = _FakeStorage({
      StorageKeys.lastOpenedBusinessId: businessId,
    });
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    final repository = DealRepository(
      local: DealLocalSource(db, storage),
      remote: DealRemoteSource(Dio()),
    );
    final service = DealService(repository);

    for (final deal in DealMockData.dealsFor(businessId)) {
      await repository.saveDeal(deal, operation: 'create');
    }

    final deals = await service.loadDeals();
    final deal = deals.firstWhere((d) => d.stage == DealStage.qualification);

    final moved = await service.moveDealToStage(
      deal,
      DealStage.valueProposition,
    );

    expect(moved.stage, DealStage.valueProposition);

    final reloaded = await service.loadDeals();
    final updated = reloaded.firstWhere((d) => d.id == deal.id);
    expect(updated.stage, DealStage.valueProposition);
  });

  test('updateDeal persists stage change for existing row', () async {
    const businessId = 'b234a35a-f0b1-4fcc-915b-dbf2c46328fa';
    final storage = _FakeStorage({
      StorageKeys.lastOpenedBusinessId: businessId,
    });
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    final repository = DealRepository(
      local: DealLocalSource(db, storage),
      remote: DealRemoteSource(Dio()),
    );
    final service = DealService(repository);

    final seeded = DealMockData.dealsFor(businessId).first;
    await repository.saveDeal(seeded, operation: 'create');

    final updated = await service.updateDeal(
      seeded.copyWith(stage: DealStage.negotiationReview),
    );

    expect(updated.stage, DealStage.negotiationReview);
  });
}