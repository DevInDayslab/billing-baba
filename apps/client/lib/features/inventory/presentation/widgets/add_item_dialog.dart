import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/models/add_item_form_model.dart';
import 'package:billing_baba/features/inventory/models/item_model.dart';
import 'package:billing_baba/features/inventory/models/category_model.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/select_unit_dialog.dart';
import 'package:billing_baba/features/inventory/providers/add_item_form_provider.dart';
import 'package:billing_baba/features/inventory/providers/inventory_catalog.dart';
import 'package:billing_baba/features/inventory/providers/inventory_items_provider.dart';
import 'package:billing_baba/features/inventory/providers/inventory_providers.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_field_decoration.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_generic_select_dropdown.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_single_date_picker.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

const _dialogMaxWidth = 960.0;
const _cardBorder = Color(0xFFE0E0E0);
const _tabActiveColor = Color(0xFFD32F2F);
const _summaryBannerColor = Color(0xFFFFF8E1);
const _uuid = Uuid();

Future<void> showAddItemDialog(
  BuildContext context, {
  ItemType initialType = ItemType.product,
}) {
  return showDialog<void>(
    context: context,
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: AddItemDialog(initialType: initialType),
    ),
  );
}

class AddItemDialog extends ConsumerStatefulWidget {
  const AddItemDialog({this.initialType = ItemType.product, super.key});

  final ItemType initialType;

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

  int _tabCountFor(ItemType type) =>
      type == ItemType.product ? 4 : 2;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: _tabCountFor(widget.initialType),
      vsync: this,
    );
    _tabController.addListener(_onTabChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(addItemFormProvider.notifier)
          .setInitialType(widget.initialType);
    });
  }

  void _handleItemTypeChange(ItemType type) {
    final form = ref.read(addItemFormProvider);
    if (form.itemType == type) return;

    final oldController = _tabController..removeListener(_onTabChanged);
    final newController = TabController(
      length: _tabCountFor(type),
      vsync: this,
    )..addListener(_onTabChanged);

    setState(() => _tabController = newController);

    ref.read(addItemFormProvider.notifier).setItemType(type);
    ref.read(addItemFormProvider.notifier).setActiveTab(0);
    ref.read(inventoryItemsTabIndexProvider.notifier).selectForItemType(type);

    // Dispose after rebuild so TabBar/AnimatedBuilder stop using the old controller.
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
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _itemNameController.dispose();
    _hsnController.dispose();
    _itemCodeController.dispose();
    _descriptionController.dispose();
    _salePriceController.dispose();
    _wholesalePriceController.dispose();
    _minWholesaleQtyController.dispose();
    _openingQtyController.dispose();
    _atPriceController.dispose();
    _minStockController.dispose();
    _locationController.dispose();
    _onlineStorePriceController.dispose();
    _onlineStoreDescriptionController.dispose();
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

  void _save({required bool saveAndNew}) {
    final notifier = ref.read(addItemFormProvider.notifier);
    if (!notifier.validate()) return;

    final form = ref.read(addItemFormProvider);
    final item = InventoryItem(
      id: _uuid.v4(),
      name: form.itemName.trim(),
      type: form.itemType,
      quantity: form.itemType == ItemType.product ? form.openingQty : null,
      salePrice: form.salePrice > 0 ? form.salePrice : null,
      stockValue: form.openingQty * form.atPrice,
      categoryId: form.categoryId ?? InventoryCatalog.uncategorizedCategoryId,
    );

    ref.read(inventoryItemsProvider.notifier).addItem(item);

    if (saveAndNew) {
      notifier.reset(itemType: form.itemType);
      _clearControllers();
      _tabController.index = 0;
      return;
    }

    Navigator.of(context).pop();
  }

  void _clearControllers() {
    _itemNameController.clear();
    _hsnController.clear();
    _itemCodeController.clear();
    _descriptionController.clear();
    _salePriceController.clear();
    _wholesalePriceController.clear();
    _minWholesaleQtyController.clear();
    _openingQtyController.clear();
    _atPriceController.clear();
    _minStockController.clear();
    _locationController.clear();
    _onlineStorePriceController.clear();
    _onlineStoreDescriptionController.clear();
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
    ref.read(addItemFormProvider.notifier).setUnits(
          baseUnitId: result.baseUnitId,
          secondaryUnitId: result.secondaryUnitId,
        );
  }

  String _displayUnitLabel() {
    final form = ref.watch(addItemFormProvider);
    final units = ref.watch(unitsProvider);
    if (form.baseUnitId == null) return 'PCS';
    return units
            .where((unit) => unit.id == form.baseUnitId)
            .map((unit) => unit.shortName)
            .firstOrNull ??
        'PCS';
  }

  @override
  Widget build(BuildContext context) {
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

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _dialogMaxWidth, maxHeight: 720),
      child: Material(
        color: AppColors.surface,
        borderRadius: AppRadius.lgBorder,
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(form, notifier),
            const Divider(height: 1, color: _cardBorder),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                0,
                AppSpacing.lg,
                AppSpacing.md,
              ),
              child: _buildTopFields(
                form: form,
                notifier: notifier,
                categoryOptions: categoryOptions,
                selectedCategory: selectedCategory,
                categories: categories,
              ),
            ),
            _buildTabBar(),
            const Divider(height: 1, color: _cardBorder),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: AnimatedBuilder(
                  key: ValueKey(form.itemType),
                  animation: _tabController,
                  builder: (context, _) => _buildActiveTabContent(form, notifier),
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

  Widget _buildHeader(AddItemFormState form, AddItemForm notifier) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.sm,
      ),
      child: Row(
        children: [
          Text(
            'Add Item',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
          ),
          const SizedBox(width: AppSpacing.lg),
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
            icon: const Icon(Icons.settings_outlined, size: 20),
            color: AppColors.textSecondary,
            tooltip: 'Settings',
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveTabContent(
    AddItemFormState form,
    AddItemForm notifier,
  ) {
    if (form.itemType == ItemType.service) {
      return switch (_tabController.index) {
        0 => _buildPricingTab(form, notifier, isService: true),
        _ => _buildOnlineStoreTab(form, notifier),
      };
    }

    return switch (_tabController.index) {
      0 => _buildPricingTab(form, notifier),
      1 => _buildStockTab(form, notifier),
      2 => _buildOnlineStoreTab(form, notifier),
      _ => _buildManufacturingTab(form, notifier),
    };
  }

  Widget _buildTopFields({
    required AddItemFormState form,
    required AddItemForm notifier,
    required List<String> categoryOptions,
    required String? selectedCategory,
    required List<InventoryCategory> categories,
  }) {
    final isProduct = form.itemType == ItemType.product;
    final taxCodeLabel = isProduct ? 'Item HSN' : 'Item SAC';
    final taxCodeHint = isProduct ? 'Search HSN' : 'Search SAC';

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 720;
        final row1 = [
          Expanded(
            child: _LabeledField(
              label: 'Item Name *',
              hasError: form.itemNameError,
              errorText: 'Item name is required',
              child: TextField(
                controller: _itemNameController,
                style: saleFieldTextStyle,
                decoration: buildSaleFieldDecoration(
                  hint: 'Item Name',
                  hasError: form.itemNameError,
                ),
                onChanged: notifier.updateItemName,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: _LabeledField(
              label: taxCodeLabel,
              child: TextField(
                controller: _hsnController,
                style: saleFieldTextStyle,
                decoration: buildSaleFieldDecoration(
                  suffixIcon: IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.search, size: 18),
                    color: AppColors.textSecondary,
                    tooltip: taxCodeHint,
                  ),
                ),
                onChanged: notifier.updateHsn,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: _LabeledField(
              label: 'Item Code',
              child: TextField(
                controller: _itemCodeController,
                style: saleFieldTextStyle,
                decoration: buildSaleFieldDecoration(
                  suffix: TextButton(
                    onPressed: notifier.assignCode,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Assign Code',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                onChanged: notifier.updateItemCode,
              ),
            ),
          ),
          if (isProduct) ...[
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _LabeledField(
                label: 'Select Unit',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    OutlinedButton(
                      onPressed: _openUnitPicker,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        backgroundColor: const Color(0xFFE3F2FD),
                        side: BorderSide.none,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: const Text(
                        'Select Unit',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _displayUnitLabel(),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ];

        final row2 = [
          Expanded(
            child: _LabeledField(
              label: 'Category',
              child: SaleGenericSelectDropdown(
                value: selectedCategory ?? 'Select',
                options: categoryOptions,
                hintText: 'Select',
                onSelected: (name) {
                  final category = categories.firstWhereOrNull(
                    (c) => c.name == name,
                  );
                  notifier.setCategory(category?.id);
                },
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: _LabeledField(
              label: 'Description',
              child: TextField(
                controller: _descriptionController,
                style: saleFieldTextStyle,
                decoration: buildSaleFieldDecoration(),
                onChanged: notifier.updateDescription,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.only(top: 22),
                child: TextButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Image upload coming soon')),
                    );
                  },
                  icon: const Icon(Icons.camera_alt_outlined, size: 16),
                  label: const Text(
                    'Add Item Image',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: EdgeInsets.zero,
                  ),
                ),
              ),
            ),
          ),
        ];

        if (isNarrow) {
          return Column(
            children: [
              ...row1.expand((w) => [w, const SizedBox(height: AppSpacing.md)]),
              ...row2.expand((w) => [w, const SizedBox(height: AppSpacing.md)]),
            ],
          );
        }

        return Column(
          children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: row1),
            const SizedBox(height: AppSpacing.md),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: row2),
          ],
        );
      },
    );
  }

  Widget _buildTabBar() {
    final form = ref.watch(addItemFormProvider);
    final tabs = form.itemType == ItemType.product
        ? const ['Pricing', 'Stock', 'Online Store', 'Manufacturing']
        : const ['Pricing', 'Online Store'];

    return TabBar(
      key: ValueKey(form.itemType),
      controller: _tabController,
      labelColor: _tabActiveColor,
      unselectedLabelColor: AppColors.textSecondary,
      indicatorColor: _tabActiveColor,
      labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      unselectedLabelStyle: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
      tabs: [for (final tab in tabs) Tab(text: tab)],
    );
  }

  Widget _buildPricingTab(
    AddItemFormState form,
    AddItemForm notifier, {
    bool isService = false,
  }) {
    final unitLabel = _displayUnitLabel();
    final taxOptions = [
      priceTaxModeLabel(PriceTaxMode.withoutTax),
      priceTaxModeLabel(PriceTaxMode.withTax),
    ];

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        border: Border.all(color: _cardBorder),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sale Price',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _salePriceController,
                  style: saleFieldTextStyle,
                  decoration: buildSaleFieldDecoration(hint: 'Sale Price'),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [_decimalInputFormatter],
                  onChanged: (v) =>
                      notifier.updateSalePrice(double.tryParse(v) ?? 0),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              SizedBox(
                width: 160,
                child: SaleGenericSelectDropdown(
                  value: priceTaxModeLabel(form.salePriceTaxMode),
                  options: taxOptions,
                  onSelected: (label) {
                    notifier.setSalePriceTaxMode(
                      label == 'With Tax'
                          ? PriceTaxMode.withTax
                          : PriceTaxMode.withoutTax,
                    );
                  },
                ),
              ),
            ],
          ),
          if (!isService) ...[
            const SizedBox(height: AppSpacing.lg),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Wholesale Price',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _wholesalePriceController,
                              style: saleFieldTextStyle,
                              decoration: buildSaleFieldDecoration(
                                hint: 'Wholesale Price',
                              ),
                              keyboardType: const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              inputFormatters: [_decimalInputFormatter],
                              onChanged: (v) => notifier.updateWholesalePrice(
                                double.tryParse(v) ?? 0,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          SizedBox(
                            width: 160,
                            child: SaleGenericSelectDropdown(
                              value: priceTaxModeLabel(
                                form.wholesalePriceTaxMode,
                              ),
                              options: taxOptions,
                              onSelected: (label) {
                                notifier.setWholesalePriceTaxMode(
                                  label == 'With Tax'
                                      ? PriceTaxMode.withTax
                                      : PriceTaxMode.withoutTax,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Minimum Wholesale Qty',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Tooltip(
                            message: 'Minimum quantity for wholesale pricing',
                            child: Icon(
                              Icons.info_outline,
                              size: 14,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _minWholesaleQtyController,
                        style: saleFieldTextStyle,
                        decoration: buildSaleFieldDecoration(),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [_decimalInputFormatter],
                        onChanged: (v) => notifier.updateMinWholesaleQty(
                          double.tryParse(v) ?? 0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        unitLabel,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStockTab(AddItemFormState form, AddItemForm notifier) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        border: Border.all(color: _cardBorder),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _LabeledField(
                  label: 'Opening Quantity',
                  child: TextField(
                    controller: _openingQtyController,
                    style: saleFieldTextStyle,
                    decoration: buildSaleFieldDecoration(),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [_decimalInputFormatter],
                    onChanged: (v) =>
                        notifier.updateOpeningQty(double.tryParse(v) ?? 0),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _LabeledField(
                  label: 'At Price',
                  child: TextField(
                    controller: _atPriceController,
                    style: saleFieldTextStyle,
                    decoration: buildSaleFieldDecoration(),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [_decimalInputFormatter],
                    onChanged: (v) =>
                        notifier.updateAtPrice(double.tryParse(v) ?? 0),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _LabeledField(
                  label: 'As of Date',
                  child: SaleSingleDatePickerAnchor(
                    key: _asOfDatePickerKey,
                    selectedDate: form.asOfDate,
                    onDateSelected: notifier.setAsOfDate,
                    child: SaleFieldTrigger(
                      onTap: () => _asOfDatePickerKey.currentState?.toggle(),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              formatSaleSingleDate(form.asOfDate),
                              style: saleFieldTextStyle,
                            ),
                          ),
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 16,
                            color: Colors.grey.shade600,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _LabeledField(
                  label: 'Min Stock To Maintain',
                  child: TextField(
                    controller: _minStockController,
                    style: saleFieldTextStyle,
                    decoration: buildSaleFieldDecoration(),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [_decimalInputFormatter],
                    onChanged: (v) =>
                        notifier.updateMinStock(double.tryParse(v) ?? 0),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _LabeledField(
            label: 'Location',
            child: TextField(
              controller: _locationController,
              style: saleFieldTextStyle,
              decoration: buildSaleFieldDecoration(hint: 'Ex: Rack A-12'),
              onChanged: notifier.updateLocation,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOnlineStoreTab(AddItemFormState form, AddItemForm notifier) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        border: Border.all(color: _cardBorder),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          _LabeledField(
            label: 'Online Store Price',
            child: TextField(
              controller: _onlineStorePriceController,
              style: saleFieldTextStyle,
              decoration: buildSaleFieldDecoration(hint: 'Online Store Price'),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [_decimalInputFormatter],
              onChanged: (v) =>
                  notifier.updateOnlineStorePrice(double.tryParse(v) ?? 0),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _LabeledField(
            label: 'Description',
            child: TextField(
              controller: _onlineStoreDescriptionController,
              style: saleFieldTextStyle,
              decoration: buildSaleFieldDecoration(hint: 'Description'),
              onChanged: notifier.updateOnlineStoreDescription,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManufacturingTab(AddItemFormState form, AddItemForm notifier) {
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Raw Material',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: _cardBorder),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              _ManufacturingTableHeader(),
              ...form.rawMaterials.asMap().entries.map(
                (entry) => _RawMaterialRow(
                  index: entry.key + 1,
                  row: entry.value,
                  nameController: _rawController(entry.value.id, entry.value.itemName),
                  onChanged: notifier.updateRawMaterial,
                  onRemove: () => notifier.removeRawMaterialRow(entry.value.id),
                  canRemove: form.rawMaterials.length > 1,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    TextButton.icon(
                      onPressed: notifier.addRawMaterialRow,
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text(
                        'Add Row',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'TOTAL: ${currency.format(form.rawMaterialTotal)}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        OutlinedButton.icon(
          onPressed: notifier.addAdditionalCost,
          icon: const Icon(Icons.add, size: 16),
          label: const Text(
            'Add Additional Cost',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary),
          ),
        ),
        if (form.additionalCosts.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          ...form.additionalCosts.map(
            (row) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _additionalCostControllers.putIfAbsent(
                        row.id,
                        () => TextEditingController(text: row.description),
                      ),
                      style: saleFieldTextStyle,
                      decoration:
                          buildSaleFieldDecoration(hint: 'Description'),
                      onChanged: (v) => notifier.updateAdditionalCost(
                        row.id,
                        description: v,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: TextField(
                      style: saleFieldTextStyle,
                      decoration: buildSaleFieldDecoration(hint: 'Amount'),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [_decimalInputFormatter],
                      onChanged: (v) => notifier.updateAdditionalCost(
                        row.id,
                        amount: double.tryParse(v) ?? 0,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => notifier.removeAdditionalCost(row.id),
                    icon: const Icon(Icons.close, size: 18, color: _tabActiveColor),
                  ),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: _summaryBannerColor,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            'Total Estimated Cost (Raw Material + Additional Cost) = '
            '${currency.format(form.totalEstimatedCost)}',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Learn how to use Manufacturing',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Video tutorial coming soon')),
                    );
                  },
                  icon: const Icon(Icons.play_circle_outline, size: 16),
                  label: const Text(
                    'Watch Video',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          OutlinedButton(
            onPressed: () => _save(saveAndNew: true),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textPrimary,
              side: const BorderSide(color: _cardBorder),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: const Text(
              'Save & New',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          FilledButton(
            onPressed: () => _save(saveAndNew: false),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
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
  static const _inactiveTrackColor = Color(0xFFE8E8E8);

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
              color: isProduct ? AppColors.primary : _inactiveTrackColor,
              borderRadius: BorderRadius.circular(_trackHeight / 2),
            ),
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              alignment:
                  isProduct ? Alignment.centerLeft : Alignment.centerRight,
              child: Container(
                width: _thumbSize,
                height: _thumbSize,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: const [
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

class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.label,
    required this.child,
    this.hasError = false,
    this.errorText,
  });

  final String label;
  final Widget child;
  final bool hasError;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: saleFieldLabelStyle),
        const SizedBox(height: 6),
        child,
        if (hasError && errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 2),
            child: Text(
              errorText!,
              style: const TextStyle(fontSize: 11, color: saleFieldErrorColor),
            ),
          ),
      ],
    );
  }
}

class _ManufacturingTableHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: const BoxDecoration(
        color: Color(0xFFF5F5F5),
        border: Border(bottom: BorderSide(color: _cardBorder)),
      ),
      child: const Row(
        children: [
          SizedBox(width: 28, child: Text('#', style: _tableHeaderStyle)),
          Expanded(
            flex: 3,
            child: Text('RAW MATERIAL', style: _tableHeaderStyle),
          ),
          Expanded(child: Text('QTY', style: _tableHeaderStyle)),
          Expanded(child: Text('UNIT', style: _tableHeaderStyle)),
          Expanded(
            flex: 2,
            child: Text('PURCHASE PRICE/UNIT (₹)', style: _tableHeaderStyle),
          ),
          Expanded(
            flex: 2,
            child: Text('ESTIMATED COST (₹)', style: _tableHeaderStyle),
          ),
          SizedBox(width: 36),
        ],
      ),
    );
  }
}

const _tableHeaderStyle = TextStyle(
  fontSize: 10,
  fontWeight: FontWeight.w600,
  color: AppColors.textSecondary,
  letterSpacing: 0.3,
);

class _RawMaterialRow extends StatelessWidget {
  const _RawMaterialRow({
    required this.index,
    required this.row,
    required this.nameController,
    required this.onChanged,
    required this.onRemove,
    required this.canRemove,
  });

  final int index;
  final RawMaterialRow row;
  final TextEditingController nameController;
  final void Function(
    String id, {
    String? itemName,
    double? qty,
    String? unitLabel,
    double? purchasePrice,
  }) onChanged;
  final VoidCallback onRemove;
  final bool canRemove;

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: _cardBorder)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 28,
            child: Text(
              '$index',
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            flex: 3,
            child: TextField(
              controller: nameController,
              style: saleFieldTextStyle,
              decoration: buildSaleFieldDecoration(hint: 'Search item...', compact: true),
              onChanged: (v) => onChanged(row.id, itemName: v),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              style: saleFieldTextStyle,
              decoration: buildSaleFieldDecoration(compact: true),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [_decimalInputFormatter],
              onChanged: (v) => onChanged(row.id, qty: double.tryParse(v) ?? 0),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SaleGenericSelectDropdown(
              value: row.unitLabel,
              options: const ['None', 'PCS', 'Kg', 'Ltr'],
              onSelected: (v) => onChanged(row.id, unitLabel: v),
              compact: true,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: TextField(
              style: saleFieldTextStyle,
              decoration: buildSaleFieldDecoration(compact: true),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [_decimalInputFormatter],
              onChanged: (v) =>
                  onChanged(row.id, purchasePrice: double.tryParse(v) ?? 0),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: Text(
              currency.format(row.estimatedCost),
              style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
            ),
          ),
          SizedBox(
            width: 36,
            child: canRemove
                ? IconButton(
                    onPressed: onRemove,
                    icon: const Icon(Icons.close, size: 16, color: _tabActiveColor),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  )
                : null,
          ),
        ],
      ),
    );
  }
}

final _decimalInputFormatter = FilteringTextInputFormatter.allow(
  RegExp(r'^\d*\.?\d*'),
);
