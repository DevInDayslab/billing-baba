import 'package:billing_baba/core/network/pinned_api_http_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Uploads bytes via presigned intent → PUT → complete flow.
class MediaUploadClient {
  MediaUploadClient(this._apiDio);

  final Dio _apiDio;
  final Dio _rawDio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
    ),
  )..httpClientAdapter = createBypassSslHttpClientAdapter();

  Future<Map<String, dynamic>> upload({
    required String endpoint,
    required Uint8List bytes,
    required String mimeType,
    Map<String, dynamic>? completeExtra,
  }) async {
    Map<String, dynamic> intent;
    try {
      final intentResponse = await _apiDio.post<Map<String, dynamic>>(
        endpoint,
        data: {
          'mime_type': mimeType,
          'file_size': bytes.length,
        },
      );

      final data = intentResponse.data?['data'];
      if (data is! Map<String, dynamic>) {
        throw DioException(
          requestOptions: intentResponse.requestOptions,
          message: 'Invalid upload intent response',
        );
      }
      intent = data;
    } on DioException catch (error) {
      throw DioException(
        requestOptions: error.requestOptions,
        response: error.response,
        type: error.type,
        error: error.error,
        message: 'Upload intent failed: ${error.message ?? error.type.name}',
      );
    }

    final uploadUrl = intent['upload_url'] as String?;
    final intentId = intent['intent_id'] as String?;
    if (uploadUrl == null || intentId == null) {
      throw DioException(
        requestOptions: RequestOptions(path: endpoint),
        message: 'Upload intent missing upload_url or intent_id',
      );
    }

    final uploadHost = _hostOf(uploadUrl);
    if (kDebugMode) {
      debugPrint(
        '[MediaUpload] intent ok intentId=$intentId host=$uploadHost '
        'bytes=${bytes.length} mime=$mimeType',
      );
    }

    final headers = <String, dynamic>{};
    final rawHeaders = intent['headers'];
    if (rawHeaders is Map) {
      rawHeaders.forEach((key, value) {
        if (key is String && value != null) {
          headers[key] = value.toString();
        }
      });
    }
    // Match signed headers from the intent (Content-Type / Content-Length).
    headers['Content-Type'] = headers['Content-Type'] ?? mimeType;
    headers['Content-Length'] = bytes.length.toString();

    try {
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
      if (kDebugMode) {
        debugPrint('[MediaUpload] PUT ok host=$uploadHost');
      }
    } on DioException catch (error) {
      if (kDebugMode) {
        debugPrint(
          '[MediaUpload] PUT failed host=$uploadHost '
          'type=${error.type} status=${error.response?.statusCode} '
          'msg=${error.message}',
        );
      }
      throw DioException(
        requestOptions: error.requestOptions,
        response: error.response,
        type: error.type,
        error: error.error,
        message:
            'Storage upload failed (PUT to $uploadHost): '
            '${error.message ?? error.type.name}',
      );
    }

    try {
      final completeResponse = await _apiDio.post<Map<String, dynamic>>(
        endpoint,
        data: {
          'intent_id': intentId,
          ...?completeExtra,
        },
      );

      final data = completeResponse.data?['data'];
      if (data is! Map<String, dynamic>) {
        throw DioException(
          requestOptions: completeResponse.requestOptions,
          message: 'Invalid upload complete response',
        );
      }
      if (kDebugMode) {
        debugPrint('[MediaUpload] complete ok intentId=$intentId');
      }
      return data;
    } on DioException catch (error) {
      if (kDebugMode) {
        debugPrint(
          '[MediaUpload] complete failed intentId=$intentId '
          'type=${error.type} status=${error.response?.statusCode}',
        );
      }
      throw DioException(
        requestOptions: error.requestOptions,
        response: error.response,
        type: error.type,
        error: error.error,
        message: 'Upload complete failed: ${error.message ?? error.type.name}',
      );
    }
  }

  static String _hostOf(String url) {
    try {
      return Uri.parse(url).host;
    } on FormatException {
      return 'unknown';
    }
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
