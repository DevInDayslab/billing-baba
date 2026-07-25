import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/core/widgets/app_button.dart';
import 'package:billing_baba/core/widgets/mobile/mobile_bottom_sheet.dart';
import 'package:billing_baba/core/widgets/mobile/mobile_option_sheet.dart';
import 'package:billing_baba/core/widgets/mobile/mobile_sheet_models.dart';
import 'package:flutter/material.dart';

/// Quick Actions — icon grid for shortcuts (home, party detail, etc.).
Future<void> showMobileQuickActionsSheet({
  required BuildContext context,
  required List<MobileQuickAction> actions,
  String title = 'Quick Actions',
}) {
  if (actions.isEmpty) return Future.value();

  return showMobileBottomSheet<void>(
    context: context,
    title: title,
    builder: (sheetContext) {
      return _QuickActionsGrid(
        actions: actions,
        onAction: (action) {
          Navigator.of(sheetContext).pop();
          action.onTap();
        },
      );
    },
  );
}

/// Filters — single-select list with radio indicators.
Future<T?> showMobileFilterSheet<T>({
  required BuildContext context,
  required String title,
  required List<MobileOption<T>> options,
  T? selected,
}) {
  return showMobileOptionSheet<T>(
    context: context,
    title: title,
    options: options,
    selected: selected,
  );
}

/// Payment — scrollable form shell with optional sticky footer actions.
Future<T?> showMobilePaymentSheet<T>({
  required BuildContext context,
  required String title,
  required WidgetBuilder builder,
  String? subtitle,
  Widget? footer,
  bool isDismissible = true,
  double maxHeightFraction = 0.92,
}) {
  return showMobileBottomSheet<T>(
    context: context,
    isDismissible: isDismissible,
    maxHeightFraction: maxHeightFraction,
    titleWidget: _SheetTitle(title: title, subtitle: subtitle),
    footer: footer,
    builder: builder,
  );
}

/// Add Options — list of create/add choices with colored icons.
Future<void> showMobileAddOptionsSheet({
  required BuildContext context,
  required List<MobileAddOption> options,
  String title = 'Add',
}) {
  if (options.isEmpty) return Future.value();

  return showMobileBottomSheet<void>(
    context: context,
    title: title,
    builder: (sheetContext) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final option in options)
            _AddOptionTile(
              option: option,
              onTap: option.enabled
                  ? () {
                      Navigator.of(sheetContext).pop();
                      option.onTap();
                    }
                  : null,
            ),
        ],
      );
    },
  );
}

/// Menu — navigational list with optional chevrons.
Future<void> showMobileMenuSheet({
  required BuildContext context,
  required List<MobileSheetAction> items,
  String title = 'Menu',
}) {
  return showMobileMoreActionsSheet(
    context: context,
    title: title,
    actions: items,
    showChevrons: true,
  );
}

/// More Actions — icon list for contextual actions on a row or screen.
Future<void> showMobileMoreActionsSheet({
  required BuildContext context,
  required List<MobileSheetAction> actions,
  String title = 'More Actions',
  bool showChevrons = false,
}) {
  if (actions.isEmpty) return Future.value();

  return showMobileBottomSheet<void>(
    context: context,
    title: title,
    builder: (sheetContext) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final action in actions)
            _ActionTile(
              action: action,
              showChevron: showChevrons,
              onTap: action.enabled
                  ? () {
                      Navigator.of(sheetContext).pop();
                      action.onTap();
                    }
                  : null,
            ),
        ],
      );
    },
  );
}

/// Standard payment sheet footer with cancel + primary save.
Widget mobilePaymentSheetFooter({
  required VoidCallback onCancel,
  required VoidCallback onSave,
  String cancelLabel = 'Cancel',
  String saveLabel = 'Save',
  bool isSaving = false,
}) {
  return Row(
    children: [
      Expanded(
        child: OutlinedButton(
          onPressed: isSaving ? null : onCancel,
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
            shape: RoundedRectangleBorder(borderRadius: AppRadius.mdBorder),
          ),
          child: Text(cancelLabel),
        ),
      ),
      const SizedBox(width: AppSpacing.md),
      Expanded(
        child: AppButton(
          label: saveLabel,
          isLoading: isSaving,
          onPressed: isSaving ? null : onSave,
        ),
      ),
    ],
  );
}

class _SheetTitle extends StatelessWidget {
  const _SheetTitle({required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            subtitle!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}

class _QuickActionsGrid extends StatelessWidget {
  const _QuickActionsGrid({
    required this.actions,
    required this.onAction,
  });

  final List<MobileQuickAction> actions;
  final ValueChanged<MobileQuickAction> onAction;

  static const _columns = 4;

  @override
  Widget build(BuildContext context) {
    final rows = <List<MobileQuickAction>>[];
    for (var i = 0; i < actions.length; i += _columns) {
      final end = (i + _columns).clamp(0, actions.length);
      rows.add(actions.sublist(i, end));
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var rowIndex = 0; rowIndex < rows.length; rowIndex++) ...[
          if (rowIndex > 0) const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              for (var col = 0; col < _columns; col++) ...[
                if (col > 0) const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: col < rows[rowIndex].length
                      ? _QuickActionTile(
                          action: rows[rowIndex][col],
                          onTap: rows[rowIndex][col].enabled
                              ? () => onAction(rows[rowIndex][col])
                              : null,
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({required this.action, this.onTap});

  final MobileQuickAction action;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final iconColor = action.iconColor ?? AppColors.primary;
    final backgroundColor =
        action.backgroundColor ?? iconColor.withValues(alpha: 0.12);

    return Opacity(
      opacity: onTap == null ? 0.45 : 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.mdBorder,
        child: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(action.icon, color: iconColor, size: 26),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              action.label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
                fontSize: 11,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddOptionTile extends StatelessWidget {
  const _AddOptionTile({required this.option, this.onTap});

  final MobileAddOption option;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final iconColor = option.iconColor ?? AppColors.primary;
    final backgroundColor =
        option.backgroundColor ?? iconColor.withValues(alpha: 0.12);

    return Opacity(
      opacity: onTap == null ? 0.45 : 1,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.mdBorder,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.md,
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: AppRadius.mdBorder,
                  ),
                  child: Icon(option.icon, color: iconColor, size: 22),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        option.label,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (option.subtitle != null) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          option.subtitle!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.action,
    this.onTap,
    this.showChevron = false,
  });

  final MobileSheetAction action;
  final VoidCallback? onTap;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    final color = !action.enabled
        ? AppColors.textSecondary
        : action.isDestructive
        ? AppColors.error
        : AppColors.textPrimary;

    return Opacity(
      opacity: onTap == null ? 0.45 : 1,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.md,
            ),
            child: Row(
              children: [
                if (action.icon != null) ...[
                  Icon(action.icon, color: color),
                  const SizedBox(width: AppSpacing.md),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        action.label,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (action.subtitle != null) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          action.subtitle!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (showChevron || action.showChevron)
                  Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textSecondary.withValues(alpha: 0.7),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
