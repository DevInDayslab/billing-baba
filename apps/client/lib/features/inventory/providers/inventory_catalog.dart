import 'package:billing_baba/features/inventory/models/category_model.dart';
import 'package:billing_baba/features/inventory/models/item_model.dart';
import 'package:billing_baba/features/inventory/models/unit_model.dart';

/// Seed catalog for inventory UI until Drift repositories are wired.
abstract final class InventoryCatalog {
  static const uncategorizedCategoryId = 'uncategorized';

  static const categories = <InventoryCategory>[
    InventoryCategory(
      id: uncategorizedCategoryId,
      name: 'Items not in any Category',
      itemCount: 1,
      isUncategorized: true,
    ),
  ];

  static const items = <InventoryItem>[
    InventoryItem(
      id: 'sample-item',
      name: 'Sample Item',
      type: ItemType.product,
      quantity: -10,
      stockValue: 0,
      categoryId: uncategorizedCategoryId,
    ),
  ];

  static const units = <InventoryUnit>[
    InventoryUnit(id: 'pcs', fullName: 'PIECES', shortName: 'PCS'),
    InventoryUnit(id: 'bags', fullName: 'BAGS', shortName: 'Bag'),
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
}
