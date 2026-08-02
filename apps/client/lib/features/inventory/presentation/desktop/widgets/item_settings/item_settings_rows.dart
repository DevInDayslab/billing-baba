import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/core/theme/list_panel_theme.dart';
import 'package:flutter/material.dart';

class ItemSettingsSectionCard extends StatelessWidget {
  const ItemSettingsSectionCard({
    required this.title,
    required this.children,
    super.key,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.mdBorder,
        border: Border.all(color: listPanelCardBorder),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title.toUpperCase(),
            style: ListPanelStyles.listHeaderStyle,
          ),
          const SizedBox(height: AppSpacing.sm),
          ...children,
        ],
      ),
    );
  }
}

class ItemSettingsLabel extends StatelessWidget {
  const ItemSettingsLabel({
    required this.label,
    this.infoTooltip,
    this.isPremium = false,
    super.key,
  });

  final String label;
  final String? infoTooltip;
  final bool isPremium;

  @override
  Widget build(BuildContext context) {
    return Row(
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
        if (infoTooltip != null) ...[
          const SizedBox(width: AppSpacing.xs),
          Tooltip(
            message: infoTooltip!,
            child: Icon(
              Icons.info_outline,
              size: 16,
              color: AppColors.textSecondary.withValues(alpha: 0.8),
            ),
          ),
        ],
        if (isPremium) ...[
          const SizedBox(width: AppSpacing.xs),
          Tooltip(
            message: 'Premium feature',
            child: Icon(
              Icons.workspace_premium,
              size: 16,
              color: Colors.deepPurple.shade400,
            ),
          ),
        ],
      ],
    );
  }
}

class ItemSettingsDivider extends StatelessWidget {
  const ItemSettingsDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      thickness: 1,
      color: listPanelCardBorder,
    );
  }
}

class ItemSettingsToggleRow extends StatelessWidget {
  const ItemSettingsToggleRow({
    required this.label,
    required this.value,
    required this.onChanged,
    this.infoTooltip,
    this.isPremium = false,
    super.key,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final String? infoTooltip;
  final bool isPremium;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs + 2),
      child: Row(
        children: [
          Expanded(
            child: ItemSettingsLabel(
              label: label,
              infoTooltip: infoTooltip,
              isPremium: isPremium,
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.primary,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }
}

class ItemSettingsCheckboxRow extends StatelessWidget {
  const ItemSettingsCheckboxRow({
    required this.label,
    required this.value,
    required this.onChanged,
    super.key,
  });

  final String label;
  final bool value;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs + 2),
      child: Row(
        children: [
          Expanded(
            child: ItemSettingsLabel(label: label),
          ),
          Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}

class ItemSettingsNavRow extends StatelessWidget {
  const ItemSettingsNavRow({
    required this.label,
    required this.onTap,
    this.subtitle,
    this.infoTooltip,
    this.isPremium = false,
    super.key,
  });

  final String label;
  final String? subtitle;
  final VoidCallback onTap;
  final String? infoTooltip;
  final bool isPremium;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.smBorder,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ItemSettingsLabel(
                    label: label,
                    infoTooltip: infoTooltip,
                    isPremium: isPremium,
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: AppTypography.inter(
                        fontSize: AppTypography.bodySmallSize,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class ItemSettingsDropdownRow extends StatelessWidget {
  const ItemSettingsDropdownRow({
    required this.label,
    required this.value,
    required this.options,
    required this.onSelected,
    this.infoTooltip,
    super.key,
  });

  final String label;
  final String value;
  final List<String> options;
  final ValueChanged<String> onSelected;
  final String? infoTooltip;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs + 2),
      child: Row(
        children: [
          Expanded(
            child: ItemSettingsLabel(
              label: label,
              infoTooltip: infoTooltip,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          SizedBox(
            width: 220,
            child: _SettingsDropdown(
              value: value,
              options: options,
              onSelected: onSelected,
            ),
          ),
        ],
      ),
    );
  }
}

class ItemSettingsCounterRow extends StatelessWidget {
  const ItemSettingsCounterRow({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.infoTooltip,
    super.key,
  });

  final String label;
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;
  final String? infoTooltip;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs + 2),
      child: Row(
        children: [
          Expanded(
            child: ItemSettingsLabel(
              label: label,
              infoTooltip: infoTooltip,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _StepButton(
                icon: Icons.remove,
                onTap: value > min ? () => onChanged(value - 1) : null,
              ),
              SizedBox(
                width: 40,
                child: Text(
                  '$value',
                  textAlign: TextAlign.center,
                  style: AppTypography.inter(
                    fontSize: AppTypography.bodyMediumSize,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ).copyWith(decoration: TextDecoration.underline),
                ),
              ),
              _StepButton(
                icon: Icons.add,
                onTap: value < max ? () => onChanged(value + 1) : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ItemSettingsRadioRow<T> extends StatelessWidget {
  const ItemSettingsRadioRow({
    required this.label,
    required this.value,
    required this.options,
    required this.labelBuilder,
    required this.onChanged,
    super.key,
  });

  final String label;
  final T value;
  final List<T> options;
  final String Function(T option) labelBuilder;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs + 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ItemSettingsLabel(label: label),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.lg,
            runSpacing: AppSpacing.xs,
            children: [
              for (final option in options)
                InkWell(
                  onTap: () => onChanged(option),
                  borderRadius: AppRadius.smBorder,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.xs,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Radio<T>(
                          value: option,
                          groupValue: value,
                          onChanged: (selected) {
                            if (selected != null) onChanged(selected);
                          },
                          activeColor: AppColors.primary,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        ),
                        Text(
                          labelBuilder(option),
                          style: AppTypography.inter(
                            fontSize: AppTypography.bodyMediumSize,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SettingsDropdown extends StatelessWidget {
  const _SettingsDropdown({
    required this.value,
    required this.options,
    required this.onSelected,
  });

  final String value;
  final List<String> options;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      decoration: InputDecoration(
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.sm,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: const BorderSide(color: listPanelCardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: const BorderSide(color: listPanelCardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        filled: true,
        fillColor: AppColors.background,
      ),
      style: AppTypography.inter(
        fontSize: AppTypography.bodySmallSize,
        color: AppColors.textPrimary,
      ),
      icon: const Icon(Icons.keyboard_arrow_down, size: 20),
      items: [
        for (final option in options)
          DropdownMenuItem<String>(
            value: option,
            child: Text(option),
          ),
      ],
      onChanged: (selected) {
        if (selected != null) onSelected(selected);
      },
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.smBorder,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          border: Border.all(color: listPanelCardBorder),
          borderRadius: AppRadius.smBorder,
          color: AppColors.surface,
        ),
        child: Icon(
          icon,
          size: 16,
          color: onTap == null
              ? AppColors.textSecondary.withValues(alpha: 0.4)
              : AppColors.textSecondary,
        ),
      ),
    );
  }
}
