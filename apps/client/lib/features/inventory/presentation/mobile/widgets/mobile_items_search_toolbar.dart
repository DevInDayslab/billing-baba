import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Search bar with filter, barcode scan, and more actions for items page.
class MobileItemsSearchToolbar extends StatelessWidget {
  const MobileItemsSearchToolbar({
    required this.controller,
    required this.onChanged,
    required this.onFilterTap,
    required this.onScanTap,
    required this.onMoreTap,
    super.key,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onFilterTap;
  final VoidCallback onScanTap;
  final VoidCallback onMoreTap;

  static const borderColor = Color(0xFFE3E8EF);
  static const actionBlue = Color(0xFF42A5F5);

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
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: borderColor),
              ),
              child: Row(
                children: [
                  const SizedBox(width: AppSpacing.lg),
                  Icon(
                    Icons.search_rounded,
                    color: AppColors.textSecondary.withValues(alpha: 0.7),
                    size: AppIconSize.lg,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      onChanged: onChanged,
                      style: Theme.of(context).textTheme.bodyMedium,
                      decoration: InputDecoration(
                        hintText: 'Search for an item or code',
                        hintStyle: Theme.of(context).textTheme.bodyMedium
                            ?.copyWith(
                              color: AppColors.textSecondary.withValues(
                                alpha: 0.75,
                              ),
                            ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.md,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 28,
                    color: borderColor,
                  ),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onFilterTap,
                      borderRadius: const BorderRadius.horizontal(
                        right: Radius.circular(999),
                      ),
                      child: const SizedBox(
                        width: 44,
                        height: 44,
                        child: Icon(
                          Icons.filter_alt_outlined,
                          color: actionBlue,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          _ToolbarActionButton(
            icon: Icons.qr_code_scanner_rounded,
            onTap: onScanTap,
          ),
          const SizedBox(width: AppSpacing.sm),
          _ToolbarActionButton(
            icon: Icons.more_vert_rounded,
            onTap: onMoreTap,
          ),
        ],
      ),
    );
  }
}

class _ToolbarActionButton extends StatelessWidget {
  const _ToolbarActionButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: MobileItemsSearchToolbar.borderColor),
          ),
          child: Icon(icon, size: 22, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}
