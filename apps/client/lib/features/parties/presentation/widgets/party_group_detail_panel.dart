import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/inventory_list_header.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/inventory_list_table_row.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/inventory_styles.dart';
import 'package:billing_baba/features/parties/models/party_group_summary.dart';
import 'package:billing_baba/features/parties/models/party_model.dart';
import 'package:billing_baba/features/parties/providers/party_group_providers.dart';
import 'package:billing_baba/features/parties/providers/parties_selection_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class PartyGroupDetailPanel extends ConsumerWidget {
  const PartyGroupDetailPanel({
    required this.groupName,
    this.onBack,
    super.key,
  });

  final String groupName;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(selectedPartyGroupSummaryProvider);
    final parties = ref.watch(partiesInSelectedGroupProvider);
    final isLoading = ref.watch(partyGroupMembersLoadingProvider);

    if (summary == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _PartyGroupDetailHeader(
          summary: summary,
          onBack: onBack,
        ),
        const Divider(height: 1, color: inventoryCardBorder),
        const InventoryListHeader(
          height: inventoryListHeaderCompactHeight,
          showColumnSeparators: false,
          includeTrailingSpace: false,
          columns: [
            InventoryListColumn(label: 'PARTY NAME'),
            InventoryListColumn(label: 'AMOUNT', fixedWidth: 88),
          ],
        ),
        Expanded(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : parties.isEmpty
              ? const Center(
                  child: Text(
                    'No parties in this group yet.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: parties.length,
                  itemBuilder: (context, index) {
                    final party = parties[index];
                    return _PartyInGroupTile(
                      party: party,
                      index: index,
                      onTap: () {
                        ref.read(selectedPartyIdProvider.notifier).selected =
                            party.id;
                        context.go(AppRoutes.partyDetails);
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _PartyGroupDetailHeader extends StatelessWidget {
  const _PartyGroupDetailHeader({
    required this.summary,
    this.onBack,
  });

  final PartyGroupSummary summary;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (onBack != null)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: IconButton(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back),
                tooltip: 'Back',
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ),
          Text(
            summary.name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${summary.partyCount} ${summary.partyCount == 1 ? 'party' : 'parties'}',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.lg,
            runSpacing: AppSpacing.xs,
            children: [
              _SummaryChip(
                label: 'To Receive',
                value: PartyModel.displayOutstanding(summary.totalReceivable),
                color: inventoryPositiveColor,
              ),
              _SummaryChip(
                label: 'To Pay',
                value: PartyModel.displayOutstanding(-summary.totalPayable),
                color: inventoryNegativeColor,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _PartyInGroupTile extends StatelessWidget {
  const _PartyInGroupTile({
    required this.party,
    required this.index,
    required this.onTap,
  });

  final PartyModel party;
  final int index;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final amountColor = party.hasReceivable
        ? inventoryPositiveColor
        : party.hasPayable
        ? inventoryNegativeColor
        : AppColors.textSecondary;
    final amountText = PartyModel.displayOutstanding(party.balance);

    return InventoryListTableRow(
      index: index,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: Row(
          children: [
            Icon(
              Icons.person_outline,
              size: 16,
              color: party.isActive
                  ? Colors.grey.shade500
                  : Colors.grey.shade400,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                party.name,
                overflow: TextOverflow.ellipsis,
                style: InventoryStyles.listCellStyle.copyWith(
                  fontWeight: FontWeight.w500,
                  color: party.isActive
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                ),
              ),
            ),
            SizedBox(
              width: 88,
              child: Text(
                amountText,
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: amountColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
