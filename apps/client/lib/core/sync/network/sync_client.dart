import 'dart:typed_data';

import 'package:billing_baba/core/sync/network/sync_api.dart';
import 'package:billing_baba/core/sync/network/sync_headers.dart';

/// Higher-level sync transport that attaches protocol headers.
///
/// Still network-only — no queue or engine logic.
class SyncClient {
  SyncClient({
    required this._api,
    required SyncHeaderProvider headerProvider,
  })  : _headers = headerProvider;

  final SyncApi _api;
  final SyncHeaderProvider _headers;

  Future<Map<String, dynamic>> registerDevice({
    required String deviceId,
    required String platform,
    required String appVersion,
    required String deviceName,
  }) async {
    final headers = await _headers.build(deviceId: deviceId, appVersion: appVersion);
    return _api.registerDevice(
      body: {
        'device_id': deviceId,
        'platform': platform,
        'app_version': appVersion,
        'device_name': deviceName,
      },
      headers: headers,
    );
  }

  Future<Map<String, dynamic>> status({
    required String deviceId,
    required String appVersion,
  }) async {
    final headers = await _headers.build(
      deviceId: deviceId,
      appVersion: appVersion,
    );
    return _api.status(headers: headers);
  }

  Future<Map<String, dynamic>> bootstrap({
    required String deviceId,
    required String appVersion,
    required int schemaVersion,
    bool includeMediaMetadata = true,
  }) async {
    final headers = await _headers.build(
      deviceId: deviceId,
      appVersion: appVersion,
    );
    return _api.bootstrap(
      body: {
        'device_id': deviceId,
        'schema_version': schemaVersion,
        'include_media_metadata': includeMediaMetadata,
      },
      headers: headers,
    );
  }

  Future<Map<String, dynamic>> bootstrapChunk({
    required String deviceId,
    required String appVersion,
    required String bootstrapId,
    required int chunkIndex,
    int page = 1,
  }) async {
    final headers = await _headers.build(
      deviceId: deviceId,
      appVersion: appVersion,
    );
    return _api.bootstrapChunk(
      bootstrapId: bootstrapId,
      chunkIndex: chunkIndex,
      headers: headers,
      page: page,
    );
  }

  Future<Map<String, dynamic>> push({
    required String deviceId,
    required String appVersion,
    required Map<String, dynamic> body,
  }) async {
    final headers = await _headers.build(
      deviceId: deviceId,
      appVersion: appVersion,
    );
    return _api.push(body: body, headers: headers);
  }

  Future<Map<String, dynamic>> pull({
    required String deviceId,
    required String appVersion,
    required String cursor,
    int? limit,
    String? entityTypes,
  }) async {
    final headers = await _headers.build(
      deviceId: deviceId,
      appVersion: appVersion,
    );
    return _api.pull(
      cursor: cursor,
      headers: headers,
      limit: limit,
      entityTypes: entityTypes,
    );
  }

  Future<Map<String, dynamic>> uploadMedia({
    required String deviceId,
    required String appVersion,
    required Map<String, dynamic> body,
  }) async {
    final headers = await _headers.build(
      deviceId: deviceId,
      appVersion: appVersion,
    );
    return _api.uploadMedia(body: body, headers: headers);
  }

  Future<Map<String, dynamic>> completeMedia({
    required String deviceId,
    required String appVersion,
    required Map<String, dynamic> body,
  }) async {
    final headers = await _headers.build(
      deviceId: deviceId,
      appVersion: appVersion,
    );
    return _api.completeMedia(body: body, headers: headers);
  }

  Future<Map<String, dynamic>> getMediaUrl({
    required String deviceId,
    required String appVersion,
    required String assetId,
    String variant = 'original',
  }) async {
    final headers = await _headers.build(
      deviceId: deviceId,
      appVersion: appVersion,
    );
    return _api.getMediaUrl(
      assetId: assetId,
      headers: headers,
      variant: variant,
    );
  }

  Future<void> putMediaBytes({
    required String uploadUrl,
    required Uint8List bytes,
    required Map<String, String> headers,
    required String contentType,
  }) =>
      _api.putBytes(
        uploadUrl: uploadUrl,
        bytes: bytes,
        headers: headers,
        contentType: contentType,
      );
}
