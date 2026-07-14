import 'package:billing_baba/features/inventory/inventory_constants.dart';
import 'package:billing_baba/features/inventory/models/add_item_form_model.dart';
import 'package:billing_baba/features/inventory/models/item_model.dart';
import 'package:billing_baba/features/inventory/models/mappers/category_mapper.dart';
import 'package:billing_baba/features/inventory/models/requests/item_requests.dart';
import 'package:billing_baba/features/pricing/models/price_tier.dart';

abstract final class AddItemFormMapper {
  static CreateItemRequest toCreateRequest(
    AddItemFormState form, {
    required String baseUnitShortName,
    String? openingGodownId,
    String? godownIdForLocation,
  }) {
    final tierPrices = _tierPricesFromForm(form);
    final godownId = form.godownId ?? openingGodownId;
    final locationGodownId = form.godownId ?? godownIdForLocation;

    CreateItemLocationRequest? location;
    if (locationGodownId != null &&
        (form.location.isNotEmpty || form.minStock > 0)) {
      location = CreateItemLocationRequest(
        godownId: locationGodownId,
        rack: form.location.isNotEmpty ? form.location : null,
      );
    }

    final hasOpeningStock =
        form.itemType == ItemType.product && form.openingQty > 0;

    return CreateItemRequest(
      name: form.itemName.trim(),
      description: form.description.trim().isEmpty ? null : form.description.trim(),
      itemType: form.itemType == ItemType.service ? 'service' : 'product',
      hsnCode: form.hsn.trim().isEmpty ? null : form.hsn.trim(),
      barcode: form.itemCode.trim().isEmpty ? null : form.itemCode.trim(),
      categoryId: CategoryMapper.toApiCategoryId(form.categoryId),
      brandId: form.brandId,
      baseUnit: baseUnitShortName,
      salePrice: _formatMoney(form.salePrice),
      purchasePrice: _formatMoney(form.atPrice),
      mrp: form.mrp > 0 ? _formatMoney(form.mrp) : null,
      reorderLevel: form.minStock > 0 ? _formatMoney(form.minStock) : null,
      hasStockTracking: form.itemType == ItemType.product,
      tierPrices: tierPrices,
      primaryImageUrl: form.primaryImageUrl.trim().isEmpty
          ? null
          : form.primaryImageUrl.trim(),
      openingQuantity: hasOpeningStock ? _formatMoney(form.openingQty) : null,
      openingCostPerUnit: hasOpeningStock ? _formatMoney(form.atPrice) : null,
      openingGodownId: hasOpeningStock ? godownId : null,
      location: location,
    );
  }

  static UpdateItemRequest toUpdateRequest(
    AddItemFormState form, {
    required String baseUnitShortName,
    String? openingGodownId,
    String? godownIdForLocation,
  }) {
    final godownId = form.godownId ?? openingGodownId;
    final locationGodownId = form.godownId ?? godownIdForLocation;

    CreateItemLocationRequest? location;
    if (locationGodownId != null &&
        (form.location.isNotEmpty || form.minStock > 0)) {
      location = CreateItemLocationRequest(
        godownId: locationGodownId,
        rack: form.location.isNotEmpty ? form.location : null,
      );
    }

    final hasOpeningStock =
        form.itemType == ItemType.product && form.openingQty > 0;

    return UpdateItemRequest(
      name: form.itemName.trim(),
      description: form.description.trim(),
      itemType: form.itemType == ItemType.service ? 'service' : 'product',
      hsnCode: form.hsn.trim(),
      barcode: form.itemCode.trim(),
      categoryId: CategoryMapper.toApiCategoryId(form.categoryId),
      clearCategory:
          form.categoryId == null ||
          form.categoryId == uncategorizedCategoryId,
      brandId: form.brandId,
      clearBrand: form.brandId == null,
      baseUnit: baseUnitShortName,
      salePrice: _formatMoney(form.salePrice),
      purchasePrice: _formatMoney(form.atPrice),
      mrp: form.mrp > 0 ? _formatMoney(form.mrp) : null,
      reorderLevel: form.minStock > 0 ? _formatMoney(form.minStock) : '0',
      hasStockTracking: form.itemType == ItemType.product,
      primaryImageUrl: form.primaryImageUrl.trim().isEmpty
          ? null
          : form.primaryImageUrl.trim(),
      openingQuantity:
          hasOpeningStock ? _formatMoney(form.openingQty) : null,
      openingCostPerUnit:
          hasOpeningStock ? _formatMoney(form.atPrice) : null,
      openingGodownId: hasOpeningStock ? godownId : null,
      location: location,
    );
  }

  static List<CreateItemTierPriceRequest> tierPricesForUpsert(
    AddItemFormState form,
  ) => _tierPricesFromForm(form);

  static List<CreateItemTierPriceRequest> _tierPricesFromForm(
    AddItemFormState form,
  ) {
    final byApiTier = <String, String>{};

    void addTier(String apiTier, double price) {
      if (price <= 0) return;
      byApiTier[apiTier] = _formatMoney(price);
    }

    addTier('tier_1', form.salePrice);
    if (form.wholesalePrice > 0) {
      addTier('tier_2', form.wholesalePrice);
    }
    for (final row in form.tierPrices) {
      addTier(PriceTier.toApiTier(row.tierKey), row.price);
    }

    return byApiTier.entries
        .map(
          (entry) => CreateItemTierPriceRequest(
            pricingTier: entry.key,
            price: entry.value,
          ),
        )
        .toList();
  }

  static String _formatMoney(double value) {
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0);
    }
    return value.toStringAsFixed(2);
  }
}
