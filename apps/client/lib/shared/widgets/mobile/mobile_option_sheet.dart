import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_bottom_sheet.dart';
import 'package:flutter/material.dart';

import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Selectable option for [showMobileOptionSheet].
class MobileOption<T> {
  const MobileOption({
    required this.value,
    required this.label,
    this.subtitle,
  });

  final T value;
  final String label;
  final String? subtitle;
}

/// Reusable bottom sheet for single-select filters, sorts, and menus.
Future<T?> showMobileOptionSheet<T>({
  required BuildContext context,
  required String title,
  required List<MobileOption<T>> options,
  T? selected,
}) {
  return showMobileBottomSheet<T>(
    context: context,
    title: title,
    builder: (sheetContext) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final option in options)
            _MobileOptionTile<T>(
              option: option,
              isSelected: selected == option.value,
              onSelected: () => Navigator.of(sheetContext).pop(option.value),
            ),
        ],
      );
    },
  );
}

class _MobileOptionTile<T> extends StatelessWidget {
  const _MobileOptionTile({
    required this.option,
    required this.isSelected,
    required this.onSelected,
  });

  final MobileOption<T> option;
  final bool isSelected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onSelected,
        borderRadius: AppRadius.mdBorder,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option.label,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (option.subtitle != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        option.subtitle!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                isSelected ? LucideIcons.circleDot : LucideIcons.circle,
                color: isSelected
                    ? AppColors.primary
                    : AppColors.textSecondary.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
