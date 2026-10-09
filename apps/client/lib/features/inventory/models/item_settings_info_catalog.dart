import 'package:billing_baba/features/settings/models/general_settings_info_catalog.dart';

enum ItemSettingsInfoKey {
  enableItem,
  whatDoYouSell,
  barcodeScan,
  directBarcodeScan,
  stockMaintenance,
  manufacturing,
  showLowStockDialog,
  itemsUnit,
  defaultUnit,
  itemCategory,
  partyWiseItemRate,
  description,
  itemWiseTax,
  itemWiseDiscount,
  updateSalePriceFromTxn,
  quantityDecimalPlaces,
  wholesalePrice,
  mrp,
  calculateSalePriceFromMrpDisc,
  calculateTaxBasedOnMrp,
  serialTracking,
  batchTracking,
}

abstract final class ItemSettingsInfoCatalog {
  static List<SettingsInfoSection> sectionsFor(ItemSettingsInfoKey key) {
    return switch (key) {
      ItemSettingsInfoKey.enableItem => _whatOnly(
        'Allows you to add Stock items in sale, purchase and expense transactions.',
      ),
      ItemSettingsInfoKey.whatDoYouSell => _whatOnly(
        'Select the type of item you sell (product, service or both)',
      ),
      ItemSettingsInfoKey.barcodeScan => _sections(
        what:
            'Enables you to scan item code/ serial numbers for your items at the time of entering transactions.',
        why:
            'If you want to use barcode scanning for searching and adding items to the transactions, you can turn this feature on and use it.',
      ),
      ItemSettingsInfoKey.directBarcodeScan => _sections(
        what:
            'This mode will let you scan Barcode for items directly as soon you open sale form',
        how:
            'If barcode setting is ON, then by enabling this setting you can directly start filling items on opening sale transactions.',
      ),
      ItemSettingsInfoKey.stockMaintenance => _sections(
        what:
            'Vyapar will maintain stock quantity and stock value on enabling this setting. You will be able to check Stock inventory reports and track the quantity of each item in your inventory.',
        why:
            'It helps you to track how many units of that item you are currently having in your stock.\n\nTransactions like Sale or Purchase will adjust the stock quantities and inventory value automatically.',
      ),
      ItemSettingsInfoKey.manufacturing => _sections(
        what:
            'Manufacturing allows the user to manage production of goods by creating a bill of material along with all the costs involved.',
        how:
            'Users can set up a bill of material for manufactured items using raw materials and additional costs. This helps the user estimate the cost of manufacturing and also use the manufactured item for transactions.',
      ),
      ItemSettingsInfoKey.showLowStockDialog => _sections(
        what:
            'Vyapar will show confirm window for low stock while making transaction',
        why:
            'Vyapar Users can use this setting to ensure that they are warned about the stock quantity of an item becoming less than the specified Minimum Quantity.',
      ),
      ItemSettingsInfoKey.itemsUnit => _whatOnly(
        'Define units for Stock items like KG, Litre, Pieces, Units, Bags, Bottles etc. Note: You can also define 2 units for an item Primary and Secondary. E.g. If 1 Bag contains 10 Bottles then your primary unit is Bag and Secondary unit is Bottles.',
      ),
      ItemSettingsInfoKey.defaultUnit => _sections(
        what:
            'Vyapar allows users to set a default primary and secondary unit that would be used for all new items. Users can change the unit, for items they don’t want to use the default unit. Existing item units don’t get affected by enabling this setting.',
        why:
            'If you deal in items that majorly have the same unit, enable this so that you don’t have to add the item unit again.',
      ),
      ItemSettingsInfoKey.itemCategory => _sections(
        what:
            'You can make different categories and assign items to them. Your items will have different categories based on which you can easily track them.',
        why:
            'You can see reports by different category of items & check their performance.',
      ),
      ItemSettingsInfoKey.partyWiseItemRate => _sections(
        what:
            'Vyapar can remember different sale and purchase prices of same item for different parties. This setting will show you last sale/purchase price of any item to selected party in transaction forms.',
        why:
            'If you want to sell items at different prices to different parties, you can turn this on. Vyapar will show you the last Sale/Purchase price of item to the party selected in transaction forms.',
      ),
      ItemSettingsInfoKey.description => _whatOnly(
        'Enables you to add description for an item.',
      ),
      ItemSettingsInfoKey.itemWiseTax => _sections(
        what:
            'Enables you to apply tax separately for each item in your sale and purchase transactions.',
        why: 'In case you are charging different tax on each item, you can enable this.',
      ),
      ItemSettingsInfoKey.itemWiseDiscount => _sections(
        what:
            'Enables you to apply discount separately for each item in your sale and purchase transactions.',
        why:
            'In case you are giving discount on each item separately, then you can enable this.',
      ),
      ItemSettingsInfoKey.updateSalePriceFromTxn => _whatOnly(
        'This setting allows you to update the sale price of an item whenever it is updated on sale transactions. Upon creating a transaction the last used sale price will be shown.',
      ),
      ItemSettingsInfoKey.quantityDecimalPlaces => _whatOnly(
        'Specify the number of digits after decimal for item quantity.',
      ),
      ItemSettingsInfoKey.wholesalePrice => _sections(
        what:
            'Set wholesale price for items. Also set minimum wholesale quantity.\n\nItem will be billed at wholesale price if it is greater than or equal to the minimum wholesale quantity.',
      ),
      ItemSettingsInfoKey.mrp => _sections(
        what:
            'Add MRP of items and print it on your invoices.\n\nYou can also manage your inventory with batches of different MRPs using this setting.',
      ),
      ItemSettingsInfoKey.calculateSalePriceFromMrpDisc => _whatOnly(
        'Your Sale Price will be calculated as:\n\nMRP - discount on MRP = sale price.\n\nThe MRP and Discount will also appear on your invoices.\n\nYou can add batches with different MRP\'s & that MRP will be used for calculating sale price.',
      ),
      ItemSettingsInfoKey.calculateTaxBasedOnMrp => _sections(
        what: 'Calculates GST on MRP instead of the selling price.',
        how:
            'Tax will be computed on item MRP (per primary unit) when enabled.',
        why:
            'Required for goods where GST must be charged on MRP as per government rule.',
      ),
      ItemSettingsInfoKey.serialTracking => _whatOnly(
        'Track each item by assigning a unique number to it. (Eg: IMEI no. etc)',
      ),
      ItemSettingsInfoKey.batchTracking => _whatOnly(
        'Track items in set of batches with specific batch no. Mfg date, Expiry date etc',
      ),
    };
  }

  static List<SettingsInfoSection> _whatOnly(String what) =>
      [SettingsInfoSection(title: 'What is this?', body: what)];

  static List<SettingsInfoSection> _sections({
    required String what,
    String? how,
    String? why,
  }) {
    return [
      SettingsInfoSection(title: 'What is this?', body: what),
      if (how != null) SettingsInfoSection(title: 'How it is used?', body: how),
      if (why != null) SettingsInfoSection(title: 'Why to use?', body: why),
    ];
  }
}
