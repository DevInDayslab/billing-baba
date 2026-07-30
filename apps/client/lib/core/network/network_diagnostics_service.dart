import 'dart:async';
import 'dart:io';

import 'package:billing_baba/core/config/app_config.dart';
import 'package:billing_baba/core/logging/diagnostics_store.dart';
import 'package:billing_baba/core/logging/logging_service.dart';
import 'package:billing_baba/core/network/api_endpoints.dart';
import 'package:billing_baba/core/network/pinned_api_http_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Runs DNS, TCP/TLS, and HTTP health checks against the API.
class NetworkDiagnosticsService {
  NetworkDiagnosticsService({Dio? dio}) : _dio = dio ?? _createDio();

  final Dio _dio;

  static Dio _createDio() {
    return Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {'Content-Type': 'application/json'},
      ),
    )..httpClientAdapter = createBypassSslHttpClientAdapter();
  }

  Future<ConnectivityTestResult> runConnectivityTest({
    String? baseUrl,
  }) async {
    final resolvedBase = baseUrl ?? AppConfig.apiBaseUrl;
    final uri = Uri.parse(resolvedBase);
    final host = uri.host;
    final healthUrl = '${resolvedBase.replaceAll(RegExp(r'/+$'), '')}'
        '${ApiEndpoints.health}';

    LoggingService.instance.info('Connectivity test starting host=$host');
    LoggingService.instance.info('Health URL: $healthUrl');

    Duration? dnsDuration;
    String? resolvedIp;

    if (!kIsWeb) {
      final dnsStart = Stopwatch()..start();
      try {
        final addresses = await InternetAddress.lookup(host)
            .timeout(const Duration(seconds: 10));
        dnsDuration = dnsStart.elapsed;
        if (addresses.isNotEmpty) {
          resolvedIp = addresses.first.address;
        }
        LoggingService.instance.info(
          'DNS lookup OK ip=$resolvedIp duration=${dnsDuration.inMilliseconds}ms',
        );
      } on TimeoutException catch (e) {
        dnsDuration = dnsStart.elapsed;
        final result = ConnectivityTestResult(
          success: false,
          resolvedIp: resolvedIp,
          dnsLookupDuration: dnsDuration,
          failureStage: 'timeout',
          failureMessage: 'DNS lookup timed out: $e',
          healthUrl: healthUrl,
        );
        _record(result);
        return result;
      } on SocketException catch (e) {
        dnsDuration = dnsStart.elapsed;
        final result = ConnectivityTestResult(
          success: false,
          resolvedIp: resolvedIp,
          dnsLookupDuration: dnsDuration,
          failureStage: 'dns',
          failureMessage: e.message,
          healthUrl: healthUrl,
        );
        _record(result);
        return result;
      } on Object catch (e) {
        dnsDuration = dnsStart.elapsed;
        final result = ConnectivityTestResult(
          success: false,
          dnsLookupDuration: dnsDuration,
          failureStage: 'dns',
          failureMessage: e.toString(),
          healthUrl: healthUrl,
        );
        _record(result);
        return result;
      }
    }

    final connectStart = Stopwatch()..start();
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        healthUrl,
        options: Options(
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          validateStatus: (_) => true,
        ),
      );
      final connectionDuration = connectStart.elapsed;
      final status = response.statusCode;
      final data = response.data?['data'] as Map<String, dynamic>?;
      final healthy =
          status == 200 && data?['status']?.toString() == 'ok';

      LoggingService.instance.info(
        'Health check status=$status healthy=$healthy '
        'duration=${connectionDuration.inMilliseconds}ms',
      );

      final result = ConnectivityTestResult(
        success: healthy,
        resolvedIp: resolvedIp,
        dnsLookupDuration: dnsDuration,
        connectionDuration: connectionDuration,
        httpStatus: status,
        failureStage: healthy ? null : 'http',
        failureMessage: healthy
            ? null
            : 'Health check returned HTTP $status: ${response.data}',
        healthUrl: healthUrl,
        responseBody: response.data?.toString(),
      );
      _record(result);
      return result;
    } on DioException catch (e) {
      final connectionDuration = connectStart.elapsed;
      final stage = _failureStageFromDio(e);
      final result = ConnectivityTestResult(
        success: false,
        resolvedIp: resolvedIp,
        dnsLookupDuration: dnsDuration,
        connectionDuration: connectionDuration,
        httpStatus: e.response?.statusCode,
        failureStage: stage,
        failureMessage: e.message ?? e.toString(),
        healthUrl: healthUrl,
        responseBody: e.response?.data?.toString(),
      );
      _record(result);
      return result;
    } on HandshakeException catch (e) {
      final connectionDuration = connectStart.elapsed;
      final result = ConnectivityTestResult(
        success: false,
        resolvedIp: resolvedIp,
        dnsLookupDuration: dnsDuration,
        connectionDuration: connectionDuration,
        failureStage: 'tls',
        failureMessage: e.message,
        healthUrl: healthUrl,
      );
      _record(result);
      return result;
    } on TimeoutException catch (e) {
      final connectionDuration = connectStart.elapsed;
      final result = ConnectivityTestResult(
        success: false,
        resolvedIp: resolvedIp,
        dnsLookupDuration: dnsDuration,
        connectionDuration: connectionDuration,
        failureStage: 'timeout',
        failureMessage: e.toString(),
        healthUrl: healthUrl,
      );
      _record(result);
      return result;
    } on SocketException catch (e) {
      final connectionDuration = connectStart.elapsed;
      final stage = e.message.toLowerCase().contains('failed host lookup')
          ? 'dns'
          : 'tcp';
      final result = ConnectivityTestResult(
        success: false,
        resolvedIp: resolvedIp,
        dnsLookupDuration: dnsDuration,
        connectionDuration: connectionDuration,
        failureStage: stage,
        failureMessage: e.message,
        healthUrl: healthUrl,
      );
      _record(result);
      return result;
    }
  }

  void _record(ConnectivityTestResult result) {
    DiagnosticsStore.instance.recordConnectivityTest(result);
    LoggingService.instance.info('Connectivity test result: $result');
  }

  static String _failureStageFromDio(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return 'timeout';
    }
    if (error.type == DioExceptionType.badCertificate) {
      return 'tls';
    }
    final inner = error.error;
    if (inner is HandshakeException) return 'tls';
    if (inner is SocketException) {
      final msg = inner.message.toLowerCase();
      if (msg.contains('failed host lookup')) return 'dns';
      return 'tcp';
    }
    if (error.response != null) return 'http';
    return 'tcp';
  }
}
