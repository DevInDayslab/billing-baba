import 'package:billing_baba/features/recycle_bin/models/recycle_bin_item.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('RecycleBinItem.fromJson maps API recycle bin row', () {
    final item = RecycleBinItem.fromJson({
      'entity_type': 'expense',
      'entity_id': '550e8400-e29b-41d4-a716-446655440000',
      'label': 'Office rent',
      'party_name': 'Landlord',
      'amount': '12000',
      'transaction_date': '2026-01-15',
      'deleted_at': '2026-02-01T10:00:00.000Z',
      'days_remaining': 45,
    });

    expect(item.entityType, 'expense');
    expect(item.entityId, '550e8400-e29b-41d4-a716-446655440000');
    expect(item.label, 'Office rent');
    expect(item.partyName, 'Landlord');
    expect(item.amount, '12000');
    expect(item.daysRemaining, 45);
  });
}
