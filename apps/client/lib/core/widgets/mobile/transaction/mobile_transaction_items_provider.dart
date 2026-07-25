import 'package:billing_baba/core/widgets/mobile/transaction/mobile_transaction_catalog.dart';
import 'package:billing_baba/core/widgets/mobile/transaction/mobile_transaction_mock_data.dart';
import 'package:billing_baba/core/widgets/mobile/transaction/mobile_transaction_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Mock transaction rows keyed by [MobileTransactionScopeDefinition.scopeId].
///
/// TODO(mobile): Replace with feature providers when live transaction APIs wire up.
final mobileTransactionItemsProvider = Provider.family<
    AsyncValue<List<MobileTransactionListItem>>,
    String>((ref, scopeId) {
  final definition = MobileTransactionCatalog.all
      .where((item) => item.scopeId == scopeId)
      .firstOrNull;

  if (definition == null) {
    return const AsyncValue.data([]);
  }

  return AsyncValue.data(
    MobileTransactionMockData.itemsFor(definition),
  );
});
