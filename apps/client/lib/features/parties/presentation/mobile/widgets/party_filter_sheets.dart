import 'package:billing_baba/shared/widgets/mobile/mobile_option_sheet.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_sheets.dart';
import 'package:billing_baba/features/parties/models/party_list_filter.dart';
import 'package:billing_baba/features/parties/presentation/mobile/application/mobile_party_list_controller.dart';
import 'package:flutter/material.dart';

/// Opens the reusable party filter bottom sheet.
Future<PartyListFilter?> showPartyFilterSheet({
  required BuildContext context,
  required PartyListFilter selected,
}) {
  return showMobileFilterSheet<PartyListFilter>(
    context: context,
    title: 'Filter Parties',
    selected: selected,
    options: PartyListFilter.values
        .map(
          (filter) => MobileOption(
            value: filter,
            label: filter.label,
            subtitle: _filterSubtitle(filter),
          ),
        )
        .toList(),
  );
}

String? _filterSubtitle(PartyListFilter filter) => switch (filter) {
  PartyListFilter.all => 'Show all parties',
  PartyListFilter.toReceive => 'Parties with receivable balance',
  PartyListFilter.toPay => 'Parties with payable balance',
  PartyListFilter.active => 'Active parties only',
  PartyListFilter.inactive => 'Inactive parties only',
};

/// Opens the reusable party sort bottom sheet.
Future<MobilePartyListSortState?> showPartySortSheet({
  required BuildContext context,
  required MobilePartyListSortState selected,
}) async {
  final column = await showMobileFilterSheet<MobilePartySortColumn>(
    context: context,
    title: 'Sort By',
    selected: selected.column,
    options: const [
      MobileOption(value: MobilePartySortColumn.name, label: 'Name'),
      MobileOption(value: MobilePartySortColumn.amount, label: 'Amount'),
    ],
  );
  if (!context.mounted || column == null) return null;

  final direction = await showMobileFilterSheet<MobilePartySortDirection>(
    context: context,
    title: 'Sort Direction',
    selected: selected.direction == MobilePartySortDirection.none
        ? MobilePartySortDirection.ascending
        : selected.direction,
    options: const [
      MobileOption(
        value: MobilePartySortDirection.ascending,
        label: 'Ascending',
      ),
      MobileOption(
        value: MobilePartySortDirection.descending,
        label: 'Descending',
      ),
    ],
  );
  if (!context.mounted || direction == null) return null;

  return MobilePartyListSortState(column: column, direction: direction);
}
