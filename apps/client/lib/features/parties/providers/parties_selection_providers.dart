import 'package:billing_baba/features/parties/models/party_list_filter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final selectedPartyIdProvider = NotifierProvider<SelectedPartyId, String?>(
  SelectedPartyId.new,
);

final partySearchQueryProvider = NotifierProvider<PartySearchQuery, String>(
  PartySearchQuery.new,
);

final partyListFilterProvider =
    NotifierProvider<PartyListFilterNotifier, PartyListFilter>(
      PartyListFilterNotifier.new,
    );

class SelectedPartyId extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String? id) => state = id;
}

class PartySearchQuery extends Notifier<String> {
  @override
  String build() => '';

  void update(String query) => state = query;
}

class PartyListFilterNotifier extends Notifier<PartyListFilter> {
  @override
  PartyListFilter build() => PartyListFilter.all;

  void select(PartyListFilter filter) => state = filter;
}
