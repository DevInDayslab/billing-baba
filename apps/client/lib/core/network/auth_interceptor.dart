import 'package:billing_baba/core/constants/storage_keys.dart';
import 'package:billing_baba/core/network/http_logging_interceptor.dart';
import 'package:billing_baba/core/services/storage_service.dart';
import 'package:dio/dio.dart';

typedef TokenRefreshCallback = Future<String?> Function();
typedef AccessTokenFallback = Future<String?> Function();

class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required this._storage,
    required this._client,
    this._onRefreshToken,
    this._accessTokenFallback,
  });

  final StorageService _storage;
  final Dio _client;
  final TokenRefreshCallback? _onRefreshToken;
  final AccessTokenFallback? _accessTokenFallback;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    var token = await _storage.readSecure(StorageKeys.accessToken);
    if ((token == null || token.isEmpty) && _accessTokenFallback != null) {
      token = await _accessTokenFallback.call();
    }
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
      // AuthService._withRefreshLock serializes refresh across all callers.
      final newToken = await onRefreshToken();
      if (newToken == null || newToken.isEmpty) {
        return handler.next(err);
      }

      final options = err.requestOptions;
      options.headers['Authorization'] = 'Bearer $newToken';
      options.extra['retried'] = true;
      HttpLoggingInterceptor.logRetry(options, reason: '401 token refresh');

      final response = await _client.fetch<dynamic>(options);
      return handler.resolve(response);
    } on Object catch (_) {
      return handler.next(err);
    }
  }
}
