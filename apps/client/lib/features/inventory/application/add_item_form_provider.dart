import 'package:billing_baba/features/inventory/models/add_item_form_model.dart';
import 'package:billing_baba/features/parties/models/party_model.dart';
import 'package:billing_baba/shared/constants/item_price_limits.dart';
import 'package:billing_baba/features/inventory/models/item_bom_model.dart';
import 'package:billing_baba/features/inventory/models/item_model.dart';
import 'package:billing_baba/features/inventory/models/mappers/add_item_form_mapper.dart';
import 'package:billing_baba/features/inventory/utils/item_pricing_discount.dart';
import 'package:billing_baba/features/pricing/models/price_tier.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/item_name_autocomplete_field.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_dropdown_options.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

int _rowCounter = 0;

String _nextRowId() {
  _rowCounter += 1;
  return 'row_$_rowCounter';
}

final NotifierProvider<AddItemForm, AddItemFormState> addItemFormProvider =
    NotifierProvider.autoDispose<AddItemForm, AddItemFormState>(
      AddItemForm.new,
    );

class AddItemForm extends Notifier<AddItemFormState> {
  @override
  AddItemFormState build() {
    final now = DateTime.now();
    return AddItemFormState(
      asOfDate: DateTime(now.year, now.month, now.day),
      rawMaterials: [
        RawMaterialRow(id: _nextRowId()),
        RawMaterialRow(id: _nextRowId()),
      ],
    );
  }

  void setInitialType(ItemType type) {
    state = state.copyWith(itemType: type);
  }

  void setItemType(ItemType type) {
    state = state.copyWith(itemType: type, isDirty: true);
  }

  void updateItemName(String value) {
    state = state.copyWith(
      itemName: value,
      itemNameError: false,
      clearFieldErrors: true,
      isDirty: true,
    );
  }

  void updateShortName(String value) {
    state = state.copyWith(shortName: value, isDirty: true);
  }

  void updateAlias(String value) {
    state = state.copyWith(alias: value, isDirty: true);
  }

  void updateSearchKeywords(String value) {
    state = state.copyWith(searchKeywords: value, isDirty: true);
  }

  void setAlternativeItemIds(List<String> itemIds) {
    state = state.copyWith(alternativeItemIds: itemIds, isDirty: true);
  }

  void setSupplierPartyIds(List<String> partyIds) {
    mergeSupplierParties(partyIds: partyIds);
  }

  void mergeSupplierParties({
    required List<String> partyIds,
    SuppliersProductSnapshot? product,
    Map<String, PartyModel> partiesById = const {},
    String? resolvedProductImageUrl,
  }) {
    final cleaned = partyIds
        .map((id) => id.trim())
        .where((id) => id.isNotEmpty)
        .toList();
    final snapshot = product ?? _suppliersSnapshotFromState();
    final imageUrl =
        resolvedProductImageUrl ?? snapshot.productImageUrl.trim();
    final existing = {
      for (final row in state.supplierRows) row.partyId: row,
    };
    final rows = <ItemSupplierFormRow>[
      for (final partyId in cleaned)
        existing[partyId] ??
            _newSupplierRow(
              partyId: partyId,
              snapshot: snapshot,
              productImageUrl: imageUrl,
              party: partiesById[partyId],
            ),
    ];
    final currentDefault = state.defaultSupplierPartyId;
    final nextDefault = cleaned.isEmpty
        ? null
        : (currentDefault != null && cleaned.contains(currentDefault)
              ? currentDefault
              : cleaned.first);
    state = state.copyWith(
      supplierPartyIds: cleaned,
      supplierRows: rows,
      defaultSupplierPartyId: nextDefault,
      clearDefaultSupplier: nextDefault == null,
      isDirty: true,
    );
  }

  void updateSupplierRow(ItemSupplierFormRow row) {
    state = state.copyWith(
      supplierRows: state.supplierRows
          .map((existing) => existing.partyId == row.partyId ? row : existing)
          .toList(),
      isDirty: true,
    );
  }

  void removeSupplierRow(String partyId) {
    final nextIds = state.supplierPartyIds
        .where((id) => id != partyId)
        .toList();
    final nextRows = state.supplierRows
        .where((row) => row.partyId != partyId)
        .toList();
    final nextDefault = state.defaultSupplierPartyId == partyId
        ? (nextIds.isEmpty ? null : nextIds.first)
        : state.defaultSupplierPartyId;
    state = state.copyWith(
      supplierPartyIds: nextIds,
      supplierRows: nextRows,
      defaultSupplierPartyId: nextDefault,
      clearDefaultSupplier: nextDefault == null,
      isDirty: true,
    );
  }

  SuppliersProductSnapshot _suppliersSnapshotFromState() {
    return SuppliersProductSnapshot(
      productImageUrl: state.primaryImageUrl,
      brandName: '',
      mrp: state.mrp,
      pricing: state.atPrice,
      minOrderQuantity: state.minWholesaleQty,
      productNotes: state.description,
    );
  }

  ItemSupplierFormRow _newSupplierRow({
    required String partyId,
    required SuppliersProductSnapshot snapshot,
    required String productImageUrl,
    PartyModel? party,
  }) {
    final moq =
        snapshot.minOrderQuantity > 0 ? snapshot.minOrderQuantity : 1.0;
    final partyNotes = party?.notes.trim() ?? '';
    final notes = snapshot.productNotes.trim().isNotEmpty
        ? snapshot.productNotes.trim()
        : partyNotes;
    return ItemSupplierFormRow(
      partyId: partyId,
      productImageUrl: productImageUrl,
      brandName: snapshot.brandName.trim(),
      mrp: snapshot.mrp,
      pricing: snapshot.pricing,
      minOrderQuantity: moq,
      paymentPolicy: _inferPaymentPolicy(party),
      notes: notes,
      sellerAddress: _formatSellerAddress(party),
    );
  }

  String _inferPaymentPolicy(PartyModel? party) {
    if (party == null) return '';
    if (party.hasCustomCreditLimit && (double.tryParse(party.creditLimit) ?? 0) > 0) {
      return 'Credit';
    }
    return 'Net 30';
  }

  String _formatSellerAddress(PartyModel? party) {
    if (party == null) return '';
    final structured = [
      party.addressLine,
      party.city,
      party.state,
      party.pincode,
    ].where((part) => part.trim().isNotEmpty).join(', ');
    if (structured.isNotEmpty) return structured;
    final billing = party.billingAddress.trim();
    if (billing.isNotEmpty) return billing;
    return party.shippingAddress.trim();
  }

  void setDefaultSupplierPartyId(String? partyId) {
    if (partyId != null && !state.supplierPartyIds.contains(partyId)) return;
    state = state.copyWith(
      defaultSupplierPartyId: partyId,
      clearDefaultSupplier: partyId == null,
      isDirty: true,
    );
  }

  void updateHsn(String value) {
    state = state.copyWith(hsn: value, isDirty: true);
  }

  void updateItemCode(String value) {
    final digitsOnly = value.replaceAll(RegExp(r'\D'), '');
    state = state.copyWith(itemCode: digitsOnly, isDirty: true);
  }

  void assignCode() {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final randomDigits = _uuid
        .v4()
        .replaceAll(RegExp(r'\D'), '')
        .padRight(4, '0');
    final code = '$timestamp${randomDigits.substring(0, 4)}';
    state = state.copyWith(itemCode: code, isDirty: true);
  }

  void setUnits({String? baseUnitId, String? secondaryUnitId}) {
    final resolvedSecondary =
        secondaryUnitId != null &&
            baseUnitId != null &&
            secondaryUnitId == baseUnitId
        ? null
        : secondaryUnitId;

    final allowedMinQtyUnits = {
      if (baseUnitId != null) baseUnitId,
      if (resolvedSecondary != null) resolvedSecondary,
    };
    var minWholesaleQtyUnitId = state.minWholesaleQtyUnitId;
    if (minWholesaleQtyUnitId != null &&
        !allowedMinQtyUnits.contains(minWholesaleQtyUnitId)) {
      minWholesaleQtyUnitId = baseUnitId;
    }
    var openingQtyUnitId = state.openingQtyUnitId;
    if (openingQtyUnitId != null &&
        !allowedMinQtyUnits.contains(openingQtyUnitId)) {
      openingQtyUnitId = baseUnitId;
    }
    var minStockUnitId = state.minStockUnitId;
    if (minStockUnitId != null && !allowedMinQtyUnits.contains(minStockUnitId)) {
      minStockUnitId = baseUnitId;
    }
    if (baseUnitId == null) {
      minWholesaleQtyUnitId = null;
      openingQtyUnitId = null;
      minStockUnitId = null;
    }

    state = state.copyWith(
      baseUnitId: baseUnitId,
      secondaryUnitId: resolvedSecondary,
      minWholesaleQtyUnitId: minWholesaleQtyUnitId,
      openingQtyUnitId: openingQtyUnitId,
      minStockUnitId: minStockUnitId,
      clearMinWholesaleQtyUnit: baseUnitId == null,
      clearOpeningQtyUnit: baseUnitId == null,
      clearMinStockUnit: baseUnitId == null,
      baseUnitError: false,
      clearFieldErrors: true,
      isDirty: true,
    );
  }

  void setCategory(String? categoryId) {
    state = state.copyWith(
      categoryId: categoryId,
      clearCategory: categoryId == null,
      isDirty: true,
    );
  }

  void setBrand(String? brandId) {
    state = state.copyWith(
      brandId: brandId,
      clearBrand: brandId == null,
      isDirty: true,
    );
  }

  void setGodown(String? godownId) {
    state = state.copyWith(
      godownId: godownId,
      clearGodown: godownId == null,
      isDirty: true,
    );
  }

  void updatePrimaryImageUrl(String value) {
    state = state.copyWith(primaryImageUrl: value, isDirty: true);
  }

  void updateDescription(String value) {
    state = state.copyWith(description: value, isDirty: true);
  }

  void setActiveTab(int index) {
    state = state.copyWith(activeTab: index);
  }

  void updateMrp(double value) {
    final mrp = ItemPriceLimits.clamp(value);
    final salePrice = _salePriceFromMrpDiscount(mrp: mrp);
    state = state.copyWith(
      mrp: mrp,
      salePrice: salePrice,
      isDirty: true,
    );
  }

  void updateMrpSaleDiscount(double value) {
    final salePrice = _salePriceFromMrpDiscount(
      mrp: state.mrp,
      discount: value,
      kind: state.mrpSaleDiscountKind,
    );
    state = state.copyWith(
      mrpSaleDiscount: value,
      salePrice: salePrice,
      isDirty: true,
    );
  }

  void setMrpSaleDiscountKind(PriceDiscountKind kind) {
    final salePrice = _salePriceFromMrpDiscount(
      mrp: state.mrp,
      discount: state.mrpSaleDiscount,
      kind: kind,
    );
    state = state.copyWith(
      mrpSaleDiscountKind: kind,
      salePrice: salePrice,
      isDirty: true,
    );
  }

  void updateSalePrice(double value) {
    final salePrice = ItemPriceLimits.clamp(value);
    final mrpDiscount = state.mrp > 0
        ? ItemPricingDiscount.percentFromMrp(mrp: state.mrp, salePrice: salePrice)
        : state.mrpSaleDiscount;
    state = state.copyWith(
      salePrice: salePrice,
      mrpSaleDiscount: mrpDiscount,
      isDirty: true,
    );
  }

  void updateSalePriceDiscount(double value) {
    state = state.copyWith(salePriceDiscount: value, isDirty: true);
  }

  void setSalePriceDiscountKind(PriceDiscountKind kind) {
    state = state.copyWith(salePriceDiscountKind: kind, isDirty: true);
  }

  void syncMrpSaleDiscountFromPrices() {
    if (state.mrp <= 0 || state.salePrice <= 0) return;
    state = state.copyWith(
      mrpSaleDiscount: ItemPricingDiscount.percentFromMrp(
        mrp: state.mrp,
        salePrice: state.salePrice,
      ),
      isDirty: true,
    );
  }

  double _salePriceFromMrpDiscount({
    double? mrp,
    double? discount,
    PriceDiscountKind? kind,
  }) {
    final resolvedMrp = mrp ?? state.mrp;
    final resolvedDiscount = discount ?? state.mrpSaleDiscount;
    final resolvedKind = kind ?? state.mrpSaleDiscountKind;
    if (resolvedMrp <= 0 || resolvedDiscount <= 0) {
      return state.salePrice;
    }
    return ItemPriceLimits.clamp(
      ItemPricingDiscount.saleFromMrp(
        mrp: resolvedMrp,
        discount: resolvedDiscount,
        kind: resolvedKind,
      ),
    );
  }

  void setSalePriceTaxMode(PriceTaxMode mode) {
    state = state.copyWith(salePriceTaxMode: mode, isDirty: true);
  }

  void updateWholesalePrice(double value) {
    final price = ItemPriceLimits.clamp(value);
    state = state.copyWith(
      wholesalePrice: price,
      wholesaleSectionVisible: true,
      tierPrices: _upsertTierPrice(state.tierPrices, PriceTier.wholesale, price),
      isDirty: true,
    );
  }

  void enableWholesaleSection() {
    final tiers = state.tierPrices;
    final hasWholesaleRow = tiers.any((row) => row.tierKey == PriceTier.wholesale);
    state = state.copyWith(
      wholesaleSectionVisible: true,
      tierPrices: hasWholesaleRow
          ? tiers
          : [
              ...tiers,
              ItemTierPriceRow(
                id: _nextRowId(),
                tierKey: PriceTier.wholesale,
                price: state.wholesalePrice,
              ),
            ],
      isDirty: true,
    );
  }

  List<ItemTierPriceRow> _upsertTierPrice(
    List<ItemTierPriceRow> rows,
    String tierKey,
    double price,
  ) {
    final index = rows.indexWhere((row) => row.tierKey == tierKey);
    if (index >= 0) {
      return rows
          .map(
            (row) => row.tierKey == tierKey
                ? row.copyWith(price: price)
                : row,
          )
          .toList();
    }
    return [
      ...rows,
      ItemTierPriceRow(id: _nextRowId(), tierKey: tierKey, price: price),
    ];
  }

  void setWholesalePriceTaxMode(PriceTaxMode mode) {
    state = state.copyWith(wholesalePriceTaxMode: mode, isDirty: true);
  }

  void updateMinWholesaleQty(double value) {
    state = state.copyWith(minWholesaleQty: value, isDirty: true);
  }

  void updateMinWholesaleQtyUnitId(String unitId) {
    state = state.copyWith(minWholesaleQtyUnitId: unitId, isDirty: true);
  }

  void setOpeningQtyUnitId(String unitId) {
    state = state.copyWith(openingQtyUnitId: unitId, isDirty: true);
  }

  void setMinStockUnitId(String unitId) {
    state = state.copyWith(minStockUnitId: unitId, isDirty: true);
  }

  void updateOpeningQty(double value) {
    state = state.copyWith(openingQty: value, isDirty: true);
  }

  void updateAtPrice(double value) {
    state = state.copyWith(
      atPrice: ItemPriceLimits.clamp(value),
      isDirty: true,
    );
  }

  void setPurchasePriceTaxMode(PriceTaxMode mode) {
    state = state.copyWith(purchasePriceTaxMode: mode, isDirty: true);
  }

  void setTaxRate(String value) {
    state = state.copyWith(taxRate: value, isDirty: true);
  }

  void setAsOfDate(DateTime date) {
    state = state.copyWith(asOfDate: date, isDirty: true);
  }

  void updateMinStock(double value) {
    state = state.copyWith(minStock: value, isDirty: true);
  }

  void updateLocation(String value) {
    state = state.copyWith(location: value, isDirty: true);
  }

  void updateOnlineStorePrice(double value) {
    state = state.copyWith(onlineStorePrice: value, isDirty: true);
  }

  void updateOnlineStoreDescription(String value) {
    state = state.copyWith(onlineStoreDescription: value, isDirty: true);
  }

  void updateRawMaterial(
    String id, {
    String? rawItemId,
    bool clearRawItemId = false,
    String? itemName,
    double? qty,
    String? unitId,
    bool clearUnitId = false,
    String? unitLabel,
    double? purchasePrice,
  }) {
    state = state.copyWith(
      rawMaterials: state.rawMaterials
          .map(
            (row) => row.id == id
                ? row.copyWith(
                    rawItemId: rawItemId,
                    clearRawItemId: clearRawItemId,
                    itemName: itemName,
                    qty: qty,
                    unitId: unitId,
                    clearUnitId: clearUnitId,
                    unitLabel: unitLabel,
                    purchasePrice: purchasePrice,
                  )
                : row,
          )
          .toList(),
      isDirty: true,
    );
  }

  void selectRawMaterialItem(String id, SaleItemOption item) {
    state = state.copyWith(
      rawMaterials: state.rawMaterials
          .map(
            (row) => row.id == id
                ? row.copyWith(
                    rawItemId: item.id,
                    itemName: item.name,
                    unitLabel: saleItemDefaultUnit(item),
                    purchasePrice: item.purchasePrice,
                  )
                : row,
          )
          .toList(),
      isDirty: true,
    );
  }

  void setBomRows({
    required List<RawMaterialRow> rawMaterials,
    required List<AdditionalCostRow> additionalCosts,
  }) {
    state = state.copyWith(
      rawMaterials: rawMaterials,
      additionalCosts: additionalCosts,
      isDirty: true,
    );
  }

  void setBomFromModel(ItemBomModel bom) {
    final rows = AddItemFormMapper.bomToFormRows(bom);
    setBomRows(
      rawMaterials: rows.rawMaterials,
      additionalCosts: rows.additionalCosts,
    );
  }

  void addRawMaterialRow() {
    state = state.copyWith(
      rawMaterials: [
        ...state.rawMaterials,
        RawMaterialRow(id: _nextRowId()),
      ],
      isDirty: true,
    );
  }

  void removeRawMaterialRow(String id) {
    if (state.rawMaterials.length <= 1) return;
    state = state.copyWith(
      rawMaterials: state.rawMaterials.where((row) => row.id != id).toList(),
      isDirty: true,
    );
  }

  void addAdditionalCost() {
    state = state.copyWith(
      additionalCosts: [
        ...state.additionalCosts,
        AdditionalCostRow(id: _nextRowId()),
      ],
      isDirty: true,
    );
  }

  void updateAdditionalCost(
    String id, {
    String? description,
    double? amount,
  }) {
    state = state.copyWith(
      additionalCosts: state.additionalCosts
          .map(
            (row) => row.id == id
                ? row.copyWith(description: description, amount: amount)
                : row,
          )
          .toList(),
      isDirty: true,
    );
  }

  void removeAdditionalCost(String id) {
    state = state.copyWith(
      additionalCosts: state.additionalCosts
          .where((row) => row.id != id)
          .toList(),
      isDirty: true,
    );
  }

  void addTierPriceRow() {
    final used = state.tierPrices.map((row) => row.tierKey).toSet();
    final available = PriceTier.availableTiersExcept(used);
    if (available.isEmpty) return;

    state = state.copyWith(
      tierPrices: [
        ...state.tierPrices,
        ItemTierPriceRow(id: _nextRowId(), tierKey: available.first),
      ],
      isDirty: true,
    );
  }

  void updateTierPriceRow(
    String id, {
    String? tierKey,
    double? price,
  }) {
    final updated = state.tierPrices
        .map(
          (row) => row.id == id
              ? row.copyWith(
                  tierKey: tierKey,
                  price: price == null ? null : ItemPriceLimits.clamp(price),
                )
              : row,
        )
        .toList();
    var wholesalePrice = state.wholesalePrice;
    var hasWholesaleRow = false;
    for (final row in updated) {
      if (row.tierKey == PriceTier.wholesale) {
        hasWholesaleRow = true;
        wholesalePrice = row.price;
      }
    }
    state = state.copyWith(
      tierPrices: updated,
      wholesalePrice: ItemPriceLimits.clamp(wholesalePrice),
      wholesaleSectionVisible: state.wholesaleSectionVisible || hasWholesaleRow,
      isDirty: true,
    );
  }

  void removeTierPriceRow(String id) {
    state = state.copyWith(
      tierPrices: state.tierPrices.where((row) => row.id != id).toList(),
      isDirty: true,
    );
  }

  void setTierPrices(List<ItemTierPriceRow> rows) {
    state = state.copyWith(tierPrices: rows, isDirty: true);
  }

  void ensureAllTierRows() {
    final used = state.tierPrices.map((row) => row.tierKey).toSet();
    final missing = PriceTier.all.where((tier) => !used.contains(tier)).toList();
    if (missing.isEmpty) return;
    state = state.copyWith(
      tierPrices: [
        ...state.tierPrices,
        for (final tier in missing)
          ItemTierPriceRow(id: _nextRowId(), tierKey: tier),
      ],
      isDirty: true,
    );
  }

  bool validate() {
    final nameMissing = state.itemName.trim().isEmpty;
    // Services can fall back to a default unit; products must pick one.
    final unitMissing = state.itemType == ItemType.product &&
        (state.baseUnitId == null || state.baseUnitId!.isEmpty);

    state = state.copyWith(
      itemNameError: nameMissing,
      baseUnitError: unitMissing,
      clearFieldErrors: true,
    );
    return !nameMissing && !unitMissing;
  }

  /// Maps API / service validation onto form fields. Returns true when at least
  /// one visible field was marked so the UI can skip a global toast.
  bool applyFieldErrors(Map<String, String> errors) {
    if (errors.isEmpty) return false;

    var nameError = false;
    var unitError = false;
    for (final entry in errors.entries) {
      final key = entry.key.toLowerCase();
      if (key == 'name' || key == 'item_name') {
        nameError = true;
      } else if (key.contains('base_unit') || key == 'unit') {
        unitError = true;
      }
    }

    state = state.copyWith(
      itemNameError: nameError || state.itemNameError,
      baseUnitError: unitError || state.baseUnitError,
      fieldErrors: errors,
    );
    return nameError || unitError;
  }

  /// Maps known client/service exception messages onto form fields.
  bool applyExceptionMessage(String message) {
    final lower = message.toLowerCase();
    if (lower.contains('base unit')) {
      state = state.copyWith(baseUnitError: true);
      return true;
    }
    if (lower.contains('item name') ||
        lower.contains('name is required') ||
        lower.contains('service name')) {
      state = state.copyWith(itemNameError: true);
      return true;
    }
    return false;
  }

  void clearErrors() {
    state = state.copyWith(
      itemNameError: false,
      baseUnitError: false,
      clearFieldErrors: true,
    );
  }

  void reset({ItemType? itemType}) {
    final now = DateTime.now();
    state = AddItemFormState(
      itemType: itemType ?? state.itemType,
      asOfDate: DateTime(now.year, now.month, now.day),
      rawMaterials: [
        RawMaterialRow(id: _nextRowId()),
        RawMaterialRow(id: _nextRowId()),
      ],
    );
  }
}
