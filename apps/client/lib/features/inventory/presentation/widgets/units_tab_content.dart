import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/models/unit_model.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/inventory_list_header.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/inventory_primary_button.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/inventory_search_field.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/inventory_split_layout.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/inventory_styles.dart';
import 'package:billing_baba/features/inventory/providers/inventory_catalog.dart';
import 'package:billing_baba/features/inventory/providers/inventory_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UnitsTabContent extends ConsumerWidget {
  const UnitsTabContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final units = ref.watch(unitsProvider);
    final selectedId = ref.watch(selectedUnitIdProvider);

    return InventorySplitLayout(
      listPanel: _UnitsListPanel(
        units: units,
        selectedId: selectedId,
        onSearchChanged: (query) =>
            ref.read(unitSearchQueryProvider.notifier).update(query),
        onUnitSelected: (id) =>
            ref.read(selectedUnitIdProvider.notifier).select(id),
        onAddUnit: () => _showComingSoonSnackBar(context, 'Add Units'),
      ),
      detailPanel: selectedId == null
          ? const InventoryDetailPlaceholder(
              message: 'Select a unit to view details',
            )
          : _UnitDetailPanel(
              unit: units.firstWhere(
                (unit) => unit.id == selectedId,
                orElse: () => InventoryCatalog.units.first,
              ),
            ),
    );
  }

  void _showComingSoonSnackBar(BuildContext context, String action) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$action coming soon')),
    );
  }
}

class _UnitsListPanel extends StatelessWidget {
  const _UnitsListPanel({
    required this.units,
    required this.selectedId,
    required this.onSearchChanged,
    required this.onUnitSelected,
    required this.onAddUnit,
  });

  final List<InventoryUnit> units;
  final String? selectedId;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onUnitSelected;
  final VoidCallback onAddUnit;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            children: [
              InventorySearchField(
                hint: 'Search',
                onChanged: onSearchChanged,
              ),
              const SizedBox(height: AppSpacing.sm),
              InventoryPrimaryButton(
                label: 'Add Units',
                onPressed: onAddUnit,
              ),
            ],
          ),
        ),
        const InventoryListHeader(
          columns: [
            InventoryListColumn(label: 'FULLNAME'),
            InventoryListColumn(label: 'SHORTNAME'),
          ],
        ),
        Expanded(
          child: units.isEmpty
              ? const InventoryListEmptyState(message: 'No units found')
              : ListView.builder(
                  itemCount: units.length,
                  itemBuilder: (context, index) {
                    final unit = units[index];
                    final isSelected = unit.id == selectedId;
                    return Material(
                      color: isSelected
                          ? inventorySelectedRowColor
                          : Colors.transparent,
                      child: InkWell(
                        onTap: () => onUnitSelected(unit.id),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: 12,
                          ),
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: inventoryCardBorder),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  unit.fullName,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  unit.shortName,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              const InventoryListRowMenu(),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _UnitDetailPanel extends ConsumerWidget {
  const _UnitDetailPanel({required this.unit});

  final InventoryUnit unit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversionQuery = ref.watch(unitConversionSearchQueryProvider);
    final conversions = unit.conversions
        .where(
          (conversion) =>
              conversionQuery.isEmpty ||
              conversion.label.toLowerCase().contains(
                conversionQuery.toLowerCase(),
              ),
        )
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  unit.fullName,
                  style: InventoryStyles.panelTitleStyle,
                ),
              ),
              InventorySecondaryButton(
                label: 'Add Conversion',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Add Conversion coming soon')),
                  );
                },
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Row(
            children: [
              const Text('UNITS', style: InventoryStyles.listHeaderStyle),
              const Spacer(),
              SizedBox(
                width: 200,
                child: InventorySearchField(
                  hint: 'Search',
                  onChanged: (query) => ref
                      .read(unitConversionSearchQueryProvider.notifier)
                      .update(query),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(color: inventoryCardBorder),
              borderRadius: AppRadius.mdBorder,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: 10,
                  ),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF5F5F5),
                    border: Border(
                      bottom: BorderSide(color: inventoryCardBorder),
                    ),
                  ),
                  child: const Text(
                    'CONVERSION',
                    style: InventoryStyles.listHeaderStyle,
                  ),
                ),
                SizedBox(
                  height: 280,
                  child: conversions.isEmpty
                      ? const Center(
                          child: Text(
                            'No Rows To Show',
                            style: InventoryStyles.emptyStateStyle,
                          ),
                        )
                      : ListView.builder(
                          itemCount: conversions.length,
                          itemBuilder: (context, index) {
                            final conversion = conversions[index];
                            return ListTile(
                              dense: true,
                              title: Text(conversion.label),
                              trailing: Text('${conversion.factor}x'),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
