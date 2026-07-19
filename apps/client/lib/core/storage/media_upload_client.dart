import 'dart:typed_data';

import 'package:dio/dio.dart';

/// Uploads bytes via presigned intent → PUT → complete flow.
class MediaUploadClient {
  MediaUploadClient(this._apiDio);

  final Dio _apiDio;
  final Dio _rawDio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
    ),
  );

  Future<Map<String, dynamic>> upload({
    required String endpoint,
    required Uint8List bytes,
    required String mimeType,
    Map<String, dynamic>? completeExtra,
  }) async {
    final intentResponse = await _apiDio.post<Map<String, dynamic>>(
      endpoint,
      data: {
        'mime_type': mimeType,
        'file_size': bytes.length,
      },
    );

    final intent = intentResponse.data?['data'];
    if (intent is! Map<String, dynamic>) {
      throw DioException(
        requestOptions: intentResponse.requestOptions,
        message: 'Invalid upload intent response',
      );
    }

    final uploadUrl = intent['upload_url'] as String?;
    final intentId = intent['intent_id'] as String?;
    if (uploadUrl == null || intentId == null) {
      throw DioException(
        requestOptions: intentResponse.requestOptions,
        message: 'Upload intent missing upload_url or intent_id',
      );
    }

    final headers = <String, String>{};
    final rawHeaders = intent['headers'];
    if (rawHeaders is Map) {
      rawHeaders.forEach((key, value) {
        if (key is String && value != null) {
          headers[key] = value.toString();
        }
      });
    }

    await _rawDio.put<void>(
      uploadUrl,
      data: bytes,
      options: Options(
        headers: headers,
        contentType: mimeType,
        sendTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
      ),
    );

    final completeResponse = await _apiDio.post<Map<String, dynamic>>(
      endpoint,
      data: {
        'intent_id': intentId,
        if (completeExtra != null) ...completeExtra,
      },
    );

    final data = completeResponse.data?['data'];
    if (data is! Map<String, dynamic>) {
      throw DioException(
        requestOptions: completeResponse.requestOptions,
        message: 'Invalid upload complete response',
      );
    }

    return data;
  }
}

String mimeTypeFromFilename(String filename) {
  final lower = filename.toLowerCase();
  if (lower.endsWith('.png')) return 'image/png';
  if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) {
    return 'image/jpeg';
  }
  if (lower.endsWith('.webp')) return 'image/webp';
  return 'application/octet-stream';
}

bool isAllowedMime(String mimeType, Set<String> allowed) =>
    allowed.contains(mimeType);
