import 'dart:async';

import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/core/widgets/app_error.dart';
import 'package:billing_baba/core/widgets/mobile/mobile_app_bar.dart';
import 'package:billing_baba/core/widgets/mobile/mobile_empty_state.dart';
import 'package:billing_baba/core/widgets/mobile/mobile_icon_action_button.dart';
import 'package:billing_baba/features/parties/application/parties_providers.dart';
import 'package:billing_baba/features/parties/application/party_error_mapper.dart';
import 'package:billing_baba/features/parties/application/party_service.dart';
import 'package:billing_baba/features/parties/models/party_list_filter.dart';
import 'package:billing_baba/features/parties/models/party_model.dart';
import 'package:billing_baba/features/parties/presentation/desktop/widgets/add_party_dialog.dart';
import 'package:billing_baba/features/parties/presentation/mobile/application/mobile_party_list_controller.dart';
import 'package:billing_baba/features/parties/presentation/mobile/application/mobile_party_mock_data.dart';
import 'package:billing_baba/features/parties/presentation/mobile/party_detail_screen.dart';
import 'package:billing_baba/features/parties/presentation/mobile/widgets/party_card.dart';
import 'package:billing_baba/features/parties/presentation/mobile/widgets/party_filter_sheets.dart';
import 'package:billing_baba/features/parties/presentation/mobile/widgets/party_list_toolbar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    await ref.read(partyListProvider.notifier).refresh();
    if (!mounted) return;
    final service = await ref.read(partyServiceProvider.future);
    final filter = service.readRememberedListFilter();
    if (filter != null && mounted) {
      ref.read(partyListFilterProvider.notifier).filter = filter;
    }
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

  List<PartyModel> _resolveParties(List<PartyModel> parties) {
    if (parties.isNotEmpty) return parties;
    // TODO(mobile): Remove mock fallback once party data is available on all devices.
    if (kDebugMode) return MobilePartyMockData.parties;
    return parties;
  }

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
        actions: [
          MobileIconActionButton(
            icon: Icons.person_add_alt_1_outlined,
            tooltip: 'Add party',
            onPressed: () => showAddPartyDialog(context),
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
        onAddParty: () => showAddPartyDialog(context),
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
    final parties = resolveParties(ref.watch(partiesListProvider));
    final sortedParties = sortMobileParties(
      parties,
      ref.watch(mobilePartyListSortProvider),
    );
    final activeFilter = ref.watch(partyListFilterProvider);
    final sortState = ref.watch(mobilePartyListSortProvider);
    final searchQuery = ref.watch(partySearchQueryProvider);
    final usingMock =
        partiesAsync.maybeWhen(
          data: (items) => items.isEmpty,
          orElse: () => false,
        ) &&
        kDebugMode &&
        sortedParties.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MobilePartyListToolbar(
          searchController: searchController,
          onSearchChanged: onSearchChanged,
          activeFilter: activeFilter,
          sortState: sortState,
          onAddParty: onAddParty,
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
        if (usingMock)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Text(
              'Showing demo parties — connect to load live data.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        Expanded(
          child: partiesAsync.when(
            loading: () => parties.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : _PartyListView(
                    parties: sortedParties,
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
                  icon: Icons.people_outline_rounded,
                  actionLabel: 'Add Party',
                  onAction: onAddParty,
                );
              }

              return _PartyListView(
                parties: sortedParties,
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
    required this.onRefresh,
    required this.onSelectParty,
    required this.isFiltered,
  });

  final List<PartyModel> parties;
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
            onTap: () => onSelectParty(party.id),
          );
        },
      ),
    );
  }
}
