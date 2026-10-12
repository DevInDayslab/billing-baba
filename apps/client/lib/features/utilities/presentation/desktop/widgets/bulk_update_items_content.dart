import 'dart:math' as math;

import 'package:billing_baba/core/routing/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/application/inventory_categories_provider.dart';
import 'package:billing_baba/features/inventory/application/inventory_items_provider.dart';
import 'package:billing_baba/features/inventory/application/inventory_search_provider.dart';
import 'package:billing_baba/features/inventory/inventory_constants.dart';
import 'package:billing_baba/features/inventory/models/bulk_item_update_payload.dart';
import 'package:billing_baba/features/inventory/models/category_model.dart';
import 'package:billing_baba/features/inventory/models/item_model.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/inventory_bulk_item_dialogs.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/inventory_item_list_thumbnail.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

const _cardBorder = Color(0xFFE7E9F0);
const _fieldFill = Color(0xFFFCFCFD);
const _selectedRow = Color(0xFFF4F0FF);
const _hoverRow = Color(0xFFFAF8FF);
const _chipBg = Color(0xFFF3EEFF);
const _leftPanelWidth = 300.0;
const _itemRowExtent = 64.0;

/// Utilities page for the same bulk item update used on the Items tab.
class BulkUpdateItemsContent extends ConsumerStatefulWidget {
  const BulkUpdateItemsContent({this.showPageHeader = true, super.key});

  final bool showPageHeader;

  @override
  ConsumerState<BulkUpdateItemsContent> createState() =>
      _BulkUpdateItemsContentState();
}

class _BulkUpdateItemsContentState
    extends ConsumerState<BulkUpdateItemsContent> {
  final _selectedIds = <String>{};
  final _salePriceController = TextEditingController();
  final _purchasePriceController = TextEditingController();
  final _mrpController = TextEditingController();
  final _hsnController = TextEditingController();
  final _searchController = TextEditingController();

  ItemType _itemType = ItemType.product;
  String? _categoryId;
  var _clearCategory = false;
  var _categoryTouched = false;
  var _isSaving = false;
  var _viewSelectedOnly = false;
  var _searchQuery = '';

  @override
  void dispose() {
    _salePriceController.dispose();
    _purchasePriceController.dispose();
    _mrpController.dispose();
    _hsnController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<InventoryItem> _eligibleItems(List<InventoryItem> all) {
    return all.where((item) => item.type == _itemType).toList()
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

  void _resetFields() {
    _salePriceController.clear();
    _purchasePriceController.clear();
    _mrpController.clear();
    _hsnController.clear();
    setState(() {
      _categoryId = null;
      _clearCategory = false;
      _categoryTouched = false;
    });
  }

  void _resetForm() {
    _resetFields();
    setState(() {
      _selectedIds.clear();
      _viewSelectedOnly = false;
    });
  }

  void _setItemType(ItemType type) {
    if (type == _itemType) return;
    setState(() {
      _itemType = type;
      _selectedIds.clear();
      _viewSelectedOnly = false;
    });
  }

  Future<void> _apply(List<InventoryItem> selected) async {
    final payload = _buildPayload();
    if (selected.isEmpty || !payload.hasChanges || _isSaving) {
      if (!mounted || _isSaving) return;
      final message = selected.isEmpty
          ? 'Select at least one item.'
          : 'Enter at least one field to update.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
      return;
    }

    final categories =
        ref.read(inventoryCategoriesProvider).value ??
        const <InventoryCategory>[];
    final confirmed = await showBulkUpdateConfirmation(
      context,
      items: selected,
      payload: payload,
      categories: categories,
    );
    if (!confirmed || !mounted) return;

    setState(() => _isSaving = true);
    final error = await ref
        .read(inventoryItemsProvider.notifier)
        .bulkUpdateItems(items: selected, payload: payload);
    if (!mounted) return;
    setState(() => _isSaving = false);
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
      return;
    }
    final updatedCount = selected.length;
    _resetForm();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Updated $updatedCount item(s).')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories =
        ref.watch(inventoryCategoriesProvider).value ??
        const <InventoryCategory>[];
    final itemsAsync = ref.watch(inventoryItemsProvider);
    final eligible = _eligibleItems(itemsAsync.value?.items ?? const []);
    final engine = ref.watch(inventorySearchEngineProvider);
    final searched = searchInventoryItems(
      engine,
      eligible,
      query: _searchQuery,
    );
    final visible = _viewSelectedOnly
        ? searched.where((item) => _selectedIds.contains(item.id)).toList()
        : searched;
    final selected = eligible
        .where((item) => _selectedIds.contains(item.id))
        .toList();
    final allVisibleSelected =
        visible.isNotEmpty &&
        visible.every((item) => _selectedIds.contains(item.id));
    final someVisibleSelected = visible.any(
      (item) => _selectedIds.contains(item.id),
    );

    return ColoredBox(
      color: AppColors.background,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 8, 28, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.showPageHeader) ...[
              const _Breadcrumb(),
              const SizedBox(height: 4),
              const _PageTitle(),
              const SizedBox(height: 2),
            ],
            Text(
              'Choose items and fill only the fields you want to overwrite.',
              style: AppTypography.inter(
                fontSize: 14,
                height: 1.3,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: _TypeSwitch(
                itemType: _itemType,
                onChanged: _setItemType,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final stacked = constraints.maxWidth < 980;
                  final form = _UpdateCard(
                    items: visible,
                    eligibleCount: eligible.length,
                    selectedCount: _selectedIds.length,
                    selectedIds: _selectedIds,
                    viewSelectedOnly: _viewSelectedOnly,
                    allVisibleSelected: allVisibleSelected,
                    someVisibleSelected: someVisibleSelected,
                    searchController: _searchController,
                    isLoading: itemsAsync.isLoading && eligible.isEmpty,
                    isSaving: _isSaving,
                    itemType: _itemType,
                    categories: categories,
                    categoryValue: _clearCategory
                        ? '__clear__'
                        : _categoryId,
                    salePriceController: _salePriceController,
                    purchasePriceController: _purchasePriceController,
                    mrpController: _mrpController,
                    hsnController: _hsnController,
                    onSearchChanged: (value) =>
                        setState(() => _searchQuery = value),
                    onToggleViewSelected: () => setState(() {
                      _viewSelectedOnly = !_viewSelectedOnly;
                    }),
                    onToggleAll: () {
                      setState(() {
                        if (allVisibleSelected) {
                          for (final item in visible) {
                            _selectedIds.remove(item.id);
                          }
                        } else {
                          _selectedIds.addAll(visible.map((item) => item.id));
                        }
                      });
                    },
                    onToggleItem: (id) => setState(() {
                      if (!_selectedIds.add(id)) _selectedIds.remove(id);
                    }),
                    onCategoryChanged: (value) => setState(() {
                      if (value == null) {
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
                    }),
                    onResetFields: _resetFields,
                    onClear: _isSaving ? null : _resetForm,
                    onUpdate: _isSaving ? null : () => _apply(selected),
                  );

                  if (stacked) return form;

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(
                        width: _leftPanelWidth,
                        child: _GuidePanel(),
                      ),
                      const SizedBox(width: 16),
                      Expanded(child: form),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Breadcrumb extends StatelessWidget {
  const _Breadcrumb();

  @override
  Widget build(BuildContext context) {
    final style = AppTypography.inter(
      fontSize: 13,
      height: 1.2,
      color: AppColors.textSecondary,
    );
    return Row(
      children: [
        InkWell(
          onTap: () => context.go(AppRoutes.utilities),
          borderRadius: AppRadius.smBorder,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Text('Utilities', style: style),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Icon(
            Icons.chevron_right,
            size: 16,
            color: AppColors.textSecondary.withValues(alpha: 0.8),
          ),
        ),
        Text(
          'Bulk Update Items',
          style: style.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _PageTitle extends StatelessWidget {
  const _PageTitle();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          'Bulk Update Items',
          style: AppTypography.inter(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            height: 1.15,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(width: 8),
        const Tooltip(
          message:
              'Select one or more items and update only the fields you want to change. Unfilled fields stay as they are.',
          child: Icon(
            Icons.info_outline,
            size: 18,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _TypeSwitch extends StatelessWidget {
  const _TypeSwitch({required this.itemType, required this.onChanged});

  final ItemType itemType;
  final ValueChanged<ItemType> onChanged;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _cardBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _TypeChip(
              icon: LucideIcons.package,
              label: 'Products',
              selected: itemType == ItemType.product,
              onTap: () => onChanged(ItemType.product),
            ),
            _TypeChip(
              icon: LucideIcons.settings,
              label: 'Services',
              selected: itemType == ItemType.service,
              onTap: () => onChanged(ItemType.service),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.textSecondary;
    return Material(
      color: selected ? _chipBg : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 8),
              Text(
                label,
                style: AppTypography.inter(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GuidePanel extends StatelessWidget {
  const _GuidePanel();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: AppGradients.primarySoft,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE4DCF8)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                LucideIcons.pencil,
                size: 18,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Bulk Update Items',
              style: AppTypography.inter(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                height: 1.25,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Select one or more items and update only the fields you want to change. Unfilled fields will remain unchanged.',
              style: AppTypography.inter(
                fontSize: 13,
                height: 1.45,
                color: const Color(0xFF6B6478),
              ),
            ),
            const SizedBox(height: 22),
            const _GuidePoint(
              icon: LucideIcons.zap,
              iconColor: Color(0xFFF59E0B),
              iconBackground: Color(0xFFFFF4DE),
              title: 'Save time',
              subtitle: 'Update multiple items at once',
            ),
            const SizedBox(height: 14),
            const _GuidePoint(
              icon: LucideIcons.shieldCheck,
              iconColor: Color(0xFF16A34A),
              iconBackground: Color(0xFFE8F8EE),
              title: 'Safe & selective',
              subtitle: 'Only provided fields will be updated',
            ),
            const SizedBox(height: 14),
            const _GuidePoint(
              icon: LucideIcons.layoutGrid,
              iconColor: AppColors.primary,
              iconBackground: Color(0xFFF0EAFF),
              title: 'Works for products & services',
              subtitle: 'Use tabs to switch between them',
            ),
            const SizedBox(height: 14),
            const _GuidePoint(
              icon: LucideIcons.eye,
              iconColor: Color(0xFF2563EB),
              iconBackground: Color(0xFFE8F0FF),
              title: 'Review before update',
              subtitle: 'Check selected items and values',
            ),
            const Spacer(),
            const Align(
              alignment: Alignment.bottomCenter,
              child: _BoxArt(),
            ),
          ],
        ),
      ),
    );
  }
}

class _GuidePoint extends StatelessWidget {
  const _GuidePoint({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: iconBackground,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 14, color: iconColor),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.inter(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: AppTypography.inter(
                  fontSize: 12,
                  height: 1.35,
                  color: const Color(0xFF7A7386),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BoxArt extends StatelessWidget {
  const _BoxArt();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 108,
      width: 140,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            LucideIcons.package,
            size: 86,
            color: AppColors.primary.withValues(alpha: 0.28),
          ),
          Positioned(
            top: 10,
            right: 18,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.16),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: const Icon(
                LucideIcons.arrowUp,
                size: 16,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UpdateCard extends StatelessWidget {
  const _UpdateCard({
    required this.items,
    required this.eligibleCount,
    required this.selectedCount,
    required this.selectedIds,
    required this.viewSelectedOnly,
    required this.allVisibleSelected,
    required this.someVisibleSelected,
    required this.searchController,
    required this.isLoading,
    required this.isSaving,
    required this.itemType,
    required this.categories,
    required this.categoryValue,
    required this.salePriceController,
    required this.purchasePriceController,
    required this.mrpController,
    required this.hsnController,
    required this.onSearchChanged,
    required this.onToggleViewSelected,
    required this.onToggleAll,
    required this.onToggleItem,
    required this.onCategoryChanged,
    required this.onResetFields,
    required this.onClear,
    required this.onUpdate,
  });

  final List<InventoryItem> items;
  final int eligibleCount;
  final int selectedCount;
  final Set<String> selectedIds;
  final bool viewSelectedOnly;
  final bool allVisibleSelected;
  final bool someVisibleSelected;
  final TextEditingController searchController;
  final bool isLoading;
  final bool isSaving;
  final ItemType itemType;
  final List<InventoryCategory> categories;
  final String? categoryValue;
  final TextEditingController salePriceController;
  final TextEditingController purchasePriceController;
  final TextEditingController mrpController;
  final TextEditingController hsnController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onToggleViewSelected;
  final VoidCallback onToggleAll;
  final ValueChanged<String> onToggleItem;
  final ValueChanged<String?> onCategoryChanged;
  final VoidCallback onResetFields;
  final VoidCallback? onClear;
  final VoidCallback? onUpdate;

  @override
  Widget build(BuildContext context) {
    final typeLabel = itemType == ItemType.product ? 'Product' : 'Service';
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _cardBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A101828),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(
                  'Select Items',
                  style: AppTypography.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (selectedCount > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: _chipBg,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '$selectedCount selected',
                      style: AppTypography.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
                const Spacer(),
                TextButton.icon(
                  onPressed: onToggleViewSelected,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    backgroundColor: viewSelectedOnly
                        ? _chipBg
                        : Colors.transparent,
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  icon: const Icon(LucideIcons.eye, size: 16),
                  label: Text('View selected ($selectedCount)'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final listHeight = math.max(
                    _itemRowExtent * 3,
                    constraints.maxHeight - 300,
                  );
                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextField(
                          controller: searchController,
                          onChanged: onSearchChanged,
                          style: AppTypography.inter(fontSize: 14),
                          decoration: InputDecoration(
                            hintText:
                                'Search items by name, code or barcode...',
                            hintStyle: AppTypography.inter(
                              fontSize: 14,
                              color: const Color(0xFF9AA0AE),
                            ),
                            prefixIcon: const Icon(
                              LucideIcons.search,
                              size: 18,
                            ),
                            isDense: true,
                            filled: true,
                            fillColor: _fieldFill,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 12,
                            ),
                            border: _fieldBorder(),
                            enabledBorder: _fieldBorder(),
                            focusedBorder: _fieldBorder(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Checkbox(
                              tristate: true,
                              value: items.isEmpty
                                  ? false
                                  : allVisibleSelected
                                  ? true
                                  : someVisibleSelected
                                  ? null
                                  : false,
                              onChanged: items.isEmpty
                                  ? null
                                  : (_) => onToggleAll(),
                              visualDensity: VisualDensity.compact,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ),
                            Text(
                              'Select all (${items.length} items)',
                              style: AppTypography.inter(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: listHeight,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              border: Border.all(color: _cardBorder),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: isLoading
                                  ? const Center(
                                      child: CircularProgressIndicator(),
                                    )
                                  : items.isEmpty
                                  ? Center(
                                      child: Text(
                                        eligibleCount == 0
                                            ? 'No items available'
                                            : viewSelectedOnly
                                            ? 'No selected items in this view'
                                            : 'No matching items',
                                        style: AppTypography.inter(
                                          fontSize: 13,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    )
                                  : ListView.separated(
                                      itemCount: items.length,
                                      separatorBuilder: (_, _) =>
                                          const Divider(
                                            height: 1,
                                            color: _cardBorder,
                                          ),
                                      itemBuilder: (context, index) {
                                        final item = items[index];
                                        return _ItemRow(
                                          item: item,
                                          typeLabel: typeLabel,
                                          selected: selectedIds.contains(
                                            item.id,
                                          ),
                                          onToggle: () => onToggleItem(item.id),
                                        );
                                      },
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
              children: [
                Text(
                  'Fields to Update',
                  style: AppTypography.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: isSaving ? null : onResetFields,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    visualDensity: VisualDensity.compact,
                  ),
                  icon: const Icon(LucideIcons.rotateCcw, size: 14),
                  label: const Text('Reset All'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _LabeledField(
                    label: 'Sale price',
                    child: _MoneyField(
                      controller: salePriceController,
                      hint: 'Enter sale price',
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _LabeledField(
                    label: 'Purchase price',
                    child: _MoneyField(
                      controller: purchasePriceController,
                      hint: 'Enter purchase price',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _LabeledField(
                    label: 'MRP',
                    child: _MoneyField(
                      controller: mrpController,
                      hint: 'Enter MRP',
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _LabeledField(
                    label: 'HSN / SAC code',
                    child: _PlainField(
                      controller: hsnController,
                      hint: 'Enter HSN / SAC code',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _LabeledField(
              label: 'Category',
              child: DropdownButtonFormField<String>(
                key: ValueKey(categoryValue ?? 'none'),
                initialValue: categoryValue,
                isExpanded: true,
                hint: Text(
                  'Select category',
                  style: AppTypography.inter(
                    fontSize: 14,
                    color: const Color(0xFF9AA0AE),
                  ),
                ),
                decoration: InputDecoration(
                  prefixIcon: const Icon(LucideIcons.tag, size: 16),
                  isDense: true,
                  filled: true,
                  fillColor: _fieldFill,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  border: _fieldBorder(),
                  enabledBorder: _fieldBorder(),
                  focusedBorder: _fieldBorder(color: AppColors.primary),
                ),
                items: [
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
                onChanged: onCategoryChanged,
              ),
            ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 14),
            const Divider(height: 1, color: _cardBorder),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: onClear,
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF667085),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  child: Text(
                    'Clear',
                    style: AppTypography.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF667085),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: onUpdate,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.primary.withValues(
                      alpha: 0.45,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: isSaving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(LucideIcons.pencil, size: 16),
                  label: const Text('Update Items'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

OutlineInputBorder _fieldBorder({Color color = _cardBorder}) {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: BorderSide(color: color),
  );
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.inter(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF344054),
          ),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}

class _MoneyField extends StatelessWidget {
  const _MoneyField({required this.controller, required this.hint});

  final TextEditingController controller;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp('[0-9.]')),
      ],
      style: AppTypography.inter(fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTypography.inter(
          fontSize: 14,
          color: const Color(0xFF9AA0AE),
        ),
        prefixIcon: const SizedBox(
          width: 36,
          child: Center(
            child: Text(
              '₹',
              style: TextStyle(
                fontSize: 15,
                color: Color(0xFF667085),
              ),
            ),
          ),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 36),
        isDense: true,
        filled: true,
        fillColor: _fieldFill,
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        border: _fieldBorder(),
        enabledBorder: _fieldBorder(),
        focusedBorder: _fieldBorder(color: AppColors.primary),
      ),
    );
  }
}

class _PlainField extends StatelessWidget {
  const _PlainField({required this.controller, required this.hint});

  final TextEditingController controller;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: AppTypography.inter(fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTypography.inter(
          fontSize: 14,
          color: const Color(0xFF9AA0AE),
        ),
        isDense: true,
        filled: true,
        fillColor: _fieldFill,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        border: _fieldBorder(),
        enabledBorder: _fieldBorder(),
        focusedBorder: _fieldBorder(color: AppColors.primary),
      ),
    );
  }
}

class _ItemRow extends StatefulWidget {
  const _ItemRow({
    required this.item,
    required this.typeLabel,
    required this.selected,
    required this.onToggle,
  });

  final InventoryItem item;
  final String typeLabel;
  final bool selected;
  final VoidCallback onToggle;

  @override
  State<_ItemRow> createState() => _ItemRowState();
}

class _ItemRowState extends State<_ItemRow> {
  var _hovered = false;

  @override
  Widget build(BuildContext context) {
    final background = widget.selected
        ? _selectedRow
        : _hovered
        ? _hoverRow
        : AppColors.surface;
    final code = widget.item.barcode?.trim();

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: SizedBox(
        height: _itemRowExtent,
        child: Material(
        color: background,
        child: InkWell(
          onTap: widget.onToggle,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                Checkbox(
                  value: widget.selected,
                  onChanged: (_) => widget.onToggle(),
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                const SizedBox(width: 8),
                InventoryItemListThumbnail(
                  item: widget.item,
                  borderRadius: 8,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.item.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (code != null && code.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          'Code: $code',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.inter(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _chipBg,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    widget.typeLabel,
                    style: AppTypography.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }
}
