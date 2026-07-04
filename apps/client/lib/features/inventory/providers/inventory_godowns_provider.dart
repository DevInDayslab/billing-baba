import 'package:billing_baba/core/network/api_validation_exception.dart';
import 'package:billing_baba/features/inventory/application/inventory_error_mapper.dart';
import 'package:billing_baba/features/inventory/application/inventory_service.dart';
import 'package:billing_baba/features/inventory/models/godown_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'inventory_godowns_provider.g.dart';

class AddGodownResult {
  const AddGodownResult({this.godown, this.error});

  final GodownModel? godown;
  final String? error;

  bool get isSuccess => godown != null;
}

@Riverpod(keepAlive: true)
class InventoryGodowns extends _$InventoryGodowns {
  @override
  Future<List<GodownModel>> build() async {
    final service = await ref.watch(inventoryServiceProvider.future);
    return service.fetchGodowns();
  }

  Future<void> refresh({String? searchQuery}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final service = await ref.read(inventoryServiceProvider.future);
      return service.fetchGodowns(searchQuery: searchQuery);
    });
  }

  Future<AddGodownResult> addGodown(String name, {String? address}) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return const AddGodownResult(error: 'Godown name is required');
    }

    try {
      final service = await ref.read(inventoryServiceProvider.future);
      final godown = await service.createGodown(trimmed, address: address);
      await refresh();
      return AddGodownResult(godown: godown);
    } on ApiValidationException catch (error) {
      return AddGodownResult(
        error: error.fieldErrors['name'] ?? error.message,
      );
    } on InventoryException catch (error) {
      return AddGodownResult(error: error.message);
    } catch (error) {
      return AddGodownResult(error: InventoryErrorMapper.messageFor(error));
    }
  }

  Future<AddGodownResult> updateGodown(
    String id,
    String name, {
    String? address,
  }) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return const AddGodownResult(error: 'Godown name is required');
    }

    try {
      final service = await ref.read(inventoryServiceProvider.future);
      final godown = await service.updateGodown(
        id,
        name: trimmed,
        address: address,
      );
      await refresh();
      return AddGodownResult(godown: godown);
    } on ApiValidationException catch (error) {
      return AddGodownResult(
        error: error.fieldErrors['name'] ?? error.message,
      );
    } on InventoryException catch (error) {
      return AddGodownResult(error: error.message);
    } catch (error) {
      return AddGodownResult(error: InventoryErrorMapper.messageFor(error));
    }
  }

  Future<String?> deleteGodown(String id) async {
    final previous = state;
    final current = state.value ?? [];
    state = AsyncData(current.where((godown) => godown.id != id).toList());

    try {
      final service = await ref.read(inventoryServiceProvider.future);
      await service.deleteGodown(id);
      await refresh();
      return null;
    } on InventoryException catch (error) {
      state = previous;
      return error.message;
    } catch (error) {
      state = previous;
      return InventoryErrorMapper.messageFor(error);
    }
  }
}
