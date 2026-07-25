import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/core/widgets/mobile/mobile_icon_action_button.dart';
import 'package:billing_baba/core/widgets/mobile/mobile_search_field.dart';
import 'package:billing_baba/core/widgets/mobile/transaction/mobile_transaction_models.dart';
import 'package:flutter/material.dart';

/// Search, filter, sort, and more-actions controls for transaction lists.
class MobileTransactionToolbar extends StatelessWidget {
  const MobileTransactionToolbar({
    required this.searchController,
    required this.searchHint,
    required this.onSearchChanged,
    required this.sortState,
    required this.sortFieldLabels,
    required this.onFilterTap,
    required this.onSortTap,
    super.key,
    this.filterLabel = 'Filter',
    this.isFilterActive = false,
    this.onMoreTap,
    this.showMoreButton = false,
  });

  final TextEditingController searchController;
  final String searchHint;
  final ValueChanged<String> onSearchChanged;
  final MobileTransactionSortState sortState;
  final Map<String, String> sortFieldLabels;
  final VoidCallback onFilterTap;
  final VoidCallback onSortTap;
  final String filterLabel;
  final bool isFilterActive;
  final VoidCallback? onMoreTap;
  final bool showMoreButton;

  @override
  Widget build(BuildContext context) {
    final sortLabel = !sortState.isActive
        ? 'Sort'
        : '${sortState.labelFor(sortFieldLabels)} ${sortState.direction == MobileTransactionSortDirection.ascending ? '↑' : '↓'}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: MobileSearchField(
                  controller: searchController,
                  hint: searchHint,
                  onChanged: onSearchChanged,
                ),
              ),
              if (showMoreButton && onMoreTap != null) ...[
                const SizedBox(width: AppSpacing.sm),
                MobileIconActionButton(
                  icon: Icons.more_horiz_rounded,
                  tooltip: 'More actions',
                  onPressed: onMoreTap,
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              _ToolbarChip(
                label: filterLabel,
                icon: Icons.filter_list_rounded,
                isActive: isFilterActive,
                onTap: onFilterTap,
              ),
              const SizedBox(width: AppSpacing.sm),
              _ToolbarChip(
                label: sortLabel,
                icon: Icons.sort_rounded,
                isActive: sortState.isActive,
                onTap: onSortTap,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ToolbarChip extends StatelessWidget {
  const _ToolbarChip({
    required this.label,
    required this.icon,
    required this.onTap,
    this.isActive = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.lgBorder,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary.withValues(alpha: 0.1)
              : AppColors.surface,
          borderRadius: AppRadius.lgBorder,
          border: Border.all(
            color: isActive
                ? AppColors.primary.withValues(alpha: 0.35)
                : const Color(0xFFE8EAED),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: AppIconSize.md,
              color: isActive ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: isActive ? AppColors.primary : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
