import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';

/// In-memory cache for item gallery and rack photo bytes.
class ItemImageCache {
  ItemImageCache(this._dio);

  final Dio _dio;
  final Map<String, Uint8List> _cache = {};

  static const _fetchTimeout = Duration(seconds: 15);

  Future<Uint8List?> getBytes(String? url) async {
    if (url == null || url.trim().isEmpty) {
      return null;
    }

    final normalized = url.trim();
    final cached = _cache[normalized];
    if (cached != null) {
      return cached;
    }

    try {
      final response = await _dio.get<List<int>>(
        normalized,
        options: Options(
          responseType: ResponseType.bytes,
          receiveTimeout: _fetchTimeout,
        ),
      );
      final data = response.data;
      if (data == null || data.isEmpty) {
        return null;
      }
      final bytes = Uint8List.fromList(data);
      _cache[normalized] = bytes;
      return bytes;
    } on DioException {
      return null;
    }
  }

  void prefetch(String? url) {
    if (url == null || url.trim().isEmpty) return;
    unawaited(getBytes(url));
  }

  void clear() => _cache.clear();
}
