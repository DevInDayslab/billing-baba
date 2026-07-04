import 'dart:async';

import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/models/unit_model.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/add_conversion_dialog.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/add_unit_dialog.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/inventory_async_list.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/inventory_list_header.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/inventory_primary_button.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/inventory_search_field.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/inventory_split_layout.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/inventory_styles.dart';
import 'package:billing_baba/features/inventory/providers/inventory_providers.dart';
import 'package:billing_baba/features/inventory/providers/inventory_units_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UnitsTabContent extends ConsumerStatefulWidget {
  const UnitsTabContent({super.key});

  @override
  ConsumerState<UnitsTabContent> createState() => _UnitsTabContentState();
}

class _UnitsTabContentState extends ConsumerState<UnitsTabContent> {
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    ref.read(unitSearchQueryProvider.notifier).query = query;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      final trimmed = query.trim();
      ref.read(unitBackendSearchProvider.notifier).query = trimmed;
      unawaited(
        ref
            .read(inventoryUnitsProvider.notifier)
            .refresh(searchQuery: trimmed.isEmpty ? null : trimmed),
      );
    });
  }

  Future<void> _confirmDeleteUnit(BuildContext context, InventoryUnit unit) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete unit?'),
        content: Text('Delete "${unit.fullName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final error = await ref
        .read(inventoryUnitsProvider.notifier)
        .deleteUnit(unit.id);
    if (!context.mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final units = ref.watch(unitsProvider);
    final unitsAsync = ref.watch(inventoryUnitsProvider);
    final selectedId = ref.watch(selectedUnitIdProvider);

    return InventorySplitLayout(
      listPanel: _UnitsListPanel(
        units: units,
        unitsAsync: unitsAsync,
        selectedId: selectedId,
        onSearchChanged: _onSearchChanged,
        onRefresh: () => ref.read(inventoryUnitsProvider.notifier).refresh(
          searchQuery: ref.read(unitBackendSearchProvider),
        ),
        onUnitSelected: (id) {
          ref.read(selectedUnitIdProvider.notifier).selected = id;
          unawaited(ref.read(inventoryUnitsProvider.notifier).loadUnitDetail(id));
        },
        onAddUnit: () => showAddUnitDialog(context),
        onMenuSelected: (value, unit) {
          switch (value) {
            case 'Edit':
              showAddUnitDialog(context, editUnit: unit);
            case 'Delete':
              unawaited(_confirmDeleteUnit(context, unit));
          }
        },
      ),
      detailPanel: selectedId == null
          ? const InventoryDetailPlaceholder(
              message: 'Select a unit to view details',
            )
          : _UnitDetailPanel(
              unit: units.firstWhere(
                (unit) => unit.id == selectedId,
                orElse: () => units.first,
              ),
            ),
    );
  }
}

class _UnitsListPanel extends StatelessWidget {
  const _UnitsListPanel({
    required this.units,
    required this.unitsAsync,
    required this.selectedId,
    required this.onSearchChanged,
    required this.onRefresh,
    required this.onUnitSelected,
    required this.onAddUnit,
    required this.onMenuSelected,
  });

  final List<InventoryUnit> units;
  final AsyncValue<List<InventoryUnit>> unitsAsync;
  final String? selectedId;
  final ValueChanged<String> onSearchChanged;
  final Future<void> Function() onRefresh;
  final ValueChanged<String> onUnitSelected;
  final VoidCallback onAddUnit;
  final void Function(String value, InventoryUnit unit) onMenuSelected;

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
          child: InventoryAsyncList<InventoryUnit>(
            asyncValue: unitsAsync,
            items: units,
            onRefresh: onRefresh,
            emptyMessage: 'No units found',
            itemBuilder: (context, unit) {
              final isSelected = unit.id == selectedId;
              return Material(
                color: isSelected
                    ? inventorySelectedRowColor
                    : Colors.transparent,
                child: Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: inventoryCardBorder),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => onUnitSelected(unit.id),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: 12,
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
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: AppSpacing.sm),
                        child: InventoryListRowMenu(
                          onSelected: (value) =>
                              onMenuSelected(value, unit),
                        ),
                      ),
                    ],
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
                onPressed: () => showAddConversionDialog(
                  context,
                  initialBaseUnitId: unit.id,
                ),
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
                      .query = query,
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
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('${conversion.factor}x'),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, size: 18),
                                    tooltip: 'Delete conversion',
                                    onPressed: () async {
                                      final error = await ref
                                          .read(inventoryUnitsProvider.notifier)
                                          .deleteConversion(
                                            conversion.id,
                                            unit.id,
                                          );
                                      if (!context.mounted) return;
                                      if (error != null) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(content: Text(error)),
                                        );
                                      }
                                    },
                                  ),
                                ],
                              ),
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
