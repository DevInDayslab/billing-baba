import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/business/application/business_service.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/inventory_detail_header.dart';
import 'package:billing_baba/features/parties/application/party_error_mapper.dart';
import 'package:billing_baba/features/parties/application/party_ledger_service.dart';
import 'package:billing_baba/features/parties/application/party_service.dart';
import 'package:billing_baba/features/parties/models/party_ledger_model.dart';
import 'package:billing_baba/features/parties/models/party_model.dart';
import 'package:billing_baba/features/parties/presentation/widgets/party_actions_menu_button.dart';
import 'package:billing_baba/features/parties/presentation/widgets/party_ledger_transactions_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PartyDetailPanel extends ConsumerWidget {
  const PartyDetailPanel({
    required this.partyId,
    this.onBack,
    super.key,
  });

  final String partyId;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(partyDetailProvider(partyId));
    final usingCache = ref.watch(partiesUsingCacheProvider);

    return detailAsync.when(
      loading: () => const _PartyDetailLoading(),
      error: (error, _) => _PartyDetailError(
        message: PartyErrorMapper.messageFor(error),
        onRetry: () => ref.invalidate(partyDetailProvider(partyId)),
      ),
      data: (party) => Column(
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
          Expanded(
            child: _PartyDetailContent(
              party: party,
              onBack: onBack,
            ),
          ),
        ],
      ),
    );
  }
}

class _PartyDetailContent extends ConsumerWidget {
  const _PartyDetailContent({
    required this.party,
    this.onBack,
  });

  final PartyModel party;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ledgerAsync = ref.watch(partyLedgerProvider(party.id));
    final businessName = ref.watch(sidebarBusinessProvider).name;
    final transactionsAsync = ledgerAsync.whenData(
      (ledger) => ledger.transactions,
    );

    return Column(
      key: ValueKey(party.id),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _PartyDetailHeader(
          party: party,
          ledgerAsync: ledgerAsync,
          businessName: businessName,
          onBack: onBack,
        ),
        const Divider(height: 1, thickness: 1),
        Expanded(
          child: ledgerAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => _PartyDetailError(
              message: PartyErrorMapper.messageFor(error),
              onRetry: () => ref.invalidate(partyLedgerProvider(party.id)),
            ),
            data: (_) => PartyLedgerTransactionsSection(
              transactionsAsync: transactionsAsync,
              onRefresh: () async =>
                  ref.invalidate(partyLedgerProvider(party.id)),
            ),
          ),
        ),
      ],
    );
  }
}

class _PartyDetailHeader extends StatelessWidget {
  const _PartyDetailHeader({
    required this.party,
    required this.ledgerAsync,
    required this.businessName,
    this.onBack,
  });

  final PartyModel party;
  final AsyncValue<PartyLedgerModel> ledgerAsync;
  final String businessName;
  final VoidCallback? onBack;

  String _billingAddress() {
    final primary = party.billingAddress.trim();
    if (primary.isNotEmpty) return primary;

    final parts = [
      party.addressLine,
      party.city,
      party.state,
      party.pincode,
    ].where((part) => part.trim().isNotEmpty);

    return parts.join(', ');
  }

  String _outstandingBalance() {
    return ledgerAsync.maybeWhen(
      data: (ledger) => PartyModel.displayOutstanding(ledger.summary.outstanding),
      orElse: () => PartyModel.displayOutstanding(party.balance),
    );
  }

  String _creditLimit() {
    return ledgerAsync.maybeWhen(
      data: (ledger) {
        final limit = ledger.summary.creditLimit;
        if (limit != null) {
          return PartyModel.formatCurrency(limit);
        }
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
  }

  @override
  Widget build(BuildContext context) {
    final leftLines = [
      _MetaLine(
        label: 'Phone Number',
        value: PartyModel.displayOrDash(party.phone),
      ),
      _MetaLine(
        label: 'Email',
        value: PartyModel.displayOrDash(party.email),
      ),
      _MetaLine(
        label: 'GSTIN',
        value: PartyModel.displayOrDash(party.gstin),
      ),
      _MetaLine(
        label: 'Billing Address',
        value: PartyModel.displayOrDash(_billingAddress()),
      ),
    ];

    final rightLines = [
      _MetaLine(label: 'Party Type', value: party.partyTypeLabel),
      _MetaLine(
        label: 'Business Name',
        value: PartyModel.displayOrDash(businessName),
      ),
      _MetaLine(label: 'Credit Limit', value: _creditLimit()),
      _MetaLine(label: 'Outstanding Balance', value: _outstandingBalance()),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.xs,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (onBack != null) ...[
                IconButton(
                  onPressed: onBack,
                  icon: const Icon(Icons.arrow_back),
                  tooltip: 'Back to list',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
              ],
              Expanded(
                child: Text(
                  party.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              PartyActionsMenuButton(party: party),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final line in leftLines)
                      InventoryDetailMetaLine(
                        label: line.label,
                        value: line.value,
                      ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final line in rightLines)
                      InventoryDetailMetaLine(
                        label: line.label,
                        value: line.value,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetaLine {
  const _MetaLine({required this.label, required this.value});

  final String label;
  final String value;
}

class _PartyDetailLoading extends StatelessWidget {
  const _PartyDetailLoading();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class _PartyDetailError extends StatelessWidget {
  const _PartyDetailError({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 32),
            const SizedBox(height: AppSpacing.sm),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.md),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
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
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          Icon(
            Icons.cloud_off_outlined,
            color: Colors.orange.shade800,
            size: 18,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Network unavailable. Showing cached data.',
              style: TextStyle(
                color: Colors.orange.shade900,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
