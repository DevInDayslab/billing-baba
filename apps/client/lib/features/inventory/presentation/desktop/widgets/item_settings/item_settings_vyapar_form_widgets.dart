import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/models/item_settings_info_catalog.dart';
import 'package:billing_baba/features/settings/presentation/desktop/widgets/settings_info_dialog.dart';
import 'package:flutter/material.dart';

abstract final class ItemSettingsRowMetrics {
  static const double checkboxLeadingWidth = 42;
}

class ItemSettingsVyaparCheckboxRow extends StatelessWidget {
  const ItemSettingsVyaparCheckboxRow({
    required this.label,
    required this.value,
    required this.onChanged,
    this.infoKey,
    this.trailing,
    super.key,
  });

  final String label;
  final bool value;
  final ValueChanged<bool?>? onChanged;
  final ItemSettingsInfoKey? infoKey;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs + 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: ItemSettingsRowMetrics.checkboxLeadingWidth,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Checkbox(
                value: value,
                onChanged: onChanged,
                activeColor: AppColors.primary,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    label,
                    style: AppTypography.inter(
                      fontSize: AppTypography.bodyMediumSize,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: AppSpacing.xs),
                  trailing!,
                ],
              ],
            ),
          ),
          if (infoKey != null)
            SettingsInfoHoverIcon(
              heading: label,
              sections: ItemSettingsInfoCatalog.sectionsFor(infoKey!),
            ),
        ],
      ),
    );
  }
}

class ItemSettingsVyaparLink extends StatelessWidget {
  const ItemSettingsVyaparLink({
    required this.label,
    required this.onTap,
    super.key,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(
          label,
          style: AppTypography.inter(
            fontSize: AppTypography.bodySmallSize,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}

class ItemSettingsQuantityStepper extends StatelessWidget {
  const ItemSettingsQuantityStepper({
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 4,
    super.key,
  });

  final int value;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;

  @override
  Widget build(BuildContext context) {
    final style = AppTypography.inter(
      fontSize: AppTypography.bodyMediumSize,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ).copyWith(
      decoration: TextDecoration.underline,
      decorationColor: AppColors.textSecondary,
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$value', style: style),
        const SizedBox(width: 2),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Arrow(
              icon: Icons.keyboard_arrow_up,
              onPressed: value < max ? () => onChanged(value + 1) : null,
            ),
            _Arrow(
              icon: Icons.keyboard_arrow_down,
              onPressed: value > min ? () => onChanged(value - 1) : null,
            ),
          ],
        ),
      ],
    );
  }
}

class _Arrow extends StatelessWidget {
  const _Arrow({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary.withValues(alpha: 0.12),
      child: InkWell(
        onTap: onPressed,
        child: SizedBox(
          width: 18,
          height: 11,
          child: Icon(
            icon,
            size: 14,
            color: onPressed == null
                ? AppColors.textSecondary.withValues(alpha: 0.4)
                : AppColors.primary,
          ),
        ),
      ),
    );
  }
}
