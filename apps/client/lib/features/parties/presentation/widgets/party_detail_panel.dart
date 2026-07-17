import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/business/application/business_service.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/inventory_detail_header.dart';
import 'package:billing_baba/features/parties/application/party_error_mapper.dart';
import 'package:billing_baba/features/parties/application/party_ledger_service.dart';
import 'package:billing_baba/features/parties/application/party_service.dart';
import 'package:billing_baba/features/parties/models/party_ledger_model.dart';
import 'package:billing_baba/features/parties/models/party_model.dart';
import 'package:billing_baba/features/parties/presentation/widgets/party_actions.dart';
import 'package:billing_baba/features/parties/presentation/widgets/party_actions_menu_button.dart';
import 'package:billing_baba/features/parties/presentation/widgets/party_ledger_transactions_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
    final ledgerAsync = ref.watch(partyTimelineProvider(party.id));
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
              onRetry: () => ref.invalidate(partyTimelineProvider(party.id)),
            ),
            data: (_) => PartyLedgerTransactionsSection(
              transactionsAsync: transactionsAsync,
              onRefresh: () async =>
                  ref.invalidate(partyTimelineProvider(party.id)),
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
            spacing: AppSpacing.sm,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                child: Row(
                  children: [
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 3),
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                party.name,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: party.isActive
                                      ? AppColors.textPrimary
                                      : AppColors.textSecondary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (!party.isActive) ...[
                              const SizedBox(width: AppSpacing.sm),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Inactive',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    IconButton(
                      onPressed: () => PartyActions.edit(context, ref, party),
                      icon: const Icon(Icons.edit_outlined, size: 20),
                      tooltip: 'Edit party',
                      color: AppColors.textSecondary,
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                      constraints: const BoxConstraints(
                        minWidth: 28,
                        minHeight: 28,
                      ),
                    ),
                  ],
                ),
              ),  
              _PartyHeaderActionIcon(
                iconWidget: const FaIcon(
                  FontAwesomeIcons.commentDots,
                  size: 20,
                  color: Color.fromARGB(255, 240, 180, 64),
                ),
                tooltip: 'Send Payment Reminder SMS to party',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Messaging coming soon'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
              _PartyHeaderActionIcon(
                iconWidget: const FaIcon(
                  FontAwesomeIcons.whatsapp,
                  size: 20,
                  color: Color(0xFF25D366),
                ),
                tooltip: 'Send Payment Reminder WhatsApp to party',
                onPressed: party.phone.trim().isEmpty
                    ? null
                    : () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Call ${party.phone}'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
              ),
              _PartyHeaderActionIcon(
                iconWidget: const FaIcon(
                  FontAwesomeIcons.clock,
                  size: 18,
                  color: Color(0xFF4095F0),
                ),
                tooltip: 'Set Reminder',
                 onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Messaging coming soon'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
              PartyActionsMenuButton(party: party),
            ],
          ),
          const Divider(height: 20, thickness: 1, color: Color.fromARGB(98, 117, 117, 117)),

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

class _PartyHeaderActionIcon extends StatelessWidget {
  const _PartyHeaderActionIcon({
    required this.tooltip,
    this.icon,
    this.iconWidget,
    this.color = AppColors.textSecondary,
    this.onPressed,
  }) : assert(
         icon != null || iconWidget != null,
         'Either icon or iconWidget must be provided',
       );

  final String tooltip;
  final IconData? icon;
  final Widget? iconWidget;
  final Color? color;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: iconWidget ?? Icon(icon, size: 20),
      tooltip: tooltip,
      color: iconWidget == null ? color : null,
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
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
