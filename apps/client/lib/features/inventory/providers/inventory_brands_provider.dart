import 'package:billing_baba/core/network/api_validation_exception.dart';
import 'package:billing_baba/features/inventory/application/inventory_error_mapper.dart';
import 'package:billing_baba/features/inventory/application/inventory_service.dart';
import 'package:billing_baba/features/inventory/models/brand_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'inventory_brands_provider.g.dart';

class AddBrandResult {
  const AddBrandResult({this.brand, this.error});

  final BrandModel? brand;
  final String? error;

  bool get isSuccess => brand != null;
}

@Riverpod(keepAlive: true)
class InventoryBrands extends _$InventoryBrands {
  @override
  Future<List<BrandModel>> build() async {
    final service = await ref.watch(inventoryServiceProvider.future);
    return service.fetchBrands();
  }

  Future<void> refresh({String? searchQuery}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final service = await ref.read(inventoryServiceProvider.future);
      return service.fetchBrands(searchQuery: searchQuery);
    });
  }

  Future<AddBrandResult> addBrand(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return const AddBrandResult(error: 'Brand name is required');
    }

    try {
      final service = await ref.read(inventoryServiceProvider.future);
      final brand = await service.createBrand(trimmed);
      await refresh();
      return AddBrandResult(brand: brand);
    } on ApiValidationException catch (error) {
      return AddBrandResult(
        error: error.fieldErrors['name'] ?? error.message,
      );
    } on InventoryException catch (error) {
      return AddBrandResult(error: error.message);
    } catch (error) {
      return AddBrandResult(error: InventoryErrorMapper.messageFor(error));
    }
  }

  Future<AddBrandResult> updateBrand(String id, String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return const AddBrandResult(error: 'Brand name is required');
    }

    try {
      final service = await ref.read(inventoryServiceProvider.future);
      final brand = await service.updateBrand(id, trimmed);
      await refresh();
      return AddBrandResult(brand: brand);
    } on ApiValidationException catch (error) {
      return AddBrandResult(
        error: error.fieldErrors['name'] ?? error.message,
      );
    } on InventoryException catch (error) {
      return AddBrandResult(error: error.message);
    } catch (error) {
      return AddBrandResult(error: InventoryErrorMapper.messageFor(error));
    }
  }

  Future<String?> deleteBrand(String id) async {
    final previous = state;
    final current = state.value ?? [];
    state = AsyncData(current.where((brand) => brand.id != id).toList());

    try {
      final service = await ref.read(inventoryServiceProvider.future);
      await service.deleteBrand(id);
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
