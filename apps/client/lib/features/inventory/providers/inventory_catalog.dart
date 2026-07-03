import 'package:billing_baba/features/inventory/models/category_model.dart';
import 'package:billing_baba/features/inventory/models/item_model.dart';
import 'package:billing_baba/features/inventory/models/product_transaction_model.dart';
import 'package:billing_baba/features/inventory/models/unit_model.dart';

/// Seed catalog for inventory UI until Drift repositories are wired.
abstract final class InventoryCatalog {
  static const uncategorizedCategoryId = 'uncategorized';

  static const solventsCategoryId = 'solvents';
  static const dairyCategoryId = 'dairy';

  static const categories = <InventoryCategory>[
    InventoryCategory(
      id: uncategorizedCategoryId,
      name: 'Items not in any Category',
      isUncategorized: true,
    ),
    InventoryCategory(id: dairyCategoryId, name: 'dairy'),
    InventoryCategory(id: 'glasses', name: 'glasses'),
    InventoryCategory(id: 'paints', name: 'paints'),
    InventoryCategory(id: solventsCategoryId, name: 'solvents'),
  ];

  static const items = <InventoryItem>[
    InventoryItem(
      id: 'item-caty',
      name: 'caty',
      type: ItemType.product,
      quantity: 28,
      stockValue: 0,
      categoryId: dairyCategoryId,
      availableForSale: 26,
      reservedQuantity: 2,
    ),
    InventoryItem(
      id: 'item-dsfgdfg',
      name: 'dsfgdfg',
      type: ItemType.product,
      quantity: 2,
      stockValue: 0,
      categoryId: dairyCategoryId,
    ),
    InventoryItem(
      id: 'item-lays',
      name: 'lays',
      type: ItemType.product,
      quantity: -2,
      stockValue: 0,
      categoryId: uncategorizedCategoryId,
    ),
    InventoryItem(
      id: 'item-munch',
      name: 'munch',
      type: ItemType.product,
      quantity: -1,
      stockValue: 0,
      categoryId: uncategorizedCategoryId,
    ),
    InventoryItem(
      id: 'item-apex',
      name: 'PRY APEX SINGLE PIECE 6D C8643',
      type: ItemType.product,
      quantity: 5,
      stockValue: 0,
      categoryId: uncategorizedCategoryId,
    ),
    InventoryItem(
      id: 'item-solvent',
      name: 'Thinner 500ml',
      type: ItemType.product,
      quantity: 12,
      stockValue: 2400,
      categoryId: solventsCategoryId,
    ),
  ];

  static const units = <InventoryUnit>[
    InventoryUnit(id: 'pcs', fullName: 'PIECES', shortName: 'PCS'),
    InventoryUnit(
      id: 'bags',
      fullName: 'BAGS',
      shortName: 'Bag',
      conversions: [
        UnitConversion(
          id: 'conv-bags-bottles',
          label: '1 BAGS = 10 BOTTLES',
          factor: 10,
        ),
      ],
    ),
    InventoryUnit(id: 'bottles', fullName: 'BOTTLES', shortName: 'Btl'),
    InventoryUnit(id: 'box', fullName: 'BOX', shortName: 'Box'),
    InventoryUnit(id: 'bundles', fullName: 'BUNDLES', shortName: 'Bdl'),
    InventoryUnit(id: 'cans', fullName: 'CANS', shortName: 'Cns'),
    InventoryUnit(id: 'cartons', fullName: 'CARTONS', shortName: 'Ctn'),
    InventoryUnit(id: 'dozens', fullName: 'DOZENS', shortName: 'Dzn'),
    InventoryUnit(id: 'grammes', fullName: 'GRAMMES', shortName: 'Gm'),
    InventoryUnit(id: 'kilograms', fullName: 'KILOGRAMS', shortName: 'Kg'),
    InventoryUnit(id: 'litre', fullName: 'LITRE', shortName: 'Ltr'),
    InventoryUnit(id: 'meters', fullName: 'METERS', shortName: 'Mtr'),
    InventoryUnit(id: 'mililitre', fullName: 'MILILITRE', shortName: 'Ml'),
  ];

  static final productTransactions = <ProductTransaction>[
    ProductTransaction(
      id: 'txn-1',
      itemId: 'item-caty',
      typeLabel: 'Sale (Main Godown)',
      invoiceRefNo: 'INV-001',
      partyName: 'ADVWDV',
      date: DateTime(2025, 6, 28, 14, 30),
      quantity: 1,
      unit: 'Pcs',
      pricePerUnit: 150,
      status: 'Paid',
    ),
    ProductTransaction(
      id: 'txn-2',
      itemId: 'item-caty',
      typeLabel: 'Purchase (Job work)',
      invoiceRefNo: 'PUR-042',
      partyName: 'rohit',
      date: DateTime(2025, 6, 25, 10, 15),
      quantity: 20,
      unit: 'Pcs',
      pricePerUnit: 120,
      status: 'Paid',
      isInbound: true,
    ),
    ProductTransaction(
      id: 'txn-3',
      itemId: 'item-caty',
      typeLabel: 'Opening Stock',
      invoiceRefNo: '-',
      partyName: '-',
      date: DateTime(2025, 4),
      quantity: 10,
      unit: 'Pcs',
      pricePerUnit: 0,
      status: '-',
      isInbound: true,
    ),
    ProductTransaction(
      id: 'txn-4',
      itemId: 'item-caty',
      typeLabel: 'Proforma Invoice',
      invoiceRefNo: 'PF-118',
      partyName: 'Cash Sale',
      date: DateTime(2025, 6, 20, 16, 45),
      quantity: 2,
      unit: 'Pcs',
      pricePerUnit: 150,
      status: 'Paid',
    ),
    ProductTransaction(
      id: 'txn-5',
      itemId: 'item-caty',
      typeLabel: 'Debit Note',
      invoiceRefNo: 'DN-007',
      partyName: 'NIHAL',
      date: DateTime(2025, 6, 15, 11),
      quantity: 1,
      unit: 'Pcs',
      pricePerUnit: 150,
      status: 'Paid',
    ),
    ProductTransaction(
      id: 'txn-6',
      itemId: 'item-lays',
      typeLabel: 'Sale (Main Godown)',
      invoiceRefNo: 'INV-089',
      partyName: 'Cash Sale',
      date: DateTime(2025, 6, 22, 9, 30),
      quantity: 5,
      unit: 'Pcs',
      pricePerUnit: 20,
      status: 'Paid',
    ),
    ProductTransaction(
      id: 'txn-7',
      itemId: 'item-lays',
      typeLabel: 'Opening Stock',
      invoiceRefNo: '-',
      partyName: '-',
      date: DateTime(2025, 4),
      quantity: 3,
      unit: 'Pcs',
      pricePerUnit: 0,
      status: '-',
      isInbound: true,
    ),
  ];
}
