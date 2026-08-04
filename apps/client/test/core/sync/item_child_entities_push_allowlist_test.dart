import 'package:billing_baba/core/sync/engine/sync_coordinator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('inventory child entities are client-pushable', () {
    final pushable = SyncCoordinator.clientPushableEntityTypesForTest;
    expect(pushable.contains('item_alternatives'), isTrue);
    expect(pushable.contains('item_suppliers'), isTrue);
    expect(pushable.contains('item_tier_prices'), isTrue);
    expect(pushable.contains('item_bom_materials'), isTrue);
    expect(pushable.contains('item_bom_costs'), isTrue);
  });
}
