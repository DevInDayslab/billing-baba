import 'package:billing_baba/core/constants/storage_keys.dart';
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
  bool _isRefreshing = false;

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
        _isRefreshing ||
        err.requestOptions.extra['retried'] == true) {
      return handler.next(err);
    }

    _isRefreshing = true;
    try {
      final newToken = await onRefreshToken();
      if (newToken == null || newToken.isEmpty) {
        return handler.next(err);
      }

      final options = err.requestOptions;
      options.headers['Authorization'] = 'Bearer $newToken';
      options.extra['retried'] = true;

      final dio = Dio(
        BaseOptions(
          baseUrl: options.baseUrl,
          connectTimeout: options.connectTimeout,
          receiveTimeout: options.receiveTimeout,
        ),
      );
      final response = await dio.fetch<dynamic>(options);
      return handler.resolve(response);
    } catch (_) {
      return handler.next(err);
    } finally {
      _isRefreshing = false;
    }
  }
}
