import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/application/inventory_item_list_merge.dart';
import 'package:billing_baba/features/inventory/models/brand_model.dart';
import 'package:billing_baba/features/inventory/models/category_model.dart';
import 'package:billing_baba/features/inventory/models/item_model.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/add_item/add_item_brand_picker_field.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/add_item/add_item_category_picker_field.dart';
import 'package:billing_baba/features/inventory/application/item_images_provider.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/item_image_gallery_section.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_field_decoration.dart';
import 'package:billing_baba/shared/widgets/app_ellipsis_text.dart';
import 'package:billing_baba/shared/widgets/forms/forms.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Basic details block — shared Product / Service grid (Vyapar-aligned).
class GeneralInformationSection extends StatelessWidget {
  const GeneralInformationSection({
    required this.itemType,
    required this.itemNameController,
    required this.shortNameController,
    required this.searchKeywordsController,
    required this.hsnController,
    required this.itemCodeController,
    required this.descriptionController,
    required this.itemNameError,
    required this.baseUnitError,
    required this.onItemNameChanged,
    required this.onShortNameChanged,
    required this.onSearchKeywordsChanged,
    required this.onHsnChanged,
    required this.onItemCodeChanged,
    required this.onDescriptionChanged,
    required this.onAssignCode,
    required this.selectedCategoryId,
    required this.selectedCategory,
    required this.categories,
    required this.onCategorySelected,
    required this.selectedBrandId,
    required this.selectedBrand,
    required this.brands,
    required this.onBrandSelected,
    required this.unitLabel,
    required this.onSelectUnit,
    this.alternativesInlineAddButton,
    this.alternativesListSection,
    this.itemId,
    this.seedPrimaryImageUrl,
    this.pendingItemPhotos = const [],
    this.onPendingPhotoTap,
    super.key,
  });

  final ItemType itemType;
  final TextEditingController itemNameController;
  final TextEditingController shortNameController;
  final TextEditingController searchKeywordsController;
  final TextEditingController hsnController;
  final TextEditingController itemCodeController;
  final TextEditingController descriptionController;
  final bool itemNameError;
  final bool baseUnitError;
  final ValueChanged<String> onItemNameChanged;
  final ValueChanged<String> onShortNameChanged;
  final ValueChanged<String> onSearchKeywordsChanged;
  final ValueChanged<String> onHsnChanged;
  final ValueChanged<String> onItemCodeChanged;
  final ValueChanged<String> onDescriptionChanged;
  final VoidCallback onAssignCode;
  final String? selectedCategoryId;
  final String? selectedCategory;
  final List<InventoryCategory> categories;
  final ValueChanged<String?> onCategorySelected;
  final String? selectedBrandId;
  final String? selectedBrand;
  final List<BrandModel> brands;
  final ValueChanged<String?> onBrandSelected;
  final String unitLabel;
  final VoidCallback onSelectUnit;
  final Widget? alternativesInlineAddButton;
  final Widget? alternativesListSection;
  final String? itemId;
  final String? seedPrimaryImageUrl;
  final List<Uint8List> pendingItemPhotos;
  final ValueChanged<int>? onPendingPhotoTap;

  bool get _isProduct => itemType == ItemType.product;

  static const _pendingThumbSize = 52.0;

  static const _gridRowGap = 12.0;

  bool _isUnitEmpty(String display) {
    return display.isEmpty ||
        display == 'None' ||
        display == 'Select unit' ||
        display == 'Select Unit';
  }

  bool get _showItemImagesRow {
    if (itemId != null && isServerBackedInventoryItemId(itemId!)) {
      return true;
    }
    return pendingItemPhotos.isNotEmpty;
  }

  Widget _buildItemImagesContent() {
    if (itemId != null && isServerBackedInventoryItemId(itemId!)) {
      return ItemImageGallerySection(
        itemId: itemId!,
        seedPrimaryImageUrl: seedPrimaryImageUrl,
      );
    }

    if (pendingItemPhotos.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (var i = 0; i < pendingItemPhotos.length; i++)
          _PendingPhotoThumb(
            bytes: pendingItemPhotos[i],
            isPrimary: i == 0,
            onTap: onPendingPhotoTap == null
                ? null
                : () => onPendingPhotoTap!(i),
          ),
      ],
    );
  }

  Widget _floatingField({
    required String label,
    required Widget child,
    bool hasError = false,
    String? errorText,
    bool fixedHeight = true,
  }) {
    return AppFormField(
      label: label,
      floatingLabel: true,
      hasError: hasError,
      errorText: errorText,
      fixedHeight: fixedHeight,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final nameLabel = _isProduct ? 'Item Name *' : 'Service Name *';
    final taxCodeLabel = _isProduct ? 'Item HSN' : 'SAC';
    final codeLabel = _isProduct ? 'Item Code' : 'Service Code';
    final unitDisplay =
        unitLabel.isEmpty || unitLabel == 'None' || unitLabel == 'Select unit'
        ? ''
        : unitLabel;
    final brandDisplay = selectedBrand ?? '';
    final categoryDisplay = selectedCategory ?? '';
    const decoratorTriggerHeight = saleFieldHeight - 20;
    const selectFieldPadding = EdgeInsets.fromLTRB(4, 12, 4, 12);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FormGrid(
          rowGap: _gridRowGap,
          cells: [
            FormGridCell(
              span: 3,
              child: _floatingField(
                label: nameLabel,
                hasError: itemNameError,
                errorText: 'Item name is required',
                child: TextField(
                  controller: itemNameController,
                  style: saleFieldTextStyle,
                  decoration: buildFormControlDecoration(
                    labelText: nameLabel,
                    hasError: itemNameError,
                  ),
                  onChanged: onItemNameChanged,
                ),
              ),
            ),
            FormGridCell(
              span: 3,
              child: _floatingField(
                label: taxCodeLabel,
                child: TextField(
                  controller: hsnController,
                  style: saleFieldTextStyle,
                  decoration: buildFormControlDecoration(
                    labelText: taxCodeLabel,
                    suffixIcon: IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.search, size: 18),
                      color: AppColors.textSecondary,
                      tooltip: taxCodeLabel,
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
              child: _floatingField(
                label: codeLabel,
                child: TextField(
                  controller: itemCodeController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: saleFieldTextStyle,
                  decoration: buildFormControlDecoration(
                    labelText: codeLabel,
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
              child: _floatingField(
                label: 'Select Unit',
                hasError: baseUnitError,
                errorText: 'Please select a base unit.',
                child: InputDecorator(
                  isEmpty: _isUnitEmpty(unitDisplay),
                  decoration: buildFormControlDecoration(
                    hint: 'Select Unit',
                    hasError: baseUnitError,
                  ),
                  child: InkWell(
                    onTap: onSelectUnit,
                    child: SizedBox(
                      height: saleFieldHeight - 20,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: AppEllipsisText(
                          _isUnitEmpty(unitDisplay) ? ' ' : unitDisplay,
                          style: saleFieldTextStyle.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            FormGridCell(
              span: 3,
              child: _floatingField(
                label: 'Short Name',
                child: TextField(
                  controller: shortNameController,
                  style: saleFieldTextStyle,
                  decoration: buildFormControlDecoration(
                    labelText: 'Short Name',
                  ),
                  onChanged: onShortNameChanged,
                ),
              ),
            ),
            FormGridCell(
              span: 3,
              child: _floatingField(
                label: 'Search Keywords',
                child: TextField(
                  controller: searchKeywordsController,
                  style: saleFieldTextStyle,
                  decoration: buildFormControlDecoration(
                    labelText: 'Search Keywords',
                  ),
                  onChanged: onSearchKeywordsChanged,
                ),
              ),
            ),
            FormGridCell(
              span: 3,
              child: _floatingField(
                label: 'Brand',
                child: InputDecorator(
                  isEmpty: brandDisplay.isEmpty,
                  decoration: buildFormControlDecoration(
                    labelText: 'Brand',
                    contentPadding: selectFieldPadding,
                  ),
                  child: AddItemBrandPickerField(
                    borderless: true,
                    triggerHeight: decoratorTriggerHeight,
                    brands: brands,
                    selectedBrandId: selectedBrandId,
                    selectedBrandName: selectedBrand,
                    onBrandSelected: onBrandSelected,
                  ),
                ),
              ),
            ),
            FormGridCell(
              span: 3,
              child: _floatingField(
                label: 'Category',
                child: InputDecorator(
                  isEmpty: categoryDisplay.isEmpty,
                  decoration: buildFormControlDecoration(
                    labelText: 'Category',
                    contentPadding: selectFieldPadding,
                  ),
                  child: AddItemCategoryPickerField(
                    borderless: true,
                    triggerHeight: decoratorTriggerHeight,
                    categories: categories,
                    selectedCategoryId: selectedCategoryId,
                    selectedCategoryName: selectedCategory,
                    onCategorySelected: onCategorySelected,
                  ),
                ),
              ),
            ),
            FormGridCell(
              span: alternativesInlineAddButton != null ? 4 : 9,
              child: _floatingField(
                label: 'Description',
                child: TextField(
                  controller: descriptionController,
                  style: saleFieldTextStyle,
                  decoration: buildFormControlDecoration(
                    labelText: 'Description',
                  ),
                  onChanged: onDescriptionChanged,
                ),
              ),
            ),
            if (alternativesInlineAddButton case final inlineActions?)
              FormGridCell(
                span: 5,
                child: SizedBox(
                  height: FormSpacing.inputHeight,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: inlineActions,
                  ),
                ),
              ),
            if (_showItemImagesRow)
              FormGridCell(
                span: 6,
                child:
                    itemId != null &&
                        isServerBackedInventoryItemId(itemId!) &&
                        alternativesInlineAddButton != null
                    ? _ServerItemImagesField(
                        itemId: itemId!,
                        isProduct: _isProduct,
                        seedPrimaryImageUrl: seedPrimaryImageUrl,
                      )
                    : _floatingField(
                        label: _isProduct ? 'Item Images' : 'Service Images',
                        fixedHeight: false,
                        child: _buildItemImagesContent(),
                      ),
              ),
          ],
        ),
        if (alternativesListSection != null) ...[
          const SizedBox(height: FormSpacing.section),
          alternativesListSection!,
        ],
      ],
    );
  }
}

/// Thumbnail row for saved items — hidden until at least one image exists
/// (empty state uses inline add-image control beside description).
class _ServerItemImagesField extends ConsumerWidget {
  const _ServerItemImagesField({
    required this.itemId,
    required this.isProduct,
    this.seedPrimaryImageUrl,
  });

  final String itemId;
  final bool isProduct;
  final String? seedPrimaryImageUrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imagesAsync = ref.watch(itemImagesProvider(itemId));
    final images = imagesAsync.value ?? const [];
    final hasSeedImage = seedPrimaryImageUrl?.trim().isNotEmpty ?? false;
    if (images.isEmpty && !hasSeedImage) {
      return const SizedBox.shrink();
    }

    final label = isProduct ? 'Item Images' : 'Service Images';
    return AppFormField(
      label: label,
      floatingLabel: true,
      fixedHeight: false,
      child: ItemImageGallerySection(
        itemId: itemId,
        label: label,
        seedPrimaryImageUrl: seedPrimaryImageUrl,
        showEmptyAddAction: false,
      ),
    );
  }
}

class _PendingPhotoThumb extends StatelessWidget {
  const _PendingPhotoThumb({
    required this.bytes,
    required this.isPrimary,
    this.onTap,
  });

  final Uint8List bytes;
  final bool isPrimary;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.smBorder,
        child: Ink(
          width: GeneralInformationSection._pendingThumbSize,
          height: GeneralInformationSection._pendingThumbSize,
          decoration: BoxDecoration(
            borderRadius: AppRadius.smBorder,
            border: Border.all(color: const Color(0xFFE0E0E0)),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              ClipRRect(
                borderRadius: AppRadius.smBorder,
                child: Image.memory(bytes, fit: BoxFit.cover),
              ),
              if (isPrimary)
                Positioned(
                  top: 2,
                  left: 2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: const Text(
                      'Primary',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
