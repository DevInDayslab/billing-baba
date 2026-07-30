import 'dart:async';

import 'package:billing_baba/core/routing/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/application/item_settings_provider.dart';
import 'package:billing_baba/features/inventory/models/item_settings.dart';
import 'package:billing_baba/features/inventory/presentation/mobile/widgets/item_settings/item_settings_mobile_rows.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Field toggles shown from the Add Item dialog settings gear.
Future<void> showMobileAddItemSettingsSheet(BuildContext context) {
  return showGeneralDialog<void>(
    context: context,
    useRootNavigator: true,
    barrierLabel: 'Dismiss',
    barrierColor: Colors.black.withValues(alpha: 0.45),
    transitionDuration: const Duration(milliseconds: 250),
    pageBuilder: (dialogContext, _, _) {
      return GestureDetector(
        onTap: () => Navigator.of(dialogContext).pop(),
        behavior: HitTestBehavior.opaque,
        child: Material(
          color: Colors.transparent,
          child: Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () {},
              child: _AddItemSettingsPanel(dialogContext: dialogContext),
            ),
          ),
        ),
      );
    },
    transitionBuilder: (context, animation, _, child) {
      return SlideTransition(
        position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
            .animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            ),
        child: child,
      );
    },
  );
}

class _AddItemSettingsPanel extends ConsumerWidget {
  const _AddItemSettingsPanel({required this.dialogContext});

  final BuildContext dialogContext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(itemSettingsProvider);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final panelWidth = screenWidth * 0.88;

    return Material(
      color: AppColors.surface,
      elevation: 16,
      shadowColor: Colors.black.withValues(alpha: 0.15),
      child: SizedBox(
        width: panelWidth,
        height: MediaQuery.sizeOf(context).height,
        child: SafeArea(
          child: settingsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => _ErrorBody(
              onRetry: () => ref.invalidate(itemSettingsProvider),
            ),
            data: (settings) => _AddItemSettingsBody(
              dialogContext: dialogContext,
              initialSettings: settings,
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Could not load item settings',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

class _AddItemSettingsBody extends ConsumerStatefulWidget {
  const _AddItemSettingsBody({
    required this.dialogContext,
    required this.initialSettings,
  });

  final BuildContext dialogContext;
  final ItemSettings initialSettings;

  @override
  ConsumerState<_AddItemSettingsBody> createState() =>
      _AddItemSettingsBodyState();
}

class _AddItemSettingsBodyState extends ConsumerState<_AddItemSettingsBody> {
  late ItemSettings _draft;

  @override
  void initState() {
    super.initState();
    _draft = widget.initialSettings;
  }

  void _update(ItemSettingsUpdater updater) {
    final next = updater(_draft);
    setState(() => _draft = next);
    unawaited(_persist(next));
  }

  Future<void> _persist(ItemSettings settings) async {
    try {
      await ref.read(itemSettingsProvider.notifier).save(settings);
    } on Object catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save settings: $error')),
      );
    }
  }

  Future<void> _editDescription(ItemSettings settings) async {
    final controller = TextEditingController(text: settings.descriptionText);
    final result = await showModalBottomSheet<String>(
      context: widget.dialogContext,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (editContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            top: AppSpacing.lg,
            bottom: MediaQuery.viewInsetsOf(editContext).bottom + AppSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Default Description',
                style: Theme.of(editContext).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: controller,
                maxLines: 4,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Description',
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                    borderRadius: AppRadius.mdBorder,
                    borderSide: const BorderSide(color: Color(0xFFE8EAED)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: AppRadius.mdBorder,
                    borderSide: const BorderSide(color: Color(0xFFE8EAED)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: AppRadius.mdBorder,
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              FilledButton(
                onPressed: () =>
                    Navigator.of(editContext).pop(controller.text.trim()),
                child: const Text('Save'),
              ),
            ],
          ),
        );
      },
    );
    controller.dispose();
    if (result == null || !mounted) return;
    _update((s) => s.copyWith(descriptionText: result));
  }

  void _openMoreSettings() {
    final router = GoRouter.of(context);
    Navigator.of(widget.dialogContext).pop();
    unawaited(router.push(AppRoutes.itemsSettings));
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature coming soon')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final draft = _draft;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SheetHeader(
          onClose: () => Navigator.of(widget.dialogContext).pop(),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ItemSettingsMobileNavTile(
                  label: 'Item Custom Fields',
                  infoTooltip: 'Create custom fields for items.',
                  isPremium: true,
                  onTap: () => _showComingSoon('Item custom fields'),
                ),
                const _FullWidthDivider(),
                ItemSettingsMobileNavTile(
                  label: 'Additional Item Fields',
                  isPremium: true,
                  onTap: () => _showComingSoon('Additional item fields'),
                ),
                const _FullWidthDivider(),
                ItemSettingsMobileCheckboxTile(
                  label: 'Wholesale Price',
                  infoTooltip: 'Track wholesale pricing tiers on items.',
                  isPremium: true,
                  value: draft.wholesalePrice,
                  onChanged: (value) => _update(
                    (s) => s.copyWith(wholesalePrice: value ?? false),
                  ),
                ),
                const _FullWidthDivider(),
                ItemSettingsMobileCheckboxTile(
                  label: 'Barcode Scan',
                  infoTooltip:
                      'Allow barcode scanning when adding or selling items.',
                  value: draft.barcodeScanningEnabled,
                  onChanged: (value) => _update(
                    (s) => s.copyWith(barcodeScanningEnabled: value ?? false),
                  ),
                  child: ItemSettingsMobileRadioGroup<BarcodeScannerType>(
                    value: draft.barcodeScannerType,
                    options: BarcodeScannerType.values,
                    labelBuilder: (type) => type.label,
                    onChanged: (type) =>
                        _update((s) => s.copyWith(barcodeScannerType: type)),
                  ),
                ),
                const _FullWidthDivider(),
                ItemSettingsMobileCheckboxTile(
                  label: 'Item Category',
                  infoTooltip: 'Organize items into categories.',
                  value: draft.itemCategory,
                  onChanged: (value) =>
                      _update((s) => s.copyWith(itemCategory: value ?? false)),
                ),
                const _FullWidthDivider(),
                ItemSettingsMobileCheckboxTile(
                  label: 'Description',
                  infoTooltip: 'Show description field when creating items.',
                  value: draft.descriptionEnabled,
                  onChanged: (value) => _update(
                    (s) => s.copyWith(descriptionEnabled: value ?? false),
                  ),
                  child: ItemSettingsMobileDescriptionFooter(
                    descriptionText: draft.descriptionText,
                    onEdit: () => _editDescription(draft),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                _ServiceRemindersBanner(
                  onTap: () => _showComingSoon('Service reminders'),
                ),
              ],
            ),
          ),
        ),
        _MoreSettingsFooter(onTap: _openMoreSettings),
      ],
    );
  }
}

class _SheetHeader extends StatelessWidget {
  const _SheetHeader({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Item Settings',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close_rounded),
            color: AppColors.textSecondary,
            iconSize: 22,
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints.tightFor(width: 36, height: 36),
          ),
        ],
      ),
    );
  }
}

class _FullWidthDivider extends StatelessWidget {
  const _FullWidthDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, thickness: 1, color: Color(0xFFE8EAED));
  }
}

class _ServiceRemindersBanner extends StatelessWidget {
  const _ServiceRemindersBanner({required this.onTap});

  final VoidCallback onTap;

  static const _bannerColor = Color(0xFFFFF8E1);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: _bannerColor,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.md,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Flexible(
                          child: Text(
                            'Service Reminders',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Icon(
                          Icons.workspace_premium,
                          size: 16,
                          color: Colors.deepPurple.shade400,
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textSecondary.withValues(alpha: 0.7),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Retain customers and ensure timely service completion with our service reminders',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textPrimary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MoreSettingsFooter extends StatelessWidget {
  const _MoreSettingsFooter({required this.onTap});

  final VoidCallback onTap;

  static const _footerColor = Color(0xFFF0F4F8);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _footerColor,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.md,
            horizontal: AppSpacing.lg,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.settings_outlined,
                size: 18,
                color: AppColors.primary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'More Settings',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
