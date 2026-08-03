import 'package:billing_baba/core/network/offline_ui_messages.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/business/application/business_service.dart';
import 'package:billing_baba/features/collaboration/application/permission_service_provider.dart';
import 'package:billing_baba/features/collaboration/domain/models/permission_module.dart';
import 'package:billing_baba/features/hidden_ledger/presentation/desktop/widgets/hidden_ledger_history_section.dart';
import 'package:billing_baba/features/hidden_ledger/presentation/desktop/widgets/hidden_ledger_summary_tile.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/inventory_detail_header.dart';
import 'package:billing_baba/features/loyalty/application/loyalty_service.dart';
import 'package:billing_baba/features/loyalty/models/loyalty_dto.dart';
import 'package:billing_baba/features/parties/application/party_error_mapper.dart';
import 'package:billing_baba/features/parties/application/party_ledger_service.dart';
import 'package:billing_baba/features/parties/application/party_reminder_schedule_provider.dart';
import 'package:billing_baba/features/parties/application/party_service.dart';
import 'package:billing_baba/features/parties/models/party_ledger_model.dart';
import 'package:billing_baba/features/parties/models/party_model.dart';
import 'package:billing_baba/features/parties/presentation/desktop/widgets/party_actions.dart';
import 'package:billing_baba/features/parties/presentation/desktop/widgets/party_actions_menu_button.dart';
import 'package:billing_baba/features/parties/presentation/desktop/widgets/party_avatar.dart';
import 'package:billing_baba/features/parties/presentation/desktop/widgets/party_ledger_transactions_section.dart';
import 'package:billing_baba/features/parties/presentation/desktop/widgets/party_profile_image_preview_dialog.dart';
import 'package:billing_baba/features/parties/presentation/desktop/widgets/party_whatsapp_actions.dart';
import 'package:billing_baba/features/parties/repositories/party_reminder_schedule_repository.dart';
import 'package:billing_baba/shared/media/image_display_context.dart';
import 'package:billing_baba/shared/widgets/app_ellipsis_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

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
      data: (party) {
        // Prefer the list row's profile image when it is newer (instant upload).
        final listParty = ref
            .watch(partyListProvider)
            .asData
            ?.value
            .where((item) => item.id == party.id)
            .firstOrNull;
        final imageUrl = listParty?.profileImageUrl ?? party.profileImageUrl;
        final mediaId =
            listParty?.profileMediaAssetId ?? party.profileMediaAssetId;
        final displayParty = party.copyWith(
          profileImageUrl: imageUrl,
          profileMediaAssetId: mediaId,
          clearProfileImage: imageUrl == null && mediaId == null,
        );

        return Column(
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
                party: displayParty,
                onBack: onBack,
              ),
            ),
          ],
        );
      },
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
    final canViewHiddenLedger =
        ref.watch(permissionServiceProvider).canViewHiddenLedger;
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
        if (canViewHiddenLedger)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              0,
            ),
            child: HiddenLedgerSummaryTile(partyId: party.id),
          ),
        if (canViewHiddenLedger) HiddenLedgerHistorySection(partyId: party.id),
        const Divider(height: 1, thickness: 1),
        Expanded(
          child: ledgerAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => _PartyDetailError(
              message: PartyErrorMapper.messageFor(error),
              onRetry: OfflineUiMessages.isOfflineError(error)
                  ? null
                  : () => ref.invalidate(partyTimelineProvider(party.id)),
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
      data: (ledger) =>
          PartyModel.displayOutstanding(ledger.summary.outstanding),
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
    final permissions = ref.watch(permissionServiceProvider);
    final canEditParty = permissions.canEdit(PermissionModule.party);
    final canShareMessaging =
        permissions.canShare(PermissionModule.party) ||
        permissions.canShare(PermissionModule.sale);
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
        value: PartyModel.displayPhones(party),
      ),
      if (party.legalName.trim().isNotEmpty)
        _MetaLine(
          label: 'Legal Name',
          value: PartyModel.displayOrDash(party.legalName),
        ),
      if (party.alias.trim().isNotEmpty)
        _MetaLine(
          label: 'Alias',
          value: PartyModel.displayOrDash(party.alias),
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
      if (party.partyGroup.trim().isNotEmpty)
        _MetaLine(
          label: 'Party Group',
          value: PartyModel.displayOrDash(party.partyGroup),
        ),
      if (party.areaCode.trim().isNotEmpty)
        _MetaLine(
          label: 'Area Code',
          value: PartyModel.displayOrDash(party.areaCode),
        ),
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
              PartyAvatar(
                key: ValueKey(
                  'party-detail-avatar-${party.id}-${party.profileMediaAssetId ?? party.profileImageUrl ?? 'none'}',
                ),
                name: party.name,
                seed: party.id,
                partyId: party.id,
                diameter: 56,
                displayContext: ImageDisplayContext.detail,
                profileImageUrl: party.profileImageUrl,
                profileMediaAssetId: party.profileMediaAssetId,
                onTap: () {
                  final url = party.profileImageUrl?.trim();
                  if (url != null && url.isNotEmpty) {
                    showPartyProfileImagePreviewDialog(
                      context: context,
                      imageUrl: url,
                      mediaAssetId: party.profileMediaAssetId,
                      onReplace: canEditParty
                          ? () => PartyActions.edit(context, ref, party)
                          : null,
                      onRemove: canEditParty
                          ? () => PartyActions.edit(context, ref, party)
                          : null,
                    );
                    return;
                  }
                  if (canEditParty) {
                    PartyActions.edit(context, ref, party);
                  }
                },
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Row(
                            children: [
                              Flexible(
                                child: AppTruncatedText(
                                  party.name,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: party.isActive
                                        ? AppColors.textPrimary
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              ),
                              if (canEditParty)
                                _PartyHeaderActionIcon(
                                  icon: Icons.edit_outlined,
                                  tooltip: 'Edit party',
                                  onPressed: () =>
                                      PartyActions.edit(context, ref, party),
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
                      ],
                    ),
                    if (showLoyalty) ...[
                      const SizedBox(height: AppSpacing.xs),
                      _PartyLoyaltyPointsBadge(party: party),
                    ],
                  ],
                ),
              ),
              _PartyHeaderActionIcon(
                iconWidget: FaIcon(
                  FontAwesomeIcons.commentDots,
                  size: 20,
                  color: canShareMessaging
                      ? const Color.fromARGB(255, 240, 180, 64)
                      : const Color(0x66F0B440),
                ),
                tooltip: canShareMessaging
                    ? 'Send payment reminder (SMS)'
                    : 'SMS — no share permission',
                onPressed: !canShareMessaging
                    ? null
                    : () => PartyWhatsAppActions.sendPaymentReminderNow(
                        context,
                        ref,
                        party,
                        outstanding: outstanding,
                      ),
              ),
              _PartyHeaderActionIcon(
                iconWidget: FaIcon(
                  FontAwesomeIcons.whatsapp,
                  size: 20,
                  color: canShareMessaging
                      ? const Color(0xFF25D366)
                      : const Color(0x6625D366),
                ),
                tooltip: canShareMessaging
                    ? 'Send payment reminder (WhatsApp)'
                    : 'WhatsApp — no share permission',
                onPressed: !canShareMessaging
                    ? null
                    : () => PartyWhatsAppActions.sendPaymentReminderNow(
                        context,
                        ref,
                        party,
                        outstanding: outstanding,
                      ),
              ),
              _PartyHeaderActionIcon(
                iconWidget: FaIcon(
                  FontAwesomeIcons.clock,
                  size: 18,
                  color: canShareMessaging
                      ? const Color(0xFF4095F0)
                      : const Color(0x664095F0),
                ),
                tooltip: canShareMessaging
                    ? 'Set Reminder'
                    : 'Reminder — no share permission',
                onPressed: !canShareMessaging
                    ? null
                    : () => PartyWhatsAppActions.showReminderDialog(
                        context,
                        ref,
                        party,
                        outstanding: outstanding,
                      ),
              ),
              PartyActionsMenuButton(party: party),
            ],
          ),
          Builder(
            builder: (context) {
              final next = ref.watch(partyNextReminderProvider(party.id));
              if (next == null) return const SizedBox.shrink();
              final dateLabel = DateFormat(
                'dd MMM yyyy',
              ).format(next.nextReminderAt);
              final freqSuffix = switch (next.frequency) {
                PartyReminderFrequency.once => '',
                PartyReminderFrequency.weekly => ' (Weekly)',
                PartyReminderFrequency.monthly => ' (Monthly)',
              };
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Text(
                  'Next Reminder at $dateLabel$freqSuffix',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            },
          ),
          const Divider(
            height: 20,
            thickness: 1,
            color: Color.fromARGB(98, 117, 117, 117),
          ),

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
    this.onPressed,
  }) : assert(
         icon != null || iconWidget != null,
         'Either icon or iconWidget must be provided',
       );

  final String tooltip;
  final IconData? icon;
  final Widget? iconWidget;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: iconWidget ?? Icon(icon, size: 20),
      tooltip: tooltip,
      color: iconWidget == null ? AppColors.textSecondary : null,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(
        minWidth: kMinInteractiveDimension,
        minHeight: kMinInteractiveDimension,
      ),
    );
  }
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

class _PartyLoyaltyPointsBadgeState
    extends ConsumerState<_PartyLoyaltyPointsBadge> {
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
    final balanceAsync = ref.watch(
      partyLoyaltyBalanceProvider(widget.party.id),
    );
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
    this.onRetry,
  });

  final String message;
  final VoidCallback? onRetry;

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
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.md),
              FilledButton(onPressed: onRetry, child: const Text('Retry')),
            ],
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
              'Working offline · Showing locally synchronized data.',
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
