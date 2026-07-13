import 'package:billing_baba/features/parties/models/party_model.dart';

enum PartyListFilter {
  all,
  toReceive,
  toPay,
  active,
  inactive;

  String get label => switch (this) {
    PartyListFilter.all => 'All',
    PartyListFilter.toReceive => 'To Receive',
    PartyListFilter.toPay => 'To Pay',
    PartyListFilter.active => 'Active',
    PartyListFilter.inactive => 'Inactive',
  };

  static const selectableValues = [
    PartyListFilter.toReceive,
    PartyListFilter.toPay,
    PartyListFilter.active,
    PartyListFilter.inactive,
  ];
}

/// Selected party list filters. An empty set means "All".
class PartyListFilters {
  const PartyListFilters([this.selected = const {}]);

  final Set<PartyListFilter> selected;

  static const all = PartyListFilters();

  static const _balanceFilters = {
    PartyListFilter.toReceive,
    PartyListFilter.toPay,
  };

  static const _statusFilters = {
    PartyListFilter.active,
    PartyListFilter.inactive,
  };

  bool get isFiltered => selected.isNotEmpty;

  bool get isActiveOnly =>
      selected.contains(PartyListFilter.active) &&
      !selected.contains(PartyListFilter.inactive);

  /// For API query: null when both/neither status filters are selected.
  bool? get apiIsActive {
    final hasActive = selected.contains(PartyListFilter.active);
    final hasInactive = selected.contains(PartyListFilter.inactive);
    if (hasActive && !hasInactive) return true;
    if (hasInactive && !hasActive) return false;
    return null;
  }

  bool matches(PartyModel party) {
    if (selected.isEmpty) return true;

    final balance = selected.intersection(_balanceFilters);
    final status = selected.intersection(_statusFilters);

    if (balance.isNotEmpty) {
      final matchesBalance = balance.any(
        (filter) => switch (filter) {
          PartyListFilter.toReceive => party.hasReceivable,
          PartyListFilter.toPay => party.hasPayable,
          _ => false,
        },
      );
      if (!matchesBalance) return false;
    }

    if (status.isNotEmpty) {
      final matchesStatus = status.any(
        (filter) => switch (filter) {
          PartyListFilter.active => party.isActive,
          PartyListFilter.inactive => !party.isActive,
          _ => false,
        },
      );
      if (!matchesStatus) return false;
    }

    return true;
  }

  PartyListFilters toggle(PartyListFilter filter) {
    if (filter == PartyListFilter.all) return all;

    final next = Set<PartyListFilter>.from(selected);
    if (next.contains(filter)) {
      next.remove(filter);
    } else {
      next.add(filter);
    }
    return PartyListFilters(next);
  }

  PartyListFilters withSingle(PartyListFilter filter) {
    if (filter == PartyListFilter.all) return all;
    return PartyListFilters({filter});
  }

  String toStorage() => selected.map((filter) => filter.name).join(',');

  factory PartyListFilters.fromStorage(String? value) {
    if (value == null || value.isEmpty || value == PartyListFilter.all.name) {
      return all;
    }

    final filters = <PartyListFilter>{};
    for (final part in value.split(',')) {
      final trimmed = part.trim();
      if (trimmed.isEmpty) continue;
      final match = PartyListFilter.values
          .where((filter) => filter.name == trimmed)
          .firstOrNull;
      if (match != null && match != PartyListFilter.all) {
        filters.add(match);
      }
    }
    return PartyListFilters(filters);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PartyListFilters &&
        other.selected.length == selected.length &&
        other.selected.containsAll(selected);
  }

  @override
  int get hashCode => Object.hashAllUnordered(selected);
}
