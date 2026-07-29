import 'dart:async';

import 'package:billing_baba/core/constants/storage_keys.dart';
import 'package:billing_baba/core/network/http_logging_interceptor.dart';
import 'package:billing_baba/core/services/storage_service.dart';
import 'package:dio/dio.dart';

typedef TokenRefreshCallback = Future<String?> Function();

class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required this._storage,
    this._onRefreshToken,
  });

  final StorageService _storage;
  final TokenRefreshCallback? _onRefreshToken;
  Completer<String?>? _refreshCompleter;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.readSecure(StorageKeys.accessToken);
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final onRefreshToken = _onRefreshToken;
    if (err.response?.statusCode != 401 ||
        onRefreshToken == null ||
        err.requestOptions.extra['retried'] == true) {
      return handler.next(err);
    }

    try {
      final newToken = await _refreshAccessToken(onRefreshToken);
      if (newToken == null || newToken.isEmpty) {
        return handler.next(err);
      }

      final options = err.requestOptions;
      options.headers['Authorization'] = 'Bearer $newToken';
      options.extra['retried'] = true;
      HttpLoggingInterceptor.logRetry(options, reason: '401 token refresh');

      final dio = Dio(
        BaseOptions(
          baseUrl: options.baseUrl,
          connectTimeout: options.connectTimeout,
          receiveTimeout: options.receiveTimeout,
        ),
      );
      final response = await dio.fetch<dynamic>(options);
      return handler.resolve(response);
    } on Object catch (_) {
      return handler.next(err);
    }
  }

  Future<String?> _refreshAccessToken(TokenRefreshCallback onRefreshToken) {
    final inFlight = _refreshCompleter;
    if (inFlight != null) {
      return inFlight.future;
    }

    final completer = Completer<String?>();
    _refreshCompleter = completer;
    onRefreshToken().then(completer.complete).catchError(completer.completeError);
    return completer.future.whenComplete(() {
      _refreshCompleter = null;
    });
  }
}
