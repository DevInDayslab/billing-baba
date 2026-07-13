import 'dart:async';

import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/core/theme/list_panel_theme.dart';
import 'package:billing_baba/core/widgets/filter_icon.dart';
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

const _tableHeaderBg = Color(0xFFF5F7FA);
const _zebraRowBg = Color(0xFFFAFAFA);

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

  void _onFiltersChanged(PartyListFilters filters) {
    ref.read(partyListFilterProvider.notifier).filters = filters;
    unawaited(
      ref
          .read(partyServiceProvider.future)
          .then((service) => service.rememberListFilter(filters)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final partiesAsync = ref.watch(partyListProvider);
    final parties = ref.watch(filteredPartiesListProvider);
    final selectedId = ref.watch(selectedPartyIdProvider);
    final activeFilters = ref.watch(partyListFilterProvider);
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
          activeFilters: activeFilters,
          onFiltersChanged: _onFiltersChanged,
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => ref
                .read(partyListProvider.notifier)
                .refresh(searchQuery: searchQuery.trim()),
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
                                    .refresh(searchQuery: searchQuery.trim()),
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
                              searchQuery.isNotEmpty || activeFilters.isFiltered
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
                    const _ContactsImportBanner(),
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
          isEvenRow: index.isEven,
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

const _filterMenuWidth = 172.0;
const _filterTriggerSize = 32.0;
const _filterCheckboxSize = 18.0;

class _PartyListHeader extends StatefulWidget {
  const _PartyListHeader({
    required this.activeFilters,
    required this.onFiltersChanged,
  });

  final PartyListFilters activeFilters;
  final ValueChanged<PartyListFilters> onFiltersChanged;

  @override
  State<_PartyListHeader> createState() => _PartyListHeaderState();
}

class _PartyListHeaderState extends State<_PartyListHeader> {
  final _menuController = MenuController();

  void _setFilters(PartyListFilters filters) {
    widget.onFiltersChanged(filters);
  }

  @override
  Widget build(BuildContext context) {
    final isFiltered = widget.activeFilters.isFiltered;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: const BoxDecoration(
        color: _tableHeaderBg,
        border: Border(bottom: BorderSide(color: listPanelCardBorder)),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text('Party Name', style: ListPanelStyles.listHeaderStyle),
          ),
          const SizedBox(
            width: 88,
            child: Text(
              'Amount',
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style: ListPanelStyles.listHeaderStyle,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          MenuAnchor(
            controller: _menuController,
            alignmentOffset: Offset(
              -_filterMenuWidth + _filterTriggerSize,
              4,
            ),
            crossAxisUnconstrained: false,
            style: MenuStyle(
              padding: const WidgetStatePropertyAll(EdgeInsets.zero),
              elevation: const WidgetStatePropertyAll(4),
              shadowColor: const WidgetStatePropertyAll(Colors.black26),
              surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
              backgroundColor: const WidgetStatePropertyAll(Colors.white),
              shape: WidgetStatePropertyAll(listPanelPopupMenuShape),
              minimumSize: const WidgetStatePropertyAll(
                Size(_filterMenuWidth, 0),
              ),
            ),
            menuChildren: [
              SizedBox(
                width: _filterMenuWidth,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _PartyFilterToggleTile(
                      label: PartyListFilter.all.label,
                      value: !isFiltered,
                      onChanged: (checked) {
                        if (checked) _setFilters(PartyListFilters.all);
                      },
                    ),
                    for (final filter in PartyListFilter.selectableValues)
                      _PartyFilterToggleTile(
                        label: filter.label,
                        value: widget.activeFilters.selected.contains(filter),
                        onChanged: (_) {
                          _setFilters(widget.activeFilters.toggle(filter));
                        },
                      ),
                  ],
                ),
              ),
            ],
            builder: (context, controller, child) {
              return IconButton(
                tooltip: 'Filter parties',
                constraints: const BoxConstraints(
                  minWidth: _filterTriggerSize,
                  minHeight: _filterTriggerSize,
                ),
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
                icon: AppFilterIcon(
                  color: isFiltered
                      ? AppColors.primary
                      : AppColors.textSecondary,
                  size: 20,
                ),
                onPressed: () {
                  if (controller.isOpen) {
                    controller.close();
                  } else {
                    controller.open();
                  }
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _PartyFilterToggleTile extends StatelessWidget {
  const _PartyFilterToggleTile({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: 6,
        ),
        child: Row(
          children: [
            SizedBox(
              width: _filterCheckboxSize,
              height: _filterCheckboxSize,
              child: Checkbox(
                value: value,
                onChanged: (checked) {
                  if (checked != null) onChanged(checked);
                },
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
                side: const BorderSide(color: Color(0xFFBDBDBD)),
                activeColor: AppColors.primary,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                label,
                style: listPanelPopupMenuItemStyle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PartyListTile extends StatelessWidget {
  const _PartyListTile({
    required this.party,
    required this.isSelected,
    required this.isEvenRow,
    required this.onTap,
  });

  final PartyModel party;
  final bool isSelected;
  final bool isEvenRow;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final amountColor = party.hasReceivable
        ? listPanelPositiveColor
        : party.hasPayable
        ? listPanelNegativeColor
        : AppColors.primary;
    final amountText = PartyModel.displayOutstanding(party.balance);
    final rowColor = isSelected
        ? listPanelSelectedRowColor
        : isEvenRow
        ? AppColors.surface
        : _zebraRowBg;

    return Material(
      color: rowColor,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: listPanelCardBorder)),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: 10,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  party.name,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: party.isActive
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              SizedBox(
                width: 88,
                child: Text(
                  amountText,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: amountColor,
                  ),
                  textAlign: TextAlign.right,
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

class _ContactsImportBanner extends StatelessWidget {
  const _ContactsImportBanner();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFE8F5E9),
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Import from contacts coming soon'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: listPanelCardBorder)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Easily convert your Phone contacts into parties',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: listPanelPositiveColor.withValues(alpha: 0.9),
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 18,
                color: listPanelPositiveColor.withValues(alpha: 0.9),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
