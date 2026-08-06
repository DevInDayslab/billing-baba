import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Search + scan row for the home overview screen.
class MobileHomeSearchBar extends StatelessWidget {
  const MobileHomeSearchBar({
    required this.controller,
    required this.onChanged,
    super.key,
    this.hint = 'Search transactions, parties, invoices...',
    this.onFilterTap,
    this.showFilter = false,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback? onFilterTap;
  final String hint;
  final bool showFilter;

  static const _rowHeight = 46.0;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.xs,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: _rowHeight,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppRadius.searchBorder,
                border: Border.all(color: AppColors.chipBorder),
                boxShadow: AppShadows.subtle,
              ),
              child: Row(
                children: [
                  const SizedBox(width: AppSpacing.md),
                  Icon(Icons.search_rounded, color: primary, size: 24),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      onChanged: onChanged,
                      style: AppTypography.inter(
                        fontSize: 13,
                        color: AppColors.textPrimary,
                        height: 1.2,
                      ),
                      decoration: InputDecoration(
                        hintText: hint,
                        hintStyle: AppTypography.inter(
                          fontSize: 12.5,
                          color: AppColors.textSecondary.withValues(
                            alpha: 0.55,
                          ),
                          height: 1.2,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  if (showFilter && onFilterTap != null)
                    IconButton(
                      onPressed: onFilterTap,
                      icon: Icon(Icons.tune_rounded, color: primary, size: 18),
                      visualDensity: VisualDensity.compact,
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Material(
            color: primary,
            borderRadius: AppRadius.searchBorder,
            child: InkWell(
              onTap: () => context.push(AppRoutes.utilitiesAddItemsBarcode),
              borderRadius: AppRadius.searchBorder,
              child: const SizedBox(
                width: _rowHeight,
                height: _rowHeight,
                child: Icon(
                  Icons.qr_code_scanner_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
