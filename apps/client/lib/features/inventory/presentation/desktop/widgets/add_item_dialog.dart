import 'dart:async';

import 'package:billing_baba/core/network/api_validation_exception.dart';
import 'package:billing_baba/core/platform/app_platform.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/business/application/business_service.dart';
import 'package:billing_baba/features/business/application/commerce_settings_provider.dart';
import 'package:billing_baba/features/inventory/application/add_item_form_provider.dart';
import 'package:billing_baba/features/inventory/application/inventory_brands_provider.dart';
import 'package:billing_baba/features/inventory/application/inventory_error_mapper.dart';
import 'package:billing_baba/features/inventory/application/inventory_godowns_provider.dart';
import 'package:billing_baba/features/inventory/application/inventory_item_list_merge.dart';
import 'package:billing_baba/features/inventory/application/inventory_items_provider.dart';
import 'package:billing_baba/features/inventory/application/inventory_providers.dart';
import 'package:billing_baba/features/inventory/application/inventory_service.dart';
import 'package:billing_baba/features/inventory/application/inventory_units_provider.dart';
import 'package:billing_baba/features/inventory/application/item_bom_provider.dart';
import 'package:billing_baba/features/inventory/application/item_settings_provider.dart';
import 'package:billing_baba/features/inventory/application/item_suppliers_provider.dart';
import 'package:billing_baba/features/inventory/application/item_tier_prices_provider.dart';
import 'package:billing_baba/features/inventory/application/rack_stock_image_warmup.dart';
import 'package:billing_baba/features/inventory/models/add_item_form_model.dart';
import 'package:billing_baba/features/inventory/models/brand_model.dart';
import 'package:billing_baba/features/inventory/models/category_model.dart';
import 'package:billing_baba/features/inventory/models/dto/item_summary_dto.dart';
import 'package:billing_baba/features/inventory/models/item_image_model.dart';
import 'package:billing_baba/features/inventory/models/item_location_history_model.dart';
import 'package:billing_baba/features/inventory/models/item_location_model.dart';
import 'package:billing_baba/features/inventory/models/item_model.dart';
import 'package:billing_baba/features/inventory/models/item_settings.dart';
import 'package:billing_baba/features/inventory/models/tier_price_model.dart';
import 'package:billing_baba/features/inventory/models/unit_model.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/add_item/add_item_image_link_button.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/add_item/alternative_items_field.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/add_item/alternatives_section.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/add_item/general_information_section.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/add_item/manufacturing_section.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/add_item/online_store_section.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/add_item/pricing_section.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/add_item/product_description_section.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/add_item/stock_section.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/add_item/suppliers_section.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/add_item/tier_pricing_section.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/rack_shelf_section.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/select_unit_dialog.dart';
import 'package:billing_baba/features/inventory/presentation/mobile/screens/mobile_barcode_scanner_screen.dart';
import 'package:billing_baba/features/inventory/presentation/mobile/screens/mobile_item_image_preview_screen.dart';
import 'package:billing_baba/features/inventory/presentation/mobile/screens/mobile_item_manufacturing_screen.dart';
import 'package:billing_baba/features/inventory/presentation/mobile/widgets/add_item/mobile_add_item_footer.dart';
import 'package:billing_baba/features/inventory/presentation/mobile/widgets/add_item/mobile_add_item_general_section.dart';
import 'package:billing_baba/features/inventory/presentation/mobile/widgets/add_item/mobile_add_item_header.dart';
import 'package:billing_baba/features/inventory/presentation/mobile/widgets/add_item/mobile_add_item_image_strip.dart';
import 'package:billing_baba/features/inventory/presentation/mobile/widgets/add_item/mobile_add_item_online_store_section.dart';
import 'package:billing_baba/features/inventory/presentation/mobile/widgets/add_item/mobile_add_item_pricing_section.dart';
import 'package:billing_baba/features/inventory/presentation/mobile/widgets/add_item/mobile_add_item_product_description_section.dart';
import 'package:billing_baba/features/inventory/presentation/mobile/widgets/add_item/mobile_add_item_stock_section.dart';
import 'package:billing_baba/features/inventory/presentation/mobile/widgets/add_item/mobile_add_item_tab_bar.dart';
import 'package:billing_baba/features/inventory/presentation/shared/item_image_pick_crop.dart';
import 'package:billing_baba/features/inventory/utils/item_tax_rate.dart';
import 'package:billing_baba/features/inventory/utils/item_tax_rate_preference.dart';
import 'package:billing_baba/features/inventory/utils/item_unit_qty_conversion.dart';
import 'package:billing_baba/features/inventory/utils/min_wholesale_qty_units.dart';
import 'package:billing_baba/features/parties/application/parties_providers.dart';
import 'package:billing_baba/features/pricing/models/price_tier.dart';
import 'package:billing_baba/features/pricing/presentation/desktop/widgets/edit_pricing_tier_labels_dialog.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_single_date_picker.dart';
import 'package:billing_baba/shared/image/image_service.dart';
import 'package:billing_baba/shared/media/prepare_media_upload_bytes.dart';
import 'package:billing_baba/shared/media/rack_photo_stamp.dart';
import 'package:billing_baba/shared/utils/text_input_formatters.dart';
import 'package:billing_baba/shared/widgets/close_form_dialog.dart';
import 'package:billing_baba/shared/widgets/forms/forms.dart';
import 'package:billing_baba/shared/widgets/transaction_success_toast.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _cardBorder = Color(0xFFE0E0E0);
const _tabActiveColor = Color(0xFFD32F2F);
const _mobileAddItemHeaderHeight = 84.0;

int _tierRowCounter = 0;

String _nextTierRowId() {
  _tierRowCounter += 1;
  return 'tier_row_$_tierRowCounter';
}

/// Wider/taller than default ERP modals — Add Item has many tabs and fields.
const _addItemDialogWidth = 1280.0;
const _addItemDialogMaxWidth = 1320.0;
const _addItemDialogMaxHeightFactor = 0.93;

Future<InventoryItem?> showAddItemDialog(
  BuildContext context, {
  ItemType initialType = ItemType.product,
  InventoryItem? editItem,
}) {
  if (AppPlatform.current.isMobile) {
    return Navigator.of(context).push<InventoryItem>(
      MaterialPageRoute(
        builder: (context) => AddItemDialog(
          initialType: initialType,
          editItem: editItem,
          fullPage: true,
        ),
      ),
    );
  }

  return showFormDialog<InventoryItem>(
    context: context,
    maxWidth: _addItemDialogMaxWidth,
    maxHeightFactor: _addItemDialogMaxHeightFactor,
    child: AddItemDialog(initialType: initialType, editItem: editItem),
  );
}

class AddItemDialog extends ConsumerStatefulWidget {
  const AddItemDialog({
    this.initialType = ItemType.product,
    this.editItem,
    this.fullPage = false,
    super.key,
  });

  final ItemType initialType;
  final InventoryItem? editItem;
  final bool fullPage;

  @override
  ConsumerState<AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends ConsumerState<AddItemDialog>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final _asOfDatePickerKey = GlobalKey<SaleSingleDatePickerAnchorState>();
  final _itemNameController = TextEditingController();
  final _shortNameController = TextEditingController();
  final _aliasController = TextEditingController();
  final _searchKeywordsController = TextEditingController();
  final _hsnController = TextEditingController();
  final _itemCodeController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _salePriceController = TextEditingController();
  final _mrpController = TextEditingController();
  final _mrpSaleDiscountController = TextEditingController();
  final _salePriceDiscountController = TextEditingController();
  final _wholesalePriceController = TextEditingController();
  final _minWholesaleQtyController = TextEditingController();
  final _openingQtyController = TextEditingController();
  final _atPriceController = TextEditingController();
  final _minStockController = TextEditingController();
  final _locationController = TextEditingController();
  final _rackEmployeeController = TextEditingController();
  final _onlineStorePriceController = TextEditingController();
  final _onlineStoreDescriptionController = TextEditingController();
  final Map<String, TextEditingController> _rawMaterialControllers = {};
  final Map<String, TextEditingController> _additionalCostControllers = {};
  final Map<String, TextEditingController> _tierPriceControllers = {};
  final _primaryImageUrlController = TextEditingController();
  final List<Uint8List> _pendingItemPhotos = [];
  final _mobileFormScrollController = ScrollController();
  bool _isSaving = false;
  bool _allowPop = false;
  bool _isClosing = false;
  String? _rackLocationId;
  String? _rackPhotoUrl;
  DateTime? _rackLastUpdatedAt;
  DateTime? _rackPhotoTakenAt;
  List<ItemLocationHistoryModel> _rackHistory = const [];
  Uint8List? _pendingRackPhoto;
  Uint8List? _pendingRackPhotoRaw;
  String _initialRackLocation = '';
  String? _rackEmployeeError;
  double _initialOpeningQty = 0;

  String get _closeFormTitle =>
      widget.editItem != null ? 'Close Item' : 'Close Add Item';

  bool _hasUnsavedChanges() {
    final form = ref.read(addItemFormProvider);
    if (form.isDirty) return true;
    if (_pendingItemPhotos.isNotEmpty) return true;
    if (_pendingRackPhoto != null) return true;
    return false;
  }

  Future<void> _requestClose() async {
    if (_isClosing || _allowPop || _isSaving) return;
    _isClosing = true;
    try {
      if (_hasUnsavedChanges()) {
        final confirmed = await showCloseFormDialog(
          context,
          title: _closeFormTitle,
        );
        if (!confirmed || !mounted) return;
      }
      setState(() => _allowPop = true);
      Navigator.of(context).pop();
    } finally {
      _isClosing = false;
    }
  }

  void _popDialog([InventoryItem? result]) {
    _allowPop = true;
    Navigator.of(context).pop(result);
  }

  Widget _wrapWithCloseGuard(Widget child) {
    return PopScope(
      canPop: _allowPop,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        await _requestClose();
      },
      child: child,
    );
  }

  bool get _isMobileFullPage => widget.fullPage && AppPlatform.current.isMobile;

  double get _headerHeight {
    if (_isMobileFullPage) return 0;
    if (AppPlatform.current.isMobile) return _mobileAddItemHeaderHeight;
    return FormSpacing.headerHeight;
  }

  int _tabCountFor(ItemType type) {
    if (_isMobileFullPage) {
      if (type == ItemType.product) {
        return widget.editItem != null ? 6 : 5;
      }
      return 2;
    }
    if (type == ItemType.product) {
      return widget.editItem != null ? 7 : 6;
    }
    return 2;
  }

  bool get _showDesktopAlternativesTab => widget.editItem != null;

  List<String> _mobileTabsFor(ItemType type) {
    if (type == ItemType.product && widget.editItem != null) {
      return const [
        'Pricing',
        'Stock',
        'Product Description',
        'Online Store',
        'Alternatives',
        'Suppliers',
      ];
    }
    return type == ItemType.product
        ? const [
            'Pricing',
            'Stock',
            'Product Description',
            'Online Store',
            'Suppliers',
          ]
        : const ['Pricing', 'Online Store'];
  }

  InventoryUnit? _selectedBaseUnit() {
    final form = ref.read(addItemFormProvider);
    final units = ref.read(unitsProvider);
    if (form.baseUnitId == null) return null;
    return units.where((unit) => unit.id == form.baseUnitId).firstOrNull;
  }

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
        _ensureDefaultBaseUnit();
        unawaited(_applyDefaultItemTaxRate());
        unawaited(_applyItemSettingsDefaults());
      }
    });
  }

  Future<void> _applyItemSettingsDefaults() async {
    if (widget.editItem != null) return;
    try {
      final settings = await ref.read(itemSettingsProvider.future);
      if (!mounted) return;
      if (settings.descriptionEnabled &&
          settings.descriptionText.trim().isNotEmpty &&
          _descriptionController.text.trim().isEmpty) {
        _descriptionController.text = settings.descriptionText;
        ref
            .read(addItemFormProvider.notifier)
            .updateDescription(settings.descriptionText);
      }
    } on Object {
      // Non-blocking default; user can enter description manually.
    }
  }

  Future<void> _applyDefaultItemTaxRate() async {
    try {
      final businessId = ref.read(currentBusinessProvider)?.id;
      if (businessId != null) {
        final pinned = await ItemTaxRatePreference.readPinned(businessId);
        if (pinned != null && pinned.isNotEmpty) {
          if (!mounted) return;
          ref.read(addItemFormProvider.notifier).setTaxRate(pinned);
          return;
        }
      }

      final commerce = await ref.read(commerceSettingsProvider.future);
      final defaultTax = commerce.defaultInvoiceTaxPercent;
      if (defaultTax == null || defaultTax <= 0) return;
      if (!mounted) return;
      ref
          .read(addItemFormProvider.notifier)
          .setTaxRate(ItemTaxRate.labelForPercent(defaultTax));
    } on Object {
      // Non-blocking default; user can set GST manually.
    }
  }

  void _ensureDefaultBaseUnit() {
    final form = ref.read(addItemFormProvider);
    if (form.baseUnitId != null) return;

    final units = ref.read(inventoryUnitsProvider).value ?? [];
    final defaultUnit = form.itemType == ItemType.service
        ? resolveDefaultServiceUnit(units)
        : resolveDefaultPcsUnit(units);
    if (defaultUnit == null) return;

    ref.read(addItemFormProvider.notifier).setUnits(baseUnitId: defaultUnit.id);
  }

  Future<void> _hydrateEditItem(InventoryItem item) async {
    // Warm gallery + list primary URL before the section mounts.
    unawaited(ref.read(itemImagesProvider(item.id).future));
    if (item.primaryImageUrl?.trim().isNotEmpty ?? false) {
      ref.read(itemImagesProvider(item.id).notifier).seed([
        seedItemImageFromUrl(item.id, item.primaryImageUrl!),
      ]);
    }

    final notifier = ref.read(addItemFormProvider.notifier);
    notifier.setInitialType(item.type);
    notifier.updateItemName(item.name);
    _itemNameController.text = item.name;

    if (item.shortName != null) {
      notifier.updateShortName(item.shortName!);
      _shortNameController.text = item.shortName!;
    }
    if (item.alias != null) {
      notifier.updateAlias(item.alias!);
      _aliasController.text = item.alias!;
    }
    if (item.searchKeywords.isNotEmpty) {
      final keywords = item.searchKeywords.join(', ');
      notifier.updateSearchKeywords(keywords);
      _searchKeywordsController.text = keywords;
    }

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
      _salePriceController.text = formatIndianItemPriceInput(item.salePrice!);
      notifier.syncMrpSaleDiscountFromPrices();
      _syncMrpSaleDiscountController();
    }
    if (item.categoryId != null) notifier.setCategory(item.categoryId);
    if (item.brandId != null) notifier.setBrand(item.brandId);
    if (item.primaryImageUrl != null) {
      notifier.updatePrimaryImageUrl(item.primaryImageUrl!);
      _primaryImageUrlController.text = item.primaryImageUrl!;
    }

    try {
      final service = await ref.read(inventoryServiceProvider.future);
      final detailDto = await service.fetchItemDetailDto(item.id);

      final detailLocation = detailDto.locations.firstOrNull;
      final prefetchLocationId = detailLocation?.id.trim();
      final rackPrefetchLocationId =
          prefetchLocationId != null && prefetchLocationId.isNotEmpty
          ? prefetchLocationId
          : null;

      final locationsFuture = service.fetchItemLocations(item.id);
      final historyFuture = rackPrefetchLocationId != null
          ? service.fetchItemLocationHistory(rackPrefetchLocationId)
          : null;

      if (detailLocation != null && mounted) {
        _applyRackShellFromDetailLocation(detailLocation, notifier);
      }
      if (historyFuture != null) {
        unawaited(_applyPrefetchedRackHistory(historyFuture));
      }

      var tiers = const <TierPriceModel>[];
      try {
        tiers = await service.fetchItemTierPrices(item.id);
      } on Object {
        // Tier prices may be unavailable offline; form still opens from local item.
      }

      await ref.read(itemTierPricesProvider.notifier).ensureInitialized();

      if (detailDto.purchasePrice.isNotEmpty) {
        final purchasePrice = double.tryParse(detailDto.purchasePrice);
        if (purchasePrice != null) {
          notifier.updateAtPrice(purchasePrice);
          _atPriceController.text = formatIndianItemPriceInput(purchasePrice);
        }
      }
      if (detailDto.mrp != null && detailDto.mrp!.isNotEmpty) {
        final mrp = double.tryParse(detailDto.mrp!);
        if (mrp != null) {
          notifier.updateMrp(mrp);
          _mrpController.text = formatIndianItemPriceInput(mrp);
          _syncSalePriceController();
          _syncMrpSaleDiscountController();
        }
      }
      if (detailDto.reorderLevel != null &&
          detailDto.reorderLevel!.isNotEmpty) {
        final reorderLevel = double.tryParse(detailDto.reorderLevel!);
        if (reorderLevel != null) {
          notifier.updateMinStock(reorderLevel);
          _syncMinStockController(reorderLevel, ref.read(unitsProvider));
        }
      }

      if (detailDto.shortName != null && detailDto.shortName!.isNotEmpty) {
        notifier.updateShortName(detailDto.shortName!);
        _shortNameController.text = detailDto.shortName!;
      }
      if (detailDto.alias != null && detailDto.alias!.isNotEmpty) {
        notifier.updateAlias(detailDto.alias!);
        _aliasController.text = detailDto.alias!;
      }
      if (detailDto.searchKeywords.isNotEmpty) {
        final keywords = detailDto.searchKeywords.join(', ');
        notifier.updateSearchKeywords(keywords);
        _searchKeywordsController.text = keywords;
      }
      final defaultTax = double.tryParse(detailDto.defaultTaxRate ?? '');
      if (defaultTax != null) {
        notifier.setTaxRate(ItemTaxRate.labelForPercent(defaultTax));
      }
      if (detailDto.alternativeItemIds.isNotEmpty) {
        notifier.setAlternativeItemIds(detailDto.alternativeItemIds);
      }

      // Prefer detail opening summary; do not fall back to current quantity —
      // that value is stock on hand, not opening, and re-saving it fails once
      // other inventory movements exist.
      final openingQty =
          double.tryParse(detailDto.openingStock?.totalQuantity ?? '') ?? 0;
      _initialOpeningQty = openingQty;
      if (openingQty > 0) {
        notifier.updateOpeningQty(openingQty);
        _syncOpeningQtyController(openingQty, ref.read(unitsProvider));
      }

      final openingGodown = detailDto.openingStock?.godowns.firstOrNull;
      final godownId = openingGodown?.godownId ?? detailLocation?.godownId;
      if (godownId != null) {
        notifier.setGodown(godownId);
      }

      final itemLocations = await locationsFuture;
      if (itemLocations.isNotEmpty && mounted) {
        final firstLocation = itemLocations.first;
        _applyRackLocationFromApi(firstLocation);
        if (rackPrefetchLocationId != firstLocation.id &&
            _rackHistory.isEmpty) {
          await _refreshRackHistory(firstLocation.id);
        }
      } else if (rackPrefetchLocationId != null &&
          mounted &&
          _rackHistory.isEmpty) {
        await _refreshRackHistory(rackPrefetchLocationId);
      }

      final wholesale = tiers
          .where((tier) => tier.pricingTier == 'tier_2')
          .map((tier) => tier.price)
          .firstOrNull;
      if (wholesale != null) {
        notifier.updateWholesalePrice(wholesale);
        notifier.enableWholesaleSection();
        _wholesalePriceController.text = formatIndianItemPriceInput(wholesale);
      }

      final localTiers = ref.read(itemTierPricesProvider).value?[item.id];
      if (localTiers != null && localTiers.isNotEmpty) {
        final rows = localTiers.entries
            .map(
              (entry) => ItemTierPriceRow(
                id: _nextTierRowId(),
                tierKey: entry.key,
                price: entry.value,
              ),
            )
            .toList();
        notifier.setTierPrices(rows);
      } else if (wholesale != null && wholesale > 0) {
        notifier.setTierPrices([
          ItemTierPriceRow(
            id: _nextTierRowId(),
            tierKey: PriceTier.wholesale,
            price: wholesale,
          ),
        ]);
      }

      final units = ref.read(inventoryUnitsProvider).value ?? [];
      final unit = units
          .where((u) => u.shortName == detailDto.baseUnit)
          .firstOrNull;
      if (unit != null) {
        notifier.setUnits(baseUnitId: unit.id);
      }
    } catch (_) {
      // Keep list-item fields if detail fetch fails.
    }

    try {
      await ref.read(itemSuppliersProvider.notifier).ensureInitialized();
      final localSuppliers = ref
          .read(itemSuppliersProvider.notifier)
          .suppliersFor(item.id);
      if (localSuppliers.isNotEmpty) {
        final formState = ref.read(addItemFormProvider);
        final parties = ref.read(partiesListProvider);
        final partiesById = {for (final party in parties) party.id: party};
        notifier.mergeSupplierParties(
          partyIds: localSuppliers,
          product: _suppliersProductSnapshot(formState),
          partiesById: partiesById,
        );
      }
    } on Object {
      // Local suppliers cache is best-effort.
    }

    try {
      final bom = await ref
          .read(itemBomProvider.notifier)
          .fetchForItem(item.id);
      notifier.setBomFromModel(bom);
    } on Object {
      // BOM cache is best-effort.
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
    _ensureDefaultBaseUnit();

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
    _shortNameController.dispose();
    _aliasController.dispose();
    _searchKeywordsController.dispose();
    _hsnController.dispose();
    _itemCodeController.dispose();
    _descriptionController.dispose();
    _salePriceController.dispose();
    _mrpController.dispose();
    _mrpSaleDiscountController.dispose();
    _salePriceDiscountController.dispose();
    _wholesalePriceController.dispose();
    _minWholesaleQtyController.dispose();
    _openingQtyController.dispose();
    _atPriceController.dispose();
    _minStockController.dispose();
    _locationController.dispose();
    _rackEmployeeController.dispose();
    _onlineStorePriceController.dispose();
    _onlineStoreDescriptionController.dispose();
    _primaryImageUrlController.dispose();
    for (final controller in _rawMaterialControllers.values) {
      controller.dispose();
    }
    for (final controller in _additionalCostControllers.values) {
      controller.dispose();
    }
    for (final controller in _tierPriceControllers.values) {
      controller.dispose();
    }
    _mobileFormScrollController.dispose();
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
    if (!notifier.validate()) {
      _revealFieldErrors();
      return;
    }

    final formForRack = ref.read(addItemFormProvider);
    final rackEmployeeError = validateRackShelfEmployee(
      rack: formForRack.location.trim(),
      initialRack: _initialRackLocation,
      employee: _rackEmployeeController.text.trim(),
      pendingPhoto: _pendingRackPhoto,
      locationId: _rackLocationId,
    );
    if (rackEmployeeError != null) {
      setState(() => _rackEmployeeError = rackEmployeeError);
      if (formForRack.itemType != ItemType.service) {
        ref.read(addItemFormProvider.notifier).setActiveTab(1);
        _tabController.index = 1;
      }
      showOverlaySnackBar(context, message: rackEmployeeError);
      return;
    }

    setState(() {
      _rackEmployeeError = null;
      _isSaving = true;
    });

    try {
      final form = ref.read(addItemFormProvider);
      InventoryItem? savedItem;
      final editItem = widget.editItem;
      if (editItem != null) {
        savedItem = await ref
            .read(inventoryItemsProvider.notifier)
            .updateItemFromForm(
              editItem.id,
              form,
              initialOpeningQty: _initialOpeningQty,
            );
        await ref
            .read(itemTierPricesProvider.notifier)
            .setTierPrices(editItem.id, form.resolvedTierPriceMap);
        await ref
            .read(itemSuppliersProvider.notifier)
            .setSuppliers(
              editItem.id,
              form.supplierPartyIds,
              defaultPartyId: form.defaultSupplierPartyId,
            );
        await ref
            .read(itemBomProvider.notifier)
            .replaceFromAddItemForm(editItem.id, form);
      } else {
        savedItem = await ref
            .read(inventoryItemsProvider.notifier)
            .addItemFromForm(form);
        if (savedItem != null) {
          await ref
              .read(itemTierPricesProvider.notifier)
              .setTierPrices(savedItem.id, form.resolvedTierPriceMap);
          await ref
              .read(itemSuppliersProvider.notifier)
              .setSuppliers(
                savedItem.id,
                form.supplierPartyIds,
                defaultPartyId: form.defaultSupplierPartyId,
              );
          await ref
              .read(itemBomProvider.notifier)
              .replaceFromAddItemForm(savedItem.id, form);
          if (form.alternativeItemIds.isNotEmpty) {
            final service = await ref.read(inventoryServiceProvider.future);
            await service.replaceItemAlternatives(
              savedItem.id,
              form.alternativeItemIds,
            );
          }
        }
      }

      if (!mounted) return;

      if (savedItem != null) {
        await _syncRackShelfAfterSave(savedItem.id, form);
        await _uploadPendingPhotosIfNeeded(savedItem.id);
      }

      if (!mounted) return;
      setState(() => _isSaving = false);

      if (saveAndNew) {
        notifier.reset(itemType: form.itemType);
        _clearControllers();
        _initialOpeningQty = 0;
        _tabController.index = 0;
        unawaited(_applyDefaultItemTaxRate());
        return;
      }

      _popDialog(savedItem);
    } on ApiValidationException catch (error) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      final mapped = notifier.applyFieldErrors(error.fieldErrors);
      if (mapped) {
        _revealFieldErrors();
        return;
      }
      _showSaveError(InventoryErrorMapper.validationMessage(error));
    } on InventoryException catch (error) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      if (notifier.applyExceptionMessage(error.message)) {
        _revealFieldErrors();
        return;
      }
      _showSaveError(error.message);
    } catch (error) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      _showSaveError(InventoryErrorMapper.messageForSaveItem(error));
    }
  }

  void _revealFieldErrors() {
    if (_isMobileFullPage && _mobileFormScrollController.hasClients) {
      unawaited(
        _mobileFormScrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        ),
      );
    }
  }

  void _showSaveError(String message) {
    if (_isMobileFullPage) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      return;
    }
    showTransactionErrorToast(context, message: message);
  }

  void _applyRackShellFromDetailLocation(
    ItemLocationSummaryDto location,
    AddItemForm notifier,
  ) {
    final rack = location.rack?.trim();
    if (rack != null && rack.isNotEmpty) {
      notifier.updateLocation(rack);
      _locationController.text = rack;
      _initialRackLocation = rack;
    }
    final locationId = location.id.trim();
    if (locationId.isNotEmpty) {
      setState(() => _rackLocationId = locationId);
    }
  }

  Future<void> _applyPrefetchedRackHistory(
    Future<List<ItemLocationHistoryModel>> future,
  ) async {
    try {
      final history = await future;
      if (!mounted) return;
      setState(() => _rackHistory = history);
      warmRackHistoryThumbnails(ref.read(imageServiceProvider), history);
    } on Object {
      // History is optional UI — ignore load failures.
    }
  }

  void _applyRackLocationFromApi(ItemLocationModel firstLocation) {
    final rackFromApi = firstLocation.rack?.trim();
    if (rackFromApi != null && rackFromApi.isNotEmpty) {
      ref.read(addItemFormProvider.notifier).updateLocation(rackFromApi);
      _locationController.text = rackFromApi;
      _initialRackLocation = rackFromApi;
    }
    setState(() {
      _rackLocationId = firstLocation.id;
      _rackPhotoUrl = firstLocation.photoUrl;
      _rackPhotoTakenAt = firstLocation.photoTakenAt;
      _rackLastUpdatedAt = firstLocation.updatedAt;
    });
    warmRackPhotoUrl(ref.read(imageServiceProvider), firstLocation.photoUrl);
  }

  Future<void> _refreshRackHistory(String locationId) async {
    try {
      final service = await ref.read(inventoryServiceProvider.future);
      final history = await service.fetchItemLocationHistory(locationId);
      if (!mounted) return;
      setState(() => _rackHistory = history);
      warmRackHistoryThumbnails(ref.read(imageServiceProvider), history);
    } on Object {
      // History is optional UI — ignore load failures.
    }
  }

  Future<void> _syncRackShelfAfterSave(
    String itemId,
    AddItemFormState form,
  ) async {
    final rack = form.location.trim();
    final employee = _rackEmployeeController.text.trim();
    final rackChanged = rack != _initialRackLocation;
    final hasWork = rackShelfHasPendingWork(
      rack: rack,
      initialRack: _initialRackLocation,
      employee: employee,
      pendingPhoto: _pendingRackPhoto,
      locationId: _rackLocationId,
    );

    if (!hasWork) return;

    final rackEmployeeError = validateRackShelfEmployee(
      rack: rack,
      initialRack: _initialRackLocation,
      employee: employee,
      pendingPhoto: _pendingRackPhotoRaw ?? _pendingRackPhoto,
      locationId: _rackLocationId,
    );
    if (rackEmployeeError != null) {
      if (!mounted) return;
      showOverlaySnackBar(context, message: rackEmployeeError);
      return;
    }

    try {
      final service = await ref.read(inventoryServiceProvider.future);
      final defaultGodown =
          form.godownId ?? (await service.getDefaultGodown())?.id;
      if (defaultGodown == null) return;

      var locationId = _rackLocationId;
      if (locationId == null) {
        final locations = await service.fetchItemLocations(itemId);
        final existing = locations
            .where((location) => location.godownId == defaultGodown)
            .firstOrNull;
        if (existing != null) {
          locationId = existing.id;
        } else if (rack.isNotEmpty) {
          final created = await service.createItemLocation(
            itemId: itemId,
            godownId: defaultGodown,
            rack: rack,
            employeeLabel: employee.isEmpty ? null : employee,
          );
          locationId = created.id;
        }
      } else if (rackChanged) {
        await service.updateItemLocation(
          locationId,
          rack: rack.isEmpty ? '' : rack,
        );
      }

      if (locationId == null) return;

      if (_pendingRackPhotoRaw != null || _pendingRackPhoto != null) {
        final ({Uint8List bytes, String mimeType}) stamped;
        if (_pendingRackPhotoRaw != null) {
          stamped = await stampRackPhoto(
            bytes: _pendingRackPhotoRaw!,
            takenAt: DateTime.now(),
            rackShelfLabel: rack,
            employeeLabel: employee.isEmpty ? null : employee,
          );
        } else {
          stamped = (bytes: _pendingRackPhoto!, mimeType: 'image/jpeg');
        }
        final prepared = await prepareMediaUploadBytes(
          bytes: stamped.bytes,
          mimeType: stamped.mimeType,
        );
        final upload = await service.uploadRackPhoto(
          locationId: locationId,
          bytes: prepared.bytes,
          mimeType: prepared.mimeType,
          employeeLabel: employee.isEmpty ? null : employee,
        );
        if (mounted) {
          setState(() {
            _rackPhotoUrl = upload.url;
            _rackPhotoTakenAt = upload.takenAt ?? DateTime.now();
            _pendingRackPhoto = null;
            _pendingRackPhotoRaw = null;
            _rackEmployeeController.clear();
          });
        }
      }

      if (!mounted) return;
      setState(() {
        _rackLocationId = locationId;
        _initialRackLocation = rack;
      });
      await _refreshRackHistory(locationId);
    } on Object catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Item saved but rack update failed: $error'),
        ),
      );
    }
  }

  Future<void> _uploadPendingPhotosIfNeeded(String itemId) async {
    if (_pendingItemPhotos.isEmpty) return;

    final remote = ref.read(itemImagesProvider(itemId)).value ?? [];
    final hasPrimary = remote.any((image) => image.isPrimary);

    try {
      final service = await ref.read(inventoryServiceProvider.future);
      for (var i = 0; i < _pendingItemPhotos.length; i++) {
        final prepared = await prepareMediaUploadBytes(
          bytes: _pendingItemPhotos[i],
          mimeType: 'image/jpeg',
        );
        final isPrimary = !hasPrimary && i == 0;
        await service.uploadItemImage(
          itemId,
          bytes: prepared.bytes,
          mimeType: prepared.mimeType,
          isPrimary: isPrimary,
        );
      }
      if (mounted) {
        setState(_pendingItemPhotos.clear);
      }
    } on Object catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Item saved but photo upload failed: $error')),
      );
    }
  }

  int _totalItemPhotoCount() {
    final editId = widget.editItem?.id;
    final remoteCount = editId != null
        ? (ref.read(itemImagesProvider(editId)).value?.length ?? 0)
        : 0;
    return remoteCount + _pendingItemPhotos.length;
  }

  Future<void> _ingestItemPhoto(Uint8List bytes) async {
    final itemId = widget.editItem?.id;
    if (itemId != null && isServerBackedInventoryItemId(itemId)) {
      try {
        final prepared = await prepareMediaUploadBytes(
          bytes: bytes,
          mimeType: 'image/jpeg',
        );
        final remote = ref.read(itemImagesProvider(itemId)).value ?? [];
        final isPrimary = remote.isEmpty;
        final service = await ref.read(inventoryServiceProvider.future);
        final uploaded = await service.uploadItemImage(
          itemId,
          bytes: prepared.bytes,
          mimeType: prepared.mimeType,
          isPrimary: isPrimary,
        );
        ref.read(itemImagesProvider(itemId).notifier).upsert(uploaded);
        unawaited(
          ref.read(itemImagesProvider(itemId).notifier).refreshInBackground(),
        );
        if (isPrimary) {
          ref
              .read(inventoryItemsProvider.notifier)
              .patchItemPrimaryImageUrl(itemId, uploaded.urlForGrid());
        }
        if (mounted) setState(() {});
      } on Object catch (error) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Image upload failed: $error')),
        );
      }
      return;
    }

    setState(() => _pendingItemPhotos.add(bytes));
  }

  Future<void> _addItemPhoto() async {
    if (_totalItemPhotoCount() >= 20) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maximum 20 images allowed')),
      );
      return;
    }

    final images = await pickItemImagesForUpload(
      context,
      existingCount: _totalItemPhotoCount(),
    );
    if (!mounted || images.isEmpty) return;

    for (final bytes in images) {
      if (_totalItemPhotoCount() >= 20) break;
      await _ingestItemPhoto(bytes);
    }
  }

  Future<void> _openPendingPhoto(int index) async {
    final bytes = _pendingItemPhotos[index];
    if (AppPlatform.current.isDesktop) {
      final outcome = await cropItemImageBytes(context, imageBytes: bytes);
      if (!mounted || outcome == null) return;
      switch (outcome) {
        case ItemImageBytesCropRemoved():
          setState(() => _pendingItemPhotos.removeAt(index));
        case ItemImageBytesCropUpdated(:final bytes):
          setState(() => _pendingItemPhotos[index] = bytes);
      }
      return;
    }

    final outcome = await openMobileItemImagePreview(
      context,
      imageBytes: bytes,
    );
    if (!mounted || outcome == null) return;
    switch (outcome) {
      case MobileItemImagePreviewDeleted():
        setState(() => _pendingItemPhotos.removeAt(index));
      case MobileItemImagePreviewUpdated(:final bytes):
        setState(() => _pendingItemPhotos[index] = bytes);
    }
  }

  Future<void> _openRemotePhoto(ItemImageModel image) async {
    final itemId = widget.editItem?.id;
    if (itemId == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Photo'),
        content: const Text('Remove this image from the item?'),
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

    final previous = ref.read(itemImagesProvider(itemId)).value ?? [];
    ref.read(itemImagesProvider(itemId).notifier).removeLocal(image.id);

    try {
      final service = await ref.read(inventoryServiceProvider.future);
      await service.deleteItemImage(itemId, image.id);
      unawaited(
        ref.read(itemImagesProvider(itemId).notifier).refreshInBackground(),
      );
    } on Object catch (error) {
      ref.read(itemImagesProvider(itemId).notifier).applyOptimistic(previous);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not delete image: $error')),
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
    _mrpSaleDiscountController.clear();
    _salePriceDiscountController.clear();
    _wholesalePriceController.clear();
    _minWholesaleQtyController.clear();
    _openingQtyController.clear();
    _atPriceController.clear();
    _minStockController.clear();
    _locationController.clear();
    _rackEmployeeController.clear();
    _pendingRackPhoto = null;
    _pendingRackPhotoRaw = null;
    _rackEmployeeError = null;
    _rackLocationId = null;
    _rackPhotoUrl = null;
    _rackLastUpdatedAt = null;
    _rackPhotoTakenAt = null;
    _rackHistory = const [];
    _initialRackLocation = '';
    _onlineStorePriceController.clear();
    _onlineStoreDescriptionController.clear();
    _primaryImageUrlController.clear();
    _pendingItemPhotos.clear();
    for (final controller in _rawMaterialControllers.values) {
      controller.dispose();
    }
    for (final controller in _additionalCostControllers.values) {
      controller.dispose();
    }
    for (final controller in _tierPriceControllers.values) {
      controller.dispose();
    }
    _rawMaterialControllers.clear();
    _additionalCostControllers.clear();
    _tierPriceControllers.clear();
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
    final updated = ref.read(addItemFormProvider);
    final units = ref.read(unitsProvider);
    _syncOpeningQtyController(updated.openingQty, units);
    _syncMinStockController(updated.minStock, units);
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
      next.whenData((_) => _ensureDefaultBaseUnit());
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
    final brands = ref.watch(inventoryBrandsProvider).value ?? const [];
    final brandOptions = brands.map((brand) => brand.name).toList();
    final selectedBrand = brands
        .where((brand) => brand.id == form.brandId)
        .map((brand) => brand.name)
        .firstOrNull;
    final itemSettings =
        ref.watch(itemSettingsProvider).value ?? ItemSettings.defaults();

    final formBody = buildFormBody(
      form,
      notifier,
      categories,
      categoryOptions,
      selectedCategory,
      brands,
      brandOptions,
      selectedBrand,
      itemSettings,
    );

    if (_isMobileFullPage) {
      return _wrapWithCloseGuard(
        AnnotatedRegion<SystemUiOverlayStyle>(
          value: AppTheme.lightSystemUi,
          child: Scaffold(
            backgroundColor: AppColors.surface,
            body: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(form),
                  Expanded(
                    child: ColoredBox(
                      color: AppColors.background,
                      child: SingleChildScrollView(
                        controller: _mobileFormScrollController,
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        child: formBody,
                      ),
                    ),
                  ),
                  _buildFooter(),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final media = MediaQuery.sizeOf(context);
    final availableWidth = media.width - 48;
    final preferredWidth = availableWidth >= _addItemDialogWidth
        ? _addItemDialogWidth
        : availableWidth.clamp(0, _addItemDialogMaxWidth);

    final dialogWidth = preferredWidth.toDouble();
    final dialogHeight = media.height * _addItemDialogMaxHeightFactor;
    const dividerHeight = 1.0;

    return _wrapWithCloseGuard(
      SizedBox(
        width: dialogWidth,
        height: dialogHeight,
        child: Material(
          color: AppColors.surface,
          borderRadius: AppRadius.lgBorder,
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(form),
              const Divider(height: dividerHeight, color: _cardBorder),
              Expanded(child: formBody),
              const Divider(height: dividerHeight, color: _cardBorder),
              _buildFooter(),
            ],
          ),
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
    List<BrandModel> brands,
    List<String> brandOptions,
    String? selectedBrand,
    ItemSettings itemSettings,
  ) {
    if (_isMobileFullPage) {
      return buildMobileFormBody(
        form,
        notifier,
        categories,
        categoryOptions,
        selectedCategory,
        brands,
        brandOptions,
        selectedBrand,
        itemSettings,
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        FormSpacing.page,
        FormSpacing.section,
        FormSpacing.page,
        FormSpacing.section,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            GeneralInformationSection(
              itemType: form.itemType,
              itemNameController: _itemNameController,
              shortNameController: _shortNameController,
              searchKeywordsController: _searchKeywordsController,
              hsnController: _hsnController,
              itemCodeController: _itemCodeController,
              descriptionController: _descriptionController,
              itemNameError: form.itemNameError,
              baseUnitError: form.baseUnitError,
              onItemNameChanged: notifier.updateItemName,
              onShortNameChanged: notifier.updateShortName,
              onSearchKeywordsChanged: notifier.updateSearchKeywords,
              onHsnChanged: notifier.updateHsn,
              onItemCodeChanged: notifier.updateItemCode,
              onDescriptionChanged: notifier.updateDescription,
              onAssignCode: () {
                notifier.assignCode();
                _itemCodeController.text = ref
                    .read(addItemFormProvider)
                    .itemCode;
              },
              selectedCategoryId: form.categoryId,
              selectedCategory: selectedCategory,
              categories: categories,
              onCategorySelected: notifier.setCategory,
              selectedBrandId: form.brandId,
              selectedBrand: selectedBrand,
              brands: brands,
              onBrandSelected: notifier.setBrand,
              unitLabel: _displayUnitLabel(),
              onSelectUnit: _openUnitPicker,
              alternativesInlineAddButton: widget.editItem == null
                  ? Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        AlternativeItemsAddButton(
                          selectedItemIds: form.alternativeItemIds,
                          excludeItemId: widget.editItem?.id,
                          onChanged: notifier.setAlternativeItemIds,
                        ),
                        AddItemImageLinkButton(
                          itemType: form.itemType,
                          onPressed: () => unawaited(_addItemPhoto()),
                        ),
                      ],
                    )
                  : AddItemImageLinkButton(
                      itemType: form.itemType,
                      onPressed: () => unawaited(_addItemPhoto()),
                    ),
              alternativesListSection: widget.editItem == null
                  ? AlternativeItemsListSection(
                      selectedItemIds: form.alternativeItemIds,
                      excludeItemId: widget.editItem?.id,
                      onChanged: notifier.setAlternativeItemIds,
                    )
                  : null,
              itemId: widget.editItem?.id,
              seedPrimaryImageUrl: widget.editItem?.primaryImageUrl,
              pendingItemPhotos: _pendingItemPhotos,
              onPendingPhotoTap: (index) =>
                  unawaited(_openPendingPhoto(index)),
            ),
            const SizedBox(height: FormSpacing.section),
            _buildTabBar(form),
            const Divider(height: 1, color: _cardBorder),
            const SizedBox(height: FormSpacing.section),
            KeyedSubtree(
              key: ValueKey(
                'add-item-tab-${form.itemType.name}-${form.activeTab}',
              ),
              child: _buildActiveTabContent(form, notifier, itemSettings),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildMobileFormBody(
    AddItemFormState form,
    AddItemForm notifier,
    List<InventoryCategory> categories,
    List<String> categoryOptions,
    String? selectedCategory,
    List<BrandModel> brands,
    List<String> brandOptions,
    String? selectedBrand,
    ItemSettings itemSettings,
  ) {
    final showBarcodeScan =
        form.itemType == ItemType.product &&
        itemSettings.barcodeScanningEnabled;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MobileAddItemImageStrip(
          pendingPhotos: _pendingItemPhotos,
          onAddPhoto: () => unawaited(_addItemPhoto()),
          onTapPendingPhoto: (index) => unawaited(_openPendingPhoto(index)),
          itemId: widget.editItem?.id,
          seedPrimaryImageUrl: widget.editItem?.primaryImageUrl,
          onTapRemotePhoto: widget.editItem != null
              ? (image) => unawaited(_openRemotePhoto(image))
              : null,
        ),
        MobileAddItemGeneralSection(
          itemType: form.itemType,
          itemNameController: _itemNameController,
          itemCodeController: _itemCodeController,
          descriptionController: _descriptionController,
          hsnController: _hsnController,
          itemNameError: form.itemNameError,
          baseUnitError: form.baseUnitError,
          onItemNameChanged: notifier.updateItemName,
          onItemCodeChanged: notifier.updateItemCode,
          onDescriptionChanged: notifier.updateDescription,
          onHsnChanged: notifier.updateHsn,
          onAssignCode: () {
            notifier.assignCode();
            _itemCodeController.text = ref.read(addItemFormProvider).itemCode;
          },
          onSelectUnit: _openUnitPicker,
          baseUnit: _selectedBaseUnit(),
          categoryOptions: categoryOptions,
          selectedCategory: selectedCategory,
          categories: categories,
          onCategorySelected: notifier.setCategory,
          selectedBrand: selectedBrand,
          brands: brands,
          onBrandSelected: notifier.setBrand,
          onAddManufacturingDetails: _openManufacturingSheet,
          onScanBarcode: showBarcodeScan ? _scanBarcode : null,
          showCategory: itemSettings.itemCategory,
          showDescription: itemSettings.descriptionEnabled,
          showManufacturing:
              form.itemType == ItemType.product && itemSettings.manufacturing,
          selectedAlternativeItemIds: form.alternativeItemIds,
          excludeAlternativeItemId: widget.editItem?.id,
          onAlternativeItemIdsChanged: notifier.setAlternativeItemIds,
        ),
        MobileAddItemTabBar(
          tabs: _mobileTabsFor(form.itemType),
          activeIndex: form.activeTab,
          onTabSelected: (index) {
            _tabController.index = index;
            notifier.setActiveTab(index);
          },
        ),
        KeyedSubtree(
          key: ValueKey(
            'mobile-add-item-tab-${form.itemType.name}-${form.activeTab}',
          ),
          child: _buildMobileTabContent(form, notifier, itemSettings),
        ),
      ],
    );
  }

  String _discountText(double value) {
    if (value == 0) return '';
    if (value == value.roundToDouble()) return value.toStringAsFixed(0);
    return value.toString();
  }

  void _syncSalePriceController() {
    final sale = ref.read(addItemFormProvider).salePrice;
    _salePriceController.text = formatIndianItemPriceInput(sale);
  }

  void _syncMrpSaleDiscountController() {
    final discount = ref.read(addItemFormProvider).mrpSaleDiscount;
    _mrpSaleDiscountController.text = _discountText(discount);
  }

  Widget _buildMobilePricingSection({
    required AddItemFormState form,
    required AddItemForm notifier,
    required bool isService,
    required ItemSettings itemSettings,
  }) {
    if (itemSettings.wholesalePrice) {
      notifier.ensureAllTierRows();
    }
    return MobileAddItemPricingSection(
      isService: isService,
      showPriceAmountInWords: itemSettings.showPriceAmountInWords,
      mrpAmount: form.mrp,
      salePriceAmount: form.salePrice,
      wholesalePriceAmount: form.wholesalePrice,
      purchasePriceAmount: form.atPrice,
      mrpController: _mrpController,
      onMrpChanged: (value) {
        notifier.updateMrp(value);
        _syncSalePriceController();
        _syncMrpSaleDiscountController();
      },
      mrpSaleDiscountController: _mrpSaleDiscountController,
      onMrpSaleDiscountChanged: (value) {
        notifier.updateMrpSaleDiscount(value);
        _syncSalePriceController();
      },
      mrpSaleDiscountKind: form.mrpSaleDiscountKind,
      onMrpSaleDiscountKindChanged: (kind) {
        notifier.setMrpSaleDiscountKind(kind);
        _syncSalePriceController();
      },
      salePriceController: _salePriceController,
      salePriceTaxMode: form.salePriceTaxMode,
      onSalePriceChanged: (value) {
        notifier.updateSalePrice(value);
        _syncMrpSaleDiscountController();
      },
      onSalePriceTaxModeChanged: notifier.setSalePriceTaxMode,
      salePriceDiscountController: _salePriceDiscountController,
      onSalePriceDiscountChanged: notifier.updateSalePriceDiscount,
      salePriceDiscountKind: form.salePriceDiscountKind,
      onSalePriceDiscountKindChanged: notifier.setSalePriceDiscountKind,
      wholesalePriceController: _wholesalePriceController,
      wholesalePriceTaxMode: form.wholesalePriceTaxMode,
      onWholesalePriceChanged: notifier.updateWholesalePrice,
      onWholesalePriceTaxModeChanged: notifier.setWholesalePriceTaxMode,
      purchasePriceController: _atPriceController,
      purchasePriceTaxMode: form.purchasePriceTaxMode,
      onPurchasePriceChanged: notifier.updateAtPrice,
      onPurchasePriceTaxModeChanged: notifier.setPurchasePriceTaxMode,
      taxRate: form.taxRate,
      onTaxRateChanged: notifier.setTaxRate,
      showWholesaleSection: form.showWholesaleSection,
      onAddWholesale: notifier.enableWholesaleSection,
      showWholesalePrice: itemSettings.wholesalePrice,
      showTierPricing: itemSettings.wholesalePrice,
      tierPrices: form.tierPrices,
      apiTierLabels: ref.watch(pricingTierLabelsProvider),
      priceControllerFor: _tierPriceController,
      onUpdateTierPrice: notifier.updateTierPriceRow,
    );
  }

  Widget _buildMobileTabContent(
    AddItemFormState form,
    AddItemForm notifier,
    ItemSettings itemSettings,
  ) {
    final tabIndex = form.activeTab;
    final godowns = ref.watch(inventoryGodownsProvider).value ?? const [];
    if (form.itemType == ItemType.service) {
      return switch (tabIndex) {
        0 => _buildMobilePricingSection(
          form: form,
          notifier: notifier,
          isService: true,
          itemSettings: itemSettings,
        ),
        _ => _buildMobileOnlineStoreSection(form, notifier),
      };
    }

    return switch (tabIndex) {
      0 => _buildMobilePricingSection(
        form: form,
        notifier: notifier,
        isService: false,
        itemSettings: itemSettings,
      ),
      1 => MobileAddItemStockSection(
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
        godowns: godowns,
        selectedGodownId: form.godownId,
        onGodownSelected: notifier.setGodown,
        stockQtyUnitOptions: minWholesaleQtyUnitOptions(
          allUnits: ref.watch(unitsProvider),
          baseUnitId: form.baseUnitId,
          secondaryUnitId: form.secondaryUnitId,
        ),
        baseUnitId: form.baseUnitId,
        secondaryUnitId: form.secondaryUnitId,
        baseToSecondaryRate: form.baseUnitId == null
            ? null
            : resolveBaseToSecondaryRate(
                units: ref.watch(unitsProvider),
                baseUnitId: form.baseUnitId!,
                secondaryUnitId: form.secondaryUnitId,
              ),
        openingQtyUnitId: form.openingQtyUnitId,
        minStockUnitId: form.minStockUnitId,
        onOpeningQtyUnitChanged: notifier.setOpeningQtyUnitId,
        onMinStockUnitChanged: notifier.setMinStockUnitId,
      ),
      2 => MobileAddItemProductDescriptionSection(
        descriptionController: _onlineStoreDescriptionController,
        onDescriptionChanged: notifier.updateOnlineStoreDescription,
      ),
      3 => _buildMobileOnlineStoreSection(form, notifier),
      4 when widget.editItem != null => Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: AlternativesSection(itemId: widget.editItem?.id),
      ),
      _ => Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: SuppliersSection(
          rows: form.supplierRows,
          product: _suppliersProductSnapshot(form),
          onPartiesSelected: (partyIds, partiesById, imageUrl) {
            notifier.mergeSupplierParties(
              partyIds: partyIds,
              product: _suppliersProductSnapshot(form),
              partiesById: partiesById,
              resolvedProductImageUrl: imageUrl,
            );
          },
          onUpdateRow: notifier.updateSupplierRow,
          onRemoveRow: notifier.removeSupplierRow,
          defaultPartyId: form.defaultSupplierPartyId,
          onDefaultChanged: notifier.setDefaultSupplierPartyId,
        ),
      ),
    };
  }

  Future<void> _scanBarcode() async {
    final barcode = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => const MobileBarcodeScannerScreen(),
      ),
    );
    if (barcode == null || !mounted) return;
    _itemCodeController.text = barcode;
    ref.read(addItemFormProvider.notifier).updateItemCode(barcode);
  }

  Future<void> _openManufacturingSheet() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (context) => const MobileItemManufacturingScreen(),
      ),
    );
  }

  Widget _buildHeader(AddItemFormState form) {
    final title = widget.editItem != null ? 'Edit Item' : 'Add Item';
    const titleStyle = TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    );
    final toggle = _ProductServiceToggle(
      isProduct: form.itemType == ItemType.product,
      onChanged: (isProduct) => _handleItemTypeChange(
        isProduct ? ItemType.product : ItemType.service,
      ),
    );

    if (AppPlatform.current.isMobile) {
      return MobileAddItemHeader(
        title: title,
        isProduct: form.itemType == ItemType.product,
        onBack: _requestClose,
        onProductServiceChanged: (isProduct) => _handleItemTypeChange(
          isProduct ? ItemType.product : ItemType.service,
        ),
      );
    }

    return SizedBox(
      height: _headerHeight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: FormSpacing.page),
        child: Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      title,
                      style: titleStyle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  toggle,
                ],
              ),
            ),
            _buildHeaderActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderActions() {
    return IconButton(
      onPressed: () => unawaited(_requestClose()),
      icon: const Icon(Icons.close, color: AppColors.textSecondary),
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints.tightFor(width: 32, height: 32),
    );
  }

  Widget _buildActiveTabContent(
    AddItemFormState form,
    AddItemForm notifier,
    ItemSettings itemSettings,
  ) {
    if (_isMobileFullPage) {
      return _buildMobileTabContent(form, notifier, itemSettings);
    }

    final tabIndex = form.activeTab;
    if (form.itemType == ItemType.service) {
      return switch (tabIndex) {
        0 => _buildPricingTab(
          form,
          notifier,
          isService: true,
          itemSettings: itemSettings,
        ),
        _ => _buildOnlineStoreTab(form, notifier),
      };
    }

    if (!_showDesktopAlternativesTab) {
      return switch (tabIndex) {
        0 => _buildPricingTab(
          form,
          notifier,
          isService: false,
          itemSettings: itemSettings,
        ),
        1 => _buildStockTab(form, notifier),
        2 => _buildProductDescriptionTab(form, notifier),
        3 => _buildOnlineStoreTab(form, notifier),
        4 => _buildManufacturingTab(form, notifier),
        _ => _buildSuppliersTab(form, notifier),
      };
    }

    return switch (tabIndex) {
      0 => _buildPricingTab(
        form,
        notifier,
        isService: false,
        itemSettings: itemSettings,
      ),
      1 => _buildStockTab(form, notifier),
      2 => _buildProductDescriptionTab(form, notifier),
      3 => _buildOnlineStoreTab(form, notifier),
      4 => _buildManufacturingTab(form, notifier),
      5 => _buildAlternativesTab(),
      _ => _buildSuppliersTab(form, notifier),
    };
  }

  TextEditingController _tierPriceController(String id, String initial) {
    return _tierPriceControllers.putIfAbsent(
      id,
      () => TextEditingController(text: initial),
    );
  }

  Widget _buildPricingTab(
    AddItemFormState form,
    AddItemForm notifier, {
    required bool isService,
    required ItemSettings itemSettings,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PricingSection(
          isService: isService,
          wholesalePriceEnabled: itemSettings.wholesalePrice,
          showWholesaleSection: form.showWholesaleSection,
          onAddWholesale: notifier.enableWholesaleSection,
          showPriceAmountInWords: itemSettings.showPriceAmountInWords,
          mrpAmount: form.mrp,
          salePriceAmount: form.salePrice,
          wholesalePriceAmount: form.wholesalePrice,
          purchasePriceAmount: form.atPrice,
          mrpController: _mrpController,
          onMrpChanged: (value) {
            notifier.updateMrp(value);
            _syncSalePriceController();
            _syncMrpSaleDiscountController();
          },
          mrpSaleDiscountController: _mrpSaleDiscountController,
          onMrpSaleDiscountChanged: (value) {
            notifier.updateMrpSaleDiscount(value);
            _syncSalePriceController();
          },
          mrpSaleDiscountKind: form.mrpSaleDiscountKind,
          onMrpSaleDiscountKindChanged: (kind) {
            notifier.setMrpSaleDiscountKind(kind);
            _syncSalePriceController();
          },
          salePriceController: _salePriceController,
          salePriceTaxMode: form.salePriceTaxMode,
          onSalePriceChanged: (value) {
            notifier.updateSalePrice(value);
            _syncMrpSaleDiscountController();
          },
          onSalePriceTaxModeChanged: notifier.setSalePriceTaxMode,
          salePriceDiscountController: _salePriceDiscountController,
          onSalePriceDiscountChanged: notifier.updateSalePriceDiscount,
          salePriceDiscountKind: form.salePriceDiscountKind,
          onSalePriceDiscountKindChanged: notifier.setSalePriceDiscountKind,
          wholesalePriceController: _wholesalePriceController,
          wholesalePriceTaxMode: form.wholesalePriceTaxMode,
          onWholesalePriceChanged: notifier.updateWholesalePrice,
          onWholesalePriceTaxModeChanged: notifier.setWholesalePriceTaxMode,
          minWholesaleQtyController: _minWholesaleQtyController,
          onMinWholesaleQtyChanged: notifier.updateMinWholesaleQty,
          minWholesaleQtyUnitOptions: minWholesaleQtyUnitOptions(
            allUnits: ref.watch(unitsProvider),
            baseUnitId: form.baseUnitId,
            secondaryUnitId: form.secondaryUnitId,
          ),
          minWholesaleQtyUnitId: form.minWholesaleQtyUnitId,
          onMinWholesaleQtyUnitChanged: notifier.updateMinWholesaleQtyUnitId,
          baseUnitId: form.baseUnitId,
          purchasePriceController: _atPriceController,
          purchasePriceTaxMode: form.purchasePriceTaxMode,
          onPurchasePriceChanged: notifier.updateAtPrice,
          onPurchasePriceTaxModeChanged: notifier.setPurchasePriceTaxMode,
          taxRate: form.taxRate,
          onTaxRateChanged: notifier.setTaxRate,
        ),
        const SizedBox(height: FormSpacing.section),
        TierPricingSection(
          tierPrices: form.tierPrices,
          apiTierLabels: ref.watch(pricingTierLabelsProvider),
          onCustomizeTierNames: () async {
            await showEditPricingTierLabelsDialog(context);
            if (mounted) setState(() {});
          },
          priceControllerFor: _tierPriceController,
          onUpdateTierPrice: notifier.updateTierPriceRow,
          onRemoveTierPrice: (id) {
            _tierPriceControllers.remove(id)?.dispose();
            notifier.removeTierPriceRow(id);
          },
          onAddTierPrice: notifier.addTierPriceRow,
        ),
      ],
    );
  }

  void _syncOpeningQtyController(double baseQty, List<InventoryUnit> units) {
    final form = ref.read(addItemFormProvider);
    _openingQtyController.text = _displayStockQtyText(
      baseQty: baseQty,
      displayUnitId: form.openingQtyUnitId,
      form: form,
      units: units,
    );
  }

  void _syncMinStockController(double baseQty, List<InventoryUnit> units) {
    final form = ref.read(addItemFormProvider);
    _minStockController.text = _displayStockQtyText(
      baseQty: baseQty,
      displayUnitId: form.minStockUnitId,
      form: form,
      units: units,
    );
  }

  String _displayStockQtyText({
    required double baseQty,
    required String? displayUnitId,
    required AddItemFormState form,
    required List<InventoryUnit> units,
  }) {
    if (baseQty == 0) return '';
    final baseUnitId = form.baseUnitId;
    if (baseUnitId == null) return formatItemQtyFieldValue(baseQty);
    final rate = resolveBaseToSecondaryRate(
      units: units,
      baseUnitId: baseUnitId,
      secondaryUnitId: form.secondaryUnitId,
    );
    final display = qtyFromBaseUnit(
      baseQty: baseQty,
      displayUnitId: displayUnitId ?? baseUnitId,
      baseUnitId: baseUnitId,
      secondaryUnitId: form.secondaryUnitId,
      baseToSecondaryRate: rate,
    );
    return formatItemQtyFieldValue(display);
  }

  Widget _buildStockTab(AddItemFormState form, AddItemForm notifier) {
    final units = ref.watch(unitsProvider);
    final stockQtyUnitOptions = minWholesaleQtyUnitOptions(
      allUnits: units,
      baseUnitId: form.baseUnitId,
      secondaryUnitId: form.secondaryUnitId,
    );
    final baseToSecondaryRate = form.baseUnitId == null
        ? null
        : resolveBaseToSecondaryRate(
            units: units,
            baseUnitId: form.baseUnitId!,
            secondaryUnitId: form.secondaryUnitId,
          );

    return StockSection(
      openingQtyController: _openingQtyController,
      openingPriceController: _atPriceController,
      minStockController: _minStockController,
      locationController: _locationController,
      employeeController: _rackEmployeeController,
      asOfDate: form.asOfDate,
      onOpeningQtyChanged: notifier.updateOpeningQty,
      onOpeningPriceChanged: notifier.updateAtPrice,
      onMinStockChanged: notifier.updateMinStock,
      onLocationChanged: notifier.updateLocation,
      onAsOfDateSelected: notifier.setAsOfDate,
      asOfDatePickerKey: _asOfDatePickerKey,
      stockQtyUnitOptions: stockQtyUnitOptions,
      baseUnitId: form.baseUnitId,
      secondaryUnitId: form.secondaryUnitId,
      baseToSecondaryRate: baseToSecondaryRate,
      openingQtyUnitId: form.openingQtyUnitId,
      minStockUnitId: form.minStockUnitId,
      onOpeningQtyUnitChanged: notifier.setOpeningQtyUnitId,
      onMinStockUnitChanged: notifier.setMinStockUnitId,
      rackLocationId: _rackLocationId,
      rackPhotoUrl: _rackPhotoUrl,
      rackPhotoTakenAt: _rackPhotoTakenAt,
      rackLastUpdatedAt: _rackLastUpdatedAt,
      rackHistory: _rackHistory,
      onRackPhotoChanged: (url, takenAt) {
        setState(() {
          _rackPhotoUrl = url;
          _rackPhotoTakenAt = url == null ? null : takenAt;
        });
      },
      onRackHistoryRefresh: _rackLocationId == null
          ? null
          : () => _refreshRackHistory(_rackLocationId!),
      pendingRackPhotoBytes: _pendingRackPhoto,
      onPendingRackPhotoChanged: (bytes) => setState(() {
        _pendingRackPhoto = bytes;
        if (bytes == null) _pendingRackPhotoRaw = null;
        if (bytes != null) _rackEmployeeError = null;
      }),
      pendingRackPhotoRawBytes: _pendingRackPhotoRaw,
      onPendingRackPhotoRawChanged: (bytes) =>
          setState(() => _pendingRackPhotoRaw = bytes),
      initialRackLocation: _initialRackLocation,
      rackEmployeeError: _rackEmployeeError,
      onRackEmployeeChanged: () {
        if (_rackEmployeeError == null) return;
        setState(() => _rackEmployeeError = null);
      },
      onRackPhotoUploaded: () {
        setState(() {
          _rackEmployeeController.clear();
          _initialRackLocation = _locationController.text.trim();
        });
      },
      onRackLocationSynced: (rack) {
        setState(() => _initialRackLocation = rack);
      },
    );
  }

  Widget _buildProductDescriptionTab(
    AddItemFormState form,
    AddItemForm notifier,
  ) {
    return ProductDescriptionSection(
      descriptionController: _onlineStoreDescriptionController,
      onDescriptionChanged: notifier.updateOnlineStoreDescription,
    );
  }

  Widget _buildMobileOnlineStoreSection(
    AddItemFormState form,
    AddItemForm notifier,
  ) {
    return MobileAddItemOnlineStoreSection(
      itemType: form.itemType,
      priceController: _onlineStorePriceController,
      onPriceChanged: notifier.updateOnlineStorePrice,
      descriptionController: form.itemType == ItemType.service
          ? _onlineStoreDescriptionController
          : null,
      onDescriptionChanged: form.itemType == ItemType.service
          ? notifier.updateOnlineStoreDescription
          : null,
    );
  }

  Widget _buildOnlineStoreTab(AddItemFormState form, AddItemForm notifier) {
    return OnlineStoreSection(
      itemType: form.itemType,
      priceController: _onlineStorePriceController,
      onPriceChanged: notifier.updateOnlineStorePrice,
      descriptionController: form.itemType == ItemType.service
          ? _onlineStoreDescriptionController
          : null,
      onDescriptionChanged: form.itemType == ItemType.service
          ? notifier.updateOnlineStoreDescription
          : null,
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
      onSelectRawMaterialItem: notifier.selectRawMaterialItem,
      onRemoveRawMaterial: notifier.removeRawMaterialRow,
      onAddRawMaterial: notifier.addRawMaterialRow,
      onAddAdditionalCost: notifier.addAdditionalCost,
      onUpdateAdditionalCost: notifier.updateAdditionalCost,
      onRemoveAdditionalCost: notifier.removeAdditionalCost,
      additionalCostControllers: _additionalCostControllers,
    );
  }

  Widget _buildAlternativesTab() {
    return AlternativesSection(
      itemId: widget.editItem?.id,
    );
  }

  SuppliersProductSnapshot _suppliersProductSnapshot(AddItemFormState form) {
    final brands = ref.watch(inventoryBrandsProvider).value ?? const [];
    final brandName = brands
        .where((brand) => brand.id == form.brandId)
        .map((brand) => brand.name)
        .firstOrNull;

    return SuppliersProductSnapshot(
      itemId: widget.editItem?.id,
      productImageUrl: form.primaryImageUrl,
      brandName: brandName ?? '',
      mrp: form.mrp,
      pricing: form.atPrice,
      minOrderQuantity: form.minWholesaleQty,
      productNotes: form.description,
    );
  }

  Widget _buildSuppliersTab(AddItemFormState form, AddItemForm notifier) {
    return SuppliersSection(
      rows: form.supplierRows,
      product: _suppliersProductSnapshot(form),
      onPartiesSelected: (partyIds, partiesById, imageUrl) {
        notifier.mergeSupplierParties(
          partyIds: partyIds,
          product: _suppliersProductSnapshot(form),
          partiesById: partiesById,
          resolvedProductImageUrl: imageUrl,
        );
      },
      onUpdateRow: notifier.updateSupplierRow,
      onRemoveRow: notifier.removeSupplierRow,
      defaultPartyId: form.defaultSupplierPartyId,
      onDefaultChanged: notifier.setDefaultSupplierPartyId,
    );
  }

  Widget _buildTabBar(AddItemFormState form) {
    final tabs = form.itemType == ItemType.product
        ? (_showDesktopAlternativesTab
              ? const [
                  'Pricing',
                  'Stock',
                  'Product Description',
                  'Online Store',
                  'Manufacturing',
                  'Alternatives',
                  'Suppliers',
                ]
              : const [
                  'Pricing',
                  'Stock',
                  'Product Description',
                  'Online Store',
                  'Manufacturing',
                  'Suppliers',
                ])
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
    if (_isMobileFullPage) {
      return MobileAddItemFooter(
        isSaving: _isSaving,
        onCancel: _requestClose,
        onSave: () => _save(saveAndNew: false),
      );
    }

    final footer = SizedBox(
      height: FormSpacing.footerHeight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: FormSpacing.page),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 360;
            final saveAndNew = OutlinedButton(
              onPressed: _isSaving ? null : () => _save(saveAndNew: true),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textPrimary,
                side: const BorderSide(color: _cardBorder),
                minimumSize: Size(
                  compact ? double.infinity : 0,
                  FormSpacing.inputHeight,
                ),
                padding: EdgeInsets.symmetric(horizontal: compact ? 12 : 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: const Text(
                'Save & New',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            );
            final save = FilledButton(
              onPressed: _isSaving ? null : () => _save(saveAndNew: false),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: Size(
                  compact ? double.infinity : 0,
                  FormSpacing.inputHeight,
                ),
                padding: EdgeInsets.symmetric(horizontal: compact ? 12 : 28),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: const Text(
                'Save',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            );

            if (compact) {
              return Row(
                children: [
                  Expanded(child: saveAndNew),
                  const SizedBox(width: 12),
                  Expanded(child: save),
                ],
              );
            }

            return Row(
              children: [
                const Spacer(),
                saveAndNew,
                const SizedBox(width: 12),
                save,
              ],
            );
          },
        ),
      ),
    );

    return footer;
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
