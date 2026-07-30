import 'package:flutter/foundation.dart';
import 'package:billing_baba/core/network/api_endpoints.dart';
import 'package:billing_baba/features/inventory/data/models/item_alternative_dto.dart';
import 'package:billing_baba/features/inventory/data/models/item_recommendations_dto.dart';
import 'package:dio/dio.dart';

class ItemAlternativesRemoteDataSource {
  ItemAlternativesRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<ItemAlternativeDto>> listAlternatives(String itemId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.listAlternatives(itemId),
    );
    if (kDebugMode) {
      debugPrint('RAW ALTERNATIVES RESPONSE: ${response.data}');
    }
    final data = response.data?['data'];
    if (data is! List) return const [];
    return data
        .whereType<Map<String, dynamic>>()
        .map(ItemAlternativeDto.fromJson)
        .toList();
  }

  Future<List<ItemAlternativeDto>> addAlternative(
    String itemId,
    String alternativeItemId,
  ) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.addAlternative(itemId),
      data: {'alternative_item_id': alternativeItemId},
    );
    final data = response.data?['data'];
    if (data is! List) return const [];
    return data
        .whereType<Map<String, dynamic>>()
        .map(ItemAlternativeDto.fromJson)
        .toList();
  }

  Future<void> removeAlternative(
    String itemId,
    String alternativeItemId,
  ) async {
    await _dio.delete<void>(
      ApiEndpoints.removeAlternative(itemId, alternativeItemId),
    );
  }

  Future<void> reorderAlternatives(
    String itemId,
    List<String> orderedIds,
  ) async {
    await _dio.patch<void>(
      ApiEndpoints.reorderAlternatives(itemId),
      data: {'ordered_ids': orderedIds},
    );
  }

  Future<ItemRecommendationsDto> fetchRecommendations(String itemId) async {
    return _parseSingle(
      response: await _dio.get<Map<String, dynamic>>(
        ApiEndpoints.itemRecommendations(itemId),
      ),
      parser: ItemRecommendationsDto.fromJson,
    );
  }

  T _parseSingle<T>({
    required Response<Map<String, dynamic>> response,
    required T Function(Map<String, dynamic>) parser,
  }) {
    final data = response.data?['data'];
    if (data is! Map<String, dynamic>) {
      throw DioException(
        requestOptions: response.requestOptions,
        message: 'Invalid single resource response',
      );
    }
    return parser(data);
  }
}
