import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/core/widgets/mobile/mobile_icon_action_button.dart';
import 'package:billing_baba/core/widgets/mobile/mobile_search_field.dart';
import 'package:billing_baba/features/parties/models/party_list_filter.dart';
import 'package:billing_baba/features/parties/presentation/mobile/application/mobile_party_list_controller.dart';
import 'package:flutter/material.dart';

/// Search + filter/sort controls for the mobile party list.
class MobilePartyListToolbar extends StatelessWidget {
  const MobilePartyListToolbar({
    required this.searchController,
    required this.onSearchChanged,
    required this.activeFilter,
    required this.sortState,
    required this.onFilterTap,
    required this.onSortTap,
    super.key,
    this.onAddParty,
  });

  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final PartyListFilter activeFilter;
  final MobilePartyListSortState sortState;
  final VoidCallback onFilterTap;
  final VoidCallback onSortTap;
  final VoidCallback? onAddParty;

  @override
  Widget build(BuildContext context) {
    final sortLabel = sortState.direction == MobilePartySortDirection.none
        ? 'Sort'
        : '${sortState.label} ${sortState.direction == MobilePartySortDirection.ascending ? '↑' : '↓'}';

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
                  hint: 'Search party name, phone, GSTIN',
                  onChanged: onSearchChanged,
                ),
              ),
              if (onAddParty != null) ...[
                const SizedBox(width: AppSpacing.sm),
                MobileIconActionButton(
                  icon: Icons.person_add_alt_1_outlined,
                  tooltip: 'Add party',
                  onPressed: onAddParty,
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              _ToolbarChip(
                label: activeFilter == PartyListFilter.all
                    ? 'Filter'
                    : activeFilter.label,
                icon: Icons.filter_list_rounded,
                isActive: activeFilter != PartyListFilter.all,
                onTap: onFilterTap,
              ),
              const SizedBox(width: AppSpacing.sm),
              _ToolbarChip(
                label: sortLabel,
                icon: Icons.sort_rounded,
                isActive: sortState.direction != MobilePartySortDirection.none,
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
