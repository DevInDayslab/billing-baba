import 'package:billing_baba/core/routing/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/collaboration/application/permission_service_provider.dart';
import 'package:billing_baba/features/hidden_ledger/application/hidden_ledger_service.dart';
import 'package:billing_baba/features/parties/models/party_model.dart';
import 'package:billing_baba/features/parties/utils/walk_in_party.dart';
import 'package:billing_baba/features/pos/presentation/desktop/widgets/pos_styles.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

const _hiddenAccent = Color(0xFF7C3AED);
const _hiddenBg = Color(0xFFF3E8FF);
const _outstandingAccent = Color(0xFFC62828);
const _outstandingBg = Color(0xFFFFEBEE);

final _currency = NumberFormat.currency(
  locale: 'en_IN',
  symbol: '₹',
  decimalDigits: 2,
);

/// Compact Hidden Ledger + Outstanding row below the POS customer field.
class SaleInvoicePartyLedgerChips extends ConsumerWidget {
  const SaleInvoicePartyLedgerChips({
    required this.parties,
    required this.customerName,
    super.key,
  });

  final List<PartyModel> parties;
  final String? customerName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final party = _partyForCustomer(parties, customerName);
    if (party == null) {
      return const SizedBox.shrink();
    }

    final canViewHiddenLedger =
        ref.watch(permissionServiceProvider).canViewHiddenLedger;
    final hiddenSummary = canViewHiddenLedger
        ? ref.watch(partyHiddenLedgerSummaryProvider(party.id))
        : null;

    final hiddenBalance = hiddenSummary?.maybeWhen(
          data: (summary) => summary.hiddenLedgerBalance,
          orElse: () => party.unrecoveredAmount,
        ) ??
        party.unrecoveredAmount;

    final showHidden = canViewHiddenLedger && hiddenBalance > 0;
    final outstandingLabel = PartyModel.displayOutstanding(party.balance);

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xs),
      child: Row(
        children: [
          if (showHidden) ...[
            Expanded(
              child: _CompactLedgerChip(
                label: 'Hidden Ledger',
                amount: _currency.format(hiddenBalance),
                tooltip:
                    'Seller-only balance — not shown on customer bills or statements.',
                icon: LucideIcons.book,
                accent: _hiddenAccent,
                background: _hiddenBg,
                onTap: () => context.go(AppRoutes.partyHiddenLedger),
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
          ],
          Expanded(
            child: _CompactLedgerChip(
              label: 'Outstanding',
              amount: outstandingLabel,
              tooltip: 'Current party balance (receivable or payable).',
              icon: LucideIcons.wallet,
              accent: _outstandingAccent,
              background: _outstandingBg,
              showChevron: true,
              onTap: () => context.go(
                Uri(
                  path: AppRoutes.partyDetails,
                  queryParameters: {'partyId': party.id},
                ).toString(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static PartyModel? _partyForCustomer(
    List<PartyModel> parties,
    String? customerName,
  ) {
    final name = customerName?.trim();
    if (name == null || name.isEmpty || isWalkInCartCustomerName(name)) {
      return null;
    }
    return parties.firstWhereOrNull((party) => party.name.trim() == name);
  }
}

class _CompactLedgerChip extends StatelessWidget {
  const _CompactLedgerChip({
    required this.label,
    required this.amount,
    required this.tooltip,
    required this.icon,
    required this.accent,
    required this.background,
    required this.onTap,
    this.showChevron = false,
  });

  final String label;
  final String amount;
  final String tooltip;
  final IconData icon;
  final Color accent;
  final Color background;
  final VoidCallback onTap;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
      fontSize: 10,
      color: AppColors.textSecondary,
      height: 1.2,
    );
    final amountStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
      fontSize: 11,
      fontWeight: FontWeight.w700,
      color: accent,
      height: 1.2,
    );

    return Material(
      color: background,
      borderRadius: AppRadius.smBorder,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.smBorder,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xs,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            borderRadius: AppRadius.smBorder,
            border: Border.all(color: posCardBorder),
          ),
          child: Row(
            children: [
              Icon(icon, size: 13, color: accent),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: labelStyle,
                ),
              ),
              Tooltip(
                message: tooltip,
                child: Icon(
                  Icons.info_outline,
                  size: 11,
                  color: AppColors.textSecondary.withValues(alpha: 0.75),
                ),
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  amount,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style: amountStyle,
                ),
              ),
              if (showChevron)
                Icon(
                  Icons.chevron_right,
                  size: 14,
                  color: AppColors.textSecondary.withValues(alpha: 0.7),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
