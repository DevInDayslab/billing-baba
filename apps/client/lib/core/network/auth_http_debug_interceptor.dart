import 'package:billing_baba/core/config/app_config.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Logs auth and health HTTP traffic when [AppConfig.authDebugLogging] is enabled.
class AuthHttpDebugInterceptor extends Interceptor {
  static bool _isAuthRequest(RequestOptions options) {
    final path = options.path;
    return path.contains('/auth/') || path.contains('/health');
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (AppConfig.authDebugLogging && _isAuthRequest(options)) {
      debugPrint('[AUTH_HTTP] → ${options.method} ${options.uri}');
      debugPrint('[AUTH_HTTP]   baseUrl: ${options.baseUrl}');
      debugPrint('[AUTH_HTTP]   body: ${options.data}');
    }
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    if (AppConfig.authDebugLogging && _isAuthRequest(response.requestOptions)) {
      debugPrint(
        '[AUTH_HTTP] ← ${response.statusCode} '
        '${response.requestOptions.method} ${response.requestOptions.uri}',
      );
      debugPrint('[AUTH_HTTP]   body: ${response.data}');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (AppConfig.authDebugLogging && _isAuthRequest(err.requestOptions)) {
      debugPrint(
        '[AUTH_HTTP] ✗ ${err.type} '
        '${err.requestOptions.method} ${err.requestOptions.uri}',
      );
      debugPrint('[AUTH_HTTP]   status: ${err.response?.statusCode}');
      debugPrint('[AUTH_HTTP]   message: ${err.message}');
      debugPrint('[AUTH_HTTP]   response: ${err.response?.data}');
      debugPrint('[AUTH_HTTP]   stackTrace:\n${err.stackTrace}');
    }
    handler.next(err);
  }
}
