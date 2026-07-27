import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/core/widgets/mobile/mobile_icon_action_button.dart';
import 'package:billing_baba/core/widgets/mobile/mobile_search_field.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

/// Search field with filter, scan, and more actions for the mobile items screen.
class ItemSearchBar extends StatelessWidget {
  const ItemSearchBar({
    required this.searchController,
    required this.onSearchChanged,
    super.key,
    this.onFilterTap,
    this.onScanTap,
    this.onMoreTap,
    this.hasActiveFilter = false,
  });

  static const _hint = 'Search for an item or code';

  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback? onFilterTap;
  final VoidCallback? onScanTap;
  final VoidCallback? onMoreTap;
  final bool hasActiveFilter;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: MobileSearchField(
              controller: searchController,
              hint: _hint,
              onChanged: onSearchChanged,
            ),
          ),
          const Gap(AppSpacing.sm),
          MobileIconActionButton(
            icon: Icons.filter_list_rounded,
            tooltip: 'Filter',
            iconColor: hasActiveFilter ? AppColors.primary : null,
            onPressed: onFilterTap,
          ),
          MobileIconActionButton(
            icon: Icons.qr_code_scanner_rounded,
            tooltip: 'Scan barcode',
            onPressed: onScanTap,
          ),
          MobileIconActionButton(
            icon: Icons.more_vert_rounded,
            tooltip: 'More',
            onPressed: onMoreTap,
          ),
        ],
      ),
    );
  }
}
