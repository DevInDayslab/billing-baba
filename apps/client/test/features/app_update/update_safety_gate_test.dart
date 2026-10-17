import 'package:billing_baba/core/database/database.dart';
import 'package:billing_baba/core/sync/models/sync_job.dart';
import 'package:billing_baba/core/sync/providers/sync_providers.dart';
import 'package:billing_baba/core/sync/queue/sync_queue.dart';
import 'package:billing_baba/features/app_update/application/update_safety_gate.dart';
import 'package:billing_baba/features/pos/application/pos_cart_provider.dart'
    show PosCart, defaultPosCartSessionKey, posCartProvider;
import 'package:billing_baba/features/pos/application/pos_cart_state.dart';
import 'package:billing_baba/features/pos/models/cart_item.dart';
import 'package:billing_baba/features/pos/models/held_bill.dart';
import 'package:billing_baba/features/pos/models/payment_entry.dart';
import 'package:billing_baba/features/pos/models/pos_item.dart';
import 'package:billing_baba/features/auth/application/auth_provider.dart';
import 'package:drift/native.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const _sessionKey = 'sale_screen_tab_1';

PosItem _item() => const PosItem(
  id: 'i1',
  name: 'Item',
  sku: 'SKU',
  price: 10,
  stock: 5,
);

class _StaticPosCart extends PosCart {
  _StaticPosCart(this.initial);
  final PosCartState initial;

  @override
  PosCartState build({String sessionKey = defaultPosCartSessionKey}) => initial;
}

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    dotenv.loadFromString(
      envString:
          'API_BASE_URL=http://127.0.0.1:3000\nWEBSITE_URL=http://127.0.0.1\n',
    );
  });

  late AppDatabase db;
  late SyncQueue queue;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    queue = SyncQueue(db);
  });

  tearDown(() async {
    await db.close();
  });

  Future<UpdateSafetyResult> evaluateWith({
    PosCartState? cartState,
    bool enqueueSync = false,
  }) async {
    if (enqueueSync) {
      await queue.enqueueRowMutation(
        businessId: 'biz',
        entityType: 'parties',
        entityId: 'p1',
        operation: SyncQueueOperation.create,
        payload: const {},
      );
    }

    final container = ProviderContainer(
      overrides: [
        authProvider.overrideWithValue(
          const AuthState(status: AuthStatus.unauthenticated),
        ),
        syncQueueProvider.overrideWithValue(queue),
        if (cartState != null)
          posCartProvider(sessionKey: _sessionKey).overrideWith(
            () => _StaticPosCart(cartState),
          ),
      ],
    );
    final result = await container.read(updateSafetyGateProvider).evaluate();
    container.dispose();
    return result;
  }

  test('empty carts are not blocked', () async {
    final result = await evaluateWith(cartState: const PosCartState());
    expect(result.hasHardBlock, isFalse);
    expect(result.hasSoftBlock, isFalse);
  });

  test('items in tab 1 hard block with tab number', () async {
    final result = await evaluateWith(
      cartState: PosCartState(items: [CartItem(item: _item(), quantity: 1)]),
    );
    expect(result.hardBlocks, contains('Finish or hold the bill in tab 1'));
  });

  test('payments in progress hard block', () async {
    final result = await evaluateWith(
      cartState: const PosCartState(
        payments: [PaymentEntry(mode: PaymentMode.cash, amount: 1)],
      ),
    );
    expect(result.hardBlocks, isNotEmpty);
  });

  test('held bills only do not hard block', () async {
    final result = await evaluateWith(
      cartState: PosCartState(
        heldBills: [
          HeldBill(
            id: 'h1',
            items: [CartItem(item: _item(), quantity: 2)],
            heldAt: DateTime.utc(2026),
          ),
        ],
      ),
    );
    expect(result.hasHardBlock, isFalse);
  });

  test('pending sync queue is soft block', () async {
    final result = await evaluateWith(enqueueSync: true);
    expect(result.hasHardBlock, isFalse);
    expect(result.softBlocks.first, contains('still syncing'));
  });
}
