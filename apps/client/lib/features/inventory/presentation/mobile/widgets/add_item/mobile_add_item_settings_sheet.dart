import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/core/widgets/mobile/mobile_bottom_sheet.dart';
import 'package:billing_baba/core/widgets/mobile/mobile_card.dart';
import 'package:billing_baba/features/inventory/application/item_settings_provider.dart';
import 'package:billing_baba/features/inventory/models/item_settings.dart';
import 'package:billing_baba/features/inventory/presentation/mobile/widgets/item_settings/item_settings_mobile_rows.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Field toggles shown from the Add Item dialog settings gear.
Future<void> showMobileAddItemSettingsSheet(BuildContext context) {
  return showMobileBottomSheet<void>(
    context: context,
    useRootNavigator: false,
    title: 'Item Settings',
    maxHeightFraction: 0.75,
    builder: (sheetContext) => const _AddItemSettingsSheet(),
  );
}

class _AddItemSettingsSheet extends ConsumerStatefulWidget {
  const _AddItemSettingsSheet();

  @override
  ConsumerState<_AddItemSettingsSheet> createState() =>
      _AddItemSettingsSheetState();
}

class _AddItemSettingsSheetState extends ConsumerState<_AddItemSettingsSheet> {
  ItemSettings? _draft;
  bool _saving = false;

  void _update(ItemSettingsUpdater updater) {
    final current = _draft;
    if (current == null) return;
    setState(() => _draft = updater(current));
  }

  Future<void> _editDescription(ItemSettings settings) async {
    final controller = TextEditingController(text: settings.descriptionText);
    final result = await showModalBottomSheet<String>(
      context: context,
      useRootNavigator: false,
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

  Future<void> _save() async {
    final draft = _draft;
    if (draft == null || _saving) return;

    setState(() => _saving = true);
    try {
      await ref.read(itemSettingsProvider.notifier).save(draft);
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item settings saved')),
      );
    } on Object catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save settings: $error')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(itemSettingsProvider);

    return settingsAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Could not load item settings',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton(
            onPressed: () => ref.invalidate(itemSettingsProvider),
            child: const Text('Retry'),
          ),
        ],
      ),
      data: (settings) {
        _draft ??= settings;
        final draft = _draft!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            MobileCard(
              padding: EdgeInsets.zero,
              child: Material(
                color: AppColors.surface,
                borderRadius: AppRadius.lgBorder,
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    ItemSettingsMobileCheckboxTile(
                      label: 'Wholesale Price',
                      infoTooltip: 'Track wholesale pricing tiers on items.',
                      isPremium: true,
                      value: draft.wholesalePrice,
                      onChanged: (value) => _update(
                        (s) => s.copyWith(wholesalePrice: value ?? false),
                      ),
                    ),
                    const ItemSettingsMobileDivider(),
                    ItemSettingsMobileCheckboxTile(
                      label: 'Barcode Scan',
                      infoTooltip:
                          'Allow barcode scanning when adding or selling items.',
                      value: draft.barcodeScanningEnabled,
                      onChanged: (value) => _update(
                        (s) =>
                            s.copyWith(barcodeScanningEnabled: value ?? false),
                      ),
                      child: ItemSettingsMobileRadioGroup<BarcodeScannerType>(
                        value: draft.barcodeScannerType,
                        options: BarcodeScannerType.values,
                        labelBuilder: (type) => type.label,
                        onChanged: (type) =>
                            _update((s) => s.copyWith(barcodeScannerType: type)),
                      ),
                    ),
                    const ItemSettingsMobileDivider(),
                    ItemSettingsMobileCheckboxTile(
                      label: 'Item Category',
                      infoTooltip: 'Organize items into categories.',
                      value: draft.itemCategory,
                      onChanged: (value) =>
                          _update((s) => s.copyWith(itemCategory: value ?? false)),
                    ),
                    const ItemSettingsMobileDivider(),
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
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: !_saving ? _save : null,
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Save'),
              ),
            ),
          ],
        );
      },
    );
  }
}
