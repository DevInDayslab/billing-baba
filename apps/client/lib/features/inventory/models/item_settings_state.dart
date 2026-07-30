/// Which item types are enabled in the business.
enum ItemTypeSetting {
  products('Products'),
  services('Services'),
  productsAndServices('Products & Services');

  const ItemTypeSetting(this.label);

  final String label;

  static ItemTypeSetting fromStorage(String? value) {
    return ItemTypeSetting.values.firstWhere(
      (entry) => entry.name == value,
      orElse: () => ItemTypeSetting.productsAndServices,
    );
  }
}

/// Barcode scanner hardware source.
enum ItemScannerType {
  usb('USB'),
  phoneCamera('Phone Camera');

  const ItemScannerType(this.label);

  final String label;

  static ItemScannerType fromStorage(String? value) {
    return ItemScannerType.values.firstWhere(
      (entry) => entry.name == value,
      orElse: () => ItemScannerType.phoneCamera,
    );
  }
}

/// Immutable device-local item module preferences.
class ItemSettingsState {
  const ItemSettingsState({
    required this.enableItem,
    required this.itemType,
    required this.barcodeScanning,
    required this.mobilePosDefaultScanner,
    required this.scannerType,
    required this.stockMaintenance,
    required this.manufacturing,
    required this.itemUnits,
    required this.defaultUnit,
    required this.defaultUnitName,
    required this.itemCategory,
    required this.partyWiseItemRate,
    required this.wholesalePrice,
    required this.quantityDecimalPlaces,
    required this.itemWiseTax,
    required this.calculateTaxOnMrp,
    required this.itemWiseDiscount,
    required this.updateSalePriceFromTxn,
    required this.descriptionEnabled,
    required this.descriptionText,
    required this.hsnSacCode,
    required this.additionalCess,
  });

  factory ItemSettingsState.defaults() {
    return const ItemSettingsState(
      enableItem: true,
      itemType: ItemTypeSetting.productsAndServices,
      barcodeScanning: true,
      mobilePosDefaultScanner: true,
      scannerType: ItemScannerType.phoneCamera,
      stockMaintenance: true,
      manufacturing: false,
      itemUnits: true,
      defaultUnit: true,
      defaultUnitName: 'Pcs',
      itemCategory: true,
      partyWiseItemRate: false,
      wholesalePrice: false,
      quantityDecimalPlaces: 2,
      itemWiseTax: true,
      calculateTaxOnMrp: false,
      itemWiseDiscount: true,
      updateSalePriceFromTxn: false,
      descriptionEnabled: true,
      descriptionText: '',
      hsnSacCode: true,
      additionalCess: false,
    );
  }

  final bool enableItem;
  final ItemTypeSetting itemType;
  final bool barcodeScanning;
  final bool mobilePosDefaultScanner;
  final ItemScannerType scannerType;
  final bool stockMaintenance;
  final bool manufacturing;
  final bool itemUnits;
  final bool defaultUnit;
  final String defaultUnitName;
  final bool itemCategory;
  final bool partyWiseItemRate;
  final bool wholesalePrice;
  final int quantityDecimalPlaces;
  final bool itemWiseTax;
  final bool calculateTaxOnMrp;
  final bool itemWiseDiscount;
  final bool updateSalePriceFromTxn;
  final bool descriptionEnabled;
  final String descriptionText;
  final bool hsnSacCode;
  final bool additionalCess;

  bool get controlsEnabled => enableItem;

  bool get barcodeChildrenEnabled => enableItem && barcodeScanning;

  bool get itemUnitsChildrenEnabled => enableItem && itemUnits;

  bool get defaultUnitNavigationEnabled =>
      enableItem && itemUnits && defaultUnit;

  bool get taxChildrenEnabled => enableItem && itemWiseTax;

  ItemSettingsState copyWith({
    bool? enableItem,
    ItemTypeSetting? itemType,
    bool? barcodeScanning,
    bool? mobilePosDefaultScanner,
    ItemScannerType? scannerType,
    bool? stockMaintenance,
    bool? manufacturing,
    bool? itemUnits,
    bool? defaultUnit,
    String? defaultUnitName,
    bool? itemCategory,
    bool? partyWiseItemRate,
    bool? wholesalePrice,
    int? quantityDecimalPlaces,
    bool? itemWiseTax,
    bool? calculateTaxOnMrp,
    bool? itemWiseDiscount,
    bool? updateSalePriceFromTxn,
    bool? descriptionEnabled,
    String? descriptionText,
    bool? hsnSacCode,
    bool? additionalCess,
  }) {
    return ItemSettingsState(
      enableItem: enableItem ?? this.enableItem,
      itemType: itemType ?? this.itemType,
      barcodeScanning: barcodeScanning ?? this.barcodeScanning,
      mobilePosDefaultScanner:
          mobilePosDefaultScanner ?? this.mobilePosDefaultScanner,
      scannerType: scannerType ?? this.scannerType,
      stockMaintenance: stockMaintenance ?? this.stockMaintenance,
      manufacturing: manufacturing ?? this.manufacturing,
      itemUnits: itemUnits ?? this.itemUnits,
      defaultUnit: defaultUnit ?? this.defaultUnit,
      defaultUnitName: defaultUnitName ?? this.defaultUnitName,
      itemCategory: itemCategory ?? this.itemCategory,
      partyWiseItemRate: partyWiseItemRate ?? this.partyWiseItemRate,
      wholesalePrice: wholesalePrice ?? this.wholesalePrice,
      quantityDecimalPlaces:
          quantityDecimalPlaces ?? this.quantityDecimalPlaces,
      itemWiseTax: itemWiseTax ?? this.itemWiseTax,
      calculateTaxOnMrp: calculateTaxOnMrp ?? this.calculateTaxOnMrp,
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
