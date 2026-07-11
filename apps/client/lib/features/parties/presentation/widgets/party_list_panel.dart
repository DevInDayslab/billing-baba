import 'dart:async';

import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/core/theme/list_panel_theme.dart';
import 'package:billing_baba/core/widgets/list_panel_header.dart';
import 'package:billing_baba/core/widgets/list_search_field.dart';
import 'package:billing_baba/features/parties/application/party_error_mapper.dart';
import 'package:billing_baba/features/parties/application/party_service.dart';
import 'package:billing_baba/features/parties/models/party_list_filter.dart';
import 'package:billing_baba/features/parties/models/party_model.dart';
import 'package:billing_baba/features/parties/providers/parties_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';

class PartyListPanel extends ConsumerStatefulWidget {
  const PartyListPanel({super.key});

  @override
  ConsumerState<PartyListPanel> createState() => _PartyListPanelState();
}

class _PartyListPanelState extends ConsumerState<PartyListPanel> {
  Timer? _debounce;

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

  @override
  Widget build(BuildContext context) {
    final partiesAsync = ref.watch(partyListProvider);
    final parties = ref.watch(partiesListProvider);
    final selectedId = ref.watch(selectedPartyIdProvider);
    final activeFilter = ref.watch(partyListFilterProvider);
    final searchQuery = ref.watch(partySearchQueryProvider);
    final usingCache = ref.watch(partiesUsingCacheProvider);

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
            AppSpacing.sm,
          ),
          child: ListSearchField(
            hint: 'Search Party Name',
            onChanged: _onSearchChanged,
          ),
        ),
        _PartyListHeader(
          activeFilter: activeFilter,
          onFilterSelected: _onFilterSelected,
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => ref
                .read(partyListProvider.notifier)
                .refresh(
                  searchQuery: searchQuery.trim(),
                  filter: activeFilter,
                ),
            child: partiesAsync.when(
              loading: () => const _PartyListSkeleton(),
              error: (error, _) {
                if (parties.isNotEmpty) {
                  return _buildList(
                    parties: parties,
                    selectedId: selectedId,
                  );
                }

                return ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(
                      height: 200,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: AppColors.error,
                                size: 32,
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                PartyErrorMapper.messageFor(error),
                                style: ListPanelStyles.emptyStateStyle.copyWith(
                                  color: AppColors.textPrimary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: AppSpacing.md),
                              FilledButton(
                                onPressed: () => ref
                                    .read(partyListProvider.notifier)
                                    .refresh(
                                      searchQuery: searchQuery.trim(),
                                      filter: activeFilter,
                                    ),
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
              data: (_) {
                if (parties.isEmpty) {
                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(
                        height: 200,
                        child: ListPanelEmptyState(
                          message:
                              searchQuery.isNotEmpty ||
                                  activeFilter != PartyListFilter.all
                              ? 'No parties found'
                              : 'No parties yet. Add your first party.',
                        ),
                      ),
                    ],
                  );
                }

                return Column(
                  children: [
                    Expanded(
                      child: _buildList(
                        parties: parties,
                        selectedId: selectedId,
                      ),
                    ),
                    if (parties.length > 20)
                      Padding(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        child: Text(
                          'Showing ${parties.length} parties',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildList({
    required List<PartyModel> parties,
    required String? selectedId,
  }) {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: parties.length,
      itemBuilder: (context, index) {
        final party = parties[index];
        return _PartyListTile(
          party: party,
          isSelected: party.id == selectedId,
          onTap: () async {
            ref.read(selectedPartyIdProvider.notifier).selected = party.id;
            final service = await ref.read(partyServiceProvider.future);
            await service.rememberSelectedParty(party.id);
          },
        );
      },
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
          margin: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
          ),
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
        'Offline — showing cached parties',
        style: TextStyle(color: Colors.orange.shade900, fontSize: 12),
      ),
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
        vertical: AppSpacing.xs,
      ),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: listPanelCardBorder)),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text('PARTY NAME', style: ListPanelStyles.listHeaderStyle),
          ),
          const SizedBox(
            width: 88,
            child: Text(
              'OUTSTANDING',
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style: ListPanelStyles.listHeaderStyle,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          PopupMenuButton<PartyListFilter>(
            tooltip: 'Filter parties',
            icon: Icon(
              Icons.filter_list,
              size: 20,
              color: isFiltered ? AppColors.primary : AppColors.textSecondary,
            ),
            onSelected: onFilterSelected,
            itemBuilder: (context) => PartyListFilter.values
                .map(
                  (filter) => PopupMenuItem(
                    value: filter,
                    child: Row(
                      children: [
                        if (filter == activeFilter)
                          const Icon(Icons.check, size: 16)
                        else
                          const SizedBox(width: 16),
                        const SizedBox(width: AppSpacing.sm),
                        Text(filter.label),
                      ],
                    ),
                  ),
                )
                .toList(),
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

  @override
  Widget build(BuildContext context) {
    final amountColor = party.hasReceivable
        ? listPanelPositiveColor
        : party.hasPayable
        ? listPanelNegativeColor
        : AppColors.textSecondary;
    final amountText = PartyModel.displayOutstanding(party.balance);

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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            party.name,
                            style: TextStyle(
                              fontSize: 13,
                              color: party.isActive
                                  ? AppColors.textPrimary
                                  : AppColors.textSecondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (party.partyType != 'customer')
                            Text(
                              party.partyTypeLabel,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                        ],
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
