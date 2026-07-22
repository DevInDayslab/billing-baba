import 'dart:async';
import 'dart:io';

import 'package:billing_baba/core/config/app_config.dart';
import 'package:billing_baba/core/logging/log_sanitizer.dart';
import 'package:billing_baba/core/network/network_error_details.dart';
import 'package:billing_baba/features/auth/services/otp_service.dart';
import 'package:dio/dio.dart';

/// Maps exceptions and HTTP errors to user-facing network error details.
abstract final class NetworkExceptionClassifier {
  static NetworkErrorDetails classify(
    Object error, {
    String? host,
    Duration? duration,
    int? httpStatus,
  }) {
    if (error is OtpException && error.cause != null) {
      return classify(error.cause!, host: host, duration: duration);
    }

    if (error is DioException) {
      return _fromDio(error, host: host, duration: duration);
    }

    if (error is SocketException) {
      return _socketError(error, host: host, duration: duration);
    }

    if (error is HandshakeException) {
      return NetworkErrorDetails(
        title: 'Connection failed',
        reason: 'SSL/TLS Certificate Error',
        host: host ?? _hostFromMessage(error.message),
        details: error.message,
        duration: duration,
        originalException: error,
      );
    }

    if (error is TimeoutException) {
      return NetworkErrorDetails(
        title: 'Connection failed',
        reason: 'Server Timeout',
        host: host,
        details: error.message ?? 'Request timed out',
        duration: duration,
        originalException: error,
      );
    }

    if (error is HttpException) {
      return NetworkErrorDetails(
        title: 'Connection failed',
        reason: 'HTTP Error',
        host: host,
        details: error.message,
        httpStatus: httpStatus,
        duration: duration,
        originalException: error,
      );
    }

    final message = error.toString();
    final lower = message.toLowerCase();

    if (lower.contains('failed host lookup') ||
        lower.contains('no address associated with hostname') ||
        lower.contains('nodename nor servname provided')) {
      return NetworkErrorDetails(
        title: 'Connection failed',
        reason: 'DNS Failure',
        host: host ?? _hostFromMessage(message),
        details: _extractDetail(message),
        duration: duration,
        originalException: error,
      );
    }

    if (lower.contains('connection refused') ||
        lower.contains('connection reset') ||
        lower.contains('network is unreachable')) {
      return NetworkErrorDetails(
        title: 'Connection failed',
        reason: 'Connection refused',
        host: host ?? _hostFromMessage(message),
        details: _extractDetail(message),
        duration: duration,
        originalException: error,
      );
    }

    if (lower.contains('certificate_verify_failed') ||
        lower.contains('handshake') ||
        lower.contains('ssl') ||
        lower.contains('tls')) {
      return NetworkErrorDetails(
        title: 'Connection failed',
        reason: 'SSL/TLS Certificate Error',
        host: host,
        details: _extractDetail(message),
        duration: duration,
        originalException: error,
      );
    }

    if (lower.contains('timeout') || lower.contains('timed out')) {
      return NetworkErrorDetails(
        title: 'Connection failed',
        reason: 'Server Timeout',
        host: host,
        details: _extractDetail(message),
        duration: duration,
        originalException: error,
      );
    }

    if (lower.contains('socketexception')) {
      return _socketErrorFromMessage(message, host: host, duration: duration);
    }

    if (lower.contains('clientexception')) {
      return NetworkErrorDetails(
        title: 'Connection failed',
        reason: 'Unable to reach server',
        host: host,
        details: _extractDetail(message),
        duration: duration,
        originalException: error,
      );
    }

  if (httpStatus != null) {
      return _fromHttpStatus(httpStatus, message, host: host, duration: duration);
    }

    return NetworkErrorDetails(
      title: 'Connection failed',
      reason: error.runtimeType.toString(),
      host: host,
      details: _extractDetail(message),
      duration: duration,
      originalException: error,
    );
  }

  static NetworkErrorDetails _fromDio(
    DioException error, {
    String? host,
    Duration? duration,
  }) {
    final resolvedHost =
        host ?? error.requestOptions.uri.host;
    final status = error.response?.statusCode;

    if (status != null) {
      return _fromHttpStatus(
        status,
        _dioDetailMessage(error),
        host: resolvedHost,
        duration: duration,
        originalException: error,
      );
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return NetworkErrorDetails(
          title: 'Connection failed',
          reason: 'Server Timeout',
          host: resolvedHost,
          details: error.message ?? 'Request timed out',
          duration: duration,
          originalException: error,
        );
      case DioExceptionType.connectionError:
        final inner = error.error;
        if (inner != null) {
          return classify(inner, host: resolvedHost, duration: duration);
        }
        return NetworkErrorDetails(
          title: 'Connection failed',
          reason: 'Unable to reach server',
          host: resolvedHost,
          details: error.message ?? 'Connection error',
          duration: duration,
          originalException: error,
        );
      case DioExceptionType.badCertificate:
        return NetworkErrorDetails(
          title: 'Connection failed',
          reason: 'SSL/TLS Certificate Error',
          host: resolvedHost,
          details: error.message ?? 'CERTIFICATE_VERIFY_FAILED',
          duration: duration,
          originalException: error,
        );
      case DioExceptionType.badResponse:
        return _fromHttpStatus(
          status ?? 0,
          _dioDetailMessage(error),
          host: resolvedHost,
          duration: duration,
          originalException: error,
        );
      case DioExceptionType.cancel:
        return NetworkErrorDetails(
          title: 'Connection failed',
          reason: 'Request cancelled',
          host: resolvedHost,
          details: error.message ?? 'Request was cancelled',
          duration: duration,
          originalException: error,
        );
      case DioExceptionType.unknown:
        final inner = error.error;
        if (inner != null) {
          return classify(inner, host: resolvedHost, duration: duration);
        }
        return NetworkErrorDetails(
          title: 'Connection failed',
          reason: error.runtimeType.toString(),
          host: resolvedHost,
          details: error.message ?? error.toString(),
          duration: duration,
          originalException: error,
        );
    }
  }

  static NetworkErrorDetails _fromHttpStatus(
    int status,
    String details, {
    String? host,
    Duration? duration,
    Object? originalException,
  }) {
    final reason = switch (status) {
      401 => 'Authentication failed',
      403 => 'Permission denied',
      404 => 'API endpoint not found',
      500 => 'Internal server error',
      502 => 'Bad Gateway',
      503 => 'Service unavailable',
      _ => 'HTTP $status',
    };

    return NetworkErrorDetails(
      title: 'Connection failed',
      reason: reason,
      host: host,
      details: details,
      httpStatus: status,
      duration: duration,
      originalException: originalException,
    );
  }

  static NetworkErrorDetails _socketError(
    SocketException error, {
    String? host,
    Duration? duration,
  }) {
    final message = error.message.toLowerCase();
    if (message.contains('failed host lookup') ||
        message.contains('no address associated')) {
      return NetworkErrorDetails(
        title: 'Connection failed',
        reason: 'DNS Failure',
        host: host ?? error.address?.host,
        details: error.message,
        duration: duration,
        originalException: error,
      );
    }
    if (message.contains('connection refused')) {
      return NetworkErrorDetails(
        title: 'Connection failed',
        reason: 'Connection refused',
        host: host ?? error.address?.host,
        details: error.message,
        duration: duration,
        originalException: error,
      );
    }
    return NetworkErrorDetails(
      title: 'Connection failed',
      reason: 'No Internet Connection',
      host: host ?? error.address?.host,
      details: error.message,
      duration: duration,
      originalException: error,
    );
  }

  static NetworkErrorDetails _socketErrorFromMessage(
    String message, {
    String? host,
    Duration? duration,
  }) {
    final lower = message.toLowerCase();
    if (lower.contains('failed host lookup')) {
      return NetworkErrorDetails(
        title: 'Connection failed',
        reason: 'DNS Failure',
        host: host,
        details: _extractDetail(message),
        duration: duration,
      );
    }
    return NetworkErrorDetails(
      title: 'Connection failed',
      reason: 'No Internet Connection',
      host: host,
      details: _extractDetail(message),
      duration: duration,
    );
  }

  static String _dioDetailMessage(DioException error) {
    final data = error.response?.data;
    if (data != null) {
      return LogSanitizer.truncate(data.toString());
    }
    return error.message ?? error.toString();
  }

  static String? _hostFromMessage(String message) {
    final match = RegExp(
      r'host lookup[:\s]+([^\s(]+)',
      caseSensitive: false,
    ).firstMatch(message);
    return match?.group(1);
  }

  static String _extractDetail(String message) {
    if (message.startsWith('Exception: ')) {
      return message.substring('Exception: '.length);
    }
    return message;
  }

  static String hostFromApiUrl() {
    return Uri.parse(AppConfig.apiBaseUrl).host;
  }
}
