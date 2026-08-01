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
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => AppError(
        message: PartyErrorMapper.messageFor(error),
        onRetry: () => ref.read(partyListProvider.notifier).refresh(),
      ),
      data: (parties) {
        final filtered = _filterParties(parties, searchQuery);

        if (filtered.isEmpty) {
          return const MobileEmptyState(
            title: 'No parties found',
            message: 'Try a different search term.',
            icon: Icons.people_outline_rounded,
          );
        }

        return ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.lg,
            AppSpacing.md,
          ),
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
