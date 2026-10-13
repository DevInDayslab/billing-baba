import 'package:billing_baba/core/constants/storage_keys.dart';
import 'package:billing_baba/core/providers/storage_service_provider.dart';
import 'package:billing_baba/features/business/application/business_service.dart';
import 'package:billing_baba/features/inventory/application/item_settings_provider.dart';
import 'package:billing_baba/features/inventory/models/item_settings.dart';
import 'package:billing_baba/features/sales/models/sale_line_item_columns.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sale_line_item_column_visibility_provider.g.dart';

/// User column prefs merged with Item Settings (item-wise tax / discount).
final saleLineItemEffectiveColumnVisibilityProvider =
    Provider<SaleLineItemColumnVisibility>((ref) {
      final saved = ref.watch(saleLineItemColumnVisibilityStateProvider);
      final settings =
          ref.watch(itemSettingsProvider).value ?? ItemSettings.defaults();
      return saved.applyItemSettings(
        itemWiseTax: settings.itemWiseTax,
        itemWiseDiscount: settings.itemWiseDiscount,
      );
    });

/// Persisted visibility for optional columns on the Add Sale line-items grid.
@Riverpod(keepAlive: true)
class SaleLineItemColumnVisibilityState
    extends _$SaleLineItemColumnVisibilityState {
  @override
  SaleLineItemColumnVisibility build() {
    ref.listen(currentBusinessProvider, (_, _) {
      ref.invalidateSelf();
    });
    _loadPreference();
    return SaleLineItemColumnVisibility.defaults;
  }

  String? get _storageKey {
    final businessId = ref.read(currentBusinessProvider)?.id;
    if (businessId == null || businessId.isEmpty) return null;
    return '${StorageKeys.saleLineItemColumnVisibility}_$businessId';
  }

  Future<void> _loadPreference() async {
    final key = _storageKey;
    if (key == null) return;

    final storage = await ref.read(storageServiceProvider.future);
    final raw = storage.read(key);
    final decoded = SaleLineItemColumnVisibility.decode(raw);
    if (decoded != state) {
      state = decoded;
    }
  }

  Future<void> _persist(SaleLineItemColumnVisibility visibility) async {
    final key = _storageKey;
    if (key == null) return;

    final storage = await ref.read(storageServiceProvider.future);
    await storage.write(key, visibility.encode());
  }

  void setVisibility(SaleLineItemColumnVisibility visibility) {
    state = visibility;
    _persist(visibility);
  }

  void toggleColumn(SaleLineItemColumn column) {
    setVisibility(state.toggle(column));
  }
}
