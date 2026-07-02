import 'package:billing_baba/features/parties/models/party_transaction_model.dart';
import 'package:billing_baba/features/parties/providers/party_catalog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final allPartyTransactionsProvider =
    NotifierProvider<PartyTransactions, List<PartyTransactionModel>>(
  PartyTransactions.new,
);

class PartyTransactions extends Notifier<List<PartyTransactionModel>> {
  @override
  List<PartyTransactionModel> build() => PartyCatalog.transactions();

  void updateTransaction(PartyTransactionModel updated) {
    final index = state.indexWhere((txn) => txn.id == updated.id);
    if (index == -1) return;

    final next = List<PartyTransactionModel>.from(state);
    next[index] = updated;
    state = next;
  }
}

final partyTransactionsForPartyProvider =
    Provider.family<List<PartyTransactionModel>, String>((ref, partyId) {
  final transactions = ref.watch(allPartyTransactionsProvider);
  return transactions.where((txn) => txn.partyId == partyId).toList()
    ..sort((a, b) => b.date.compareTo(a.date));
});
