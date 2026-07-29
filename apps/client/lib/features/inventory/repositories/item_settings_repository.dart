import 'dart:convert';

import 'package:billing_baba/core/constants/storage_keys.dart';
import 'package:billing_baba/core/services/storage_service.dart';
import 'package:billing_baba/features/inventory/models/item_settings_state.dart';

/// Local persistence for item settings. Swap implementation for API sync later.
abstract interface class ItemSettingsDataSource {
  Future<ItemSettingsState> load();

  Future<void> save(ItemSettingsState settings);
}

class ItemSettingsRepository implements ItemSettingsDataSource {
  ItemSettingsRepository(this._storage, this._businessId);

  final StorageService _storage;
  final String _businessId;

  String get _key => '${StorageKeys.itemSettings}_$_businessId.json';

  @override
  Future<ItemSettingsState> load() async {
    final raw = _storage.read(_key);
    if (raw == null || raw.isEmpty) {
      return ItemSettingsState.defaults();
    }

    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return _fromJson(json);
    } on Object {
      return ItemSettingsState.defaults();
    }
  }

  @override
  Future<void> save(ItemSettingsState settings) async {
    await _storage.write(_key, jsonEncode(_toJson(settings)));
  }

  Map<String, dynamic> _toJson(ItemSettingsState settings) {
    return {
      'enableItem': settings.enableItem,
      'itemType': settings.itemType.name,
      'barcodeScanning': settings.barcodeScanning,
      'mobilePosDefaultScanner': settings.mobilePosDefaultScanner,
      'scannerType': settings.scannerType.name,
      'stockMaintenance': settings.stockMaintenance,
      'manufacturing': settings.manufacturing,
      'itemUnits': settings.itemUnits,
      'defaultUnit': settings.defaultUnit,
      'defaultUnitName': settings.defaultUnitName,
      'itemCategory': settings.itemCategory,
      'partyWiseItemRate': settings.partyWiseItemRate,
      'wholesalePrice': settings.wholesalePrice,
      'quantityDecimalPlaces': settings.quantityDecimalPlaces,
      'itemWiseTax': settings.itemWiseTax,
      'calculateTaxOnMrp': settings.calculateTaxOnMrp,
      'itemWiseDiscount': settings.itemWiseDiscount,
      'updateSalePriceFromTxn': settings.updateSalePriceFromTxn,
      'descriptionEnabled': settings.descriptionEnabled,
      'descriptionText': settings.descriptionText,
      'hsnSacCode': settings.hsnSacCode,
      'additionalCess': settings.additionalCess,
    };
  }

  ItemSettingsState _fromJson(Map<String, dynamic> json) {
    final defaults = ItemSettingsState.defaults();

    return defaults.copyWith(
      enableItem: json['enableItem'] as bool? ?? defaults.enableItem,
      itemType: ItemTypeSetting.fromStorage(json['itemType'] as String?),
      barcodeScanning:
          json['barcodeScanning'] as bool? ?? defaults.barcodeScanning,
      mobilePosDefaultScanner: json['mobilePosDefaultScanner'] as bool? ??
          defaults.mobilePosDefaultScanner,
      scannerType:
          ItemScannerType.fromStorage(json['scannerType'] as String?),
      stockMaintenance:
          json['stockMaintenance'] as bool? ?? defaults.stockMaintenance,
      manufacturing: json['manufacturing'] as bool? ?? defaults.manufacturing,
      itemUnits: json['itemUnits'] as bool? ?? defaults.itemUnits,
      defaultUnit: json['defaultUnit'] as bool? ?? defaults.defaultUnit,
      defaultUnitName:
          json['defaultUnitName'] as String? ?? defaults.defaultUnitName,
      itemCategory: json['itemCategory'] as bool? ?? defaults.itemCategory,
      partyWiseItemRate:
          json['partyWiseItemRate'] as bool? ?? defaults.partyWiseItemRate,
      wholesalePrice:
          json['wholesalePrice'] as bool? ?? defaults.wholesalePrice,
      quantityDecimalPlaces: (json['quantityDecimalPlaces'] as num?)
              ?.toInt()
              .clamp(0, 4) ??
          defaults.quantityDecimalPlaces,
      itemWiseTax: json['itemWiseTax'] as bool? ?? defaults.itemWiseTax,
      calculateTaxOnMrp:
          json['calculateTaxOnMrp'] as bool? ?? defaults.calculateTaxOnMrp,
      itemWiseDiscount:
          json['itemWiseDiscount'] as bool? ?? defaults.itemWiseDiscount,
      updateSalePriceFromTxn: json['updateSalePriceFromTxn'] as bool? ??
          defaults.updateSalePriceFromTxn,
      descriptionEnabled:
          json['descriptionEnabled'] as bool? ?? defaults.descriptionEnabled,
      descriptionText:
          json['descriptionText'] as String? ?? defaults.descriptionText,
      hsnSacCode: json['hsnSacCode'] as bool? ?? defaults.hsnSacCode,
      additionalCess:
          json['additionalCess'] as bool? ?? defaults.additionalCess,
    );
  }
}
