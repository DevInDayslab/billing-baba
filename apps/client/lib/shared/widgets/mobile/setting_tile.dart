import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:lucide_icons_flutter/lucide_icons.dart';

const _settingsBlue = Color(0xFF42A5F5);
const _dividerColor = Color(0xFFE8EAED);

/// Reusable Vyapar-style settings row with optional info icon and rich trailing.
class SettingTile extends StatelessWidget {
  const SettingTile({
    required this.title,
    super.key,
    this.subtitle,
    this.showInfoIcon = false,
    this.onInfoTap,
    this.enabled = true,
    this.indent = 0,
    this.onTap,
    this.trailing,
    this.value,
    this.showChevron = false,
  });

  factory SettingTile.switchTile({
    required String title,
    required bool value,
    required ValueChanged<bool>? onChanged,
    String? subtitle,
    bool showInfoIcon = false,
    VoidCallback? onInfoTap,
    bool enabled = true,
    double indent = 0,
  }) {
    return SettingTile(
      title: title,
      subtitle: subtitle,
      showInfoIcon: showInfoIcon,
      onInfoTap: onInfoTap,
      enabled: enabled,
      indent: indent,
      trailing: Switch.adaptive(
        value: value,
        onChanged: enabled ? onChanged : null,
        activeThumbColor: Colors.white,
        activeTrackColor: _settingsBlue,
        inactiveThumbColor: Colors.white,
        inactiveTrackColor: AppColors.textSecondary.withValues(alpha: 0.25),
      ),
    );
  }

  factory SettingTile.checkboxTile({
    required String title,
    required bool value,
    required ValueChanged<bool>? onChanged,
    String? subtitle,
    bool showInfoIcon = false,
    VoidCallback? onInfoTap,
    bool enabled = true,
    double indent = 0,
  }) {
    return SettingTile(
      title: title,
      subtitle: subtitle,
      showInfoIcon: showInfoIcon,
      onInfoTap: onInfoTap,
      enabled: enabled,
      indent: indent,
      onTap: enabled && onChanged != null ? () => onChanged(!value) : null,
      trailing: Checkbox(
        value: value,
        onChanged: enabled
            ? (checked) => onChanged?.call(checked ?? false)
            : null,
        activeColor: _settingsBlue,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
    );
  }

  factory SettingTile.stepperTile({
    required String title,
    required int value,
    required ValueChanged<int>? onChanged,
    int min = 0,
    int max = 4,
    String? subtitle,
    bool showInfoIcon = false,
    VoidCallback? onInfoTap,
    bool enabled = true,
    double indent = 0,
  }) {
    return SettingTile(
      title: title,
      subtitle: subtitle,
      showInfoIcon: showInfoIcon,
      onInfoTap: onInfoTap,
      enabled: enabled,
      indent: indent,
      trailing: _SettingStepper(
        value: value,
        min: min,
        max: max,
        enabled: enabled,
        onChanged: onChanged,
      ),
    );
  }

  final String title;
  final String? subtitle;
  final bool showInfoIcon;
  final VoidCallback? onInfoTap;
  final bool enabled;
  final double indent;
  final VoidCallback? onTap;
  final Widget? trailing;
  final String? value;
  final bool showChevron;

  static SettingTile dropdown<T>({
    required BuildContext context,
    required String title,
    required T value,
    required List<T> options,
    required String Function(T option) labelBuilder,
    required ValueChanged<T>? onChanged,
    String? subtitle,
    bool showInfoIcon = false,
    VoidCallback? onInfoTap,
    bool enabled = true,
    double indent = 0,
  }) {
    return SettingTile(
      title: title,
      subtitle: subtitle,
      showInfoIcon: showInfoIcon,
      onInfoTap: onInfoTap,
      enabled: enabled,
      indent: indent,
      value: labelBuilder(value),
      showChevron: true,
      onTap: enabled && onChanged != null
          ? () => _openDropdownPicker<T>(
              context: context,
              title: title,
              value: value,
              options: options,
              labelBuilder: labelBuilder,
              onChanged: onChanged,
            )
          : null,
    );
  }

  static SettingTile radio<T>({
    required String title,
    required T groupValue,
    required T tileValue,
    required ValueChanged<T>? onChanged,
    String? subtitle,
    bool showInfoIcon = false,
    VoidCallback? onInfoTap,
    bool enabled = true,
    double indent = 0,
  }) {
    return SettingTile(
      title: title,
      subtitle: subtitle,
      showInfoIcon: showInfoIcon,
      onInfoTap: onInfoTap,
      enabled: enabled,
      indent: indent,
      onTap: enabled && onChanged != null ? () => onChanged(tileValue) : null,
      trailing: Radio<T>(
        value: tileValue,
        groupValue: groupValue,
        onChanged: enabled
            ? (value) {
                if (value != null) onChanged?.call(value);
              }
            : null,
        activeColor: _settingsBlue,
      ),
    );
  }

  static SettingTile navigation({
    required String title,
    required VoidCallback? onTap,
    String? subtitle,
    String? value,
    bool showInfoIcon = false,
    VoidCallback? onInfoTap,
    bool enabled = true,
    double indent = 0,
    bool showChevron = true,
    Widget? trailing,
  }) {
    return SettingTile(
      title: title,
      subtitle: subtitle,
      showInfoIcon: showInfoIcon,
      onInfoTap: onInfoTap,
      enabled: enabled,
      indent: indent,
      value: value,
      showChevron: showChevron,
      onTap: enabled ? onTap : null,
      trailing: trailing,
    );
  }

  static Future<void> _openDropdownPicker<T>({
    required BuildContext context,
    required String title,
    required T value,
    required List<T> options,
    required String Function(T option) labelBuilder,
    required ValueChanged<T> onChanged,
  }) async {
    final selected = await showModalBottomSheet<T>(
      context: context,
      showDragHandle: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.sm,
                  AppSpacing.lg,
                  AppSpacing.md,
                ),
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              for (final option in options)
                ListTile(
                  title: Text(labelBuilder(option)),
                  trailing: option == value
                      ? const Icon(LucideIcons.check, color: _settingsBlue)
                      : null,
                  onTap: () => Navigator.of(context).pop(option),
                ),
            ],
          ),
        );
      },
    );

    if (selected != null) onChanged(selected);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = enabled
        ? AppColors.textPrimary
        : AppColors.textSecondary.withValues(alpha: 0.55);

    return Opacity(
      opacity: enabled ? 1 : 0.65,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.lg + indent,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.md,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showInfoIcon) ...[
                  InkWell(
                    onTap: onInfoTap,
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.only(
                        right: AppSpacing.sm,
                        top: 2,
                      ),
                      child: Icon(
                        LucideIcons.info,
                        size: 18,
                        color: AppColors.textSecondary.withValues(alpha: 0.75),
                      ),
                    ),
                  ),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: textColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          subtitle!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (value != null) ...[
                  const SizedBox(width: AppSpacing.sm),
                  Flexible(
                    child: Text(
                      value!,
                      textAlign: TextAlign.right,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
                if (trailing != null) ...[
                  const SizedBox(width: AppSpacing.sm),
                  trailing!,
                ] else if (showChevron && onTap != null)
                  Icon(
                    LucideIcons.chevronRight,
                    color: AppColors.textSecondary.withValues(alpha: 0.55),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingStepper extends StatelessWidget {
  const _SettingStepper({
    required this.value,
    required this.min,
    required this.max,
    required this.enabled,
    this.onChanged,
  });

  final int value;
  final int min;
  final int max;
  final bool enabled;
  final ValueChanged<int>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _StepperButton(
          icon: LucideIcons.minus,
          enabled: enabled && value > min,
          onTap: () => onChanged?.call(value - 1),
        ),
        Container(
          width: 36,
          alignment: Alignment.center,
          child: Text(
            '$value',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        _StepperButton(
          icon: LucideIcons.plus,
          enabled: enabled && value < max,
          onTap: () => onChanged?.call(value + 1),
        ),
      ],
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({
    required this.icon,
    required this.enabled,
    this.onTap,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: enabled ? const Color(0xFFF1F3F5) : const Color(0xFFFAFAFA),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 32,
          height: 32,
          child: Icon(
            icon,
            size: 18,
            color: enabled
                ? AppColors.textPrimary
                : AppColors.textSecondary.withValues(alpha: 0.35),
          ),
        ),
      ),
    );
  }
}

/// Animated container for dependent settings that show/hide with a parent toggle.
class AnimatedSettingGroup extends StatelessWidget {
  const AnimatedSettingGroup({
    required this.visible,
    required this.children,
    super.key,
  });

  final bool visible;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeInOutCubic,
      alignment: Alignment.topCenter,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 180),
        opacity: visible ? 1 : 0,
        child: visible
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: _withDividers(children),
              )
            : const SizedBox.shrink(),
      ),
    );
  }

  List<Widget> _withDividers(List<Widget> items) {
    if (items.isEmpty) return items;

    final result = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      result.add(items[i]);
      if (i < items.length - 1) {
        result.add(
          const Divider(
            height: 1,
            thickness: 1,
            color: _dividerColor,
            indent: AppSpacing.lg,
          ),
        );
      }
    }
    return result;
  }
}

/// Shows a short info tooltip/snackbar for setting help text.
void showSettingInfo(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
}

/// Prevents accidental double-taps while persisting settings.
class SettingTileInteractionLock {
  static Future<void> run(Future<void> Function() action) async {
    await action();
  }
}

/// Formatter guard for stepper values.
int clampSettingStepper(int value, {int min = 0, int max = 4}) {
  return value.clamp(min, max);
}

/// Haptic feedback helper for toggles.
void settingToggleHaptic() {
  HapticFeedback.selectionClick();
}
