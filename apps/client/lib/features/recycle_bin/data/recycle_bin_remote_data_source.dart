import 'package:billing_baba/core/network/api_endpoints.dart';
import 'package:billing_baba/features/recycle_bin/models/recycle_bin_item.dart';
import 'package:dio/dio.dart';

class RecycleBinRemoteDataSource {
  RecycleBinRemoteDataSource(this._dio);

  final Dio _dio;

  Future<({List<RecycleBinItem> items, int total})> list({
    int page = 1,
    int limit = 50,
    String? entityType,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.recycleBin,
      queryParameters: {
        'page': page,
        'limit': limit,
        if (entityType != null) 'entity_type': entityType,
      },
    );
    final body = response.data ?? {};
    final data = (body['data'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>();
    final meta = body['meta'] as Map<String, dynamic>? ?? {};
    return (
      items: data.map(RecycleBinItem.fromJson).toList(),
      total: (meta['total'] as num?)?.toInt() ?? data.length,
    );
  }

  Future<void> restore({
    required String entityType,
    required String entityId,
  }) async {
    await _dio.post<void>(
      ApiEndpoints.recycleBinRestore(entityType, entityId),
    );
  }

  Future<void> purge({
    required String entityType,
    required String entityId,
  }) async {
    await _dio.delete<void>(
      ApiEndpoints.recycleBinEntity(entityType, entityId),
    );
  }
}
