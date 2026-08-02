import 'package:billing_baba/features/inventory/models/add_item_form_model.dart';
import 'package:billing_baba/features/inventory/models/item_model.dart';
import 'package:billing_baba/features/pricing/models/price_tier.dart';
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
    state = state.copyWith(supplierPartyIds: partyIds, isDirty: true);
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

  void setTrackingMode(ItemTrackingMode mode) {
    state = state.copyWith(trackingMode: mode, isDirty: true);
  }

  void clearTracking() {
    state = state.copyWith(
      trackingMode: ItemTrackingMode.none,
      isDirty: true,
    );
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
    String? itemName,
    double? qty,
    String? unitLabel,
    double? purchasePrice,
  }) {
    state = state.copyWith(
      rawMaterials: state.rawMaterials
          .map(
            (row) => row.id == id
                ? row.copyWith(
                    itemName: itemName,
                    qty: qty,
                    unitLabel: unitLabel,
                    purchasePrice: purchasePrice,
                  )
                : row,
          )
          .toList(),
      isDirty: true,
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

  bool validate() {
    final isValid = state.itemName.trim().isNotEmpty;
    state = state.copyWith(itemNameError: !isValid);
    return isValid;
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
