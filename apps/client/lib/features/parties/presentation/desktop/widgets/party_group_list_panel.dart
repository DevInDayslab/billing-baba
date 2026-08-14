import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/inventory_highlighted_text.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/inventory_list_header.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/inventory_list_table_row.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/inventory_search_field.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/inventory_styles.dart';
import 'package:billing_baba/features/parties/application/parties_selection_providers.dart';
import 'package:billing_baba/features/parties/application/party_group_providers.dart';
import 'package:billing_baba/features/parties/models/party_group_summary.dart';
import 'package:billing_baba/features/parties/models/party_model.dart';
import 'package:billing_baba/shared/widgets/app_ellipsis_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';

const _groupListAmountHeaderWidth = 88.0;

class PartyGroupListPanel extends ConsumerWidget {
  const PartyGroupListPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaries = ref.watch(partyGroupSummariesProvider);
    final selectedGroup = ref.watch(selectedPartyGroupProvider);
    final searchQuery = ref.watch(partyGroupSearchQueryProvider);
    final isLoading = ref.watch(partyGroupsPageLoadingProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.md,
            0,
          ),
          child: InventorySearchField(
            hint: 'Search Group Name',
            initialValue: searchQuery,
            debounceDuration: const Duration(milliseconds: 300),
            onChanged: (query) {
              ref.read(partyGroupSearchQueryProvider.notifier).query = query;
            },
            onDebouncedChanged: (query) {
              ref.read(partyGroupSearchQueryProvider.notifier).query = query;
            },
          ),
        ),
        const SizedBox(height: 14),
        const InventoryListHeader(
          height: inventoryListHeaderCompactHeight,
          showColumnSeparators: false,
          includeTrailingSpace: false,
          columns: [
            InventoryListColumn(label: 'GROUP NAME'),
            InventoryListColumn(
              label: 'AMOUNT',
              fixedWidth: _groupListAmountHeaderWidth,
            ),
          ],
        ),
        Expanded(
          child: isLoading
              ? const _PartyGroupListSkeleton()
              : summaries.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Text(
                      searchQuery.trim().isNotEmpty
                          ? 'No groups found'
                          : 'No party groups yet. Add your first group.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: summaries.length,
                  itemBuilder: (context, index) {
                    final summary = summaries[index];
                    return _PartyGroupListTile(
                      summary: summary,
                      index: index,
                      isSelected: summary.name == selectedGroup,
                      searchQuery: searchQuery,
                      onTap: () {
                        ref.read(selectedPartyGroupProvider.notifier).selected =
                            summary.name;
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _PartyGroupListSkeleton extends StatelessWidget {
  const _PartyGroupListSkeleton();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: ListView.builder(
        itemCount: 8,
        itemBuilder: (context, index) => Container(
          height: inventoryItemListRowHeight,
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: inventoryCardBorder)),
          ),
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        ),
      ),
    );
  }
}

class _PartyGroupListTile extends StatelessWidget {
  const _PartyGroupListTile({
    required this.summary,
    required this.index,
    required this.isSelected,
    required this.searchQuery,
    required this.onTap,
  });

  final PartyGroupSummary summary;
  final int index;
  final bool isSelected;
  final String searchQuery;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final amountColor = summary.netBalance > 0
        ? inventoryPositiveColor
        : summary.netBalance < 0
        ? inventoryNegativeColor
        : AppColors.textSecondary;
    final amountText = PartyModel.displayOutstanding(summary.netBalance);

    return InventoryListTableRow(
      index: index,
      isSelected: isSelected,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: Row(
          children: [
            Icon(
              Icons.groups_outlined,
              size: 16,
              color: Colors.grey.shade500,
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 3,
              child: InventoryHighlightedText(
                text: summary.name,
                query: searchQuery,
                style: InventoryStyles.listCellStyle.copyWith(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
            SizedBox(
              width: _groupListAmountHeaderWidth,
              child: AppEllipsisText(
                amountText,
                textAlign: TextAlign.right,
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
