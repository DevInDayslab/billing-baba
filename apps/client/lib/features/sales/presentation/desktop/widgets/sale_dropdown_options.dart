import 'package:billing_baba/features/inventory/application/inventory_search_engine.dart';
import 'package:billing_baba/features/inventory/utils/gst_tax_slabs.dart';

/// Dropdown option lists for the Add Sale page.
abstract final class SaleDropdownOptions {
  static const units = ['NONE', 'PCS', 'KG', 'GM', 'LTR', 'MTR', 'BOX', 'BAG'];

  static List<String> get taxSlabs => [
    ...GstTaxSlabs.saleDropdownLabels(),
    '28%',
  ];

  static const paymentTypes = ['Cash', 'Credit', 'UPI', 'Cheque'];

  static const priceTaxModes = ['Without Tax', 'With Tax'];

  static const paymentTerms = [
    'Due on Receipt',
    'Net 7',
    'Net 15',
    'Net 30',
    'Net 45',
    'Net 60',
  ];

  static const termsTitles = [
    'Sale Invoice',
    'Tax Invoice',
    'Bill of Supply',
    'Estimate Quotation',
    'Proforma Invoice',
    'Sale Order',
    'Delivery Challan',
    'Credit Note',
  ];

  static const godowns = ['Main Location', 'Warehouse B'];

  static const jobWorkAdditionalCostCharges = [
    'Labour Cost',
    'Packaging Charge',
    'Transport Charge',
    'Electricity Charge',
    'Other',
  ];

  static const indianStates = [
    'Andhra Pradesh',
    'Arunachal Pradesh',
    'Assam',
    'Bihar',
    'Chhattisgarh',
    'Goa',
    'Gujarat',
    'Haryana',
    'Himachal Pradesh',
    'Jharkhand',
    'Karnataka',
    'Kerala',
    'Madhya Pradesh',
    'Maharashtra',
    'Manipur',
    'Meghalaya',
    'Mizoram',
    'Nagaland',
    'Odisha',
    'Punjab',
    'Rajasthan',
    'Sikkim',
    'Tamil Nadu',
    'Telangana',
    'Tripura',
    'Uttar Pradesh',
    'Uttarakhand',
    'West Bengal',
    'Andaman and Nicobar Islands',
    'Chandigarh',
    'Dadra and Nagar Haveli and Daman and Diu',
    'Delhi',
    'Jammu and Kashmir',
    'Ladakh',
    'Lakshadweep',
    'Puducherry',
  ];

  static const countries = [
    'India',
    'Afghanistan',
    'Bangladesh',
    'Bhutan',
    'China',
    'Malaysia',
    'Nepal',
    'Singapore',
    'Sri Lanka',
    'United Arab Emirates',
    'United Kingdom',
    'United States',
  ];
}

class SaleItemOption {
  const SaleItemOption({
    required this.id,
    required this.name,
    required this.salePrice,
    required this.purchasePrice,
    required this.mfgCost,
    required this.stock,
    this.unit,
    this.hsn,
    this.itemCode,
    this.sku,
    this.barcode,
    this.tierPrices = const {},
    this.defaultTaxPercent = 0,
    this.isAlternativeSuggestion = false,
  });

  final String id;
  final String name;
  final double salePrice;
  final double purchasePrice;
  final double mfgCost;
  final double stock;
  final String? unit;
  final String? hsn;
  final String? itemCode;
  final String? sku;
  final String? barcode;
  final Map<String, double> tierPrices;
  final double defaultTaxPercent;
  final bool isAlternativeSuggestion;

  bool matchesSearchQuery(String query) {
    return InventorySearchEngine.matchesFields(
      InventorySearchableFields(
        id: id,
        name: name,
        sku: sku,
        barcode: barcode,
        hsn: hsn,
        unitName: unit,
      ),
      query,
    );
  }
}

abstract final class SaleItemCatalog {
  static const items = <SaleItemOption>[];
}
