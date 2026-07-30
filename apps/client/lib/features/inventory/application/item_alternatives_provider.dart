import 'package:billing_baba/core/providers/api_client_provider.dart';
import 'package:billing_baba/features/inventory/application/inventory_error_mapper.dart';
import 'package:billing_baba/features/inventory/data/item_alternatives_remote_data_source.dart';
import 'package:billing_baba/features/inventory/data/item_alternatives_repository.dart';
import 'package:billing_baba/features/inventory/data/models/item_alternative_dto.dart';
import 'package:billing_baba/features/inventory/data/models/item_recommendations_dto.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'item_alternatives_provider.g.dart';

@Riverpod(keepAlive: true)
Future<ItemAlternativesRepository> itemAlternativesRepository(Ref ref) async {
  final api = await ref.watch(apiClientProvider.future);
  return ItemAlternativesRepository(
    remote: ItemAlternativesRemoteDataSource(api.dio),
  );
}

@riverpod
class ItemAlternativesNotifier extends _$ItemAlternativesNotifier {
  @override
  Future<List<ItemAlternativeDto>> build(String itemId) async {
    final repository = await ref.watch(
      itemAlternativesRepositoryProvider.future,
    );
    return repository.listAlternatives(itemId);
  }

  Future<void> addAlternative(String alternativeItemId) async {
    try {
      final repository = await ref.read(
        itemAlternativesRepositoryProvider.future,
      );
      await repository.addAlternative(itemId, alternativeItemId);
      ref.invalidateSelf();
    } on InventoryOfflineException {
      rethrow;
    } on InventoryException {
      rethrow;
    }
  }

  Future<void> removeAlternative(String alternativeItemId) async {
    try {
      final repository = await ref.read(
        itemAlternativesRepositoryProvider.future,
      );
      await repository.removeAlternative(itemId, alternativeItemId);
      ref.invalidateSelf();
    } on InventoryOfflineException {
      rethrow;
    } on InventoryException {
      rethrow;
    }
  }

  Future<void> reorder(List<String> orderedIds) async {
    try {
      final repository = await ref.read(
        itemAlternativesRepositoryProvider.future,
      );
      await repository.reorderAlternatives(itemId, orderedIds);
      ref.invalidateSelf();
    } on InventoryOfflineException {
      rethrow;
    } on InventoryException {
      rethrow;
    }
  }
}

@riverpod
Future<ItemRecommendationsDto> itemRecommendations(
  Ref ref,
  String itemId,
) async {
  final repository = await ref.watch(itemAlternativesRepositoryProvider.future);
  return repository.fetchRecommendations(itemId);
}
