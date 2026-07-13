import 'package:billing_baba/features/parties/models/party_list_filter.dart';
import 'package:billing_baba/features/parties/models/party_type_filter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final selectedPartyIdProvider = NotifierProvider<SelectedPartyId, String?>(
  SelectedPartyId.new,
);

final partySearchQueryProvider = NotifierProvider<PartySearchQuery, String>(
  PartySearchQuery.new,
);

final partyListFilterProvider =
    NotifierProvider<PartyListFilterNotifier, PartyListFilters>(
      PartyListFilterNotifier.new,
    );

final partyTypeFilterProvider =
    NotifierProvider<PartyTypeFilterNotifier, PartyTypeFilter>(
      PartyTypeFilterNotifier.new,
    );

class SelectedPartyId extends Notifier<String?> {
  @override
  String? build() => null;

  String? get selected => state;
  set selected(String? id) => state = id;
}

class PartySearchQuery extends Notifier<String> {
  @override
  String build() => '';

  String get query => state;
  set query(String value) => state = value;
}

class PartyListFilterNotifier extends Notifier<PartyListFilters> {
  @override
  PartyListFilters build() => PartyListFilters.all;

  PartyListFilters get filters => state;
  set filters(PartyListFilters value) => state = value;

  /// Single-filter setter for deep links (e.g. dashboard shortcuts).
  set filter(PartyListFilter value) => state = state.withSingle(value);

  void toggle(PartyListFilter filter) => state = state.toggle(filter);
}

class PartyTypeFilterNotifier extends Notifier<PartyTypeFilter> {
  @override
  PartyTypeFilter build() => PartyTypeFilter.all;

  PartyTypeFilter get filter => state;
  set filter(PartyTypeFilter value) => state = value;
}
