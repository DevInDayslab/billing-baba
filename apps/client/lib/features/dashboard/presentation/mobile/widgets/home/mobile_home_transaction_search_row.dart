import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Transaction-details search row with filter settings button.
class MobileHomeTransactionSearchRow extends StatelessWidget {
  const MobileHomeTransactionSearchRow({
    required this.controller,
    required this.onChanged,
    this.onSettingsTap,
    super.key,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback? onSettingsTap;

  static const _rowHeight = 44.0;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.xs,
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: _rowHeight,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppRadius.searchBorder,
                boxShadow: AppShadows.subtle,
              ),
              child: Row(
                children: [
                  const SizedBox(width: AppSpacing.md),
                  Icon(LucideIcons.search, color: primary, size: 20),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      onChanged: onChanged,
                      style: AppTypography.inter(
                        fontSize: 13,
                        color: AppColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search by item, party or number',
                        hintStyle: AppTypography.inter(
                          fontSize: 12.5,
                          color: AppColors.textSecondary.withValues(
                            alpha: 0.6,
                          ),
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (onSettingsTap != null) ...[
            const SizedBox(width: AppSpacing.sm),
            Material(
              color: AppColors.surface,
              borderRadius: AppRadius.buttonBorder,
              child: InkWell(
                onTap: onSettingsTap,
                borderRadius: AppRadius.buttonBorder,
                child: Ink(
                  width: _rowHeight,
                  height: _rowHeight,
                  decoration: BoxDecoration(
                    borderRadius: AppRadius.buttonBorder,
                    border: Border.all(color: AppColors.chipBorder),
                    boxShadow: AppShadows.subtle,
                  ),
                  child: Icon(LucideIcons.slidersHorizontal, color: primary, size: 18),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
