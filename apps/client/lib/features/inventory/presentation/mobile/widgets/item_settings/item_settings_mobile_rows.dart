import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

import 'package:lucide_icons_flutter/lucide_icons.dart';

class ItemSettingsMobileLabel extends StatelessWidget {
  const ItemSettingsMobileLabel({
    required this.label,
    super.key,
    this.infoTooltip,
    this.isPremium = false,
    this.style,
  });

  final String label;
  final String? infoTooltip;
  final bool isPremium;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Flexible(
          child: Text(
            label,
            style:
                style ??
                theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
          ),
        ),
        if (infoTooltip != null) ...[
          const SizedBox(width: AppSpacing.xs),
          _InfoButton(message: infoTooltip!),
        ],
        if (isPremium) ...[
          const SizedBox(width: AppSpacing.xs),
          Icon(
            LucideIcons.award,
            size: 16,
            color: Colors.deepPurple.shade400,
          ),
        ],
      ],
    );
  }
}

class ItemSettingsMobileSwitchTile extends StatelessWidget {
  const ItemSettingsMobileSwitchTile({
    required this.label,
    required this.value,
    required this.onChanged,
    super.key,
    this.infoTooltip,
    this.isPremium = false,
    this.subtitle,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final String? infoTooltip;
  final bool isPremium;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ItemSettingsMobileLabel(
                  label: label,
                  infoTooltip: infoTooltip,
                  isPremium: isPremium,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

class ItemSettingsMobileCheckboxTile extends StatelessWidget {
  const ItemSettingsMobileCheckboxTile({
    required this.label,
    required this.value,
    required this.onChanged,
    super.key,
    this.infoTooltip,
    this.isPremium = false,
    this.child,
  });

  final String label;
  final bool value;
  final ValueChanged<bool?> onChanged;
  final String? infoTooltip;
  final bool isPremium;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.xs,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: ItemSettingsMobileLabel(
                  label: label,
                  infoTooltip: infoTooltip,
                  isPremium: isPremium,
                ),
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
        ),
        if (value && child != null) child!,
      ],
    );
  }
}

class ItemSettingsMobileRadioGroup<T> extends StatelessWidget {
  const ItemSettingsMobileRadioGroup({
    required this.value,
    required this.options,
    required this.labelBuilder,
    required this.onChanged,
    super.key,
  });

  final T value;
  final List<T> options;
  final String Function(T option) labelBuilder;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Wrap(
        spacing: AppSpacing.lg,
        runSpacing: AppSpacing.xs,
        children: [
          for (final option in options)
            InkWell(
              onTap: () => onChanged(option),
              borderRadius: AppRadius.smBorder,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
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
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ),
                    Text(
                      labelBuilder(option),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class ItemSettingsMobileDescriptionFooter extends StatelessWidget {
  const ItemSettingsMobileDescriptionFooter({
    required this.descriptionText,
    required this.onEdit,
    super.key,
  });

  final String descriptionText;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final preview = descriptionText.trim().isEmpty
        ? 'Description'
        : descriptionText.trim();

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              preview,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          GestureDetector(
            onTap: onEdit,
            child: Text(
              'Edit',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ItemSettingsMobileNavTile extends StatelessWidget {
  const ItemSettingsMobileNavTile({
    required this.label,
    required this.onTap,
    super.key,
    this.subtitle,
    this.trailingValue,
    this.infoTooltip,
    this.isPremium = false,
  });

  final String label;
  final VoidCallback onTap;
  final String? subtitle;
  final String? trailingValue;
  final String? infoTooltip;
  final bool isPremium;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: AppColors.surface,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ItemSettingsMobileLabel(
                      label: label,
                      infoTooltip: infoTooltip,
                      isPremium: isPremium,
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (trailingValue != null) ...[
                    Text(
                      trailingValue!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                  ],
                  Icon(
                    LucideIcons.chevronRight,
                    color: AppColors.textSecondary.withValues(alpha: 0.7),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ItemSettingsMobileOptionTile extends StatelessWidget {
  const ItemSettingsMobileOptionTile({
    required this.label,
    required this.value,
    required this.onTap,
    super.key,
    this.infoTooltip,
  });

  final String label;
  final String value;
  final VoidCallback onTap;
  final String? infoTooltip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: AppColors.surface,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              Expanded(
                child: ItemSettingsMobileLabel(
                  label: label,
                  infoTooltip: infoTooltip,
                ),
              ),
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        value,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Icon(
                      LucideIcons.chevronDown,
                      color: AppColors.textSecondary.withValues(alpha: 0.7),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ItemSettingsMobileCounterTile extends StatelessWidget {
  const ItemSettingsMobileCounterTile({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    super.key,
    this.infoTooltip,
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
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          Expanded(
            child: ItemSettingsMobileLabel(
              label: label,
              infoTooltip: infoTooltip,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _StepButton(
                icon: LucideIcons.minus,
                onTap: value > min ? () => onChanged(value - 1) : null,
              ),
              SizedBox(
                width: 40,
                child: Text(
                  '$value',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              _StepButton(
                icon: LucideIcons.plus,
                onTap: value < max ? () => onChanged(value + 1) : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ItemSettingsMobileDivider extends StatelessWidget {
  const ItemSettingsMobileDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, indent: AppSpacing.lg, endIndent: 0);
  }
}

class _InfoButton extends StatelessWidget {
  const _InfoButton({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      },
      child: Icon(
        LucideIcons.info,
        size: 16,
        color: AppColors.textSecondary.withValues(alpha: 0.8),
      ),
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
          border: Border.all(color: const Color(0xFFE8EAED)),
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
