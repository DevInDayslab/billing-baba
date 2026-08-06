import 'package:billing_baba/features/inventory/application/inventory_service.dart';
import 'package:billing_baba/features/inventory/models/add_item_form_model.dart';
import 'package:billing_baba/features/inventory/models/item_bom_model.dart';
import 'package:billing_baba/features/inventory/models/mappers/add_item_form_mapper.dart';
import 'package:billing_baba/features/inventory/models/requests/item_bom_requests.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'item_bom_provider.g.dart';

@riverpod
class ItemBom extends _$ItemBom {
  @override
  FutureOr<void> build() {}

  Future<ItemBomModel> fetchForItem(String itemId) async {
    final service = await ref.read(inventoryServiceProvider.future);
    return service.fetchItemBom(itemId);
  }

  Future<void> replaceFromForm(String itemId, ReplaceItemBomRequest request) async {
    final service = await ref.read(inventoryServiceProvider.future);
    await service.replaceItemBom(itemId, request);
  }

  Future<void> replaceFromAddItemForm(
    String itemId,
    AddItemFormState form,
  ) async {
    await replaceFromForm(itemId, AddItemFormMapper.toBomRequest(form));
  }

  Future<void> removeForItem(String itemId) async {
    final service = await ref.read(inventoryServiceProvider.future);
    await service.removeItemBom(itemId);
  }
}
