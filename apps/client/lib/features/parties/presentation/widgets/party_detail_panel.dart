import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/business/application/business_service.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/inventory_detail_header.dart';
import 'package:billing_baba/features/loyalty/application/loyalty_service.dart';
import 'package:billing_baba/features/loyalty/models/loyalty_dto.dart';
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

    if (LoyaltyRules.isEligibleParty(party)) {
      ref.watch(partyLoyaltyBalanceProvider(party.id));
    }

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

class _PartyDetailHeader extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final outstanding = ledgerAsync.maybeWhen(
      data: (ledger) => ledger.summary.outstanding,
      orElse: () => party.balance,
    );
    final showLoyalty = LoyaltyRules.shouldShowPartyLoyalty(
      party,
      outstanding: outstanding,
    );
    final loyaltyCache = showLoyalty
        ? ref.watch(partyLoyaltyBalanceCacheProvider)
        : null;
    final loyaltyAsync = showLoyalty
        ? ref.watch(partyLoyaltyBalanceProvider(party.id))
        : null;

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
      if (showLoyalty && loyaltyAsync != null)
        _MetaLine(
          label: 'Loyalty Points',
          value: _loyaltyDisplayValue(
            loyaltyAsync,
            cached: loyaltyCache?[party.id],
          ),
        ),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      party.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (showLoyalty) ...[
                      const SizedBox(height: AppSpacing.xs),
                      _PartyLoyaltyPointsBadge(party: party),
                    ],
                  ],
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

String _formatLoyaltyPoints(double value) {
  return value == value.roundToDouble()
      ? '${value.toInt()}'
      : value.toStringAsFixed(0);
}

const _loyaltyZeroLabel = '0 earned';

String _loyaltyBalanceSummary(PartyLoyaltyBalanceDto balance) {
  final earnedLabel = _formatLoyaltyPoints(balance.earnedPointsValue);
  final availableLabel = _formatLoyaltyPoints(balance.availablePoints);
  if (balance.availablePoints != balance.earnedPointsValue) {
    return '$earnedLabel earned · $availableLabel available';
  }
  return '$earnedLabel earned';
}

String _loyaltyDisplayValue(
  AsyncValue<PartyLoyaltyBalanceDto> balanceAsync, {
  PartyLoyaltyBalanceDto? cached,
}) {
  return balanceAsync.maybeWhen(
    data: _loyaltyBalanceSummary,
    orElse: () =>
        cached != null ? _loyaltyBalanceSummary(cached) : _loyaltyZeroLabel,
  );
}

class _PartyLoyaltyPointsBadge extends ConsumerStatefulWidget {
  const _PartyLoyaltyPointsBadge({required this.party});

  final PartyModel party;

  static const _badgeBackground = Color(0xFFFFF8E7);
  static const _badgeBorder = Color(0xFFFFE082);

  @override
  ConsumerState<_PartyLoyaltyPointsBadge> createState() =>
      _PartyLoyaltyPointsBadgeState();
}

class _PartyLoyaltyPointsBadgeState extends ConsumerState<_PartyLoyaltyPointsBadge> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.invalidate(partyLoyaltyBalanceProvider(widget.party.id));
    });
  }

  Widget _badgeShell({required Widget child}) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: _PartyLoyaltyPointsBadge._badgeBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _PartyLoyaltyPointsBadge._badgeBorder.withValues(alpha: 0.55),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: child,
      ),
    );
  }

  Widget _badgeText(String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '⭐',
          style: AppTypography.inter(fontSize: 12, height: 1.2),
        ),
        const SizedBox(width: 6),
        Text(
          'Loyalty Points',
          style: AppTypography.inter(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
            height: 1.2,
            letterSpacing: 0.15,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Text(
            '·',
            style: AppTypography.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
              height: 1.2,
            ),
          ),
        ),
        Text(
          value,
          style: AppTypography.inter(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            height: 1.2,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final balanceAsync = ref.watch(partyLoyaltyBalanceProvider(widget.party.id));
    final cached = ref.watch(partyLoyaltyBalanceCacheProvider)[widget.party.id];

    return _badgeShell(
      child: _badgeText(
        _loyaltyDisplayValue(balanceAsync, cached: cached),
      ),
    );
  }
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
