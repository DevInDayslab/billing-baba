import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/parties/application/parties_providers.dart';
import 'package:billing_baba/features/parties/application/party_error_mapper.dart';
import 'package:billing_baba/features/parties/application/party_service.dart';
import 'package:billing_baba/features/parties/models/party_model.dart';
import 'package:billing_baba/features/parties/presentation/mobile/widgets/party_card.dart';
import 'package:billing_baba/shared/widgets/app_error.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Party list embedded in the mobile home screen when Party Details is active.
///
/// Builds slivers so it shares the parent [CustomScrollView] — a nested
/// [ListView] inside [SliverFillRemaining] blocked outer scroll / load UX.
class MobileHomePartySection extends ConsumerWidget {
  const MobileHomePartySection({
    required this.searchQuery,
    required this.onSelectParty,
    super.key,
  });

  final String searchQuery;
  final ValueChanged<String> onSelectParty;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final partiesAsync = ref.watch(partyListProvider);
    final outstandingIndex = ref.watch(partyOutstandingIndexProvider).value;

    return partiesAsync.when(
      loading: () => const SliverFillRemaining(
        hasScrollBody: false,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => SliverFillRemaining(
        hasScrollBody: false,
        child: AppError(
          message: PartyErrorMapper.messageFor(error),
          onRetry: () => ref.read(partyListProvider.notifier).refresh(),
        ),
      ),
      data: (parties) {
        final filtered = _filterParties(parties, searchQuery);

        if (filtered.isEmpty) {
          return const SliverFillRemaining(
            hasScrollBody: false,
            child: MobileEmptyState(
              title: 'No parties found',
              message: 'Try a different search term.',
              icon: Icons.people_outline_rounded,
            ),
          );
        }

        // Bottom clearance for the Add Sale FAB lives on the parent home
        // scroll view so list rows remain visible behind/around the pill.
        return SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.lg,
            0,
          ),
          sliver: SliverList.separated(
            itemCount: filtered.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
            itemBuilder: (context, index) {
              final party = filtered[index];
              return MobilePartyCard(
                party: party,
                displayBalance: projectedPartyBalance(party, outstandingIndex),
                onTap: () => onSelectParty(party.id),
              );
            },
          ),
        );
      },
    );
  }
}

List<PartyModel> _filterParties(List<PartyModel> parties, String query) {
  final normalized = query.trim().toLowerCase();
  if (normalized.isEmpty) return parties;

  return parties.where((party) {
    final haystack = [
      party.name,
      party.phone,
      party.email,
      party.partyGroup,
    ].whereType<String>().join(' ').toLowerCase();
    return haystack.contains(normalized);
  }).toList();
}
