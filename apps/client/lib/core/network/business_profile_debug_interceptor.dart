import 'package:billing_baba/features/business/utils/business_profile_debug_log.dart';
import 'package:dio/dio.dart';

/// Logs business profile API traffic when debug logging is enabled.
class BusinessProfileDebugInterceptor extends Interceptor {
  static bool _isProfileRequest(RequestOptions options) {
    final path = options.path;
    return path.contains('/business/profile') ||
        path.contains('/auth/refresh') ||
        path.contains('/auth/me');
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (BusinessProfileDebugLog.enabled && _isProfileRequest(options)) {
      BusinessProfileDebugLog.section('HTTP REQUEST');
      BusinessProfileDebugLog.log('${options.method} ${options.uri}');
      BusinessProfileDebugLog.log(
        'headers: ${BusinessProfileDebugLog.sanitizeHeaders(options.headers)}',
      );
      BusinessProfileDebugLog.log('body: ${options.data}');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    if (BusinessProfileDebugLog.enabled &&
        _isProfileRequest(response.requestOptions)) {
      BusinessProfileDebugLog.section('HTTP RESPONSE');
      BusinessProfileDebugLog.log(
        '${response.requestOptions.method} ${response.requestOptions.uri}',
      );
      BusinessProfileDebugLog.log('status: ${response.statusCode}');
      BusinessProfileDebugLog.log('body: ${response.data}');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (BusinessProfileDebugLog.enabled &&
        _isProfileRequest(err.requestOptions)) {
      BusinessProfileDebugLog.section('HTTP ERROR');
      BusinessProfileDebugLog.log(
        '${err.requestOptions.method} ${err.requestOptions.uri}',
      );
      BusinessProfileDebugLog.log('type: ${err.type}');
      BusinessProfileDebugLog.log('status: ${err.response?.statusCode}');
      BusinessProfileDebugLog.log('response: ${err.response?.data}');
      BusinessProfileDebugLog.log('message: ${err.message}');
      if (err.stackTrace.toString().isNotEmpty) {
        BusinessProfileDebugLog.log('stack: ${err.stackTrace}');
      }
    }
    handler.next(err);
  }
}
