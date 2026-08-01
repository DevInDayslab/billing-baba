import 'package:billing_baba/core/constants/storage_keys.dart';
import 'package:billing_baba/core/database/database.dart';
import 'package:billing_baba/core/services/storage_service.dart';
import 'package:billing_baba/features/crm/data/sources/deal_local_source.dart';
import 'package:billing_baba/features/crm/domain/models/deal.dart';
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

Deal _deal({
  required String id,
  required String businessId,
  DealStage stage = DealStage.qualification,
  bool isDeleted = false,
  DateTime? createdAt,
  DateTime? updatedAt,
}) {
  final now = createdAt ?? DateTime.utc(2026, 1, 15);
  return Deal(
    id: id,
    businessId: businessId,
    name: 'Test Deal',
    stage: stage,
    accountName: 'Acme Corp',
    assignedTo: 'Alice',
    amount: 10000,
    isDeleted: isDeleted,
    updatedAt: updatedAt ?? now,
    createdAt: now,
  );
}

void main() {
  group('DealLocalSource', () {
    late AppDatabase db;
    late DealLocalSource source;
    const businessId = 'b234a35a-f0b1-4fcc-915b-dbf2c46328fa';

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      source = DealLocalSource(
        db,
        _FakeStorage({StorageKeys.lastOpenedBusinessId: businessId}),
      );
    });

    tearDown(() async {
      await db.close();
    });

    test('readBusinessId returns value from storage', () {
      expect(source.readBusinessId(), businessId);
    });

    test('upsertDeal persists stage on insert and update', () async {
      const dealId = 'deal-1';
      final seed = _deal(id: dealId, businessId: businessId);
      await source.upsertDeal(seed);

      var deals = await source.getDeals(businessId);
      expect(deals, hasLength(1));
      expect(deals.first.stage, DealStage.qualification);

      final updated = seed.copyWith(
        stage: DealStage.valueProposition,
        updatedAt: DateTime.utc(2026, 1, 16),
      );
      await source.upsertDeal(updated);

      deals = await source.getDeals(businessId);
      expect(deals, hasLength(1));
      expect(deals.first.stage, DealStage.valueProposition);
    });

    test('getDealById returns updated stage after upsert', () async {
      const dealId = 'deal-2';
      final seed = _deal(
        id: dealId,
        businessId: businessId,
        stage: DealStage.negotiationReview,
      );
      await source.upsertDeal(seed);

      final reloaded = await source.getDealById(businessId, dealId);
      expect(reloaded?.stage, DealStage.negotiationReview);
    });

    test('getDeals excludes deleted deals', () async {
      await source.upsertDeal(_deal(id: 'deal-active', businessId: businessId));
      await source.upsertDeal(
        _deal(
          id: 'deal-deleted',
          businessId: businessId,
          isDeleted: true,
        ),
      );

      final deals = await source.getDeals(businessId);
      expect(deals, hasLength(1));
      expect(deals.first.id, 'deal-active');
    });

    test('watchDeals emits stage updates', () async {
      const dealId = 'deal-3';
      final seed = _deal(id: dealId, businessId: businessId);
      await source.upsertDeal(seed);

      final emissions = <List<Deal>>[];
      final subscription = source.watchDeals(businessId).listen(emissions.add);
      addTearDown(subscription.cancel);

      await Future<void>.delayed(Duration.zero);
      expect(emissions.last, hasLength(1));
      expect(emissions.last.first.stage, DealStage.qualification);

      await source.upsertDeal(
        seed.copyWith(
          stage: DealStage.valueProposition,
          updatedAt: DateTime.utc(2026, 1, 16),
        ),
      );

      await Future<void>.delayed(Duration.zero);
      expect(emissions.last.first.stage, DealStage.valueProposition);
    });
  });
}
