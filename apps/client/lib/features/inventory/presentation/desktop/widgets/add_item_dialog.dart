import 'dart:async';
import 'dart:typed_data';

import 'package:billing_baba/core/routing/app_routes.dart';
import 'package:billing_baba/core/media/prepare_media_upload_bytes.dart';
import 'package:billing_baba/features/inventory/presentation/mobile/screens/mobile_item_image_preview_screen.dart';
import 'package:billing_baba/features/inventory/presentation/mobile/screens/mobile_barcode_scanner_screen.dart';
import 'package:billing_baba/features/inventory/presentation/mobile/widgets/add_item/mobile_add_item_footer.dart';
import 'package:billing_baba/features/inventory/presentation/mobile/widgets/add_item/mobile_add_item_general_section.dart';
import 'package:billing_baba/features/inventory/presentation/mobile/widgets/add_item/mobile_add_item_header.dart';
import 'package:billing_baba/features/inventory/presentation/mobile/widgets/add_item/mobile_add_item_online_store_section.dart';
import 'package:billing_baba/features/inventory/presentation/mobile/widgets/add_item/mobile_add_item_pricing_section.dart';
import 'package:billing_baba/features/inventory/presentation/mobile/widgets/add_item/mobile_add_item_settings_sheet.dart';
import 'package:billing_baba/features/inventory/presentation/mobile/widgets/add_item/mobile_add_item_stock_section.dart';
import 'package:billing_baba/features/inventory/presentation/mobile/widgets/add_item/mobile_add_item_image_strip.dart';
import 'package:billing_baba/features/inventory/presentation/mobile/widgets/add_item/mobile_add_item_tab_bar.dart';
import 'package:billing_baba/features/inventory/presentation/mobile/widgets/add_item/mobile_item_image_picker.dart';
import 'package:billing_baba/core/platform/app_platform.dart';
import 'package:billing_baba/core/network/api_validation_exception.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/shared/widgets/transaction_success_toast.dart';
import 'package:billing_baba/features/business/application/commerce_settings_provider.dart';
import 'package:billing_baba/features/inventory/application/add_item_form_provider.dart';
import 'package:billing_baba/features/inventory/application/inventory_brands_provider.dart';
import 'package:billing_baba/features/inventory/application/inventory_error_mapper.dart';
import 'package:billing_baba/features/inventory/application/inventory_items_provider.dart';
import 'package:billing_baba/features/inventory/application/item_images_provider.dart';
import 'package:billing_baba/features/inventory/models/item_image_model.dart';
import 'package:billing_baba/features/inventory/application/inventory_providers.dart';
import 'package:billing_baba/features/inventory/application/inventory_service.dart';
import 'package:billing_baba/features/inventory/application/inventory_units_provider.dart';
import 'package:billing_baba/features/inventory/application/item_settings_provider.dart';
import 'package:billing_baba/features/inventory/application/local_item_suppliers_provider.dart';
import 'package:billing_baba/features/inventory/models/add_item_form_model.dart';
import 'package:billing_baba/features/inventory/models/brand_model.dart';
import 'package:billing_baba/features/inventory/models/category_model.dart';
import 'package:billing_baba/features/inventory/models/item_model.dart';
import 'package:billing_baba/features/inventory/models/item_settings.dart';
import 'package:billing_baba/features/inventory/models/tier_price_model.dart';
import 'package:billing_baba/features/inventory/models/unit_model.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/add_item/alternative_items_field.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/add_item/alternatives_section.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/add_item/general_information_section.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/add_item/manufacturing_section.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/add_item/online_store_section.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/add_item/pricing_section.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/add_item/stock_section.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/add_item/suppliers_section.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/add_item/tier_pricing_section.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/select_unit_dialog.dart';
import 'package:billing_baba/features/inventory/utils/item_tax_rate.dart';
import 'package:billing_baba/features/pricing/application/local_item_tier_prices_provider.dart';
import 'package:billing_baba/features/pricing/models/price_tier.dart';
import 'package:billing_baba/features/pricing/presentation/desktop/widgets/edit_pricing_tier_labels_dialog.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_single_date_picker.dart';
import 'package:billing_baba/shared/widgets/forms/forms.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

const _cardBorder = Color(0xFFE0E0E0);
const _tabActiveColor = Color(0xFFD32F2F);
const _mobileAddItemHeaderHeight = 84.0;

int _tierRowCounter = 0;

String _nextTierRowId() {
  _tierRowCounter += 1;
  return 'tier_row_$_tierRowCounter';
}

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
  final Map<String, TextEditingController> _tierPriceControllers = {};
  final _primaryImageUrlController = TextEditingController();
  final List<Uint8List> _pendingItemPhotos = [];
  bool _isSaving = false;
  String? _rackLocationId;
  String? _rackPhotoUrl;
  double _initialOpeningQty = 0;

  bool get _isMobileFullPage => widget.fullPage && AppPlatform.current.isMobile;

  double get _headerHeight {
    if (_isMobileFullPage) return 0;
    if (AppPlatform.current.isMobile) return _mobileAddItemHeaderHeight;
    return FormSpacing.headerHeight;
  }

  int _tabCountFor(ItemType type) {
    if (_isMobileFullPage) {
      return type == ItemType.product ? 3 : 2;
    }
    return type == ItemType.product ? 6 : 2;
  }

  List<String> _mobileTabsFor(ItemType type) => type == ItemType.product
      ? const ['Pricing', 'Stock', 'Online Store']
      : const ['Pricing', 'Online Store'];

  InventoryUnit? _selectedBaseUnit() {
    final form = ref.read(addItemFormProvider);
    final units = ref.read(unitsProvider);
    if (form.baseUnitId == null) return null;
    return units
        .where((unit) => unit.id == form.baseUnitId)
        .firstOrNull;
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
        _ensureDefaultServiceUnit();
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

  void _ensureDefaultServiceUnit() {
    final form = ref.read(addItemFormProvider);
    if (form.itemType != ItemType.service || form.baseUnitId != null) return;

    final units = ref.read(inventoryUnitsProvider).value ?? [];
    final defaultUnit = resolveDefaultServiceUnit(units);
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
      final detailDto = await service.fetchItemDetailDto(item.id);
      var tiers = const <TierPriceModel>[];
      try {
        tiers = await service.fetchItemTierPrices(item.id);
      } on Object {
        // Tier prices may be unavailable offline; form still opens from local item.
      }

      await ref.read(localItemTierPricesProvider.notifier).ensureInitialized();

      if (detailDto.purchasePrice.isNotEmpty) {
        final purchasePrice = double.tryParse(detailDto.purchasePrice);
        if (purchasePrice != null) {
          notifier.updateAtPrice(purchasePrice);
          _atPriceController.text = purchasePrice.toString();
        }
      }
      if (detailDto.mrp != null && detailDto.mrp!.isNotEmpty) {
        final mrp = double.tryParse(detailDto.mrp!);
        if (mrp != null) {
          notifier.updateMrp(mrp);
          _mrpController.text = mrp.toString();
        }
      }
      if (detailDto.reorderLevel != null && detailDto.reorderLevel!.isNotEmpty) {
        final reorderLevel = double.tryParse(detailDto.reorderLevel!);
        if (reorderLevel != null) {
          notifier.updateMinStock(reorderLevel);
          _minStockController.text = reorderLevel.toString();
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
        _openingQtyController.text = openingQty.toString();
      }

      final openingGodown = detailDto.openingStock?.godowns.firstOrNull;
      final location = detailDto.locations.firstOrNull;
      final godownId = openingGodown?.godownId ?? location?.godownId;
      if (godownId != null) {
        notifier.setGodown(godownId);
      }
      if (location?.rack != null && location!.rack!.isNotEmpty) {
        notifier.updateLocation(location.rack!);
        _locationController.text = location.rack!;
      }

      final itemLocations = await service.fetchItemLocations(item.id);
      if (itemLocations.isNotEmpty && mounted) {
        final firstLocation = itemLocations.first;
        setState(() {
          _rackLocationId = firstLocation.id;
          _rackPhotoUrl = firstLocation.photoUrl;
        });
      }

      final wholesale = tiers
          .where((tier) => tier.pricingTier == 'tier_2')
          .map((tier) => tier.price)
          .firstOrNull;
      if (wholesale != null) {
        notifier.updateWholesalePrice(wholesale);
        _wholesalePriceController.text = wholesale.toString();
      }

      final localTiers = ref.read(localItemTierPricesProvider)[item.id];
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
      await ref.read(localItemSuppliersProvider.notifier).ensureInitialized();
      final localSuppliers =
          ref.read(localItemSuppliersProvider.notifier).suppliersFor(item.id);
      if (localSuppliers.isNotEmpty) {
        notifier.setSupplierPartyIds(localSuppliers);
      }
    } on Object {
      // Local suppliers cache is best-effort.
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
    _shortNameController.dispose();
    _aliasController.dispose();
    _searchKeywordsController.dispose();
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
    for (final controller in _tierPriceControllers.values) {
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
            .updateItemFromForm(
              editItem.id,
              form,
              initialOpeningQty: _initialOpeningQty,
            );
        ref
            .read(localItemTierPricesProvider.notifier)
            .setTierPrices(editItem.id, form.tierPriceMap);
        ref
            .read(localItemSuppliersProvider.notifier)
            .setSuppliers(editItem.id, form.supplierPartyIds);
      } else {
        savedItem = await ref
            .read(inventoryItemsProvider.notifier)
            .addItemFromForm(form);
        if (savedItem != null) {
          ref
              .read(localItemTierPricesProvider.notifier)
              .setTierPrices(savedItem.id, form.tierPriceMap);
          ref
              .read(localItemSuppliersProvider.notifier)
              .setSuppliers(savedItem.id, form.supplierPartyIds);
        }
      }

      if (!mounted) return;

      if (savedItem != null) {
        await _uploadPendingPhotosIfNeeded(savedItem.id);
      }

      if (!mounted) return;
      setState(() => _isSaving = false);

      if (saveAndNew) {
        notifier.reset(itemType: form.itemType);
        _clearControllers();
        _initialOpeningQty = 0;
        _tabController.index = 0;
        return;
      }

      Navigator.of(context).pop(savedItem);
    } on ApiValidationException catch (error) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      _showSaveError(InventoryErrorMapper.validationMessage(error));
    } on InventoryException catch (error) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      _showSaveError(error.message);
    } catch (error) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      _showSaveError(InventoryErrorMapper.messageForSaveItem(error));
    }
  }

  void _showSaveError(String message) {
    showTransactionErrorToast(context, message: message);
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
        setState(() => _pendingItemPhotos.clear());
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

  Future<void> _addItemPhoto() async {
    if (_totalItemPhotoCount() >= 20) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maximum 20 images allowed')),
      );
      return;
    }

    final bytes = await pickMobileItemImage(context);
    if (bytes == null || !mounted) return;
    setState(() => _pendingItemPhotos.add(bytes));
  }

  Future<void> _openPendingPhoto(int index) async {
    final bytes = _pendingItemPhotos[index];
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
    _wholesalePriceController.clear();
    _minWholesaleQtyController.clear();
    _openingQtyController.clear();
    _atPriceController.clear();
    _minStockController.clear();
    _locationController.clear();
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
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(form),
              Expanded(
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  child: formBody,
                ),
              ),
              _buildFooter(),
            ],
          ),
        ),
      );
    }

    final media = MediaQuery.sizeOf(context);
    final availableWidth = media.width - 48;
    final preferredWidth = availableWidth >= FormSpacing.dialogWidth
        ? FormSpacing.dialogWidth
        : availableWidth.clamp(0, FormSpacing.dialogMaxWidth);

    final maxDialogHeight = media.height * FormSpacing.dialogMaxHeightFactor;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: preferredWidth.toDouble(),
        maxHeight: maxDialogHeight,
      ),
      child: Material(
        color: AppColors.surface,
        borderRadius: AppRadius.lgBorder,
        clipBehavior: Clip.antiAlias,
        child: LayoutBuilder(
          builder: (context, constraints) {
            const dividerHeight = 1.0;
            final bodyMaxHeight =
                (constraints.maxHeight -
                        _headerHeight -
                        FormSpacing.footerHeight -
                        dividerHeight * 2)
                    .clamp(0.0, double.infinity);

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(form),
                const Divider(height: dividerHeight, color: _cardBorder),
                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: bodyMaxHeight),
                  child: SingleChildScrollView(child: formBody),
                ),
                const Divider(height: dividerHeight, color: _cardBorder),
                _buildFooter(),
              ],
            );
          },
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
        itemSettings,
      );
    }

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
            shortNameController: _shortNameController,
            aliasController: _aliasController,
            searchKeywordsController: _searchKeywordsController,
            hsnController: _hsnController,
            itemCodeController: _itemCodeController,
            descriptionController: _descriptionController,
            itemNameError: form.itemNameError,
            onItemNameChanged: notifier.updateItemName,
            onShortNameChanged: notifier.updateShortName,
            onAliasChanged: notifier.updateAlias,
            onSearchKeywordsChanged: notifier.updateSearchKeywords,
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
            brandOptions: brandOptions,
            selectedBrand: selectedBrand,
            brands: brands,
            onBrandSelected: notifier.setBrand,
            unitLabel: _displayUnitLabel(),
            onSelectUnit: _openUnitPicker,
            alternativeItemsField: AlternativeItemsField(
              selectedItemIds: form.alternativeItemIds,
              excludeItemId: widget.editItem?.id,
              onChanged: notifier.setAlternativeItemIds,
            ),
            itemId: widget.editItem?.id,
            seedPrimaryImageUrl: widget.editItem?.primaryImageUrl,
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

    return content;
  }

  Widget buildMobileFormBody(
    AddItemFormState form,
    AddItemForm notifier,
    List<InventoryCategory> categories,
    List<String> categoryOptions,
    String? selectedCategory,
    ItemSettings itemSettings,
  ) {
    final showBarcodeScan = form.itemType == ItemType.product &&
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
          trackingMode: form.trackingMode,
          onTrackingModeChanged: notifier.setTrackingMode,
          onAddManufacturingDetails: _openManufacturingSheet,
          onScanBarcode: showBarcodeScan ? _scanBarcode : null,
          showCategory: itemSettings.itemCategory,
          showDescription: itemSettings.descriptionEnabled,
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

  Widget _buildMobileTabContent(
    AddItemFormState form,
    AddItemForm notifier,
    ItemSettings itemSettings,
  ) {
    final tabIndex = form.activeTab;
    if (form.itemType == ItemType.service) {
      return switch (tabIndex) {
        0 => MobileAddItemPricingSection(
          isService: true,
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
          purchasePriceController: _atPriceController,
          purchasePriceTaxMode: form.purchasePriceTaxMode,
          onPurchasePriceChanged: notifier.updateAtPrice,
          onPurchasePriceTaxModeChanged: notifier.setPurchasePriceTaxMode,
          taxRate: form.taxRate,
          onTaxRateChanged: notifier.setTaxRate,
          showWholesalePrice: itemSettings.wholesalePrice,
        ),
        _ => MobileAddItemOnlineStoreSection(
          itemType: form.itemType,
          priceController: _onlineStorePriceController,
          descriptionController: _onlineStoreDescriptionController,
          onPriceChanged: notifier.updateOnlineStorePrice,
          onDescriptionChanged: notifier.updateOnlineStoreDescription,
        ),
      };
    }

    return switch (tabIndex) {
      0 => MobileAddItemPricingSection(
        isService: false,
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
        purchasePriceController: _atPriceController,
        purchasePriceTaxMode: form.purchasePriceTaxMode,
        onPurchasePriceChanged: notifier.updateAtPrice,
        onPurchasePriceTaxModeChanged: notifier.setPurchasePriceTaxMode,
        taxRate: form.taxRate,
        onTaxRateChanged: notifier.setTaxRate,
        showWholesalePrice: itemSettings.wholesalePrice,
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
      ),
      _ => MobileAddItemOnlineStoreSection(
        itemType: form.itemType,
        priceController: _onlineStorePriceController,
        descriptionController: _onlineStoreDescriptionController,
        onPriceChanged: notifier.updateOnlineStorePrice,
        onDescriptionChanged: notifier.updateOnlineStoreDescription,
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
    final form = ref.read(addItemFormProvider);
    final notifier = ref.read(addItemFormProvider.notifier);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          left: FormSpacing.page,
          right: FormSpacing.page,
          top: FormSpacing.page,
          bottom: MediaQuery.viewInsetsOf(sheetContext).bottom + FormSpacing.page,
        ),
        child: SingleChildScrollView(
          child: ManufacturingSection(
            form: form,
            rawControllerFor: _rawController,
            onUpdateRawMaterial: notifier.updateRawMaterial,
            onRemoveRawMaterial: notifier.removeRawMaterialRow,
            onAddRawMaterial: notifier.addRawMaterialRow,
            onAddAdditionalCost: notifier.addAdditionalCost,
            onUpdateAdditionalCost: notifier.updateAdditionalCost,
            onRemoveAdditionalCost: notifier.removeAdditionalCost,
            additionalCostControllers: _additionalCostControllers,
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AddItemFormState form) {
    final title = widget.editItem != null ? 'Edit Item' : 'Add Item';
    final titleStyle = const TextStyle(
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
        onBack: () => Navigator.of(context).maybePop(),
        onSettingsTap: () {
          unawaited(showMobileAddItemSettingsSheet(context));
        },
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
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: () {
            if (AppPlatform.current.isMobile) {
              unawaited(showMobileAddItemSettingsSheet(context));
              return;
            }
            context.push(AppRoutes.itemsSettings);
          },
          icon: const Icon(
            Icons.settings_outlined,
            color: AppColors.textSecondary,
          ),
          tooltip: 'Settings',
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints.tightFor(width: 32, height: 32),
        ),
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close, color: AppColors.textSecondary),
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints.tightFor(width: 32, height: 32),
        ),
      ],
    );
  }

  Widget _buildActiveTabContent(
    AddItemFormState form,
    AddItemForm notifier,
  ) {
    if (_isMobileFullPage) {
      final itemSettings =
          ref.read(itemSettingsProvider).value ?? ItemSettings.defaults();
      return _buildMobileTabContent(form, notifier, itemSettings);
    }

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
      3 => _buildManufacturingTab(form, notifier),
      4 => _buildAlternativesTab(),
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
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PricingSection(
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
      rackLocationId: _rackLocationId,
      rackPhotoUrl: _rackPhotoUrl,
      onRackPhotoChanged: (url) => setState(() => _rackPhotoUrl = url),
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

  Widget _buildAlternativesTab() {
    return AlternativesSection(
      itemId: widget.editItem?.id,
    );
  }

  Widget _buildSuppliersTab(AddItemFormState form, AddItemForm notifier) {
    return SuppliersSection(
      selectedPartyIds: form.supplierPartyIds,
      onChanged: notifier.setSupplierPartyIds,
    );
  }

  Widget _buildTabBar(AddItemFormState form) {
    final tabs = form.itemType == ItemType.product
        ? const [
            'Pricing',
            'Stock',
            'Online Store',
            'Manufacturing',
            'Alternatives',
            'Suppliers',
          ]
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
        onCancel: () => Navigator.of(context).maybePop(),
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
                minimumSize: Size(compact ? double.infinity : 0, FormSpacing.inputHeight),
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
                minimumSize: Size(compact ? double.infinity : 0, FormSpacing.inputHeight),
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
