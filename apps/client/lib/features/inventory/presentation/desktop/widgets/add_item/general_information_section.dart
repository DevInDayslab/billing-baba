import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/shared/widgets/app_ellipsis_text.dart';
import 'package:billing_baba/features/inventory/application/inventory_item_list_merge.dart';
import 'package:billing_baba/features/inventory/models/brand_model.dart';
import 'package:billing_baba/features/inventory/models/category_model.dart';
import 'package:billing_baba/features/inventory/models/item_model.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/add_category_dialog.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/item_image_gallery_section.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_field_decoration.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_generic_select_dropdown.dart';
import 'package:billing_baba/shared/widgets/forms/forms.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Basic details block — shared Product / Service grid (Vyapar-aligned).
class GeneralInformationSection extends StatelessWidget {
  const GeneralInformationSection({
    required this.itemType,
    required this.itemNameController,
    required this.shortNameController,
    required this.aliasController,
    required this.searchKeywordsController,
    required this.hsnController,
    required this.itemCodeController,
    required this.descriptionController,
    required this.itemNameError,
    required this.onItemNameChanged,
    required this.onShortNameChanged,
    required this.onAliasChanged,
    required this.onSearchKeywordsChanged,
    required this.onHsnChanged,
    required this.onItemCodeChanged,
    required this.onDescriptionChanged,
    required this.onAssignCode,
    required this.categoryOptions,
    required this.selectedCategory,
    required this.categories,
    required this.onCategorySelected,
    required this.brandOptions,
    required this.selectedBrand,
    required this.brands,
    required this.onBrandSelected,
    required this.unitLabel,
    required this.onSelectUnit,
    this.alternativeItemsField,
    this.itemId,
    this.seedPrimaryImageUrl,
    super.key,
  });

  final ItemType itemType;
  final TextEditingController itemNameController;
  final TextEditingController shortNameController;
  final TextEditingController aliasController;
  final TextEditingController searchKeywordsController;
  final TextEditingController hsnController;
  final TextEditingController itemCodeController;
  final TextEditingController descriptionController;
  final bool itemNameError;
  final ValueChanged<String> onItemNameChanged;
  final ValueChanged<String> onShortNameChanged;
  final ValueChanged<String> onAliasChanged;
  final ValueChanged<String> onSearchKeywordsChanged;
  final ValueChanged<String> onHsnChanged;
  final ValueChanged<String> onItemCodeChanged;
  final ValueChanged<String> onDescriptionChanged;
  final VoidCallback onAssignCode;
  final List<String> categoryOptions;
  final String? selectedCategory;
  final List<InventoryCategory> categories;
  final ValueChanged<String?> onCategorySelected;
  final List<String> brandOptions;
  final String? selectedBrand;
  final List<BrandModel> brands;
  final ValueChanged<String?> onBrandSelected;
  final String unitLabel;
  final VoidCallback onSelectUnit;
  final Widget? alternativeItemsField;
  final String? itemId;
  final String? seedPrimaryImageUrl;

  bool get _isProduct => itemType == ItemType.product;

  @override
  Widget build(BuildContext context) {
    final nameLabel = _isProduct ? 'Item Name *' : 'Service Name *';
    final taxCodeLabel = _isProduct ? 'Item HSN' : 'SAC';
    final taxCodeHint = _isProduct ? 'Search HSN' : 'Search SAC';
    final codeLabel = _isProduct ? 'Item Code' : 'Service Code';
    final unitDisplay =
        unitLabel.isEmpty || unitLabel == 'None' || unitLabel == 'Select unit'
        ? 'Select Unit'
        : unitLabel;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Row 1 — equal-width controls (3+3+3+3)
        FormGrid(
          cells: [
            FormGridCell(
              span: 3,
              child: AppFormField(
                label: nameLabel,
                hasError: itemNameError,
                errorText: 'Item name is required',
                child: TextField(
                  controller: itemNameController,
                  style: saleFieldTextStyle,
                  decoration: buildFormControlDecoration(
                    hint: _isProduct ? 'Enter item name' : 'Enter service name',
                    hasError: itemNameError,
                  ),
                  onChanged: onItemNameChanged,
                ),
              ),
            ),
            FormGridCell(
              span: 3,
              child: AppFormField(
                label: taxCodeLabel,
                child: TextField(
                  controller: hsnController,
                  style: saleFieldTextStyle,
                  decoration: buildFormControlDecoration(
                    hint: taxCodeHint,
                    suffixIcon: IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.search, size: 18),
                      color: AppColors.textSecondary,
                      tooltip: taxCodeHint,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: FormSpacing.inputHeight,
                        minHeight: FormSpacing.inputHeight,
                      ),
                    ),
                  ),
                  onChanged: onHsnChanged,
                ),
              ),
            ),
            FormGridCell(
              span: 3,
              child: AppFormField(
                label: codeLabel,
                child: TextField(
                  controller: itemCodeController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: saleFieldTextStyle,
                  decoration: buildFormControlDecoration(
                    hint: codeLabel,
                    suffix: TextButton(
                      onPressed: onAssignCode,
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Assign Code',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  onChanged: onItemCodeChanged,
                ),
              ),
            ),
            FormGridCell(
              span: 3,
              child: AppFormField(
                label: 'Select Unit',
                child: OutlinedButton(
                  onPressed: onSelectUnit,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    backgroundColor: const Color(0xFFE3F2FD),
                    side: BorderSide.none,
                    minimumSize: const Size.fromHeight(FormSpacing.inputHeight),
                    maximumSize: const Size.fromHeight(FormSpacing.inputHeight),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: AppEllipsisText(
                    unitDisplay,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
            FormGridCell(
              span: 3,
              child: AppFormField(
                label: 'Short Name',
                child: TextField(
                  controller: shortNameController,
                  style: saleFieldTextStyle,
                  decoration: buildFormControlDecoration(
                    hint: 'Short display name',
                  ),
                  onChanged: onShortNameChanged,
                ),
              ),
            ),
            FormGridCell(
              span: 3,
              child: AppFormField(
                label: 'Alias',
                child: TextField(
                  controller: aliasController,
                  style: saleFieldTextStyle,
                  decoration: buildFormControlDecoration(hint: 'Alternate name'),
                  onChanged: onAliasChanged,
                ),
              ),
            ),
            FormGridCell(
              span: 3,
              child: AppFormField(
                label: 'Search Keywords',
                child: TextField(
                  controller: searchKeywordsController,
                  style: saleFieldTextStyle,
                  decoration: buildFormControlDecoration(
                    hint: 'Comma-separated keywords',
                  ),
                  onChanged: onSearchKeywordsChanged,
                ),
              ),
            ),
            FormGridCell(
              span: 3,
              child: AppFormField(
                label: 'Brand',
                fixedHeight: false,
                child: SizedBox(
                  height: FormSpacing.inputHeight,
                  child: SaleGenericSelectDropdown(
                    value: selectedBrand ?? 'Select',
                    options: brandOptions,
                    onSelected: (name) {
                      final brand = brands.firstWhereOrNull(
                        (entry) => entry.name == name,
                      );
                      onBrandSelected(brand?.id);
                    },
                  ),
                ),
              ),
            ),
            // Row 2 — Category | Description | Add Item Image
            FormGridCell(
              span: 4,
              child: AppFormField(
                label: 'Category',
                fixedHeight: false,
                child: SizedBox(
                  height: FormSpacing.inputHeight,
                  child: Row(
                    children: [
                      Expanded(
                        child: SaleGenericSelectDropdown(
                          value: selectedCategory ?? 'Select',
                          options: categoryOptions,
                          onSelected: (name) {
                            final category = categories.firstWhereOrNull(
                              (c) => c.name == name,
                            );
                            onCategorySelected(category?.id);
                          },
                        ),
                      ),
                      IconButton(
                        onPressed: () => showAddCategoryDialog(context),
                        icon: const Icon(Icons.add, size: 18),
                        tooltip: 'Add category',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: FormSpacing.inputHeight,
                          minHeight: FormSpacing.inputHeight,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            FormGridCell(
              span: 5,
              child: AppFormField(
                label: 'Description',
                child: TextField(
                  controller: descriptionController,
                  style: saleFieldTextStyle,
                  decoration: buildFormControlDecoration(hint: 'Description'),
                  onChanged: onDescriptionChanged,
                ),
              ),
            ),
            FormGridCell(
              span: 3,
              child: AppFormField(
                label: _isProduct ? 'Item Images' : 'Service Images',
                fixedHeight: false,
                child: itemId == null || !isServerBackedInventoryItemId(itemId!)
                    ? Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          itemId == null
                              ? (_isProduct
                                    ? 'Save item to add images'
                                    : 'Save service to add images')
                              : 'Images available after item is synced to the server',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary.withValues(
                              alpha: 0.9,
                            ),
                          ),
                        ),
                      )
                    : ItemImageGallerySection(
                        itemId: itemId!,
                        seedPrimaryImageUrl: seedPrimaryImageUrl,
                      ),
              ),
            ),
          ],
        ),
        if (alternativeItemsField != null) ...[
          const SizedBox(height: FormSpacing.section),
          alternativeItemsField!,
        ],
      ],
    );
  }
}
