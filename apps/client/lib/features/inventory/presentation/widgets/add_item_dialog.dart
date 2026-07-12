import 'dart:async';

import 'package:billing_baba/core/network/api_validation_exception.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/application/inventory_error_mapper.dart';
import 'package:billing_baba/features/inventory/application/inventory_service.dart';
import 'package:billing_baba/features/inventory/models/add_item_form_model.dart';
import 'package:billing_baba/features/inventory/models/category_model.dart';
import 'package:billing_baba/features/inventory/models/item_model.dart';
import 'package:billing_baba/features/inventory/models/unit_model.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/add_item/general_information_section.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/add_item/manufacturing_section.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/add_item/online_store_section.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/add_item/pricing_section.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/add_item/stock_section.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/select_unit_dialog.dart';
import 'package:billing_baba/features/inventory/providers/add_item_form_provider.dart';
import 'package:billing_baba/features/inventory/providers/inventory_items_provider.dart';
import 'package:billing_baba/features/inventory/providers/inventory_providers.dart';
import 'package:billing_baba/features/inventory/providers/inventory_units_provider.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_single_date_picker.dart';
import 'package:billing_baba/shared/widgets/forms/forms.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _cardBorder = Color(0xFFE0E0E0);
const _tabActiveColor = Color(0xFFD32F2F);

Future<InventoryItem?> showAddItemDialog(
  BuildContext context, {
  ItemType initialType = ItemType.product,
  InventoryItem? editItem,
}) {
  return showDialog<InventoryItem>(
    context: context,
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: FormSpacing.page),
      child: AddItemDialog(initialType: initialType, editItem: editItem),
    ),
  );
}

class AddItemDialog extends ConsumerStatefulWidget {
  const AddItemDialog({
    this.initialType = ItemType.product,
    this.editItem,
    super.key,
  });

  final ItemType initialType;
  final InventoryItem? editItem;

  @override
  ConsumerState<AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends ConsumerState<AddItemDialog>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final _asOfDatePickerKey = GlobalKey<SaleSingleDatePickerAnchorState>();
  final _itemNameController = TextEditingController();
  final _hsnController = TextEditingController();
  final _itemCodeController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _salePriceController = TextEditingController();
  final _mrpController = TextEditingController();
  final _wholesalePriceController = TextEditingController();
  final _minWholesaleQtyController = TextEditingController();
  final _openingQtyController = TextEditingController();
  final _atPriceController = TextEditingController();
  final _minStockController = TextEditingController();
  final _locationController = TextEditingController();
  final _onlineStorePriceController = TextEditingController();
  final _onlineStoreDescriptionController = TextEditingController();
  final Map<String, TextEditingController> _rawMaterialControllers = {};
  final Map<String, TextEditingController> _additionalCostControllers = {};
  final _primaryImageUrlController = TextEditingController();
  bool _isSaving = false;

  int _tabCountFor(ItemType type) => type == ItemType.product ? 4 : 2;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: _tabCountFor(widget.initialType),
      vsync: this,
    );
    _tabController.addListener(_onTabChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.editItem != null) {
        unawaited(_hydrateEditItem(widget.editItem!));
      } else {
        ref
            .read(addItemFormProvider.notifier)
            .setInitialType(widget.initialType);
        _ensureDefaultServiceUnit();
      }
    });
  }

  void _ensureDefaultServiceUnit() {
    final form = ref.read(addItemFormProvider);
    if (form.itemType != ItemType.service || form.baseUnitId != null) return;

    final units = ref.read(inventoryUnitsProvider).value ?? [];
    final defaultUnit = resolveDefaultServiceUnit(units);
    if (defaultUnit == null) return;

    ref.read(addItemFormProvider.notifier).setUnits(baseUnitId: defaultUnit.id);
  }

  Future<void> _hydrateEditItem(InventoryItem item) async {
    final notifier = ref.read(addItemFormProvider.notifier);
    notifier.setInitialType(item.type);
    notifier.updateItemName(item.name);
    _itemNameController.text = item.name;

    if (item.hsnCode != null) {
      notifier.updateHsn(item.hsnCode!);
      _hsnController.text = item.hsnCode!;
    }
    if (item.barcode != null) {
      notifier.updateItemCode(item.barcode!);
      _itemCodeController.text = item.barcode!;
    }
    if (item.description != null) {
      notifier.updateDescription(item.description!);
      _descriptionController.text = item.description!;
    }
    if (item.salePrice != null) {
      notifier.updateSalePrice(item.salePrice!);
      _salePriceController.text = item.salePrice!.toString();
    }
    if (item.categoryId != null) notifier.setCategory(item.categoryId);
    if (item.brandId != null) notifier.setBrand(item.brandId);
    if (item.primaryImageUrl != null) {
      notifier.updatePrimaryImageUrl(item.primaryImageUrl!);
      _primaryImageUrlController.text = item.primaryImageUrl!;
    }

    try {
      final service = await ref.read(inventoryServiceProvider.future);
      final detail = await service.getItem(item.id);
      final tiers = await service.fetchItemTierPrices(item.id);

      if (detail.purchasePrice != null) {
        notifier.updateAtPrice(detail.purchasePrice!);
        _atPriceController.text = detail.purchasePrice!.toString();
      }
      if (detail.mrp != null) {
        notifier.updateMrp(detail.mrp!);
        _mrpController.text = detail.mrp!.toString();
      }
      if (detail.reorderLevel != null) {
        notifier.updateMinStock(detail.reorderLevel!);
        _minStockController.text = detail.reorderLevel!.toString();
      }

      final wholesale = tiers
          .where((tier) => tier.pricingTier == 'tier_2')
          .map((tier) => tier.price)
          .firstOrNull;
      if (wholesale != null) {
        notifier.updateWholesalePrice(wholesale);
        _wholesalePriceController.text = wholesale.toString();
      }

      final units = ref.read(inventoryUnitsProvider).value ?? [];
      final unit = units
          .where((u) => u.shortName == detail.baseUnitShortName)
          .firstOrNull;
      if (unit != null) {
        notifier.setUnits(baseUnitId: unit.id);
      }
    } catch (_) {
      // Keep list-item fields if detail fetch fails.
    }
  }

  void _handleItemTypeChange(ItemType type) {
    final form = ref.read(addItemFormProvider);
    if (form.itemType == type) return;

    final oldController = _tabController..removeListener(_onTabChanged);
    final newController = TabController(
      length: _tabCountFor(type),
      vsync: this,
    )..addListener(_onTabChanged);

    // Update form type before swapping the controller so TabBar tabs and
    // controller length stay in sync on the next build.
    ref.read(addItemFormProvider.notifier).setItemType(type);
    ref.read(addItemFormProvider.notifier).setActiveTab(0);
    ref.read(inventoryItemsTabIndexProvider.notifier).selectForItemType(type);
    if (type == ItemType.service) {
      _ensureDefaultServiceUnit();
    }

    setState(() => _tabController = newController);

    // Dispose after rebuild so TabBar stops using the old controller.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      oldController.dispose();
    });
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      ref.read(addItemFormProvider.notifier).setActiveTab(_tabController.index);
    }
  }

  @override
  void dispose() {
    _tabController
      ..removeListener(_onTabChanged)
      ..dispose();
    _itemNameController.dispose();
    _hsnController.dispose();
    _itemCodeController.dispose();
    _descriptionController.dispose();
    _salePriceController.dispose();
    _mrpController.dispose();
    _wholesalePriceController.dispose();
    _minWholesaleQtyController.dispose();
    _openingQtyController.dispose();
    _atPriceController.dispose();
    _minStockController.dispose();
    _locationController.dispose();
    _onlineStorePriceController.dispose();
    _onlineStoreDescriptionController.dispose();
    _primaryImageUrlController.dispose();
    for (final controller in _rawMaterialControllers.values) {
      controller.dispose();
    }
    for (final controller in _additionalCostControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  TextEditingController _rawController(String id, String initial) {
    return _rawMaterialControllers.putIfAbsent(
      id,
      () => TextEditingController(text: initial),
    );
  }

  Future<void> _save({required bool saveAndNew}) async {
    if (_isSaving) return;
    final notifier = ref.read(addItemFormProvider.notifier);
    if (!notifier.validate()) return;

    setState(() => _isSaving = true);

    try {
      final form = ref.read(addItemFormProvider);
      InventoryItem? savedItem;
      final editItem = widget.editItem;
      if (editItem != null) {
        savedItem = await ref
            .read(inventoryItemsProvider.notifier)
            .updateItemFromForm(editItem.id, form);
        ref.invalidate(productDetailProvider(editItem.id));
        ref.invalidate(itemTierPricesProvider(editItem.id));
      } else {
        savedItem = await ref
            .read(inventoryItemsProvider.notifier)
            .addItemFromForm(form);
      }

      if (!mounted) return;
      setState(() => _isSaving = false);

      if (saveAndNew) {
        notifier.reset(itemType: form.itemType);
        _clearControllers();
        _tabController.index = 0;
        return;
      }

      Navigator.of(context).pop(savedItem);
    } on ApiValidationException catch (error) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.fieldErrors['name'] ?? error.message),
        ),
      );
    } on InventoryException catch (error) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } catch (error) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(InventoryErrorMapper.messageFor(error))),
      );
    }
  }

  void _clearControllers() {
    _itemNameController.clear();
    _hsnController.clear();
    _itemCodeController.clear();
    _descriptionController.clear();
    _salePriceController.clear();
    _mrpController.clear();
    _wholesalePriceController.clear();
    _minWholesaleQtyController.clear();
    _openingQtyController.clear();
    _atPriceController.clear();
    _minStockController.clear();
    _locationController.clear();
    _onlineStorePriceController.clear();
    _onlineStoreDescriptionController.clear();
    _primaryImageUrlController.clear();
    for (final controller in _rawMaterialControllers.values) {
      controller.dispose();
    }
    for (final controller in _additionalCostControllers.values) {
      controller.dispose();
    }
    _rawMaterialControllers.clear();
    _additionalCostControllers.clear();
  }

  Future<void> _openUnitPicker() async {
    final form = ref.read(addItemFormProvider);
    final result = await showSelectUnitDialog(
      context,
      initialBaseUnitId: form.baseUnitId,
      initialSecondaryUnitId: form.secondaryUnitId,
    );
    if (result == null || !mounted) return;
    ref
        .read(addItemFormProvider.notifier)
        .setUnits(
          baseUnitId: result.baseUnitId,
          secondaryUnitId: result.secondaryUnitId,
        );
  }

  String _displayUnitLabel() {
    final form = ref.watch(addItemFormProvider);
    final units = ref.watch(unitsProvider);
    if (form.baseUnitId == null) {
      return units.isEmpty ? 'Select unit' : 'None';
    }
    return units
            .where((unit) => unit.id == form.baseUnitId)
            .map((unit) => unit.shortName)
            .firstOrNull ??
        'None';
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(inventoryUnitsProvider, (previous, next) {
      next.whenData((_) => _ensureDefaultServiceUnit());
    });

    ref.listen<int>(inventoryItemsTabIndexProvider, (previous, next) {
      if (next > inventoryServicesTabIndex) return;
      final targetType = next == inventoryProductsTabIndex
          ? ItemType.product
          : ItemType.service;
      if (ref.read(addItemFormProvider).itemType != targetType) {
        _handleItemTypeChange(targetType);
      }
    });

    final form = ref.watch(addItemFormProvider);
    final notifier = ref.read(addItemFormProvider.notifier);
    final categories = ref.watch(categoriesProvider);
    final categoryOptions = categories.map((c) => c.name).toList();
    final selectedCategory = categories
        .where((c) => c.id == form.categoryId)
        .map((c) => c.name)
        .firstOrNull;

    final media = MediaQuery.sizeOf(context);
    final availableWidth = media.width - 48;
    final preferredWidth = availableWidth >= FormSpacing.dialogWidth
        ? FormSpacing.dialogWidth
        : availableWidth.clamp(0, FormSpacing.dialogMaxWidth);
    final isService = form.itemType == ItemType.service;

    return ConstrainedBox(
      constraints: isService
          ? BoxConstraints(maxWidth: preferredWidth.toDouble())
          : BoxConstraints(
              maxWidth: preferredWidth.toDouble(),
              maxHeight: media.height * FormSpacing.dialogMaxHeightFactor,
            ),
      child: Material(
        color: AppColors.surface,
        borderRadius: AppRadius.lgBorder,
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(form),
            const Divider(height: 1, color: _cardBorder),
            if (isService)
              buildFormBody(form, notifier, categories, categoryOptions, selectedCategory)
            else
              Flexible(
                child: SingleChildScrollView(
                  child: buildFormBody(
                    form,
                    notifier,
                    categories,
                    categoryOptions,
                    selectedCategory,
                  ),
                ),
              ),
            const Divider(height: 1, color: _cardBorder),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget buildFormBody(
    AddItemFormState form,
    AddItemForm notifier,
    List<InventoryCategory> categories,
    List<String> categoryOptions,
    String? selectedCategory,
  ) {
    final isService = form.itemType == ItemType.service;
    final bodyPadding = EdgeInsets.fromLTRB(
      FormSpacing.page,
      FormSpacing.section,
      FormSpacing.page,
      isService ? FormSpacing.section : FormSpacing.page,
    );

    final content = Padding(
      padding: bodyPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          GeneralInformationSection(
            itemType: form.itemType,
            itemNameController: _itemNameController,
            hsnController: _hsnController,
            itemCodeController: _itemCodeController,
            descriptionController: _descriptionController,
            itemNameError: form.itemNameError,
            onItemNameChanged: notifier.updateItemName,
            onHsnChanged: notifier.updateHsn,
            onItemCodeChanged: notifier.updateItemCode,
            onDescriptionChanged: notifier.updateDescription,
            onAssignCode: () {
              notifier.assignCode();
              _itemCodeController.text = ref.read(addItemFormProvider).itemCode;
            },
            categoryOptions: categoryOptions,
            selectedCategory: selectedCategory,
            categories: categories,
            onCategorySelected: notifier.setCategory,
            unitLabel: _displayUnitLabel(),
            onSelectUnit: _openUnitPicker,
          ),
          const SizedBox(height: FormSpacing.section),
          _buildTabBar(form),
          const Divider(height: 1, color: _cardBorder),
          const SizedBox(height: FormSpacing.section),
          KeyedSubtree(
            key: ValueKey(
              'add-item-tab-${form.itemType.name}-${form.activeTab}',
            ),
            child: _buildActiveTabContent(form, notifier),
          ),
        ],
      ),
    );

    if (!isService) return content;

    // Service forms are short — size to content, scroll only if viewport is tight.
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: content,
          ),
        );
      },
    );
  }

  Widget _buildHeader(AddItemFormState form) {
    return SizedBox(
      height: FormSpacing.headerHeight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: FormSpacing.page),
        child: Row(
          children: [
            Text(
              widget.editItem != null ? 'Edit Item' : 'Add Item',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 16),
            _ProductServiceToggle(
              isProduct: form.itemType == ItemType.product,
              onChanged: (isProduct) => _handleItemTypeChange(
                isProduct ? ItemType.product : ItemType.service,
              ),
            ),
            const Spacer(),
            IconButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Item settings coming soon')),
                );
              },
              icon: const Icon(Icons.settings_outlined, color: AppColors.textSecondary),
              tooltip: 'Settings',
              visualDensity: VisualDensity.compact,
            ),
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close, color: AppColors.textSecondary),
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveTabContent(
    AddItemFormState form,
    AddItemForm notifier,
  ) {
    final tabIndex = form.activeTab;
    if (form.itemType == ItemType.service) {
      return switch (tabIndex) {
        0 => _buildPricingTab(form, notifier, isService: true),
        _ => _buildOnlineStoreTab(form, notifier),
      };
    }

    return switch (tabIndex) {
      0 => _buildPricingTab(form, notifier, isService: false),
      1 => _buildStockTab(form, notifier),
      2 => _buildOnlineStoreTab(form, notifier),
      _ => _buildManufacturingTab(form, notifier),
    };
  }

  Widget _buildPricingTab(
    AddItemFormState form,
    AddItemForm notifier, {
    required bool isService,
  }) {
    return PricingSection(
      isService: isService,
      mrpController: _mrpController,
      onMrpChanged: notifier.updateMrp,
      salePriceController: _salePriceController,
      salePriceTaxMode: form.salePriceTaxMode,
      onSalePriceChanged: notifier.updateSalePrice,
      onSalePriceTaxModeChanged: notifier.setSalePriceTaxMode,
      wholesalePriceController: _wholesalePriceController,
      wholesalePriceTaxMode: form.wholesalePriceTaxMode,
      onWholesalePriceChanged: notifier.updateWholesalePrice,
      onWholesalePriceTaxModeChanged: notifier.setWholesalePriceTaxMode,
      minWholesaleQtyController: _minWholesaleQtyController,
      onMinWholesaleQtyChanged: notifier.updateMinWholesaleQty,
      purchasePriceController: _atPriceController,
      purchasePriceTaxMode: form.purchasePriceTaxMode,
      onPurchasePriceChanged: notifier.updateAtPrice,
      onPurchasePriceTaxModeChanged: notifier.setPurchasePriceTaxMode,
      taxRate: form.taxRate,
      onTaxRateChanged: notifier.setTaxRate,
      unitLabel: _displayUnitLabel(),
    );
  }

  Widget _buildStockTab(AddItemFormState form, AddItemForm notifier) {
    return StockSection(
      openingQtyController: _openingQtyController,
      openingPriceController: _atPriceController,
      minStockController: _minStockController,
      locationController: _locationController,
      asOfDate: form.asOfDate,
      onOpeningQtyChanged: notifier.updateOpeningQty,
      onOpeningPriceChanged: notifier.updateAtPrice,
      onMinStockChanged: notifier.updateMinStock,
      onLocationChanged: notifier.updateLocation,
      onAsOfDateSelected: notifier.setAsOfDate,
      asOfDatePickerKey: _asOfDatePickerKey,
    );
  }

  Widget _buildOnlineStoreTab(AddItemFormState form, AddItemForm notifier) {
    return OnlineStoreSection(
      itemType: form.itemType,
      priceController: _onlineStorePriceController,
      descriptionController: _onlineStoreDescriptionController,
      onPriceChanged: notifier.updateOnlineStorePrice,
      onDescriptionChanged: notifier.updateOnlineStoreDescription,
    );
  }

  Widget _buildManufacturingTab(
    AddItemFormState form,
    AddItemForm notifier,
  ) {
    return ManufacturingSection(
      form: form,
      rawControllerFor: _rawController,
      onUpdateRawMaterial: notifier.updateRawMaterial,
      onRemoveRawMaterial: notifier.removeRawMaterialRow,
      onAddRawMaterial: notifier.addRawMaterialRow,
      onAddAdditionalCost: notifier.addAdditionalCost,
      onUpdateAdditionalCost: notifier.updateAdditionalCost,
      onRemoveAdditionalCost: notifier.removeAdditionalCost,
      additionalCostControllers: _additionalCostControllers,
    );
  }

  Widget _buildTabBar(AddItemFormState form) {
    final tabs = form.itemType == ItemType.product
        ? const ['Pricing', 'Stock', 'Online Store', 'Manufacturing']
        : const ['Pricing', 'Online Store'];

    return TabBar(
      // Distinct from tab-content key — never ValueKey(itemType) alone.
      key: ValueKey('add-item-tab-bar-${form.itemType.name}'),
      controller: _tabController,
      isScrollable: true,
      tabAlignment: TabAlignment.start,
      labelPadding: const EdgeInsets.symmetric(horizontal: 16),
      labelColor: _tabActiveColor,
      unselectedLabelColor: AppColors.textSecondary,
      indicatorColor: _tabActiveColor,
      indicatorSize: TabBarIndicatorSize.label,
      labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      unselectedLabelStyle: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
      tabs: [
        for (final tab in tabs)
          Tab(
            height: 40,
            text: tab,
          ),
      ],
    );
  }

  Widget _buildFooter() {
    return SizedBox(
      height: FormSpacing.footerHeight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: FormSpacing.page),
        child: Row(
          children: [
            const Spacer(),
            OutlinedButton(
              onPressed: _isSaving ? null : () => _save(saveAndNew: true),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textPrimary,
                side: const BorderSide(color: _cardBorder),
                minimumSize: const Size(0, FormSpacing.inputHeight),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: const Text(
                'Save & New',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(width: 12),
            FilledButton(
              onPressed: _isSaving ? null : () => _save(saveAndNew: false),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(0, FormSpacing.inputHeight),
                padding: const EdgeInsets.symmetric(horizontal: 28),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: const Text(
                'Save',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductServiceToggle extends StatelessWidget {
  const _ProductServiceToggle({
    required this.isProduct,
    required this.onChanged,
  });

  final bool isProduct;
  final ValueChanged<bool> onChanged;

  static const _trackWidth = 44.0;
  static const _trackHeight = 24.0;
  static const _thumbSize = 20.0;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () => onChanged(true),
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
            child: Text(
              'Product',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isProduct ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () => onChanged(!isProduct),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            width: _trackWidth,
            height: _trackHeight,
            decoration: BoxDecoration(
              // Always primary — never grey while either side is active.
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(_trackHeight / 2),
            ),
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              alignment: isProduct
                  ? Alignment.centerLeft
                  : Alignment.centerRight,
              child: Container(
                width: _thumbSize,
                height: _thumbSize,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x33000000),
                      blurRadius: 2,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () => onChanged(false),
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
            child: Text(
              'Service',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: !isProduct ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
