import 'dart:async';

import 'package:billing_baba/core/routing/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/core/widgets/app_error.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_app_bar.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_bottom_navigation.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_bottom_sheet.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_empty_state.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_search_field.dart';
import 'package:billing_baba/features/dashboard/presentation/mobile/widgets/mobile_home_fab.dart';
import 'package:billing_baba/features/inventory/application/inventory_items_provider.dart';
import 'package:billing_baba/features/inventory/application/inventory_providers.dart';
import 'package:billing_baba/features/inventory/application/inventory_units_provider.dart';
import 'package:billing_baba/features/inventory/models/item_model.dart';
import 'package:billing_baba/features/inventory/models/unit_model.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/add_conversion_dialog.dart';
import 'package:billing_baba/features/inventory/presentation/mobile/widgets/units/mobile_add_unit_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Mobile units list with search, conversions, and add/edit/delete.
class MobileUnitsScreen extends ConsumerStatefulWidget {
  const MobileUnitsScreen({super.key});

  @override
  ConsumerState<MobileUnitsScreen> createState() => _MobileUnitsScreenState();
}

class _MobileUnitsScreenState extends ConsumerState<MobileUnitsScreen> {
  late final TextEditingController _searchController;
  Timer? _debounce;
  final _expandedUnitIds = <String>{};

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    ref.read(unitSearchQueryProvider.notifier).query = query;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      final trimmed = query.trim();
      ref.read(unitBackendSearchProvider.notifier).query = trimmed;
      unawaited(
        ref.read(inventoryUnitsProvider.notifier).refresh(
              searchQuery: trimmed.isEmpty ? null : trimmed,
            ),
      );
    });
  }

  Future<void> _onRefresh() {
    return ref.read(inventoryUnitsProvider.notifier).refresh(
          searchQuery: ref.read(unitBackendSearchProvider),
        );
  }

  Future<void> _addUnit() {
    return showMobileAddUnitSheet(context);
  }

  Future<void> _editUnit(InventoryUnit unit) {
    return showMobileAddUnitSheet(context, editUnit: unit);
  }

  Future<void> _confirmDeleteUnit(InventoryUnit unit) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete unit?'),
        content: Text('Delete "${unit.fullName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final error =
        await ref.read(inventoryUnitsProvider.notifier).deleteUnit(unit.id);
    if (!mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    }
  }

  Future<void> _toggleExpanded(InventoryUnit unit) async {
    final willExpand = !_expandedUnitIds.contains(unit.id);
    setState(() {
      if (willExpand) {
        _expandedUnitIds.add(unit.id);
      } else {
        _expandedUnitIds.remove(unit.id);
      }
    });

    if (willExpand) {
      ref.read(selectedUnitIdProvider.notifier).selected = unit.id;
      await ref.read(inventoryUnitsProvider.notifier).loadUnitDetail(unit.id);
      if (mounted) setState(() {});
    }
  }

  Future<void> _pickUnitAnd({
    required String title,
    required ValueChanged<InventoryUnit> onSelected,
  }) async {
    final units = ref.read(unitsProvider);
    if (units.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add a unit first')),
      );
      return;
    }

    final selected = await showMobileBottomSheet<InventoryUnit>(
      context: context,
      useRootNavigator: true,
      title: title,
      maxHeightFraction: 0.7,
      builder: (_) => ListView.separated(
        shrinkWrap: true,
        itemCount: units.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final unit = units[index];
          return ListTile(
            title: Text(unit.fullName),
            subtitle: Text(unit.shortName),
            onTap: () => Navigator.of(context).pop(unit),
          );
        },
      ),
    );
    if (selected == null || !mounted) return;
    onSelected(selected);
  }

  Future<void> _setConversion() async {
    await _pickUnitAnd(
      title: 'Select base unit',
      onSelected: (unit) {
        unawaited(
          showAddConversionDialog(
            context,
            initialBaseUnitId: unit.id,
          ),
        );
      },
    );
  }

  Future<void> _unitToItems() async {
    await _pickUnitAnd(
      title: 'Select unit',
      onSelected: (unit) {
        unawaited(_showItemsForUnit(unit));
      },
    );
  }

  Future<void> _showItemsForUnit(InventoryUnit unit) async {
    final items = ref.read(inventoryItemsProvider).value ?? const <InventoryItem>[];
    final shortName = unit.shortName.toLowerCase();
    final matching = items
        .where(
          (item) =>
              (item.baseUnitShortName?.toLowerCase() ?? '') == shortName ||
              (item.baseUnitShortName?.toLowerCase() ?? '') ==
                  unit.fullName.toLowerCase(),
        )
        .toList();

    if (!mounted) return;

    await showMobileBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      title: 'Items in ${unit.shortName}',
      maxHeightFraction: 0.75,
      builder: (_) {
        if (matching.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
            child: Text(
              'No items use this unit yet.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          itemCount: matching.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final item = matching[index];
            return ListTile(
              title: Text(item.name),
              subtitle: Text(item.baseUnitShortName ?? unit.shortName),
            );
          },
        );
      },
    );
  }

  Future<void> _deleteConversion(
    InventoryUnit unit,
    UnitConversion conversion,
  ) async {
    final error = await ref
        .read(inventoryUnitsProvider.notifier)
        .deleteConversion(conversion.id, unit.id);
    if (!mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
      return;
    }
    setState(() {});
  }

  bool _hasConversions(InventoryUnit unit) {
    return unit.conversionCount > 0 || unit.conversions.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final units = ref.watch(unitsProvider);
    final unitsAsync = ref.watch(inventoryUnitsProvider);
    final isInitialLoading = unitsAsync.isLoading && units.isEmpty;
    final showError = unitsAsync.hasError && units.isEmpty;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: MobileAppBar(
        showBackButton: true,
        title: 'Units',
        showBusinessHeader: false,
        showNotification: false,
        showSettings: true,
        onSettingsTap: () => context.push(AppRoutes.itemsSettings),
      ),
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.md,
                  AppSpacing.lg,
                  AppSpacing.sm,
                ),
                child: MobileSearchField(
                  controller: _searchController,
                  hint: 'Search Unit',
                  onChanged: _onSearchChanged,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  0,
                  AppSpacing.lg,
                  AppSpacing.sm,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _ActionChipButton(
                        label: 'Set Conversion',
                        onTap: () => unawaited(_setConversion()),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: _ActionChipButton(
                        label: 'Unit to Items',
                        onTap: () => unawaited(_unitToItems()),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: switch ((isInitialLoading, showError, units.isEmpty)) {
                  (true, _, _) => const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  (_, true, _) => Center(
                    child: AppError(
                      message: 'Could not load units',
                      onRetry: _onRefresh,
                    ),
                  ),
                  (_, _, true) => MobileEmptyState(
                    title: 'No units found',
                    message: 'Add a unit to measure your inventory items.',
                    icon: Icons.straighten_outlined,
                    actionLabel: 'Add Unit',
                    onAction: () => unawaited(_addUnit()),
                  ),
                  _ => Stack(
                    children: [
                      RefreshIndicator(
                        onRefresh: _onRefresh,
                        child: ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.only(
                            bottom: MobileBottomNavigation.scrollBottomPadding(
                              context,
                              floatingActionHeight: 44,
                            ),
                          ),
                          itemCount: units.length,
                          separatorBuilder: (_, __) => const Divider(
                            height: 1,
                            thickness: 1,
                            color: Color(0xFFEEEEEE),
                          ),
                          itemBuilder: (context, index) {
                            final unit = units[index];
                            final isExpanded = _expandedUnitIds.contains(unit.id);
                            final hasConversions = _hasConversions(unit);
                            return _UnitListTile(
                              unit: unit,
                              isExpanded: isExpanded,
                              hasConversions: hasConversions,
                              onToggleExpand: hasConversions
                                  ? () => unawaited(_toggleExpanded(unit))
                                  : null,
                              onEdit: () => unawaited(_editUnit(unit)),
                              onDelete: () => unawaited(_confirmDeleteUnit(unit)),
                              onDeleteConversion: (conversion) => unawaited(
                                _deleteConversion(unit, conversion),
                              ),
                              onAddConversion: () => unawaited(
                                showAddConversionDialog(
                                  context,
                                  initialBaseUnitId: unit.id,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      if (unitsAsync.isLoading)
                        const Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: LinearProgressIndicator(minHeight: 2),
                        ),
                    ],
                  ),
                },
              ),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: MobileBottomNavigation.floatingActionBottomOffset(context),
            child: Center(
              child: _AddUnitFab(onPressed: () => unawaited(_addUnit())),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionChipButton extends StatelessWidget {
  const _ActionChipButton({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFE8F0FE),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm + 2,
          ),
          child: Center(
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _UnitListTile extends StatelessWidget {
  const _UnitListTile({
    required this.unit,
    required this.isExpanded,
    required this.hasConversions,
    this.onToggleExpand,
    required this.onEdit,
    required this.onDelete,
    required this.onDeleteConversion,
    required this.onAddConversion,
  });

  final InventoryUnit unit;
  final bool isExpanded;
  final bool hasConversions;
  final VoidCallback? onToggleExpand;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ValueChanged<UnitConversion> onDeleteConversion;
  final VoidCallback onAddConversion;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Material(
          color: AppColors.surface,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
            ),
            child: Row(
              children: [
                if (hasConversions)
                  IconButton(
                    icon: Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                    ),
                    color: AppColors.textSecondary,
                    onPressed: onToggleExpand,
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                  )
                else
                  const SizedBox(width: 32),
                Expanded(
                  child: InkWell(
                    onTap: onToggleExpand,
                    onLongPress: onDelete,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          unit.fullName.toUpperCase(),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          unit.shortName,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  color: AppColors.textSecondary,
                  tooltip: 'Edit unit',
                  onPressed: onEdit,
                ),
              ],
            ),
          ),
        ),
        if (isExpanded) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg + 32,
              0,
              AppSpacing.lg,
              AppSpacing.sm,
            ),
            child: unit.conversions.isEmpty
                ? Text(
                    'No conversions yet',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  )
                : Column(
                    children: [
                      for (final conversion in unit.conversions)
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  conversion.label,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: AppColors.textPrimary,
                                      ),
                                ),
                              ),
                              Text(
                                '${conversion.factor}x',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  size: 18,
                                ),
                                color: AppColors.textSecondary,
                                onPressed: () => onDeleteConversion(conversion),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg + 32,
              0,
              AppSpacing.lg,
              AppSpacing.md,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: onAddConversion,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Add Conversion'),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _AddUnitFab extends StatelessWidget {
  const _AddUnitFab({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: MobileHomeAddSaleFab.accentRed,
      elevation: 2,
      shadowColor: MobileHomeAddSaleFab.accentRed.withValues(alpha: 0.25),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm + 2,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: const Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                  size: 14,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Add Unit',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Colors.white,
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
