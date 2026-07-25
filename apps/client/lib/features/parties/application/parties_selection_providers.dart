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
    NotifierProvider<PartyListFilterNotifier, PartyListFilter>(
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

class PartyListFilterNotifier extends Notifier<PartyListFilter> {
  @override
  PartyListFilter build() => PartyListFilter.all;

  PartyListFilter get filter => state;
  set filter(PartyListFilter value) => state = value;
}

class PartyTypeFilterNotifier extends Notifier<PartyTypeFilter> {
  @override
  PartyTypeFilter build() => PartyTypeFilter.all;

  PartyTypeFilter get filter => state;
  set filter(PartyTypeFilter value) => state = value;
}

class SelectedPartyGroup extends Notifier<String?> {
  @override
  String? build() => null;

  String? get selected => state;
  set selected(String? name) => state = name;
}

class PartyGroupSearchQuery extends Notifier<String> {
  @override
  String build() => '';

  String get query => state;
  set query(String value) => state = value;
}

final selectedPartyGroupProvider = NotifierProvider<SelectedPartyGroup, String?>(
  SelectedPartyGroup.new,
);

final partyGroupSearchQueryProvider =
    NotifierProvider<PartyGroupSearchQuery, String>(
      PartyGroupSearchQuery.new,
    );
