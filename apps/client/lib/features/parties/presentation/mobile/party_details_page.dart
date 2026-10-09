import 'dart:async';

import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/dashboard/presentation/mobile/application/mobile_home_controller.dart';
import 'package:billing_baba/features/parties/application/parties_providers.dart';
import 'package:billing_baba/features/parties/application/party_error_mapper.dart';
import 'package:billing_baba/features/parties/application/party_service.dart';
import 'package:billing_baba/features/parties/parties_navigation.dart';
import 'package:billing_baba/features/parties/models/party_list_filter.dart';
import 'package:billing_baba/features/parties/models/party_model.dart';
import 'package:billing_baba/features/parties/presentation/desktop/widgets/add_party_dialog.dart';
import 'package:billing_baba/features/parties/presentation/mobile/application/mobile_party_list_controller.dart';
import 'package:billing_baba/features/parties/presentation/mobile/party_detail_screen.dart';
import 'package:billing_baba/features/parties/presentation/mobile/widgets/party_card.dart';
import 'package:billing_baba/features/parties/presentation/mobile/widgets/party_filter_sheets.dart';
import 'package:billing_baba/features/parties/presentation/mobile/widgets/party_list_toolbar.dart';
import 'package:billing_baba/shared/widgets/app_error.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_app_bar.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_empty_state.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_icon_action_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Mobile parties experience — list, search, filter, sort, and detail.
class MobilePartyDetailsPage extends ConsumerStatefulWidget {
  const MobilePartyDetailsPage({super.key});

  @override
  ConsumerState<MobilePartyDetailsPage> createState() =>
      _MobilePartyDetailsPageState();
}

class _MobilePartyDetailsPageState
    extends ConsumerState<MobilePartyDetailsPage> {
  late final TextEditingController _searchController;
  ProviderContainer? _container;
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: ref.read(partySearchQueryProvider),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_initialize());
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _container = ProviderScope.containerOf(context);
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _handOffSearchToHomeAndClear();
    _searchController.dispose();
    super.dispose();
  }

  /// Home embeds the same [partyListProvider]; hand the query to Home's search
  /// bar (so it can be cleared) and reset the shared list filter.
  void _handOffSearchToHomeAndClear() {
    final container = _container;
    if (container == null) return;

    final partyQuery = container.read(partySearchQueryProvider).trim();
    final backendQuery = container.read(partyBackendSearchProvider).trim();
    final active = partyQuery.isNotEmpty ? partyQuery : backendQuery;
    if (active.isEmpty) return;

    container.read(mobileHomeControllerProvider.notifier).setSearch(active);
    container.read(partySearchQueryProvider.notifier).query = '';
    container.read(partyBackendSearchProvider.notifier).query = '';
    unawaited(
      container.read(partyListProvider.notifier).refresh(searchQuery: ''),
    );
  }

  Future<void> _initialize() async {
    final current = ref.read(partyListFilterProvider);
    if (PartiesNavigation.isDashboardBalanceFilter(current)) {
      await ref.read(partyListProvider.notifier).refresh(filter: current);
      return;
    }

    final service = await ref.read(partyServiceProvider.future);
    final remembered = service.readRememberedListFilter();
    final filter = PartiesNavigation.filterForPageRestore(remembered);
    if (mounted) {
      ref.read(partyListFilterProvider.notifier).filter = filter;
    }
    await ref.read(partyListProvider.notifier).refresh(filter: filter);
  }

  void _onSearchChanged(String query) {
    ref.read(partySearchQueryProvider.notifier).query = query;
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
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

  void _selectParty(String partyId) {
    ref.read(selectedPartyIdProvider.notifier).selected = partyId;
    unawaited(
      ref
          .read(partyServiceProvider.future)
          .then(
            (service) => service.rememberSelectedParty(partyId),
          ),
    );
  }

  void _clearSelection() {
    ref.read(selectedPartyIdProvider.notifier).selected = null;
    unawaited(
      ref
          .read(partyServiceProvider.future)
          .then(
            (service) => service.rememberSelectedParty(null),
          ),
    );
  }

  List<PartyModel> _resolveParties(List<PartyModel> parties) => parties;

  @override
  Widget build(BuildContext context) {
    final selectedId = ref.watch(selectedPartyIdProvider);

    if (selectedId != null) {
      return ColoredBox(
        color: AppColors.background,
        child: MobilePartyDetailScreen(
          partyId: selectedId,
          onBack: _clearSelection,
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: MobileAppBar(
        title: 'Parties',
        showBusinessHeader: false,
        showNotification: false,
        showSettings: false,
        actions: [
          MobileIconActionButton(
            icon: LucideIcons.userPlus,
            tooltip: 'Add party',
            onPressed: () => showAddPartyEntry(context, ref),
          ),
        ],
      ),
      body: _PartyListBody(
        searchController: _searchController,
        onSearchChanged: _onSearchChanged,
        onRefresh: _onRefresh,
        onSelectParty: _selectParty,
        resolveParties: _resolveParties,
        onFilterSelected: _onFilterSelected,
        onAddParty: () => showAddPartyEntry(context, ref),
      ),
    );
  }
}

class _PartyListBody extends ConsumerWidget {
  const _PartyListBody({
    required this.searchController,
    required this.onSearchChanged,
    required this.onRefresh,
    required this.onSelectParty,
    required this.resolveParties,
    required this.onFilterSelected,
    required this.onAddParty,
  });

  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final Future<void> Function() onRefresh;
  final ValueChanged<String> onSelectParty;
  final List<PartyModel> Function(List<PartyModel>) resolveParties;
  final Future<void> Function(PartyListFilter) onFilterSelected;
  final VoidCallback onAddParty;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final partiesAsync = ref.watch(partyListProvider);
    final outstandingIndex = ref.watch(partyOutstandingIndexProvider).value;
    final parties = resolveParties(ref.watch(partiesListProvider));
    final sortedParties = sortMobileParties(
      parties,
      ref.watch(mobilePartyListSortProvider),
      outstandingIndex: outstandingIndex,
    );
    final activeFilter = ref.watch(partyListFilterProvider);
    final sortState = ref.watch(mobilePartyListSortProvider);
    final searchQuery = ref.watch(partySearchQueryProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MobilePartyListToolbar(
          searchController: searchController,
          onSearchChanged: onSearchChanged,
          activeFilter: activeFilter,
          sortState: sortState,
          onFilterTap: () async {
            final result = await showPartyFilterSheet(
              context: context,
              selected: activeFilter,
            );
            if (result != null) await onFilterSelected(result);
          },
          onSortTap: () async {
            final result = await showPartySortSheet(
              context: context,
              selected: sortState,
            );
            if (result != null) {
              ref
                  .read(mobilePartyListSortProvider.notifier)
                  .applySelection(
                    column: result.column,
                    direction: result.direction,
                  );
            }
          },
        ),
        Expanded(
          child: partiesAsync.when(
            loading: () => parties.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : _PartyListView(
                    parties: sortedParties,
                    outstandingIndex: outstandingIndex,
                    onRefresh: onRefresh,
                    onSelectParty: onSelectParty,
                    isFiltered:
                        activeFilter != PartyListFilter.all ||
                        searchQuery.isNotEmpty,
                  ),
            error: (error, _) => AppError(
              message: PartyErrorMapper.messageFor(error),
              onRetry: () => ref.invalidate(partyListProvider),
            ),
            data: (_) {
              if (sortedParties.isEmpty) {
                return MobileEmptyState(
                  title: 'No parties found',
                  message:
                      activeFilter != PartyListFilter.all ||
                          searchQuery.isNotEmpty
                      ? 'Try changing your search or filter.'
                      : 'Add your first party to get started.',
                  icon: LucideIcons.users,
                  actionLabel: 'Add Party',
                  onAction: onAddParty,
                );
              }

              return _PartyListView(
                parties: sortedParties,
                outstandingIndex: outstandingIndex,
                onRefresh: onRefresh,
                onSelectParty: onSelectParty,
                isFiltered:
                    activeFilter != PartyListFilter.all ||
                    searchQuery.isNotEmpty,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _PartyListView extends StatelessWidget {
  const _PartyListView({
    required this.parties,
    required this.outstandingIndex,
    required this.onRefresh,
    required this.onSelectParty,
    required this.isFiltered,
  });

  final List<PartyModel> parties;
  final Map<String, double>? outstandingIndex;
  final Future<void> Function() onRefresh;
  final ValueChanged<String> onSelectParty;
  final bool isFiltered;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.xl,
        ),
        itemCount: parties.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
        itemBuilder: (context, index) {
          final party = parties[index];
          return MobilePartyCard(
            party: party,
            displayBalance: projectedPartyBalance(party, outstandingIndex),
            onTap: () => onSelectParty(party.id),
          );
        },
      ),
    );
  }
}
