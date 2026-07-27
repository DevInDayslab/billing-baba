import 'package:billing_baba/core/network/api_endpoints.dart';
import 'package:dio/dio.dart';

/// HTTP client for `/api/v1/sync/*` with protocol headers attached.
///
/// Features must not call this directly — only SyncEngine / SyncCoordinator.
class SyncApi {
  SyncApi(this._dio, {this.protocolVersion = '1'});

  final Dio _dio;
  final String protocolVersion;

  Future<Map<String, dynamic>> registerDevice({
    required String deviceId,
    required String platform,
    required String appVersion,
    required String deviceName,
  }) {
    return _post(
      ApiEndpoints.syncDevices,
      deviceId: deviceId,
      appVersion: appVersion,
      body: {
        'device_id': deviceId,
        'platform': platform,
        'app_version': appVersion,
        'device_name': deviceName,
      },
    );
  }

  Future<Map<String, dynamic>> status({
    required String deviceId,
    required String appVersion,
  }) {
    return _get(
      ApiEndpoints.syncStatus,
      deviceId: deviceId,
      appVersion: appVersion,
    );
  }

  /// MVP bootstrap: returns `{ initial_cursor, schema_version, ... }`.
  Future<Map<String, dynamic>> bootstrap({
    required String deviceId,
    required String appVersion,
    required int schemaVersion,
  }) {
    return _post(
      ApiEndpoints.syncBootstrap,
      deviceId: deviceId,
      appVersion: appVersion,
      body: {
        'device_id': deviceId,
        'schema_version': schemaVersion,
        'include_media_metadata': false,
      },
    );
  }

  Future<Map<String, dynamic>> push({
    required String deviceId,
    required String appVersion,
    required Map<String, dynamic> body,
  }) {
    return _post(
      ApiEndpoints.syncPush,
      deviceId: deviceId,
      appVersion: appVersion,
      body: body,
    );
  }

  Future<Map<String, dynamic>> pull({
    required String deviceId,
    required String appVersion,
    required String cursor,
    int? limit,
    String? entityTypes,
  }) {
    return _get(
      ApiEndpoints.syncPull,
      deviceId: deviceId,
      appVersion: appVersion,
      queryParameters: {
        'cursor': cursor,
        'limit': ?limit,
        'entity_types': ?entityTypes,
      },
    );
  }

  Map<String, String> _headers({
    required String deviceId,
    required String appVersion,
  }) {
    return {
      'X-Device-Id': deviceId,
      'X-App-Version': appVersion,
      'X-Sync-Protocol-Version': protocolVersion,
    };
  }

  Future<Map<String, dynamic>> _get(
    String path, {
    required String deviceId,
    required String appVersion,
    Map<String, dynamic>? queryParameters,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      path,
      queryParameters: queryParameters,
      options: Options(headers: _headers(deviceId: deviceId, appVersion: appVersion)),
    );
    return _unwrap(response);
  }

  Future<Map<String, dynamic>> _post(
    String path, {
    required String deviceId,
    required String appVersion,
    required Map<String, dynamic> body,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      path,
      data: body,
      options: Options(headers: _headers(deviceId: deviceId, appVersion: appVersion)),
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
