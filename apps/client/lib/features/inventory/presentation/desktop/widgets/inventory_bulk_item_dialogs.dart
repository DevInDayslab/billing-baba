import 'package:billing_baba/core/theme/app_gradients.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/core/theme/list_panel_theme.dart';
import 'package:billing_baba/features/inventory/application/inventory_categories_provider.dart';
import 'package:billing_baba/features/inventory/application/inventory_items_provider.dart';
import 'package:billing_baba/features/inventory/application/inventory_search_provider.dart';
import 'package:billing_baba/features/inventory/application/inventory_stock_calculator.dart';
import 'package:billing_baba/features/inventory/application/inventory_units_provider.dart';
import 'package:billing_baba/features/inventory/inventory_constants.dart';
import 'package:billing_baba/features/inventory/models/bulk_item_update_payload.dart';
import 'package:billing_baba/features/inventory/models/category_model.dart';
import 'package:billing_baba/features/inventory/models/item_model.dart';
import 'package:billing_baba/features/inventory/models/unit_model.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/inventory_search_field.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/inventory_stock_utils.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/inventory_styles.dart';
import 'package:billing_baba/features/inventory/utils/inventory_item_catalog_status.dart';
import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

const _dialogWidth = 920.0;
const _dialogHeight = 600.0;
const _sidebarWidth = 280.0;

const _bulkItemNameFontSize = 13.0;
const _bulkItemCodeFontSize = 11.0;
const _bulkItemNameCodeGap = 6.0;
const _bulkItemRowPaddingV = 10.0;
const _bulkItemRowPaddingH = 12.0;

Future<void> showBulkInactiveItemsDialog(
  BuildContext context, {
  required ItemType itemType,
}) {
  return showDialog<void>(
    context: context,
    builder: (context) => _BulkCatalogStatusDialog(
      title: 'Bulk Inactive',
      description:
          'Selected items will be marked inactive and hidden from billing flows.',
      itemType: itemType,
      active: false,
      itemFilter: (item) => !isCatalogInactiveItem(item),
      emptyMessage: 'No active items to update',
    ),
  );
}

Future<void> showBulkActiveItemsDialog(
  BuildContext context, {
  required ItemType itemType,
}) {
  return showDialog<void>(
    context: context,
    builder: (context) => _BulkCatalogStatusDialog(
      title: 'Bulk Active',
      description: 'Selected items will be marked active again.',
      itemType: itemType,
      active: true,
      itemFilter: isCatalogInactiveItem,
      emptyMessage: 'No inactive items to update',
    ),
  );
}

Future<void> showBulkAssignCodeDialog(
  BuildContext context, {
  required ItemType itemType,
}) {
  return showDialog<void>(
    context: context,
    builder: (context) => _BulkAssignCodeDialog(itemType: itemType),
  );
}

Future<void> showBulkAssignUnitsDialog(
  BuildContext context, {
  required ItemType itemType,
}) {
  return showDialog<void>(
    context: context,
    builder: (context) => _BulkAssignUnitsDialog(itemType: itemType),
  );
}

Future<void> showBulkUpdateItemsDialog(
  BuildContext context, {
  required ItemType itemType,
}) {
  return showDialog<void>(
    context: context,
    builder: (context) => _BulkUpdateItemsDialog(itemType: itemType),
  );
}

class _BulkCatalogStatusDialog extends ConsumerStatefulWidget {
  const _BulkCatalogStatusDialog({
    required this.title,
    required this.description,
    required this.itemType,
    required this.active,
    required this.itemFilter,
    required this.emptyMessage,
  });

  final String title;
  final String description;
  final ItemType itemType;
  final bool active;
  final bool Function(InventoryItem item) itemFilter;
  final String emptyMessage;

  @override
  ConsumerState<_BulkCatalogStatusDialog> createState() =>
      _BulkCatalogStatusDialogState();
}

class _BulkCatalogStatusDialogState
    extends ConsumerState<_BulkCatalogStatusDialog> {
  final _selectedIds = <String>{};
  var _isSaving = false;

  List<InventoryItem> _eligibleItems(List<InventoryItem> all) {
    return all
        .where(
          (item) => item.type == widget.itemType && widget.itemFilter(item),
        )
        .toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  }

  Future<void> _apply(List<InventoryItem> selected) async {
    if (selected.isEmpty || _isSaving) return;
    setState(() => _isSaving = true);
    final error = await ref
        .read(inventoryItemsProvider.notifier)
        .bulkSetCatalogActive(items: selected, active: widget.active);
    if (!mounted) return;
    setState(() => _isSaving = false);
    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${selected.length} item(s) marked ${widget.active ? 'active' : 'inactive'}.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allItems = ref.watch(inventoryItemListProvider);
    final eligible = _eligibleItems(allItems);
    final selected = eligible.where((i) => _selectedIds.contains(i.id));

    return _BulkDialogShell(
      title: widget.title,
      description: widget.description,
      heroIcon: widget.active ? LucideIcons.eye : LucideIcons.eyeOff,
      items: eligible,
      emptyMessage: widget.emptyMessage,
      selectedIds: _selectedIds,
      onSelectionChanged: (ids) => setState(() {
        _selectedIds
          ..clear()
          ..addAll(ids);
      }),
      primaryLabel: widget.active ? 'Mark active' : 'Mark inactive',
      primaryIcon: widget.active ? LucideIcons.eye : LucideIcons.eyeOff,
      showQuantityBadge: widget.itemType == ItemType.product,
      isSaving: _isSaving,
      onPrimary: () => _apply(selected.toList()),
    );
  }
}

class _BulkAssignCodeDialog extends ConsumerStatefulWidget {
  const _BulkAssignCodeDialog({required this.itemType});

  final ItemType itemType;

  @override
  ConsumerState<_BulkAssignCodeDialog> createState() =>
      _BulkAssignCodeDialogState();
}

class _BulkAssignCodeDialogState extends ConsumerState<_BulkAssignCodeDialog> {
  final _selectedIds = <String>{};
  var _onlyWithoutBarcode = true;
  var _isSaving = false;

  List<InventoryItem> _eligibleItems(List<InventoryItem> all) {
    return all.where((item) => item.type == widget.itemType).toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  }

  Future<void> _apply(List<InventoryItem> selected) async {
    if (selected.isEmpty || _isSaving) return;
    setState(() => _isSaving = true);
    final error = await ref
        .read(inventoryItemsProvider.notifier)
        .bulkAssignBarcodes(
          items: selected,
          onlyWithoutBarcode: _onlyWithoutBarcode,
        );
    if (!mounted) return;
    setState(() => _isSaving = false);
    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Barcodes assigned to ${selected.length} item(s).'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final eligible = _eligibleItems(ref.watch(inventoryItemListProvider));
    final selected = eligible.where((i) => _selectedIds.contains(i.id));

    return _BulkDialogShell(
      title: 'Bulk Assign Code',
      description:
          'Auto-generate item codes (barcodes) for the selected items.',
      heroIcon: LucideIcons.barcode,
      items: eligible,
      emptyMessage: 'No items available',
      selectedIds: _selectedIds,
      onSelectionChanged: (ids) => setState(() {
        _selectedIds
          ..clear()
          ..addAll(ids);
      }),
      primaryLabel: 'Assign codes',
      primaryIcon: LucideIcons.barcode,
      showQuantityBadge: widget.itemType == ItemType.product,
      isSaving: _isSaving,
      onPrimary: () => _apply(selected.toList()),
      footer: Row(
        children: [
          Checkbox(
            value: _onlyWithoutBarcode,
            onChanged: (value) =>
                setState(() => _onlyWithoutBarcode = value ?? true),
            visualDensity: VisualDensity.compact,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          const Expanded(
            child: Text(
              'Only assign to items without an existing code',
              style: TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _BulkAssignUnitsDialog extends ConsumerStatefulWidget {
  const _BulkAssignUnitsDialog({required this.itemType});

  final ItemType itemType;

  @override
  ConsumerState<_BulkAssignUnitsDialog> createState() =>
      _BulkAssignUnitsDialogState();
}

class _BulkAssignUnitsDialogState
    extends ConsumerState<_BulkAssignUnitsDialog> {
  final _selectedIds = <String>{};
  String? _unitId;
  var _isSaving = false;

  List<InventoryItem> _eligibleItems(List<InventoryItem> all) {
    return all.where((item) => item.type == widget.itemType).toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  }

  Future<void> _apply(List<InventoryItem> selected) async {
    final units =
        ref.read(inventoryUnitsProvider).value ?? const <InventoryUnit>[];
    final unit = units.where((u) => u.id == _unitId).firstOrNull;
    if (unit == null || selected.isEmpty || _isSaving) return;

    setState(() => _isSaving = true);
    final error = await ref
        .read(inventoryItemsProvider.notifier)
        .bulkAssignBaseUnit(
          items: selected,
          baseUnitShortName: unit.shortName,
        );
    if (!mounted) return;
    setState(() => _isSaving = false);
    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Unit "${unit.shortName}" assigned to ${selected.length} item(s).',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final units =
        ref.watch(inventoryUnitsProvider).value ?? const <InventoryUnit>[];
    final eligible = _eligibleItems(ref.watch(inventoryItemListProvider));
    final selected = eligible.where((i) => _selectedIds.contains(i.id));

    return _BulkDialogShell(
      title: 'Assign Units',
      description: 'Set the same base unit on all selected items.',
      heroIcon: LucideIcons.ruler,
      items: eligible,
      emptyMessage: 'No items available',
      selectedIds: _selectedIds,
      onSelectionChanged: (ids) => setState(() {
        _selectedIds
          ..clear()
          ..addAll(ids);
      }),
      primaryLabel: 'Assign unit',
      primaryIcon: LucideIcons.ruler,
      showQuantityBadge: widget.itemType == ItemType.product,
      isSaving: _isSaving,
      onPrimary: _unitId == null ? null : () => _apply(selected.toList()),
      header: _BulkBaseUnitDropdown(
        unitId: _unitId,
        units: units,
        onChanged: (value) => setState(() => _unitId = value),
      ),
    );
  }
}

class _BulkBaseUnitDropdown extends StatefulWidget {
  const _BulkBaseUnitDropdown({
    required this.unitId,
    required this.units,
    required this.onChanged,
  });

  final String? unitId;
  final List<InventoryUnit> units;
  final ValueChanged<String?> onChanged;

  @override
  State<_BulkBaseUnitDropdown> createState() => _BulkBaseUnitDropdownState();
}

class _BulkBaseUnitDropdownState extends State<_BulkBaseUnitDropdown> {
  static const _triggerWidth = 280.0;
  static const _triggerHeight = 40.0;
  static const _itemHeight = 40.0;
  static const _maxMenuHeight = 220.0;

  final MenuController _menuController = MenuController();

  static final TextStyle _valueTextStyle = AppTypography.inter(
    fontSize: AppTypography.bodySmallSize,
    height: 1.35,
    color: AppColors.textPrimary,
  );

  InventoryUnit? get _selectedUnit =>
      widget.units.where((unit) => unit.id == widget.unitId).firstOrNull;

  void _toggleMenu() {
    if (widget.units.isEmpty) return;
    setState(() {
      if (_menuController.isOpen) {
        _menuController.close();
      } else {
        _menuController.open();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selectedUnit;
    final menuHeight = math.min(
      widget.units.length * _itemHeight,
      _maxMenuHeight,
    );

    return Align(
      alignment: Alignment.centerLeft,
      child: SizedBox(
        width: _triggerWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Base unit',
              style: AppTypography.inter(
                fontSize: AppTypography.bodySmallSize,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            MenuAnchor(
              controller: _menuController,
              useRootOverlay: true,
              consumeOutsideTap: true,
              alignmentOffset: const Offset(0, 4),
              style: MenuStyle(
                backgroundColor: const WidgetStatePropertyAll(
                  AppColors.surface,
                ),
                elevation: const WidgetStatePropertyAll(6),
                shadowColor: const WidgetStatePropertyAll(Colors.black26),
                surfaceTintColor: const WidgetStatePropertyAll(
                  Colors.transparent,
                ),
                shape: WidgetStatePropertyAll(
                  RoundedRectangleBorder(
                    borderRadius: AppRadius.mdBorder,
                    side: const BorderSide(color: listPanelCardBorder),
                  ),
                ),
                padding: const WidgetStatePropertyAll(EdgeInsets.zero),
                minimumSize: WidgetStatePropertyAll(Size(_triggerWidth, 0)),
                maximumSize: WidgetStatePropertyAll(
                  Size(_triggerWidth, _maxMenuHeight),
                ),
              ),
              menuChildren: [
                if (widget.units.isEmpty)
                  const SizedBox(
                    width: _triggerWidth,
                    height: _itemHeight,
                    child: Center(
                      child: Text(
                        'No units available',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  )
                else
                  SizedBox(
                    width: _triggerWidth,
                    height: menuHeight,
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      itemExtent: _itemHeight,
                      itemCount: widget.units.length,
                      itemBuilder: (context, index) {
                        final unit = widget.units[index];
                        final isSelected = unit.id == widget.unitId;
                        return Material(
                          color: isSelected
                              ? listPanelSelectedRowColor
                              : Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              widget.onChanged(unit.id);
                              setState(_menuController.close);
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                              ),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  unit.fullName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: _valueTextStyle.copyWith(
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
              builder: (context, controller, child) {
                final isOpen = controller.isOpen;
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _toggleMenu,
                    borderRadius: AppRadius.smBorder,
                    child: Ink(
                      height: _triggerHeight,
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: AppRadius.smBorder,
                        border: Border.all(
                          color: isOpen
                              ? AppColors.primary
                              : listPanelCardBorder,
                          width: isOpen ? 1.5 : 1,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                selected?.fullName ?? 'Select unit',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: selected == null
                                    ? _valueTextStyle.copyWith(
                                        color: AppColors.textSecondary,
                                      )
                                    : _valueTextStyle,
                              ),
                            ),
                            Icon(
                              Icons.keyboard_arrow_down,
                              size: 20,
                              color: isOpen
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _BulkUpdateItemsDialog extends ConsumerStatefulWidget {
  const _BulkUpdateItemsDialog({required this.itemType});

  final ItemType itemType;

  @override
  ConsumerState<_BulkUpdateItemsDialog> createState() =>
      _BulkUpdateItemsDialogState();
}

class _BulkUpdateItemsDialogState
    extends ConsumerState<_BulkUpdateItemsDialog> {
  final _selectedIds = <String>{};
  final _salePriceController = TextEditingController();
  final _purchasePriceController = TextEditingController();
  final _mrpController = TextEditingController();
  final _hsnController = TextEditingController();
  String? _categoryId;
  var _clearCategory = false;
  var _categoryTouched = false;
  var _isSaving = false;

  @override
  void dispose() {
    _salePriceController.dispose();
    _purchasePriceController.dispose();
    _mrpController.dispose();
    _hsnController.dispose();
    super.dispose();
  }

  List<InventoryItem> _eligibleItems(List<InventoryItem> all) {
    return all.where((item) => item.type == widget.itemType).toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  }

  BulkItemUpdatePayload _buildPayload() {
    final sale = _salePriceController.text.trim();
    final purchase = _purchasePriceController.text.trim();
    final mrp = _mrpController.text.trim();
    final hsn = _hsnController.text.trim();

    return BulkItemUpdatePayload(
      salePrice: sale.isEmpty ? null : sale,
      purchasePrice: purchase.isEmpty ? null : purchase,
      mrp: mrp.isEmpty ? null : mrp,
      categoryId: _categoryTouched && !_clearCategory ? _categoryId : null,
      clearCategory: _categoryTouched && _clearCategory,
      hsnCode: hsn.isEmpty ? null : hsn,
    );
  }

  Future<void> _apply(List<InventoryItem> selected) async {
    final payload = _buildPayload();
    if (!payload.hasChanges || selected.isEmpty || _isSaving) {
      if (!payload.hasChanges && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Enter at least one field to update.')),
        );
      }
      return;
    }

    setState(() => _isSaving = true);
    final error = await ref
        .read(inventoryItemsProvider.notifier)
        .bulkUpdateItems(
          items: selected,
          payload: payload,
        );
    if (!mounted) return;
    setState(() => _isSaving = false);
    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Updated ${selected.length} item(s).')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories =
        ref.watch(inventoryCategoriesProvider).value ??
        const <InventoryCategory>[];
    final eligible = _eligibleItems(ref.watch(inventoryItemListProvider));
    final selected = eligible.where((i) => _selectedIds.contains(i.id));

    return _BulkDialogShell(
      title: 'Bulk Update Items',
      description:
          'Choose items and fill only the fields you want to overwrite.',
      heroIcon: LucideIcons.pencil,
      items: eligible,
      emptyMessage: 'No items available',
      selectedIds: _selectedIds,
      onSelectionChanged: (ids) => setState(() {
        _selectedIds
          ..clear()
          ..addAll(ids);
      }),
      primaryLabel: 'Update items',
      primaryIcon: LucideIcons.pencil,
      showQuantityBadge: widget.itemType == ItemType.product,
      isSaving: _isSaving,
      onPrimary: () => _apply(selected.toList()),
      footer: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _BulkMoneyField(
            label: 'Sale price',
            controller: _salePriceController,
          ),
          const SizedBox(height: AppSpacing.sm),
          _BulkMoneyField(
            label: 'Purchase price',
            controller: _purchasePriceController,
          ),
          const SizedBox(height: AppSpacing.sm),
          _BulkMoneyField(label: 'MRP', controller: _mrpController),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _hsnController,
            decoration: const InputDecoration(
              labelText: 'HSN / SAC code',
              isDense: true,
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          DropdownButtonFormField<String>(
            value: _clearCategory
                ? '__clear__'
                : (_categoryId ?? '__no_change__'),
            decoration: const InputDecoration(
              labelText: 'Category',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            items: [
              const DropdownMenuItem(
                value: '__no_change__',
                child: Text('No change'),
              ),
              const DropdownMenuItem(
                value: '__clear__',
                child: Text('Remove category'),
              ),
              const DropdownMenuItem(
                value: uncategorizedCategoryId,
                child: Text('Uncategorized'),
              ),
              for (final category in categories)
                DropdownMenuItem(
                  value: category.id,
                  child: Text(category.name),
                ),
            ],
            onChanged: (value) {
              setState(() {
                if (value == '__no_change__' || value == null) {
                  _categoryTouched = false;
                  _clearCategory = false;
                  _categoryId = null;
                } else if (value == '__clear__') {
                  _categoryTouched = true;
                  _clearCategory = true;
                  _categoryId = null;
                } else {
                  _categoryTouched = true;
                  _clearCategory = false;
                  _categoryId = value;
                }
              });
            },
          ),
        ],
      ),
    );
  }
}

class _BulkMoneyField extends StatelessWidget {
  const _BulkMoneyField({required this.label, required this.controller});

  final String label;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
      ],
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
        border: const OutlineInputBorder(),
      ),
    );
  }
}

class _BulkDialogHeroPanel extends StatelessWidget {
  const _BulkDialogHeroPanel({
    required this.title,
    required this.description,
    required this.icon,
  });

  final String title;
  final String description;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _sidebarWidth,
      decoration: const BoxDecoration(gradient: AppGradients.primarySoft),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 22, color: AppColors.primary),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              style: AppTypography.inter(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                height: 1.25,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              description,
              style: AppTypography.inter(
                fontSize: AppTypography.bodySmallSize,
                color: AppColors.textSecondary,
                height: 1.45,
              ),
            ),
            const Spacer(),
            Align(
              alignment: Alignment.bottomLeft,
              child: Opacity(
                opacity: 0.35,
                child: Icon(icon, size: 72, color: AppColors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BulkQuantityBadge extends StatelessWidget {
  const _BulkQuantityBadge({required this.item});

  final InventoryItem item;

  @override
  Widget build(BuildContext context) {
    final metrics = InventoryStockCalculator.metricsFromItem(item);
    final quantity = metrics.physicalQuantity;
    final color = listQuantityColor(quantity, reorderLevel: item.reorderLevel);
    final label = formatQuantityValue(quantity);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: AppTypography.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          height: 1.2,
          color: color,
        ),
      ),
    );
  }
}

class _BulkDialogItemRow extends StatefulWidget {
  const _BulkDialogItemRow({
    required this.item,
    required this.isSelected,
    required this.showQuantityBadge,
    required this.onToggle,
  });

  final InventoryItem item;
  final bool isSelected;
  final bool showQuantityBadge;
  final VoidCallback onToggle;

  @override
  State<_BulkDialogItemRow> createState() => _BulkDialogItemRowState();
}

class _BulkDialogItemRowState extends State<_BulkDialogItemRow> {
  var _isHovered = false;

  Color get _backgroundColor {
    if (widget.isSelected) return listPanelSelectedRowColor;
    if (_isHovered) return listPanelRowHoverColor;
    return Colors.transparent;
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Material(
        color: _backgroundColor,
        child: InkWell(
          onTap: widget.onToggle,
          hoverColor: Colors.transparent,
          splashColor: AppColors.primary.withValues(alpha: 0.08),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: _bulkItemRowPaddingH,
              vertical: _bulkItemRowPaddingV,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Checkbox(
                    value: widget.isSelected,
                    onChanged: (_) => widget.onToggle(),
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.item.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.inter(
                          fontSize: _bulkItemNameFontSize,
                          fontWeight: FontWeight.w600,
                          height: 1.45,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (widget.item.barcode != null) ...[
                        const SizedBox(height: _bulkItemNameCodeGap),
                        Text(
                          'Code: ${widget.item.barcode}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.inter(
                            fontSize: _bulkItemCodeFontSize,
                            height: 1.5,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (widget.showQuantityBadge) ...[
                  const SizedBox(width: AppSpacing.md),
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: _BulkQuantityBadge(item: widget.item),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BulkDialogShell extends ConsumerStatefulWidget {
  const _BulkDialogShell({
    required this.title,
    required this.description,
    required this.heroIcon,
    required this.items,
    required this.emptyMessage,
    required this.selectedIds,
    required this.onSelectionChanged,
    required this.primaryLabel,
    required this.onPrimary,
    this.primaryIcon,
    this.showQuantityBadge = false,
    this.isSaving = false,
    this.header,
    this.footer,
  });

  final String title;
  final String description;
  final IconData heroIcon;
  final List<InventoryItem> items;
  final String emptyMessage;
  final Set<String> selectedIds;
  final ValueChanged<Set<String>> onSelectionChanged;
  final String primaryLabel;
  final IconData? primaryIcon;
  final bool showQuantityBadge;
  final VoidCallback? onPrimary;
  final bool isSaving;
  final Widget? header;
  final Widget? footer;

  @override
  ConsumerState<_BulkDialogShell> createState() => _BulkDialogShellState();
}

class _BulkDialogShellState extends ConsumerState<_BulkDialogShell> {
  var _searchQuery = '';

  List<InventoryItem> get _visibleItems {
    final engine = ref.read(inventorySearchEngineProvider);
    return searchInventoryItems(
      engine,
      widget.items,
      query: _searchQuery,
    ).toList();
  }

  void _toggleAll() {
    final visible = _visibleItems;
    final next = Set<String>.from(widget.selectedIds);
    final allSelected =
        visible.isNotEmpty && visible.every((i) => next.contains(i.id));
    if (allSelected) {
      for (final item in visible) {
        next.remove(item.id);
      }
    } else {
      next.addAll(visible.map((i) => i.id));
    }
    widget.onSelectionChanged(next);
  }

  void _toggleItem(String id) {
    final next = Set<String>.from(widget.selectedIds);
    if (next.contains(id)) {
      next.remove(id);
    } else {
      next.add(id);
    }
    widget.onSelectionChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visibleItems;
    final allSelected =
        visible.isNotEmpty &&
        visible.every((i) => widget.selectedIds.contains(i.id));

    final primaryIcon = widget.primaryIcon ?? widget.heroIcon;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: ClipRRect(
        borderRadius: AppRadius.lgBorder,
        child: SizedBox(
          width: _dialogWidth,
          height: _dialogHeight,
          child: Material(
            color: AppColors.surface,
            clipBehavior: Clip.antiAlias,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _BulkDialogHeroPanel(
                  title: widget.title,
                  description: widget.description,
                  icon: widget.heroIcon,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.md,
                      AppSpacing.lg,
                      AppSpacing.lg,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.close, size: 20),
                            tooltip: 'Close',
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                        if (widget.header != null) ...[
                          widget.header!,
                          const SizedBox(height: AppSpacing.md),
                        ],
                        InventorySearchField(
                          hint: 'Search items by name or code...',
                          onChanged: (query) =>
                              setState(() => _searchQuery = query),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: Row(
                            children: [
                              Checkbox(
                                value: allSelected,
                                onChanged: visible.isEmpty
                                    ? null
                                    : (_) => _toggleAll(),
                                visualDensity: VisualDensity.compact,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              ),
                              Text(
                                'Select all',
                                style: AppTypography.inter(
                                  fontSize: AppTypography.bodySmallSize,
                                  fontWeight: FontWeight.w500,
                                  height: 1.4,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '${widget.selectedIds.length} selected',
                                style: AppTypography.inter(
                                  fontSize: AppTypography.bodySmallSize,
                                  height: 1.4,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              border: Border.all(color: listPanelCardBorder),
                              borderRadius: AppRadius.mdBorder,
                            ),
                            child: ClipRRect(
                              borderRadius: AppRadius.mdBorder,
                              child: visible.isEmpty
                                  ? Center(
                                      child: Text(
                                        widget.emptyMessage,
                                        style: InventoryStyles.emptyStateStyle,
                                      ),
                                    )
                                  : ListView.separated(
                                      itemCount: visible.length,
                                      separatorBuilder: (_, __) =>
                                          const Divider(
                                            height: 1,
                                            color: listPanelCardBorder,
                                          ),
                                      itemBuilder: (context, index) {
                                        final item = visible[index];
                                        final isSelected = widget.selectedIds
                                            .contains(item.id);
                                        return _BulkDialogItemRow(
                                          item: item,
                                          isSelected: isSelected,
                                          showQuantityBadge:
                                              widget.showQuantityBadge,
                                          onToggle: () => _toggleItem(item.id),
                                        );
                                      },
                                    ),
                            ),
                          ),
                        ),
                        if (widget.footer != null) ...[
                          const SizedBox(height: AppSpacing.md),
                          widget.footer!,
                        ],
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            OutlinedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Cancel'),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            widget.isSaving
                                ? FilledButton(
                                    onPressed: null,
                                    child: const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  )
                                : FilledButton.icon(
                                    onPressed: widget.onPrimary,
                                    icon: Icon(primaryIcon, size: 18),
                                    label: Text(widget.primaryLabel),
                                  ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
