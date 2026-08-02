import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/models/add_item_form_model.dart';
import 'package:billing_baba/features/inventory/models/category_model.dart';
import 'package:billing_baba/features/inventory/models/item_model.dart';
import 'package:billing_baba/features/inventory/models/unit_model.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/add_category_dialog.dart';
import 'package:billing_baba/features/inventory/presentation/mobile/widgets/add_item/mobile_add_item_field.dart';
import 'package:billing_baba/features/inventory/presentation/mobile/widgets/add_item/mobile_add_item_theme.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Vyapar-style basic details for mobile Add Item.
class MobileAddItemGeneralSection extends StatelessWidget {
  const MobileAddItemGeneralSection({
    required this.itemType,
    required this.itemNameController,
    required this.itemCodeController,
    required this.descriptionController,
    required this.hsnController,
    required this.itemNameError,
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
    required this.trackingMode,
    required this.onTrackingModeChanged,
    required this.onAddManufacturingDetails,
    this.onScanBarcode,
    this.showCategory = true,
    this.showDescription = true,
    super.key,
  });

  final ItemType itemType;
  final TextEditingController itemNameController;
  final TextEditingController itemCodeController;
  final TextEditingController descriptionController;
  final TextEditingController hsnController;
  final bool itemNameError;
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
  final ItemTrackingMode trackingMode;
  final ValueChanged<ItemTrackingMode> onTrackingModeChanged;
  final VoidCallback onAddManufacturingDetails;
  final VoidCallback? onScanBarcode;
  final bool showCategory;
  final bool showDescription;

  bool get _isProduct => itemType == ItemType.product;

  String? get _unitHelper {
    final unit = baseUnit;
    if (unit == null) return null;
    return '${unit.fullName.toUpperCase()} (${unit.shortName.toUpperCase()})';
  }

  @override
  Widget build(BuildContext context) {
    final nameLabel = _isProduct ? 'Item Name *' : 'Service Name *';
    final codeLabel = _isProduct ? 'Item Code / Barcode' : 'Service Code';
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
              hasError: itemNameError,
              errorText: 'Item name is required',
              helperText: _unitHelper,
              onChanged: onItemNameChanged,
              suffix: TextButton(
                onPressed: onSelectUnit,
                style: MobileAddItemTheme.inlineActionStyle(),
                child: const Text('Edit Unit'),
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
                icon: const Icon(
                  Icons.search,
                  size: 20,
                  color: AppColors.primary,
                ),
                tooltip: 'Search $taxLabel',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              ),
            ),
            if (_isProduct) ...[
              const SizedBox(height: MobileAddItemTheme.fieldSpacing),
              Row(
                children: [
                  Checkbox(
                    value: trackingMode == ItemTrackingMode.batch,
                    activeColor: AppColors.primary,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                    onChanged: (checked) => onTrackingModeChanged(
                      checked == true
                          ? ItemTrackingMode.batch
                          : ItemTrackingMode.none,
                    ),
                  ),
                  const Text(
                    'Batch Tracking',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.info_outline_rounded,
                      size: 18,
                      color: AppColors.textSecondary.withValues(alpha: 0.8),
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 28,
                      minHeight: 28,
                    ),
                    tooltip: 'Track inventory by batch number',
                  ),
                ],
              ),
              const SizedBox(height: 4),
              TextButton.icon(
                onPressed: onAddManufacturingDetails,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Add Manufacturing Details'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  alignment: Alignment.centerLeft,
                  textStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
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
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
                        showAddCategoryDialog(context);
                      },
                      child: const Text('Add New'),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
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
        );
      },
    );

    if (picked == null) return;
    final category = categories.firstWhereOrNull((c) => c.name == picked);
    onCategorySelected(category?.id);
  }
}
