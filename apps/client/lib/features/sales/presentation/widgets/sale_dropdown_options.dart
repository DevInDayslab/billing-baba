/// Dropdown option lists for the Add Sale page.
abstract final class SaleDropdownOptions {
  static const units = ['NONE', 'PCS', 'KG', 'GM', 'LTR', 'MTR', 'BOX', 'BAG'];

  static const taxSlabs = ['NONE', '5%', '12%', '18%', '28%'];

  static const paymentTypes = ['Cash', 'Credit', 'UPI', 'Cheque'];

  static const godowns = ['Main Location', 'Warehouse B'];

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
  });

  final String id;
  final String name;
  final double salePrice;
  final double purchasePrice;
  final double mfgCost;
  final double stock;
  final String? unit;
}

abstract final class SaleItemCatalog {
  static const items = <SaleItemOption>[];
}
