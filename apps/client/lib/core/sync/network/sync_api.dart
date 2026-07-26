import 'dart:typed_data';

import 'package:billing_baba/core/network/api_endpoints.dart';
import 'package:dio/dio.dart';

/// Low-level HTTP client for `/api/v1/sync/*` (contract v1).
///
/// Features must not call this directly — only the SyncEngine / transport layer.
class SyncApi {
  SyncApi(this._dio);

  final Dio _dio;

  Future<Map<String, dynamic>> registerDevice({
    required Map<String, dynamic> body,
    required Map<String, String> headers,
  }) =>
      _post(ApiEndpoints.syncDevices, body: body, headers: headers);

  Future<Map<String, dynamic>> listDevices({
    required Map<String, String> headers,
  }) =>
      _get(ApiEndpoints.syncDevices, headers: headers);

  Future<Map<String, dynamic>> status({
    required Map<String, String> headers,
  }) =>
      _get(ApiEndpoints.syncStatus, headers: headers);

  Future<Map<String, dynamic>> bootstrap({
    required Map<String, dynamic> body,
    required Map<String, String> headers,
  }) =>
      _post(ApiEndpoints.syncBootstrap, body: body, headers: headers);

  Future<Map<String, dynamic>> bootstrapChunk({
    required String bootstrapId,
    required int chunkIndex,
    required Map<String, String> headers,
    int page = 1,
  }) =>
      _get(
        ApiEndpoints.syncBootstrapChunk(bootstrapId, chunkIndex),
        headers: headers,
        queryParameters: {'page': page},
      );

  Future<Map<String, dynamic>> push({
    required Map<String, dynamic> body,
    required Map<String, String> headers,
  }) =>
      _post(ApiEndpoints.syncPush, body: body, headers: headers);

  Future<Map<String, dynamic>> pull({
    required String cursor,
    required Map<String, String> headers,
    int? limit,
    String? entityTypes,
  }) =>
      _get(
        ApiEndpoints.syncPull,
        headers: headers,
        queryParameters: {
          'cursor': cursor,
          'limit': ?limit,
          'entity_types': ?entityTypes,
        },
      );

  Future<Map<String, dynamic>> uploadMedia({
    required Map<String, dynamic> body,
    required Map<String, String> headers,
  }) =>
      _post(ApiEndpoints.syncMediaUploads, body: body, headers: headers);

  Future<Map<String, dynamic>> completeMedia({
    required Map<String, dynamic> body,
    required Map<String, String> headers,
  }) =>
      _post(ApiEndpoints.syncMediaUploadsComplete, body: body, headers: headers);

  Future<Map<String, dynamic>> getMediaUrl({
    required String assetId,
    required Map<String, String> headers,
    String variant = 'original',
  }) =>
      _get(
        ApiEndpoints.syncMediaUrl(assetId),
        headers: headers,
        queryParameters: {'variant': variant},
      );

  /// Raw PUT to a presigned URL (no API auth headers).
  Future<void> putBytes({
    required String uploadUrl,
    required Uint8List bytes,
    required Map<String, String> headers,
    required String contentType,
  }) async {
    final raw = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
      ),
    );
    await raw.put<void>(
      uploadUrl,
      data: bytes,
      options: Options(
        headers: headers,
        contentType: contentType,
      ),
    );
  }

  Future<Map<String, dynamic>> _get(
    String path, {
    required Map<String, String> headers,
    Map<String, dynamic>? queryParameters,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      path,
      queryParameters: queryParameters,
      options: Options(headers: headers),
    );
    return _unwrap(response);
  }

  Future<Map<String, dynamic>> _post(
    String path, {
    required Map<String, dynamic> body,
    required Map<String, String> headers,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      path,
      data: body,
      options: Options(headers: headers),
    );
    return _unwrap(response);
  }

  Map<String, dynamic> _unwrap(Response<Map<String, dynamic>> response) {
    final data = response.data?['data'];
    if (data is Map<String, dynamic>) {
      return data;
    }
    throw DioException(
      requestOptions: response.requestOptions,
      message: 'Invalid sync API response envelope',
      response: response,
    );
  }
}
