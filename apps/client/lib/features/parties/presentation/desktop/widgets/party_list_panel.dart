import 'dart:async';

import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/inventory_async_list.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/inventory_list_header.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/inventory_list_table_row.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/inventory_search_field.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/inventory_styles.dart';
import 'package:billing_baba/features/parties/application/parties_providers.dart';
import 'package:billing_baba/features/parties/application/party_list_image_warmup.dart';
import 'package:billing_baba/features/parties/application/party_service.dart';
import 'package:billing_baba/features/parties/models/party_list_filter.dart';
import 'package:billing_baba/features/parties/models/party_model.dart';
import 'package:billing_baba/features/parties/presentation/desktop/widgets/party_actions.dart';
import 'package:billing_baba/features/parties/presentation/desktop/widgets/party_avatar.dart';
import 'package:billing_baba/features/parties/presentation/widgets/party_name_stack.dart';
import 'package:billing_baba/shared/widgets/app_ellipsis_text.dart';
import 'package:billing_baba/shared/widgets/table_filters/column_filter_trigger.dart';
import 'package:billing_baba/shared/widgets/table_filters/filter_models.dart';
import 'package:billing_baba/shared/widgets/table_filters/filter_result.dart';
import 'package:billing_baba/shared/widgets/table_filters/filter_types.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';

enum PartyListSortColumn { name, amount }

enum PartyListSortDirection { none, ascending, descending }

class _PartyListSortState {
  const _PartyListSortState({
    this.column = PartyListSortColumn.name,
    this.direction = PartyListSortDirection.none,
  });

  final PartyListSortColumn column;
  final PartyListSortDirection direction;

  _PartyListSortState toggle(PartyListSortColumn target) {
    if (column == target) {
      final nextDirection = switch (direction) {
        PartyListSortDirection.none => PartyListSortDirection.ascending,
        PartyListSortDirection.ascending => PartyListSortDirection.descending,
        PartyListSortDirection.descending => PartyListSortDirection.none,
      };
      return _PartyListSortState(column: target, direction: nextDirection);
    }

    return _PartyListSortState(
      column: target,
      direction: PartyListSortDirection.ascending,
    );
  }

  bool isSorted(PartyListSortColumn target) =>
      column == target && direction != PartyListSortDirection.none;

  bool isAscending(PartyListSortColumn target) =>
      column == target && direction == PartyListSortDirection.ascending;
}

/// Fixed width for the Amount column in the Parties left list header.
const partyListAmountHeaderWidth = 72.0;

const _partyListFilterConfig = ColumnFilter(
  id: 'party_status',
  title: 'Filter Parties',
  type: FilterType.singleSelect,
  searchable: false,
  values: [
    'To Receive',
    'To Pay',
    'Active',
    'Inactive',
  ],
);

class PartyListPanel extends ConsumerStatefulWidget {
  const PartyListPanel({super.key});

  @override
  ConsumerState<PartyListPanel> createState() => _PartyListPanelState();
}

class _PartyListPanelState extends ConsumerState<PartyListPanel> {
  Timer? _debounce;
  _PartyListSortState _sort = const _PartyListSortState();

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    ref.read(partySearchQueryProvider.notifier).query = query;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      ref.read(partyBackendSearchProvider.notifier).query = query.trim();
      unawaited(
        ref.read(partyListProvider.notifier).refresh(searchQuery: query.trim()),
      );
    });
  }

  Future<void> _onFilterSelected(PartyListFilter filter) async {
    ref.read(partyListFilterProvider.notifier).filter = filter;
    final service = await ref.read(partyServiceProvider.future);
    await service.rememberListFilter(filter);
    await ref.read(partyListProvider.notifier).refresh(filter: filter);
  }

  void _toggleSort(PartyListSortColumn column) {
    setState(() => _sort = _sort.toggle(column));
  }

  List<PartyModel> _sortedParties(
    List<PartyModel> parties,
    Map<String, double>? outstandingIndex,
  ) {
    if (_sort.direction == PartyListSortDirection.none) {
      return parties;
    }

    final ascending = _sort.direction == PartyListSortDirection.ascending;
    final sorted = List<PartyModel>.from(parties)
      ..sort((a, b) {
        final comparison = switch (_sort.column) {
          PartyListSortColumn.name => a.name.toLowerCase().compareTo(
            b.name.toLowerCase(),
          ),
          PartyListSortColumn.amount =>
            projectedPartyBalance(a, outstandingIndex).abs().compareTo(
              projectedPartyBalance(b, outstandingIndex).abs(),
            ),
        };
        return ascending ? comparison : -comparison;
      });
    return sorted;
  }

  Future<void> _onRefresh() {
    final searchQuery = ref.read(partySearchQueryProvider);
    final activeFilter = ref.read(partyListFilterProvider);
    return ref
        .read(partyListProvider.notifier)
        .refresh(
          searchQuery: searchQuery.trim(),
          filter: activeFilter,
        );
  }

  @override
  Widget build(BuildContext context) {
    final partiesAsync = ref.watch(partyListProvider);
    final outstandingIndex = ref.watch(partyOutstandingIndexProvider).value;
    final parties = _sortedParties(
      partiesAsync.asData?.value ?? ref.watch(partiesListProvider),
      outstandingIndex,
    );
    final selectedId = ref.watch(selectedPartyIdProvider);
    final activeFilter = ref.watch(partyListFilterProvider);
    final searchQuery = ref.watch(partySearchQueryProvider);
    final usingCache = ref.watch(partiesUsingCacheProvider);
    final isFiltered =
        activeFilter != PartyListFilter.all || searchQuery.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (usingCache)
          const Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              0,
            ),
            child: _OfflineBanner(),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.md,
            0,
          ),
          child: InventorySearchField(
            hint: 'Search Party Name',
            initialValue: searchQuery,
            debounceDuration: const Duration(milliseconds: 300),
            onChanged: _onSearchChanged,
            onDebouncedChanged: _onSearchChanged,
          ),
        ),
        const SizedBox(height: 14),
        InventoryListHeader(
          height: inventoryListHeaderCompactHeight,
          showColumnSeparators: false,
          includeTrailingSpace: false,
          columns: [
            InventoryListColumn(
              label: 'PARTY NAME',
              trailing: TableColumnFilterTrigger(
                config: _partyListFilterConfig,
                iconOnly: true,
                iconColor: AppColors.error,
                initialValue: _toSelectFilter(activeFilter),
                onApply: (result) =>
                    _onFilterSelected(_fromSelectFilter(result)),
              ),
              sortable: true,
              isSorted: _sort.isSorted(PartyListSortColumn.name),
              sortAscending: _sort.isAscending(PartyListSortColumn.name),
              onSort: () => _toggleSort(PartyListSortColumn.name),
            ),
            const InventoryListColumn(
              label: 'AMOUNT',
              fixedWidth: partyListAmountHeaderWidth,
              alignEnd: true,
            ),
          ],
        ),
        Expanded(
          child: partiesAsync.isLoading && parties.isEmpty
              ? const _PartyListSkeleton()
              : InventoryAsyncList<PartyModel>(
                  asyncValue: partiesAsync,
                  items: parties,
                  onRefresh: _onRefresh,
                  emptyMessage: isFiltered
                      ? 'No parties found'
                      : 'No parties yet. Add your first party.',
                  itemBuilder: (context, party, index) {
                    if (index == 0) {
                      ref
                          .read(partyListImageWarmupProvider)
                          .warmParties(parties);
                    }
                    return _PartyListTile(
                      party: party,
                      displayBalance: projectedPartyBalance(
                        party,
                        outstandingIndex,
                      ),
                      index: index,
                      isSelected: party.id == selectedId,
                      searchQuery: searchQuery,
                      onTap: () async {
                        ref.read(selectedPartyIdProvider.notifier).selected =
                            party.id;
                        final service = await ref.read(
                          partyServiceProvider.future,
                        );
                        await service.rememberSelectedParty(party.id);
                      },
                      onDoubleTap: () => PartyActions.edit(context, ref, party),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

SelectColumnFilter? _toSelectFilter(PartyListFilter filter) {
  if (filter == PartyListFilter.all) return null;
  return SelectColumnFilter(value: filter.label);
}

PartyListFilter _fromSelectFilter(FilterResult? result) {
  if (result == null || !result.isActive) return PartyListFilter.all;
  if (result is SelectFilterResult) {
    final value = result.filter.value;
    return PartyListFilter.values.firstWhere(
      (filter) => filter.label == value,
      orElse: () => PartyListFilter.all,
    );
  }
  return PartyListFilter.all;
}

class _PartyListTile extends StatelessWidget {
  const _PartyListTile({
    required this.party,
    required this.displayBalance,
    required this.index,
    required this.isSelected,
    required this.searchQuery,
    required this.onTap,
    required this.onDoubleTap,
  });

  final PartyModel party;
  final double displayBalance;
  final int index;
  final bool isSelected;
  final String searchQuery;
  final VoidCallback onTap;
  final VoidCallback onDoubleTap;

  @override
  Widget build(BuildContext context) {
    final amountColor = displayBalance > 0
        ? inventoryPositiveColor
        : displayBalance < 0
        ? inventoryNegativeColor
        : AppColors.textSecondary;
    final amountText = PartyModel.displayOutstanding(displayBalance);

    return InventoryListTableRow(
      index: index,
      isSelected: isSelected,
      onTap: onTap,
      onDoubleTap: onDoubleTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: Row(
          children: [
            PartyAvatar(
              key: ValueKey(
                'party-avatar-${party.id}-${party.profileMediaAssetId ?? party.profileImageUrl ?? 'none'}',
              ),
              name: party.name,
              seed: party.id,
              partyId: party.id,
              diameter: 28,
              profileImageUrl: party.profileImageUrl,
              profileMediaAssetId: party.profileMediaAssetId,
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  Expanded(
                    child: PartyNameStack(
                      party: party,
                      searchQuery: searchQuery,
                      nameStyle: InventoryStyles.listCellStyle.copyWith(
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
                        color: party.isActive
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                  if (!party.isActive) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Inactive',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: AppEllipsisText(
                amountText,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: amountColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PartyListSkeleton extends StatelessWidget {
  const _PartyListSkeleton();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: ListView.builder(
        itemCount: 8,
        itemBuilder: (context, index) => Container(
          height: inventoryItemListRowHeight,
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: inventoryCardBorder)),
          ),
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        ),
      ),
    );
  }
}

class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Text(
        'Working offline · Showing locally synchronized data.',
        style: TextStyle(color: Colors.orange.shade900, fontSize: 12),
      ),
    );
  }
}
