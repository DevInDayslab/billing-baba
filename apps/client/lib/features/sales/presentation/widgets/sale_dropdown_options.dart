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
    required this.name,
    required this.salePrice,
    required this.purchasePrice,
    required this.mfgCost,
    required this.stock,
  });

  final String name;
  final double salePrice;
  final double purchasePrice;
  final double mfgCost;
  final double stock;
}

abstract final class SaleItemCatalog {
  static const items = [
    SaleItemOption(
      name: 'Rice 25kg',
      salePrice: 1200,
      purchasePrice: 1050,
      mfgCost: 980,
      stock: 42,
    ),
    SaleItemOption(
      name: 'Wheat Flour 10kg',
      salePrice: 450,
      purchasePrice: 390,
      mfgCost: 360,
      stock: 68,
    ),
    SaleItemOption(
      name: 'Cooking Oil 1L',
      salePrice: 180,
      purchasePrice: 155,
      mfgCost: 140,
      stock: 120,
    ),
    SaleItemOption(
      name: 'Sugar 1kg',
      salePrice: 48,
      purchasePrice: 42,
      mfgCost: 38,
      stock: 200,
    ),
    SaleItemOption(
      name: 'Tea Powder 500g',
      salePrice: 220,
      purchasePrice: 190,
      mfgCost: 175,
      stock: 35,
    ),
    SaleItemOption(
      name: 'Detergent 1kg',
      salePrice: 95,
      purchasePrice: 78,
      mfgCost: 70,
      stock: 88,
    ),
  ];
}
