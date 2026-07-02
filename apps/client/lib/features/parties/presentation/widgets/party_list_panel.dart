import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/core/theme/list_panel_theme.dart';
import 'package:billing_baba/core/widgets/list_panel_header.dart';
import 'package:billing_baba/core/widgets/list_search_field.dart';
import 'package:billing_baba/features/parties/models/party_list_filter.dart';
import 'package:billing_baba/features/parties/models/party_model.dart';
import 'package:billing_baba/features/parties/providers/parties_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class PartyListPanel extends ConsumerWidget {
  const PartyListPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final parties = ref.watch(partiesListProvider);
    final selectedId = ref.watch(selectedPartyIdProvider);
    final activeFilter = ref.watch(partyListFilterProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.sm,
          ),
          child: ListSearchField(
            hint: 'Search Party Name',
            onChanged: (query) =>
                ref.read(partySearchQueryProvider.notifier).update(query),
          ),
        ),
        _PartyListHeader(
          activeFilter: activeFilter,
          onFilterSelected: (filter) => ref
              .read(partyListFilterProvider.notifier)
              .select(filter),
        ),
        Expanded(
          child: parties.isEmpty
              ? const ListPanelEmptyState(message: 'No parties found')
              : ListView.builder(
                  itemCount: parties.length,
                  itemBuilder: (context, index) {
                    final party = parties[index];
                    return _PartyListTile(
                      party: party,
                      isSelected: party.id == selectedId,
                      onTap: () => ref
                          .read(selectedPartyIdProvider.notifier)
                          .select(party.id),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _PartyListHeader extends StatelessWidget {
  const _PartyListHeader({
    required this.activeFilter,
    required this.onFilterSelected,
  });

  final PartyListFilter activeFilter;
  final ValueChanged<PartyListFilter> onFilterSelected;

  @override
  Widget build(BuildContext context) {
    final isFiltered = activeFilter != PartyListFilter.all;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 10,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFF5F5F5),
        border: Border(bottom: BorderSide(color: listPanelCardBorder)),
      ),
      child: Row(
        children: [
          const Expanded(
            flex: 3,
            child: Text(
              'PARTY NAME',
              style: ListPanelStyles.listHeaderStyle,
            ),
          ),
          ListPanelPopupMenuButton<PartyListFilter>(
            tooltip: 'Filter parties',
            offset: const Offset(0, 28),
            onSelected: onFilterSelected,
            itemBuilder: (context) => [
              for (final filter in PartyListFilter.values)
                PopupMenuItem(
                  value: filter,
                  child: Row(
                    children: [
                      SizedBox(
                        width: 20,
                        child: activeFilter == filter
                            ? const Icon(
                                Icons.check,
                                size: 16,
                                color: AppColors.primary,
                              )
                            : null,
                      ),
                      Text(filter.label),
                    ],
                  ),
                ),
            ],
            child: Icon(
              Icons.tune,
              size: 18,
              color: isFiltered ? AppColors.primary : Colors.grey.shade600,
            ),
          ),
          const Expanded(
            flex: 2,
            child: Text(
              'AMOUNT',
              style: ListPanelStyles.listHeaderStyle,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

class _PartyListTile extends StatelessWidget {
  const _PartyListTile({
    required this.party,
    required this.isSelected,
    required this.onTap,
  });

  final PartyModel party;
  final bool isSelected;
  final VoidCallback onTap;

  static final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    final amountColor = party.hasReceivable
        ? listPanelPositiveColor
        : party.hasPayable
        ? listPanelNegativeColor
        : AppColors.textSecondary;
    final amountText = _currencyFormat.format(party.balance.abs());

    return Material(
      color: isSelected ? listPanelSelectedRowColor : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: listPanelCardBorder)),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: 12,
          ),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 16,
                      color: party.isActive
                          ? Colors.grey.shade500
                          : Colors.grey.shade400,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        party.name,
                        style: TextStyle(
                          fontSize: 13,
                          color: party.isActive
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                flex: 2,
                child: Text(
                  amountText,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: amountColor,
                  ),
                  textAlign: TextAlign.end,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
