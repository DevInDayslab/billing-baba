import 'package:billing_baba/features/inventory/data/category_local_source.dart';

/// Local inventory store. Categories are Drift-backed; other entities TBD.
abstract class InventoryLocalDataSource {
  CategoryLocalSource get categories;
}

class DriftInventoryLocalDataSource implements InventoryLocalDataSource {
  DriftInventoryLocalDataSource(this._categories);

  final CategoryLocalSource _categories;

  @override
  CategoryLocalSource get categories => _categories;
}

class UnimplementedInventoryLocalDataSource
    implements InventoryLocalDataSource {
  @override
  CategoryLocalSource get categories =>
      throw UnsupportedError('Inventory local store is not configured');
}
