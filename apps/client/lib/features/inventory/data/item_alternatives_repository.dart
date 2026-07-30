import 'package:billing_baba/features/inventory/application/inventory_error_mapper.dart';
import 'package:billing_baba/features/inventory/data/item_alternatives_remote_data_source.dart';
import 'package:billing_baba/features/inventory/data/models/item_alternative_dto.dart';
import 'package:billing_baba/features/inventory/data/models/item_recommendations_dto.dart';
import 'package:dio/dio.dart';

class ItemAlternativesRepository {
  ItemAlternativesRepository({required this._remote});

  final ItemAlternativesRemoteDataSource _remote;

  Future<List<ItemAlternativeDto>> listAlternatives(String itemId) async {
    try {
      return await _remote.listAlternatives(itemId);
    } on DioException catch (error) {
      InventoryErrorMapper.mapAndThrow(error);
    }
  }

  Future<List<ItemAlternativeDto>> addAlternative(
    String itemId,
    String alternativeItemId,
  ) async {
    try {
      return await _remote.addAlternative(itemId, alternativeItemId);
    } on DioException catch (error) {
      InventoryErrorMapper.mapAndThrow(error);
    }
  }

  Future<void> removeAlternative(
    String itemId,
    String alternativeItemId,
  ) async {
    try {
      await _remote.removeAlternative(itemId, alternativeItemId);
    } on DioException catch (error) {
      InventoryErrorMapper.mapAndThrow(error);
    }
  }

  Future<void> reorderAlternatives(
    String itemId,
    List<String> orderedIds,
  ) async {
    try {
      await _remote.reorderAlternatives(itemId, orderedIds);
    } on DioException catch (error) {
      InventoryErrorMapper.mapAndThrow(error);
    }
  }

  Future<ItemRecommendationsDto> fetchRecommendations(String itemId) async {
    try {
      return await _remote.fetchRecommendations(itemId);
    } on DioException catch (error) {
      InventoryErrorMapper.mapAndThrow(error);
    }
  }
}
