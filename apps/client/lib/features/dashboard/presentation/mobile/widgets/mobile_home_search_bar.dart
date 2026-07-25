import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Search bar with inline filter action for the mobile home screen.
class MobileHomeSearchBar extends StatelessWidget {
  const MobileHomeSearchBar({
    required this.controller,
    required this.onChanged,
    required this.onFilterTap,
    super.key,
    this.hint = 'Search for a transaction...',
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onFilterTap;
  final String hint;

  static const borderColor = Color(0xFFE3E8EF);
  static const filterBlue = Color(0xFF42A5F5);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
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
                  hintText: hint,
                  hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary.withValues(alpha: 0.75),
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.md,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Material(
                color: filterBlue,
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  onTap: onFilterTap,
                  borderRadius: BorderRadius.circular(10),
                  child: const SizedBox(
                    width: 36,
                    height: 36,
                    child: Icon(
                      Icons.filter_alt_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
