import 'dart:async';

import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_card.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_settings_detail_page.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_settings_tiles.dart';
import 'package:billing_baba/shared/widgets/mobile/setting_tile.dart';
import 'package:billing_baba/features/inventory/application/item_settings_provider.dart';
import 'package:billing_baba/features/inventory/models/item_settings_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Vyapar-style item module settings screen.
class MobileItemSettingsPage extends ConsumerWidget {
  const MobileItemSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(itemSettingsProvider);

    return settingsAsync.when(
      loading: () => const MobileSettingsDetailPage(
        title: 'Item Settings',
        isLoading: true,
        body: SizedBox.shrink(),
      ),
      error: (error, _) => MobileSettingsDetailPage(
        title: 'Item Settings',
        errorMessage: 'Failed to load item settings',
        onRetry: () => ref.invalidate(itemSettingsProvider),
        body: const SizedBox.shrink(),
      ),
      data: (settings) => MobileSettingsDetailPage(
        title: 'Item Settings',
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.lg,
          AppSpacing.xl,
        ),
        body: _ItemSettingsBody(settings: settings),
      ),
    );
  }
}

class _ItemSettingsBody extends ConsumerWidget {
  const _ItemSettingsBody({required this.settings});

  final ItemSettingsState settings;

  Future<void> _update(
    WidgetRef ref,
    ItemSettingsState Function(ItemSettingsState) updater,
  ) {
    settingToggleHaptic();
    return ref.read(itemSettingsProvider.notifier).updateSettings(updater);
  }

  Future<void> _editDescription(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController(text: settings.descriptionText);
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Edit Description'),
          content: TextField(
            controller: controller,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Default item description',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(controller.text),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
    controller.dispose();

    if (result == null) return;
    await _update(ref, (state) => state.copyWith(descriptionText: result));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = settings.controlsEnabled;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SettingsCard(
          children: [
            SettingTile.switchTile(
              title: 'Enable Item',
              value: settings.enableItem,
              showInfoIcon: true,
              onInfoTap: () => showSettingInfo(
                context,
                'Turn item management on or off for this business.',
              ),
              onChanged: (value) =>
                  _update(ref, (state) => state.copyWith(enableItem: value)),
            ),
            const _TileDivider(),
            SettingTile.dropdown<ItemTypeSetting>(
              context: context,
              title: 'Item Type',
              value: settings.itemType,
              options: ItemTypeSetting.values,
              labelBuilder: (option) => option.label,
              enabled: enabled,
              showInfoIcon: true,
              onInfoTap: () => showSettingInfo(
                context,
                'Choose whether you sell products, services, or both.',
              ),
              onChanged: (value) =>
                  _update(ref, (state) => state.copyWith(itemType: value)),
            ),
          ],
        ),
        SettingsSection(
          title: 'Barcode',
          children: [
            SettingTile.switchTile(
              title: 'Barcode Scanning',
              value: settings.barcodeScanning,
              enabled: enabled,
              showInfoIcon: true,
              onInfoTap: () => showSettingInfo(
                context,
                'Scan barcodes while adding or selling items.',
              ),
              onChanged: (value) => _update(
                ref,
                (state) => state.copyWith(barcodeScanning: value),
              ),
            ),
            AnimatedSettingGroup(
              visible: settings.barcodeChildrenEnabled,
              children: [
                SettingTile.checkboxTile(
                  title: 'Mobile POS default',
                  value: settings.mobilePosDefaultScanner,
                  indent: AppSpacing.lg,
                  enabled: settings.barcodeChildrenEnabled,
                  onChanged: (value) => _update(
                    ref,
                    (state) => state.copyWith(mobilePosDefaultScanner: value),
                  ),
                ),
                for (final scanner in ItemScannerType.values)
                  SettingTile.radio<ItemScannerType>(
                    title: scanner.label,
                    groupValue: settings.scannerType,
                    tileValue: scanner,
                    indent: AppSpacing.lg,
                    enabled: settings.barcodeChildrenEnabled,
                    onChanged: (value) => _update(
                      ref,
                      (state) => state.copyWith(scannerType: value),
                    ),
                  ),
              ],
            ),
          ],
        ),
        _SettingsCard(
          children: [
            SettingTile.switchTile(
              title: 'Stock Maintenance',
              value: settings.stockMaintenance,
              enabled: enabled,
              onChanged: (value) => _update(
                ref,
                (state) => state.copyWith(stockMaintenance: value),
              ),
            ),
            const _TileDivider(),
            SettingTile.switchTile(
              title: 'Manufacturing',
              value: settings.manufacturing,
              enabled: enabled,
              onChanged: (value) => _update(
                ref,
                (state) => state.copyWith(manufacturing: value),
              ),
            ),
            const _TileDivider(),
            SettingTile.switchTile(
              title: 'Item Units',
              value: settings.itemUnits,
              enabled: enabled,
              onChanged: (value) =>
                  _update(ref, (state) => state.copyWith(itemUnits: value)),
            ),
            AnimatedSettingGroup(
              visible: settings.itemUnitsChildrenEnabled,
              children: [
                SettingTile.switchTile(
                  title: 'Default Unit',
                  value: settings.defaultUnit,
                  indent: AppSpacing.lg,
                  enabled: settings.itemUnitsChildrenEnabled,
                  onChanged: (value) => _update(
                    ref,
                    (state) => state.copyWith(defaultUnit: value),
                  ),
                ),
                SettingTile.navigation(
                  title: 'Change Default Unit',
                  value: settings.defaultUnitName,
                  indent: AppSpacing.lg,
                  enabled: settings.defaultUnitNavigationEnabled,
                  onTap: () => context.push(AppRoutes.itemsUnits),
                ),
              ],
            ),
            const _TileDivider(),
            SettingTile.switchTile(
              title: 'Item Category',
              value: settings.itemCategory,
              enabled: enabled,
              onChanged: (value) => _update(
                ref,
                (state) => state.copyWith(itemCategory: value),
              ),
            ),
          ],
        ),
        _SettingsCard(
          children: [
            SettingTile.switchTile(
              title: 'Party Wise Item Rate',
              value: settings.partyWiseItemRate,
              enabled: enabled,
              onChanged: (value) => _update(
                ref,
                (state) => state.copyWith(partyWiseItemRate: value),
              ),
            ),
            const _TileDivider(),
            SettingTile.switchTile(
              title: 'Wholesale Price',
              value: settings.wholesalePrice,
              enabled: enabled,
              onChanged: (value) => _update(
                ref,
                (state) => state.copyWith(wholesalePrice: value),
              ),
            ),
            const _TileDivider(),
            SettingTile.stepperTile(
              title: 'Quantity Decimal Places',
              value: settings.quantityDecimalPlaces,
              enabled: enabled,
              onChanged: (value) => _update(
                ref,
                (state) => state.copyWith(
                  quantityDecimalPlaces: clampSettingStepper(value),
                ),
              ),
            ),
          ],
        ),
        _SettingsCard(
          children: [
            SettingTile.switchTile(
              title: 'Item Wise Tax',
              value: settings.itemWiseTax,
              enabled: enabled,
              onChanged: (value) =>
                  _update(ref, (state) => state.copyWith(itemWiseTax: value)),
            ),
            AnimatedSettingGroup(
              visible: settings.taxChildrenEnabled,
              children: [
                SettingTile.switchTile(
                  title: 'Calculate Tax on MRP',
                  value: settings.calculateTaxOnMrp,
                  indent: AppSpacing.lg,
                  enabled: settings.taxChildrenEnabled,
                  onChanged: (value) => _update(
                    ref,
                    (state) => state.copyWith(calculateTaxOnMrp: value),
                  ),
                ),
              ],
            ),
            const _TileDivider(),
            SettingTile.switchTile(
              title: 'Item Wise Discount',
              value: settings.itemWiseDiscount,
              enabled: enabled,
              onChanged: (value) => _update(
                ref,
                (state) => state.copyWith(itemWiseDiscount: value),
              ),
            ),
            const _TileDivider(),
            SettingTile.switchTile(
              title: 'Update Sale Price from TXN',
              value: settings.updateSalePriceFromTxn,
              enabled: enabled,
              onChanged: (value) => _update(
                ref,
                (state) => state.copyWith(updateSalePriceFromTxn: value),
              ),
            ),
            const _TileDivider(),
            SettingTile.navigation(
              title: 'Additional Item Fields',
              enabled: enabled,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Additional Item Fields coming soon'),
                  ),
                );
              },
            ),
            const _TileDivider(),
            SettingTile.navigation(
              title: 'Item Custom Fields',
              enabled: enabled,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Item Custom Fields coming soon'),
                  ),
                );
              },
            ),
            const _TileDivider(),
            SettingTile.navigation(
              title: 'Description',
              enabled: enabled,
              trailing: Switch.adaptive(
                value: settings.descriptionEnabled,
                onChanged: enabled
                    ? (value) => _update(
                        ref,
                        (state) => state.copyWith(descriptionEnabled: value),
                      )
                    : null,
                activeThumbColor: Colors.white,
                activeTrackColor: const Color(0xFF42A5F5),
              ),
              onTap: settings.descriptionEnabled && enabled
                  ? () => unawaited(_editDescription(context, ref))
                  : null,
              showChevron: settings.descriptionEnabled && enabled,
            ),
          ],
        ),
        SettingsSection(
          title: 'GST',
          children: [
            SettingTile.switchTile(
              title: 'HSN/SAC Code',
              value: settings.hsnSacCode,
              enabled: enabled,
              onChanged: (value) =>
                  _update(ref, (state) => state.copyWith(hsnSacCode: value)),
            ),
            SettingTile.switchTile(
              title: 'Additional CESS',
              value: settings.additionalCess,
              enabled: enabled,
              onChanged: (value) => _update(
                ref,
                (state) => state.copyWith(additionalCess: value),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: MobileCard(
        padding: EdgeInsets.zero,
        child: Column(children: children),
      ),
    );
  }
}

class _TileDivider extends StatelessWidget {
  const _TileDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, thickness: 1, color: Color(0xFFE8EAED));
  }
}
