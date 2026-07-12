import 'package:billing_baba/shared/widgets/table_filters/filter_models.dart';
import 'package:billing_baba/shared/widgets/table_filters/filter_types.dart';

/// Canonical specs for the developer playground reference table.
abstract final class FilterWidgetSpecs {
  static const all = [
    FilterWidgetSpec(
      name: 'Invoice Number',
      widgetClass: 'TextFilterWidget',
      typeLabel: 'Text Filter',
      operators: ['Contains', 'Exact Match'],
      usedIn: ['Sales', 'Purchase', 'Reports', 'Inventory', 'Parties'],
      exampleFields: [
        'Invoice No',
        'Reference No',
        'Party Name',
        'SKU',
        'Barcode',
      ],
      config: ColumnFilter(
        id: 'invoice',
        title: 'Invoice Number',
        type: FilterType.text,
        hintText: 'Enter invoice number',
      ),
    ),
    FilterWidgetSpec(
      name: 'Amount',
      widgetClass: 'NumberFilterWidget',
      typeLabel: 'Number Filter',
      operators: ['Equal To', 'Less Than', 'Greater Than'],
      usedIn: ['Sales', 'Inventory', 'Reports'],
      exampleFields: [
        'Amount',
        'Quantity',
        'Price',
        'Balance',
        'Outstanding',
        'GST',
      ],
      config: ColumnFilter(
        id: 'amount',
        title: 'Amount',
        type: FilterType.number,
      ),
    ),
    FilterWidgetSpec(
      name: 'Invoice Date',
      widgetClass: 'DateFilterWidget',
      typeLabel: 'Date Filter',
      operators: ['Equal To', 'Less Than', 'Greater Than', 'Range'],
      usedIn: ['Sales', 'Purchase', 'Reports', 'Dashboard'],
      exampleFields: [
        'Invoice Date',
        'Due Date',
        'Purchase Date',
        'Payment Date',
      ],
      config: ColumnFilter(
        id: 'date',
        title: 'Invoice Date',
        type: FilterType.date,
      ),
    ),
    FilterWidgetSpec(
      name: 'Status',
      widgetClass: 'SingleSelectFilterWidget',
      typeLabel: 'Single Select',
      operators: ['Dropdown'],
      usedIn: ['Sales', 'Purchases'],
      exampleFields: [
        'Status',
        'Payment Mode',
        'Firm',
        'Godown',
        'User',
      ],
      config: ColumnFilter(
        id: 'status',
        title: 'Status',
        type: FilterType.singleSelect,
        values: ['Paid', 'Unpaid', 'Partial', 'Cancelled'],
      ),
    ),
    FilterWidgetSpec(
      name: 'Categories',
      widgetClass: 'MultiSelectFilterWidget',
      typeLabel: 'Multi Select',
      operators: ['Checkbox list'],
      usedIn: ['Inventory', 'Reports'],
      exampleFields: [
        'Tags',
        'Categories',
        'Multiple Status',
        'Brands',
      ],
      config: ColumnFilter(
        id: 'categories',
        title: 'Categories',
        type: FilterType.multiSelect,
        values: ['Electronics', 'Grocery', 'Apparel', 'Hardware'],
      ),
    ),
    FilterWidgetSpec(
      name: 'Active',
      widgetClass: 'BooleanFilterWidget',
      typeLabel: 'Boolean Filter',
      operators: ['All', 'Yes', 'No'],
      usedIn: ['Inventory', 'Parties'],
      exampleFields: [
        'Active',
        'Archived',
        'Low Stock',
        'GST Enabled',
        'Track Inventory',
      ],
      config: ColumnFilter(
        id: 'active',
        title: 'Active',
        type: FilterType.boolean,
      ),
    ),
    FilterWidgetSpec(
      name: 'Loyalty Points',
      widgetClass: 'RangeSliderFilterWidget',
      typeLabel: 'Range Slider',
      operators: ['Min – Max slider'],
      usedIn: ['Dashboard', 'CRM', 'Analytics'],
      exampleFields: [
        'Loyalty Points',
        'Rating',
        'Percentage',
        'Score',
      ],
      config: ColumnFilter(
        id: 'loyalty',
        title: 'Loyalty Points',
        type: FilterType.rangeSlider,
        maxValue: 1000,
        rangeLabel: 'Points range',
      ),
    ),
  ];

  static const referenceTable = [
    (
      'TextFilterWidget',
      'Party names, invoice numbers, SKUs',
      'Sales, Purchases, Inventory, Parties',
    ),
    (
      'NumberFilterWidget',
      'Amount, quantity, stock, prices',
      'Sales, Inventory, Reports',
    ),
    (
      'DateFilterWidget',
      'Invoice date, due date, purchase date',
      'All modules',
    ),
    (
      'SingleSelectFilterWidget',
      'Status, payment mode, firm',
      'Sales, Purchases',
    ),
    (
      'MultiSelectFilterWidget',
      'Categories, tags, multiple statuses',
      'Inventory, Reports',
    ),
    (
      'BooleanFilterWidget',
      'Active, archived, low stock',
      'Inventory, Parties',
    ),
    (
      'RangeSliderFilterWidget',
      'Loyalty points, ratings, percentages',
      'Dashboard, CRM, Analytics',
    ),
  ];
}
