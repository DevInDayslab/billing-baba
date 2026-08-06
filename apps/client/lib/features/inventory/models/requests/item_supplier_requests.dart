class ItemSupplierInput {
  const ItemSupplierInput({
    required this.partyId,
    this.isDefault = false,
    this.sortOrder = 0,
  });

  final String partyId;
  final bool isDefault;
  final int sortOrder;

  Map<String, dynamic> toJson() => {
    'party_id': partyId,
    'is_default': isDefault,
    'sort_order': sortOrder,
  };
}

class ReplaceItemSuppliersRequest {
  const ReplaceItemSuppliersRequest({required this.suppliers});

  final List<ItemSupplierInput> suppliers;

  Map<String, dynamic> toJson() => {
    'suppliers': suppliers.map((supplier) => supplier.toJson()).toList(),
  };
}
