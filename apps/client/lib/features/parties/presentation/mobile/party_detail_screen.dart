import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/parties/application/party_error_mapper.dart';
import 'package:billing_baba/features/parties/application/party_ledger_service.dart';
import 'package:billing_baba/features/parties/application/party_service.dart';
import 'package:billing_baba/features/parties/models/party_model.dart';
import 'package:billing_baba/features/parties/presentation/desktop/widgets/party_actions.dart';
import 'package:billing_baba/features/parties/presentation/mobile/application/mobile_party_mock_data.dart';
import 'package:billing_baba/features/parties/presentation/mobile/widgets/party_detail_header.dart';
import 'package:billing_baba/features/parties/presentation/mobile/widgets/party_more_actions_sheet.dart';
import 'package:billing_baba/features/parties/presentation/mobile/widgets/party_quick_actions.dart';
import 'package:billing_baba/features/parties/presentation/mobile/widgets/party_transaction_settings_panel.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_icon_action_button.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_list_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Mobile party detail view (info, quick actions, transaction settings).
class MobilePartyDetailScreen extends ConsumerWidget {
  const MobilePartyDetailScreen({
    required this.partyId,
    required this.onBack,
    super.key,
  });

  final String partyId;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (partyId.startsWith('mock-party-')) {
      final party = MobilePartyMockData.parties
          .where((item) => item.id == partyId)
          .firstOrNull;
      if (party != null) {
        return _PartyDetailBody(party: party, onBack: onBack);
      }
    }

    final detailAsync = ref.watch(partyDetailProvider(partyId));

    return detailAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => _PartyDetailError(
        message: PartyErrorMapper.messageFor(error),
        onRetry: () => ref.invalidate(partyDetailProvider(partyId)),
        onBack: onBack,
      ),
      data: (party) => _PartyDetailBody(
        party: party,
        onBack: onBack,
      ),
    );
  }
}

class _PartyDetailBody extends ConsumerWidget {
  const _PartyDetailBody({
    required this.party,
    required this.onBack,
  });

  final PartyModel party;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ledgerAsync = ref.watch(partyTimelineProvider(party.id));
    final outstanding = ledgerAsync.maybeWhen(
      data: (ledger) => ledger.summary.outstanding,
      orElse: () => party.balance,
    );
    final outstandingLabel = ledgerAsync.maybeWhen(
      data: (ledger) =>
          PartyModel.displayOutstanding(ledger.summary.outstanding),
      orElse: () => PartyModel.displayOutstanding(party.balance),
    );
    final creditLimitLabel = ledgerAsync.maybeWhen(
      data: (ledger) {
        final limit = ledger.summary.creditLimit;
        if (limit != null) return PartyModel.formatCurrency(limit);
        return PartyModel.displayCreditLimit(
          hasCustomCreditLimit: party.hasCustomCreditLimit,
          creditLimit: party.creditLimit,
        );
      },
      orElse: () => PartyModel.displayCreditLimit(
        hasCustomCreditLimit: party.hasCustomCreditLimit,
        creditLimit: party.creditLimit,
      ),
    );

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: Row(
            children: [
              IconButton(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back_rounded),
                tooltip: 'Back',
              ),
              Expanded(
                child: Text(
                  'Party Details',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              MobileIconActionButton(
                icon: Icons.edit_outlined,
                tooltip: 'Edit party',
                onPressed: () => PartyActions.edit(context, ref, party),
              ),
              MobileIconActionButton(
                icon: Icons.more_horiz_rounded,
                tooltip: 'More actions',
                onPressed: () => showPartyMoreActionsSheet(
                  context: context,
                  ref: ref,
                  party: party,
                  outstanding: outstanding,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(partyDetailProvider(party.id));
              ref.invalidate(partyTimelineProvider(party.id));
              await ref.read(partyDetailProvider(party.id).future);
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                MobilePartyDetailHeader(
                  party: party,
                  outstandingLabel: outstandingLabel,
                  creditLimitLabel: creditLimitLabel,
                  onAvatarTap: () => PartyActions.edit(context, ref, party),
                ),
                const SizedBox(height: AppSpacing.md),
                MobilePartyQuickActions(
                  party: party,
                  outstanding: outstanding,
                ),
                const SizedBox(height: AppSpacing.lg),
                MobilePartyTransactionSettingsPanel(
                  party: party,
                  outstandingLabel: outstandingLabel,
                  creditLimitLabel: creditLimitLabel,
                ),
                MobileListSection(
                  title: 'Party Info',
                  children: [
                    _InfoRow(
                      label: 'GSTIN',
                      value: PartyModel.displayOrDash(party.gstin),
                    ),
                    _InfoRow(
                      label: 'Email',
                      value: PartyModel.displayOrDash(party.email),
                    ),
                    _InfoRow(
                      label: 'Billing Address',
                      value: PartyModel.displayOrDash(_billingAddress(party)),
                    ),
                    if (party.partyGroup.trim().isNotEmpty)
                      _InfoRow(
                        label: 'Party Group',
                        value: party.partyGroup,
                      ),
                  ],
                ),
                // TODO(mobile): Transaction list will be added in a later phase.
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Text(
                    'Transactions will appear here in a future update.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _billingAddress(PartyModel party) {
    final primary = party.billingAddress.trim();
    if (primary.isNotEmpty) return primary;

    return [
      party.addressLine,
      party.city,
      party.state,
      party.pincode,
    ].where((part) => part.trim().isNotEmpty).join(', ');
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PartyDetailError extends StatelessWidget {
  const _PartyDetailError({
    required this.message,
    required this.onRetry,
    required this.onBack,
  });

  final String message;
  final VoidCallback onRetry;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_rounded),
          ),
        ),
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(message, textAlign: TextAlign.center),
                  const SizedBox(height: AppSpacing.md),
                  FilledButton(
                    onPressed: onRetry,
                    child: const Text('Try again'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
