enum ItemTypeScope {
  productsAndServices,
  productsOnly,
  servicesOnly,
}

enum BarcodeScannerType {
  usbScanner,
  phoneCamera,
}

extension ItemTypeScopeX on ItemTypeScope {
  String get label => switch (this) {
    ItemTypeScope.productsAndServices => 'Products and Services',
    ItemTypeScope.productsOnly => 'Products Only',
    ItemTypeScope.servicesOnly => 'Services Only',
  };

  String get storageKey => switch (this) {
    ItemTypeScope.productsAndServices => 'products_and_services',
    ItemTypeScope.productsOnly => 'products_only',
    ItemTypeScope.servicesOnly => 'services_only',
  };

  static ItemTypeScope fromStorageKey(String? key) =>
      ItemTypeScope.values.firstWhere(
        (value) => value.storageKey == key,
        orElse: () => ItemTypeScope.productsAndServices,
      );
}

extension BarcodeScannerTypeX on BarcodeScannerType {
  String get label => switch (this) {
    BarcodeScannerType.usbScanner => 'USB Scanner',
    BarcodeScannerType.phoneCamera => 'Phone camera',
  };

  String get storageKey => switch (this) {
    BarcodeScannerType.usbScanner => 'usb_scanner',
    BarcodeScannerType.phoneCamera => 'phone_camera',
  };

  static BarcodeScannerType fromStorageKey(String? key) =>
      BarcodeScannerType.values.firstWhere(
        (value) => value.storageKey == key,
        orElse: () => BarcodeScannerType.phoneCamera,
      );
}

typedef ItemSettingsUpdater = ItemSettings Function(ItemSettings settings);

/// Business-level item feature toggles and defaults.
class ItemSettings {
  const ItemSettings({
    required this.enableItem,
    required this.itemTypeScope,
    required this.barcodeScanningEnabled,
    required this.mobilePosDefaultBilling,
    required this.barcodeScannerType,
    required this.stockMaintenance,
    required this.manufacturing,
    required this.itemUnits,
    required this.defaultUnitEnabled,
    required this.defaultUnitId,
    required this.itemCategory,
    required this.partyWiseItemRate,
    required this.wholesalePrice,
    required this.quantityDecimalPlaces,
    required this.itemWiseTax,
    required this.calculateTaxBasedOnMrp,
    required this.itemWiseDiscount,
    required this.updateSalePriceFromTxn,
    required this.descriptionEnabled,
    required this.descriptionText,
    required this.hsnSacCode,
    required this.additionalCess,
  });

  factory ItemSettings.defaults() => const ItemSettings(
    enableItem: true,
    itemTypeScope: ItemTypeScope.productsAndServices,
    barcodeScanningEnabled: true,
    mobilePosDefaultBilling: false,
    barcodeScannerType: BarcodeScannerType.phoneCamera,
    stockMaintenance: true,
    manufacturing: true,
    itemUnits: true,
    defaultUnitEnabled: true,
    defaultUnitId: null,
    itemCategory: true,
    partyWiseItemRate: true,
    wholesalePrice: true,
    quantityDecimalPlaces: 2,
    itemWiseTax: true,
    calculateTaxBasedOnMrp: false,
    itemWiseDiscount: false,
    updateSalePriceFromTxn: true,
    descriptionEnabled: true,
    descriptionText: '',
    hsnSacCode: true,
    additionalCess: false,
  );

  factory ItemSettings.fromJson(Map<String, dynamic> json) {
    final defaults = ItemSettings.defaults();

    return ItemSettings(
      enableItem: json['enable_item'] as bool? ?? defaults.enableItem,
      itemTypeScope: ItemTypeScopeX.fromStorageKey(
        json['item_type_scope'] as String?,
      ),
      barcodeScanningEnabled:
          json['barcode_scanning_enabled'] as bool? ??
          defaults.barcodeScanningEnabled,
      mobilePosDefaultBilling:
          json['mobile_pos_default_billing'] as bool? ??
          defaults.mobilePosDefaultBilling,
      barcodeScannerType: BarcodeScannerTypeX.fromStorageKey(
        json['barcode_scanner_type'] as String?,
      ),
      stockMaintenance:
          json['stock_maintenance'] as bool? ?? defaults.stockMaintenance,
      manufacturing: json['manufacturing'] as bool? ?? defaults.manufacturing,
      itemUnits: json['item_units'] as bool? ?? defaults.itemUnits,
      defaultUnitEnabled:
          json['default_unit_enabled'] as bool? ?? defaults.defaultUnitEnabled,
      defaultUnitId: json['default_unit_id'] as String?,
      itemCategory: json['item_category'] as bool? ?? defaults.itemCategory,
      partyWiseItemRate:
          json['party_wise_item_rate'] as bool? ?? defaults.partyWiseItemRate,
      wholesalePrice:
          json['wholesale_price'] as bool? ?? defaults.wholesalePrice,
      quantityDecimalPlaces:
          json['quantity_decimal_places'] as int? ??
          defaults.quantityDecimalPlaces,
      itemWiseTax: json['item_wise_tax'] as bool? ?? defaults.itemWiseTax,
      calculateTaxBasedOnMrp:
          json['calculate_tax_based_on_mrp'] as bool? ??
          defaults.calculateTaxBasedOnMrp,
      itemWiseDiscount:
          json['item_wise_discount'] as bool? ?? defaults.itemWiseDiscount,
      updateSalePriceFromTxn:
          json['update_sale_price_from_txn'] as bool? ??
          defaults.updateSalePriceFromTxn,
      descriptionEnabled:
          json['description_enabled'] as bool? ?? defaults.descriptionEnabled,
      descriptionText:
          json['description_text'] as String? ?? defaults.descriptionText,
      hsnSacCode: json['hsn_sac_code'] as bool? ?? defaults.hsnSacCode,
      additionalCess:
          json['additional_cess'] as bool? ?? defaults.additionalCess,
    );
  }

  final bool enableItem;
  final ItemTypeScope itemTypeScope;
  final bool barcodeScanningEnabled;
  final bool mobilePosDefaultBilling;
  final BarcodeScannerType barcodeScannerType;
  final bool stockMaintenance;
  final bool manufacturing;
  final bool itemUnits;
  final bool defaultUnitEnabled;
  final String? defaultUnitId;
  final bool itemCategory;
  final bool partyWiseItemRate;
  final bool wholesalePrice;
  final int quantityDecimalPlaces;
  final bool itemWiseTax;
  final bool calculateTaxBasedOnMrp;
  final bool itemWiseDiscount;
  final bool updateSalePriceFromTxn;
  final bool descriptionEnabled;
  final String descriptionText;
  final bool hsnSacCode;
  final bool additionalCess;

  Map<String, dynamic> toJson() => {
    'enable_item': enableItem,
    'item_type_scope': itemTypeScope.storageKey,
    'barcode_scanning_enabled': barcodeScanningEnabled,
    'mobile_pos_default_billing': mobilePosDefaultBilling,
    'barcode_scanner_type': barcodeScannerType.storageKey,
    'stock_maintenance': stockMaintenance,
    'manufacturing': manufacturing,
    'item_units': itemUnits,
    'default_unit_enabled': defaultUnitEnabled,
    'default_unit_id': defaultUnitId,
    'item_category': itemCategory,
    'party_wise_item_rate': partyWiseItemRate,
    'wholesale_price': wholesalePrice,
    'quantity_decimal_places': quantityDecimalPlaces,
    'item_wise_tax': itemWiseTax,
    'calculate_tax_based_on_mrp': calculateTaxBasedOnMrp,
    'item_wise_discount': itemWiseDiscount,
    'update_sale_price_from_txn': updateSalePriceFromTxn,
    'description_enabled': descriptionEnabled,
    'description_text': descriptionText,
    'hsn_sac_code': hsnSacCode,
    'additional_cess': additionalCess,
  };

  ItemSettings copyWith({
    bool? enableItem,
    ItemTypeScope? itemTypeScope,
    bool? barcodeScanningEnabled,
    bool? mobilePosDefaultBilling,
    BarcodeScannerType? barcodeScannerType,
    bool? stockMaintenance,
    bool? manufacturing,
    bool? itemUnits,
    bool? defaultUnitEnabled,
    String? defaultUnitId,
    bool clearDefaultUnitId = false,
    bool? itemCategory,
    bool? partyWiseItemRate,
    bool? wholesalePrice,
    int? quantityDecimalPlaces,
    bool? itemWiseTax,
    bool? calculateTaxBasedOnMrp,
    bool? itemWiseDiscount,
    bool? updateSalePriceFromTxn,
    bool? descriptionEnabled,
    String? descriptionText,
    bool? hsnSacCode,
    bool? additionalCess,
  }) {
    return ItemSettings(
      enableItem: enableItem ?? this.enableItem,
      itemTypeScope: itemTypeScope ?? this.itemTypeScope,
      barcodeScanningEnabled:
          barcodeScanningEnabled ?? this.barcodeScanningEnabled,
      mobilePosDefaultBilling:
          mobilePosDefaultBilling ?? this.mobilePosDefaultBilling,
      barcodeScannerType: barcodeScannerType ?? this.barcodeScannerType,
      stockMaintenance: stockMaintenance ?? this.stockMaintenance,
      manufacturing: manufacturing ?? this.manufacturing,
      itemUnits: itemUnits ?? this.itemUnits,
      defaultUnitEnabled: defaultUnitEnabled ?? this.defaultUnitEnabled,
      defaultUnitId: clearDefaultUnitId
          ? null
          : (defaultUnitId ?? this.defaultUnitId),
      itemCategory: itemCategory ?? this.itemCategory,
      partyWiseItemRate: partyWiseItemRate ?? this.partyWiseItemRate,
      wholesalePrice: wholesalePrice ?? this.wholesalePrice,
      quantityDecimalPlaces:
          quantityDecimalPlaces ?? this.quantityDecimalPlaces,
      itemWiseTax: itemWiseTax ?? this.itemWiseTax,
      calculateTaxBasedOnMrp:
          calculateTaxBasedOnMrp ?? this.calculateTaxBasedOnMrp,
      itemWiseDiscount: itemWiseDiscount ?? this.itemWiseDiscount,
      updateSalePriceFromTxn:
          updateSalePriceFromTxn ?? this.updateSalePriceFromTxn,
      descriptionEnabled: descriptionEnabled ?? this.descriptionEnabled,
      descriptionText: descriptionText ?? this.descriptionText,
      hsnSacCode: hsnSacCode ?? this.hsnSacCode,
      additionalCess: additionalCess ?? this.additionalCess,
    );
  }
}
