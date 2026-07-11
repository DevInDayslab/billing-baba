import 'package:billing_baba/core/constants/storage_keys.dart';
import 'package:billing_baba/core/providers/storage_service_provider.dart';
import 'package:billing_baba/features/sales/models/sale_line_item_columns.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sale_line_item_column_visibility_provider.g.dart';

/// Persisted visibility for optional columns on the Add Sale line-items grid.
@Riverpod(keepAlive: true)
class SaleLineItemColumnVisibilityState
    extends _$SaleLineItemColumnVisibilityState {
  @override
  SaleLineItemColumnVisibility build() {
    _loadPreference();
    return SaleLineItemColumnVisibility.defaults;
  }

  Future<void> _loadPreference() async {
    final storage = await ref.read(storageServiceProvider.future);
    final raw = storage.read(StorageKeys.saleLineItemColumnVisibility);
    final decoded = SaleLineItemColumnVisibility.decode(raw);
    if (decoded != state) {
      state = decoded;
    }
  }

  Future<void> _persist(SaleLineItemColumnVisibility visibility) async {
    final storage = await ref.read(storageServiceProvider.future);
    await storage.write(
      StorageKeys.saleLineItemColumnVisibility,
      visibility.encode(),
    );
  }

  void setVisibility(SaleLineItemColumnVisibility visibility) {
    state = visibility;
    _persist(visibility);
  }

  void toggleColumn(SaleLineItemColumn column) {
    setVisibility(state.toggle(column));
  }
}
