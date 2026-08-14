import 'package:billing_baba/features/inventory/models/add_item_form_model.dart';
import 'package:billing_baba/features/inventory/models/item_bom_model.dart';
import 'package:billing_baba/features/inventory/models/item_model.dart';
import 'package:billing_baba/features/inventory/models/mappers/add_item_form_mapper.dart';
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
    final cleaned = partyIds
        .map((id) => id.trim())
        .where((id) => id.isNotEmpty)
        .toList();
    final currentDefault = state.defaultSupplierPartyId;
    final nextDefault = cleaned.isEmpty
        ? null
        : (currentDefault != null && cleaned.contains(currentDefault)
              ? currentDefault
              : cleaned.first);
    state = state.copyWith(
      supplierPartyIds: cleaned,
      defaultSupplierPartyId: nextDefault,
      clearDefaultSupplier: nextDefault == null,
      isDirty: true,
    );
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
    state = state.copyWith(
      baseUnitId: baseUnitId,
      secondaryUnitId: secondaryUnitId,
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
    state = state.copyWith(mrp: value, isDirty: true);
  }

  void updateSalePrice(double value) {
    state = state.copyWith(salePrice: value, isDirty: true);
  }

  void setSalePriceTaxMode(PriceTaxMode mode) {
    state = state.copyWith(salePriceTaxMode: mode, isDirty: true);
  }

  void updateWholesalePrice(double value) {
    state = state.copyWith(wholesalePrice: value, isDirty: true);
  }

  void setWholesalePriceTaxMode(PriceTaxMode mode) {
    state = state.copyWith(wholesalePriceTaxMode: mode, isDirty: true);
  }

  void updateMinWholesaleQty(double value) {
    state = state.copyWith(minWholesaleQty: value, isDirty: true);
  }

  void updateOpeningQty(double value) {
    state = state.copyWith(openingQty: value, isDirty: true);
  }

  void updateAtPrice(double value) {
    state = state.copyWith(atPrice: value, isDirty: true);
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
    state = state.copyWith(
      tierPrices: state.tierPrices
          .map(
            (row) => row.id == id
                ? row.copyWith(tierKey: tierKey, price: price)
                : row,
          )
          .toList(),
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
