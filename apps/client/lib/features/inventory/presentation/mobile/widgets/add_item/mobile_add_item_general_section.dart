import 'dart:async';

import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/application/inventory_brands_provider.dart';
import 'package:billing_baba/features/inventory/application/inventory_items_provider.dart';
import 'package:billing_baba/features/inventory/application/inventory_search_provider.dart';
import 'package:billing_baba/features/inventory/models/brand_model.dart';
import 'package:billing_baba/features/inventory/models/category_model.dart';
import 'package:billing_baba/features/inventory/models/item_model.dart';
import 'package:billing_baba/features/inventory/models/unit_model.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/add_category_dialog.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/add_item/alternative_items_field.dart';
import 'package:billing_baba/features/inventory/presentation/mobile/widgets/add_item/mobile_add_item_field.dart';
import 'package:billing_baba/features/inventory/presentation/mobile/widgets/add_item/mobile_add_item_theme.dart';
import 'package:billing_baba/features/inventory/presentation/mobile/widgets/brands/mobile_add_brand_sheet.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Vyapar-style basic details for mobile Add Item.
class MobileAddItemGeneralSection extends ConsumerWidget {
  const MobileAddItemGeneralSection({
    required this.itemType,
    required this.itemNameController,
    required this.itemCodeController,
    required this.descriptionController,
    required this.hsnController,
    required this.itemNameError,
    required this.baseUnitError,
    required this.onItemNameChanged,
    required this.onItemCodeChanged,
    required this.onDescriptionChanged,
    required this.onHsnChanged,
    required this.onAssignCode,
    required this.onSelectUnit,
    required this.baseUnit,
    required this.categoryOptions,
    required this.selectedCategory,
    required this.categories,
    required this.onCategorySelected,
    required this.selectedBrand,
    required this.brands,
    required this.onBrandSelected,
    required this.onAddManufacturingDetails,
    this.onScanBarcode,
    this.showCategory = true,
    this.showDescription = true,
    this.showManufacturing = false,
    this.selectedAlternativeItemIds = const [],
    this.excludeAlternativeItemId,
    this.onAlternativeItemIdsChanged,
    this.showAlternatives = false,
    super.key,
  });

  final ItemType itemType;
  final TextEditingController itemNameController;
  final TextEditingController itemCodeController;
  final TextEditingController descriptionController;
  final TextEditingController hsnController;
  final bool itemNameError;
  final bool baseUnitError;
  final ValueChanged<String> onItemNameChanged;
  final ValueChanged<String> onItemCodeChanged;
  final ValueChanged<String> onDescriptionChanged;
  final ValueChanged<String> onHsnChanged;
  final VoidCallback onAssignCode;
  final VoidCallback onSelectUnit;
  final InventoryUnit? baseUnit;
  final List<String> categoryOptions;
  final String? selectedCategory;
  final List<InventoryCategory> categories;
  final ValueChanged<String?> onCategorySelected;
  final String? selectedBrand;
  final List<BrandModel> brands;
  final ValueChanged<String?> onBrandSelected;
  final VoidCallback onAddManufacturingDetails;
  final VoidCallback? onScanBarcode;
  final bool showCategory;
  final bool showDescription;
  final bool showManufacturing;
  final List<String> selectedAlternativeItemIds;
  final String? excludeAlternativeItemId;
  final ValueChanged<List<String>>? onAlternativeItemIdsChanged;
  final bool showAlternatives;

  bool get _isProduct => itemType == ItemType.product;

  String? get _unitHelper {
    final unit = baseUnit;
    if (unit == null) return null;
    return '${unit.fullName.toUpperCase()} (${unit.shortName.toUpperCase()})';
  }

  String? get _nameFieldErrorText {
    final parts = <String>[
      if (itemNameError)
        _isProduct ? 'Item name is required' : 'Service name is required',
      if (baseUnitError) 'Please select a base unit.',
    ];
    if (parts.isEmpty) return null;
    return parts.join('\n');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nameLabel = _isProduct ? 'Item Name *' : 'Service Name *';
    final codeLabel =
        _isProduct ? 'Item Code / Barcode' : 'Service Code';
    final taxLabel = _isProduct ? 'HSN/SAC Code' : 'SAC Code';

    return ColoredBox(
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          MobileAddItemTheme.horizontalPadding,
          12,
          MobileAddItemTheme.horizontalPadding,
          4,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MobileAddItemField(
              controller: itemNameController,
              label: nameLabel,
              hint: nameLabel,
              hasError: itemNameError || baseUnitError,
              errorText: _nameFieldErrorText,
              helperText: baseUnitError ? null : _unitHelper,
              onChanged: onItemNameChanged,
              suffix: TextButton(
                onPressed: onSelectUnit,
                style: MobileAddItemTheme.inlineActionStyle().copyWith(
                  foregroundColor: WidgetStatePropertyAll(
                    baseUnitError ? AppColors.error : MobileAddItemTheme.inlineButtonText,
                  ),
                ),
                child: Text(baseUnit == null ? 'Select Unit' : 'Edit Unit'),
              ),
            ),
            const SizedBox(height: MobileAddItemTheme.fieldSpacing),
            MobileAddItemField(
              controller: itemCodeController,
              label: codeLabel,
              hint: codeLabel,
              keyboardType: TextInputType.text,
              onChanged: onItemCodeChanged,
              suffix: TextButton(
                onPressed: onAssignCode,
                style: MobileAddItemTheme.inlineActionStyle(),
                child: const Text('Assign Code'),
              ),
            ),
            if (_isProduct && onScanBarcode != null) ...[
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: onScanBarcode,
                  icon: const Icon(Icons.qr_code_scanner_rounded, size: 18),
                  label: const Text('Scan code'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    textStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
            if (showCategory) ...[
              const SizedBox(height: MobileAddItemTheme.fieldSpacing),
              _CategoryField(
                categoryOptions: categoryOptions,
                selectedCategory: selectedCategory,
                categories: categories,
                onCategorySelected: onCategorySelected,
              ),
            ],
            const SizedBox(height: MobileAddItemTheme.fieldSpacing),
            _BrandField(
              selectedBrandName: selectedBrand,
              brands: brands,
              onBrandSelected: onBrandSelected,
            ),
            if (showAlternatives && onAlternativeItemIdsChanged != null) ...[
              const SizedBox(height: MobileAddItemTheme.fieldSpacing),
              _AlternativesField(
                selectedItemIds: selectedAlternativeItemIds,
                excludeItemId: excludeAlternativeItemId,
                onChanged: onAlternativeItemIdsChanged!,
              ),
            ],
            if (showDescription) ...[
              const SizedBox(height: MobileAddItemTheme.fieldSpacing),
              MobileAddItemField(
                controller: descriptionController,
                label: 'Description',
                hint: 'Description',
                maxLines: 3,
                onChanged: onDescriptionChanged,
              ),
            ],
            const SizedBox(height: MobileAddItemTheme.fieldSpacing),
            MobileAddItemField(
              controller: hsnController,
              label: taxLabel,
              hint: taxLabel,
              onChanged: onHsnChanged,
              suffixIcon: IconButton(
                onPressed: () {},
                icon: const Icon(Icons.search, size: 20, color: AppColors.primary),
                tooltip: 'Search $taxLabel',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              ),
            ),
            if (_isProduct) ...[
              if (showManufacturing) ...[
                const SizedBox(height: MobileAddItemTheme.fieldSpacing),
                TextButton.icon(
                  onPressed: onAddManufacturingDetails,
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Add Manufacturing Details'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(),
                    alignment: Alignment.centerLeft,
                    textStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _CategoryField extends StatelessWidget {
  const _CategoryField({
    required this.categoryOptions,
    required this.selectedCategory,
    required this.categories,
    required this.onCategorySelected,
  });

  final List<String> categoryOptions;
  final String? selectedCategory;
  final List<InventoryCategory> categories;
  final ValueChanged<String?> onCategorySelected;

  @override
  Widget build(BuildContext context) {
    final display = selectedCategory ?? 'Item Category';

    return InkWell(
      onTap: () => _openCategoryPicker(context),
      borderRadius: BorderRadius.circular(MobileAddItemTheme.fieldRadius),
      child: InputDecorator(
        decoration: MobileAddItemTheme.fieldDecoration(
          label: 'Item Category',
          hint: 'Item Category',
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                display,
                style: TextStyle(
                  fontSize: 14,
                  color: selectedCategory == null
                      ? AppColors.textSecondary.withValues(alpha: 0.7)
                      : AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.textSecondary.withValues(alpha: 0.7),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openCategoryPicker(BuildContext context) async {
    if (categoryOptions.isEmpty) {
      await showAddCategoryDialog(context);
      return;
    }

    final picked = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        final height = MediaQuery.sizeOf(sheetContext).height * 0.55;
        return SizedBox(
          height: height,
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Item Category',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(sheetContext).pop();
                          unawaited(showAddCategoryDialog(context));
                        },
                        child: const Text('Add New'),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView.builder(
                    itemCount: categoryOptions.length,
                    itemBuilder: (context, index) {
                      final name = categoryOptions[index];
                      return ListTile(
                        title: Text(name),
                        trailing: name == selectedCategory
                            ? const Icon(Icons.check, color: AppColors.primary)
                            : null,
                        onTap: () => Navigator.of(sheetContext).pop(name),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (picked == null) return;
    final category = categories.firstWhereOrNull((c) => c.name == picked);
    onCategorySelected(category?.id);
  }
}

class _BrandField extends ConsumerWidget {
  const _BrandField({
    required this.selectedBrandName,
    required this.brands,
    required this.onBrandSelected,
  });

  final String? selectedBrandName;
  final List<BrandModel> brands;
  final ValueChanged<String?> onBrandSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final display = selectedBrandName ?? 'Select';

    return InkWell(
      onTap: () => unawaited(_openBrandPicker(context, ref)),
      borderRadius: BorderRadius.circular(MobileAddItemTheme.fieldRadius),
      child: InputDecorator(
        decoration: MobileAddItemTheme.fieldDecoration(
          label: 'Brand',
          hint: 'Select',
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                display,
                style: TextStyle(
                  fontSize: 14,
                  color: selectedBrandName == null
                      ? AppColors.textSecondary.withValues(alpha: 0.7)
                      : AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.textSecondary.withValues(alpha: 0.7),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openBrandPicker(BuildContext context, WidgetRef ref) async {
    final brandsAsync = ref.read(inventoryBrandsProvider);
    if (brandsAsync.isLoading && brands.isEmpty) {
      return;
    }

    final options = brands.isNotEmpty
        ? brands
        : (brandsAsync.value ?? const <BrandModel>[]);

    if (options.isEmpty) {
      final created = await showMobileAddBrandSheet(context);
      if (created != null) onBrandSelected(created.id);
      return;
    }

    final pickedId = await showModalBottomSheet<String?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) => _BrandPickerSheet(
        brands: options,
        selectedBrandName: selectedBrandName,
        onAddNew: () async {
          Navigator.of(sheetContext).pop();
          final created = await showMobileAddBrandSheet(context);
          if (created != null) onBrandSelected(created.id);
        },
      ),
    );

    if (!context.mounted) return;
    // null = sheet dismissed; empty string = clear selection.
    if (pickedId == null) return;
    if (pickedId.isEmpty) {
      onBrandSelected(null);
      return;
    }
    onBrandSelected(pickedId);
  }
}

class _BrandPickerSheet extends StatefulWidget {
  const _BrandPickerSheet({
    required this.brands,
    required this.selectedBrandName,
    required this.onAddNew,
  });

  final List<BrandModel> brands;
  final String? selectedBrandName;
  final VoidCallback onAddNew;

  @override
  State<_BrandPickerSheet> createState() => _BrandPickerSheetState();
}

class _BrandPickerSheetState extends State<_BrandPickerSheet> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim().toLowerCase();
    final filtered = query.isEmpty
        ? widget.brands
        : widget.brands
            .where((b) => b.name.toLowerCase().contains(query))
            .toList();
    final height = MediaQuery.sizeOf(context).height * 0.6;

    return SizedBox(
      height: height,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Brand',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: widget.onAddNew,
                    child: const Text('Add New'),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _searchController,
                decoration: MobileAddItemTheme.fieldDecoration(
                  hint: 'Search brands',
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(height: 8),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                itemCount: filtered.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return ListTile(
                      title: const Text('None'),
                      trailing: widget.selectedBrandName == null
                          ? const Icon(Icons.check, color: AppColors.primary)
                          : null,
                      // Empty string signals clear selection.
                      onTap: () => Navigator.of(context).pop(''),
                    );
                  }
                  final brand = filtered[index - 1];
                  final selected = brand.name == widget.selectedBrandName;
                  return ListTile(
                    title: Text(brand.name),
                    trailing: selected
                        ? const Icon(Icons.check, color: AppColors.primary)
                        : null,
                    onTap: () => Navigator.of(context).pop(brand.id),
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

class _AlternativesField extends ConsumerWidget {
  const _AlternativesField({
    required this.selectedItemIds,
    required this.onChanged,
    this.excludeItemId,
  });

  final List<String> selectedItemIds;
  final String? excludeItemId;
  final ValueChanged<List<String>> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(inventoryItemListProvider);
    final itemsById = {for (final item in items) item.id: item};
    final selectedItems = selectedItemIds
        .map((id) => itemsById[id])
        .whereType<InventoryItem>()
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Alternative Items',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary.withValues(alpha: 0.95),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final item in selectedItems)
              InputChip(
                label: Text(item.name),
                onDeleted: () => onChanged(
                  selectedItemIds.where((id) => id != item.id).toList(),
                ),
              ),
            ActionChip(
              avatar: const Icon(Icons.add, size: 16),
              label: const Text('Add alternative'),
              onPressed: () => unawaited(_openPicker(context, ref)),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Suggested when users search for this item on invoices.',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary.withValues(alpha: 0.85),
          ),
        ),
      ],
    );
  }

  Future<void> _openPicker(BuildContext context, WidgetRef ref) async {
    final items = ref.read(inventoryItemListProvider);
    final picked = await showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) => _AlternativeItemsPickerSheet(
        items: items,
        initialSelection: selectedItemIds,
        excludeItemId: excludeItemId,
      ),
    );
    if (picked != null) onChanged(picked);
  }
}

class _AlternativeItemsPickerSheet extends ConsumerStatefulWidget {
  const _AlternativeItemsPickerSheet({
    required this.items,
    required this.initialSelection,
    this.excludeItemId,
  });

  final List<InventoryItem> items;
  final List<String> initialSelection;
  final String? excludeItemId;

  @override
  ConsumerState<_AlternativeItemsPickerSheet> createState() =>
      _AlternativeItemsPickerSheetState();
}

class _AlternativeItemsPickerSheetState
    extends ConsumerState<_AlternativeItemsPickerSheet> {
  late final TextEditingController _searchController;
  late Set<String> _selected;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _selected = widget.initialSelection.toSet();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim();
    final engine = ref.watch(inventorySearchEngineProvider);
    // Match desktop: all items except the item being edited.
    final candidates = widget.items
        .where((item) => item.id != widget.excludeItemId)
        .toList();
    final filtered = query.isEmpty
        ? candidates
        : engine.searchItems(candidates, query: query);
    final height = MediaQuery.sizeOf(context).height * 0.7;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SizedBox(
        height: height,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Select alternative items',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      onPressed: () =>
                          Navigator.of(context).pop(_selected.toList()),
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _searchController,
                  decoration: MobileAddItemTheme.fieldDecoration(
                    hint: 'Search items',
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(height: 8),
              const Divider(height: 1),
              Expanded(
                child: filtered.isEmpty
                    ? const Center(
                        child: Text(
                          'No items found',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      )
                    : ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final item = filtered[index];
                          final checked = _selected.contains(item.id);
                          return CheckboxListTile(
                            value: checked,
                            title: Text(item.name),
                            subtitle: Text(
                              alternativePickerStockLabel(item),
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            onChanged: (value) {
                              setState(() {
                                if (value == true) {
                                  _selected.add(item.id);
                                } else {
                                  _selected.remove(item.id);
                                }
                              });
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
