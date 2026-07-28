import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/core/widgets/mobile/mobile_empty_state.dart';
import 'package:billing_baba/features/parties/models/party_model.dart';
import 'package:billing_baba/features/parties/presentation/mobile/application/mobile_party_mock_data.dart';
import 'package:billing_baba/features/parties/presentation/mobile/widgets/party_card.dart';
import 'package:flutter/material.dart';

/// Party list embedded in the mobile home screen when Party Details is active.
class MobileHomePartySection extends StatelessWidget {
  const MobileHomePartySection({
    required this.searchQuery,
    required this.onSelectParty,
    super.key,
  });

  final String searchQuery;
  final ValueChanged<String> onSelectParty;

  @override
  Widget build(BuildContext context) {
    final parties = _filterParties(
      MobilePartyMockData.parties,
      searchQuery,
    );

    if (parties.isEmpty) {
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
      itemCount: parties.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        final party = parties[index];
        return MobilePartyCard(
          party: party,
          onTap: () => onSelectParty(party.id),
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
