import 'dart:async';

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
class MobileHomePartySection extends ConsumerStatefulWidget {
  const MobileHomePartySection({
    required this.searchQuery,
    required this.onSelectParty,
    super.key,
  });

  final String searchQuery;
  final ValueChanged<String> onSelectParty;

  @override
  ConsumerState<MobileHomePartySection> createState() =>
      _MobileHomePartySectionState();
}

class _MobileHomePartySectionState
    extends ConsumerState<MobileHomePartySection> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final parties = ref.read(partiesListProvider);
      if (parties.isEmpty) {
        unawaited(ref.read(partyListProvider.notifier).refresh());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final partiesAsync = ref.watch(partyListProvider);
    final parties = _filterParties(
      ref.watch(partiesListProvider),
      widget.searchQuery,
    );

    return partiesAsync.when(
      loading: () => parties.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : _PartyList(
              parties: parties,
              onSelectParty: widget.onSelectParty,
            ),
      error: (error, _) => parties.isEmpty
          ? AppError(
              message: PartyErrorMapper.messageFor(error),
              onRetry: () =>
                  unawaited(ref.read(partyListProvider.notifier).refresh()),
            )
          : _PartyList(
              parties: parties,
              onSelectParty: widget.onSelectParty,
            ),
      data: (_) {
        if (parties.isEmpty) {
          return MobileEmptyState(
            title: 'No parties found',
            message: widget.searchQuery.trim().isEmpty
                ? 'Add a party to get started.'
                : 'Try a different search term.',
            icon: Icons.people_outline_rounded,
          );
        }
        return _PartyList(
          parties: parties,
          onSelectParty: widget.onSelectParty,
        );
      },
    );
  }
}

class _PartyList extends StatelessWidget {
  const _PartyList({
    required this.parties,
    required this.onSelectParty,
  });

  final List<PartyModel> parties;
  final ValueChanged<String> onSelectParty;

  @override
  Widget build(BuildContext context) {
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
