import 'package:billing_baba/features/parties/application/parties_providers.dart';
import 'package:billing_baba/features/parties/models/party_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum MobilePartySortColumn { name, amount }

enum MobilePartySortDirection { none, ascending, descending }

class MobilePartyListSortState {
  const MobilePartyListSortState({
    this.column = MobilePartySortColumn.name,
    this.direction = MobilePartySortDirection.none,
  });

  final MobilePartySortColumn column;
  final MobilePartySortDirection direction;

  String get label => switch (column) {
    MobilePartySortColumn.name => 'Name',
    MobilePartySortColumn.amount => 'Amount',
  };

  MobilePartyListSortState toggle(MobilePartySortColumn target) {
    if (column == target) {
      final nextDirection = switch (direction) {
        MobilePartySortDirection.none => MobilePartySortDirection.ascending,
        MobilePartySortDirection.ascending =>
          MobilePartySortDirection.descending,
        MobilePartySortDirection.descending => MobilePartySortDirection.none,
      };
      return MobilePartyListSortState(column: target, direction: nextDirection);
    }

    return MobilePartyListSortState(
      column: target,
      direction: MobilePartySortDirection.ascending,
    );
  }

  MobilePartyListSortState copyWith({
    MobilePartySortColumn? column,
    MobilePartySortDirection? direction,
  }) {
    return MobilePartyListSortState(
      column: column ?? this.column,
      direction: direction ?? this.direction,
    );
  }
}

final mobilePartyListSortProvider =
    NotifierProvider<MobilePartyListSortNotifier, MobilePartyListSortState>(
      MobilePartyListSortNotifier.new,
    );

class MobilePartyListSortNotifier extends Notifier<MobilePartyListSortState> {
  @override
  MobilePartyListSortState build() => const MobilePartyListSortState();

  void toggle(MobilePartySortColumn column) {
    state = state.toggle(column);
  }

  void applySelection({
    required MobilePartySortColumn column,
    required MobilePartySortDirection direction,
  }) {
    state = MobilePartyListSortState(column: column, direction: direction);
  }
}

/// Client-side sort for the mobile party list (mirrors desktop list panel).
List<PartyModel> sortMobileParties(
  List<PartyModel> parties,
  MobilePartyListSortState sort, {
  Map<String, double>? outstandingIndex,
}) {
  if (sort.direction == MobilePartySortDirection.none) {
    return parties;
  }

  final ascending = sort.direction == MobilePartySortDirection.ascending;
  final sorted = List<PartyModel>.from(parties)
    ..sort((a, b) {
      final comparison = switch (sort.column) {
        MobilePartySortColumn.name => a.name.toLowerCase().compareTo(
          b.name.toLowerCase(),
        ),
        MobilePartySortColumn.amount =>
          projectedPartyBalance(a, outstandingIndex).abs().compareTo(
            projectedPartyBalance(b, outstandingIndex).abs(),
          ),
      };
      return ascending ? comparison : -comparison;
    });
  return sorted;
}
