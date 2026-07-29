import 'package:billing_baba/core/config/app_config.dart';
import 'package:billing_baba/core/logging/diagnostics_store.dart';
import 'package:billing_baba/core/logging/log_sanitizer.dart';
import 'package:billing_baba/core/logging/logging_service.dart';
import 'package:billing_baba/core/network/network_exception_classifier.dart';
import 'package:dio/dio.dart';

/// Centralized Dio interceptor for HTTP request/response/error logging.
class HttpLoggingInterceptor extends Interceptor {
  static const _extraStartTime = 'logging_start_time';
  static const _extraRetryCount = 'logging_retry_count';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra[_extraStartTime] = DateTime.now().millisecondsSinceEpoch;
    if (AppConfig.consoleVerbose) {
      final headers = LogSanitizer.sanitizeHeaders(options.headers);
      final body = LogSanitizer.sanitizeBody(options.data);
      LoggingService.instance.info(
        '→ ${options.method} ${options.uri}',
      );
      LoggingService.instance.info('  Headers: $headers');
      if (body != '(empty)') {
        LoggingService.instance.info('  Body: $body');
      }
    }
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    final duration = _elapsed(response.requestOptions);
    final status = response.statusCode;
    final body = LogSanitizer.truncate(
      LogSanitizer.sanitizeBody(response.data),
    );

    if (AppConfig.consoleVerbose) {
      LoggingService.instance.info(
        '← ${response.requestOptions.method} ${response.requestOptions.uri}',
      );
      LoggingService.instance.info('  Status $status');
      LoggingService.instance.info('  Duration ${duration.inMilliseconds}ms');
      LoggingService.instance.info('  Response: $body');
    }

    DiagnosticsStore.instance.recordApiCall(
      method: response.requestOptions.method,
      url: response.requestOptions.uri.toString(),
      statusCode: status,
      duration: duration,
    );

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final duration = _elapsed(err.requestOptions);
    final status = err.response?.statusCode;
    final body = LogSanitizer.truncate(
      LogSanitizer.sanitizeBody(err.response?.data),
    );

    if (AppConfig.consoleVerbose) {
      final isRecoverableAuth401 =
          status == 401 &&
          err.requestOptions.path.contains('/auth/me');
      final message =
          '✗ ${err.requestOptions.method} ${err.requestOptions.uri}\n'
          '  Type: ${err.type}\n'
          '  Status: $status\n'
          '  Duration: ${duration.inMilliseconds}ms\n'
          '  Message: ${err.message}\n'
          '  Response: $body';

      if (isRecoverableAuth401) {
        LoggingService.instance.info(message);
      } else {
        LoggingService.instance.error(
          message,
          err,
          err.stackTrace,
        );
      }
    }

    DiagnosticsStore.instance.recordApiCall(
      method: err.requestOptions.method,
      url: err.requestOptions.uri.toString(),
      statusCode: status,
      duration: duration,
    );

    final details = NetworkExceptionClassifier.classify(
      err,
      host: err.requestOptions.uri.host,
      duration: duration,
      httpStatus: status,
    );
    DiagnosticsStore.instance.recordError(details);

    handler.next(err);
  }

  Duration _elapsed(RequestOptions options) {
    final start = options.extra[_extraStartTime] as int?;
    if (start == null) return Duration.zero;
    return Duration(
      milliseconds: DateTime.now().millisecondsSinceEpoch - start,
    );
  }

  /// Call when retrying a request (e.g. after 401 refresh).
  static void logRetry(RequestOptions options, {required String reason}) {
    final count = (options.extra[_extraRetryCount] as int? ?? 0) + 1;
    options.extra[_extraRetryCount] = count;
    if (AppConfig.consoleVerbose) {
      LoggingService.instance.warn(
        '↻ Retry #$count ${options.method} ${options.uri} ($reason)',
      );
    }
  }
}
