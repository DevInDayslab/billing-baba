import 'package:billing_baba/core/network/network_error_details.dart';

/// Result of a backend connectivity / health check.
class ConnectivityTestResult {
  const ConnectivityTestResult({
    required this.success,
    this.resolvedIp,
    this.dnsLookupDuration,
    this.connectionDuration,
    this.httpStatus,
    this.failureStage,
    this.failureMessage,
    this.healthUrl,
    this.responseBody,
  });

  final bool success;
  final String? resolvedIp;
  final Duration? dnsLookupDuration;
  final Duration? connectionDuration;
  final int? httpStatus;
  final String? failureStage;
  final String? failureMessage;
  final String? healthUrl;
  final String? responseBody;

  NetworkErrorDetails? toErrorDetails() {
    if (success) return null;
    return NetworkErrorDetails(
      title: 'Connection failed',
      reason: _stageReason(failureStage),
      host: healthUrl != null ? Uri.tryParse(healthUrl!)?.host : null,
      details: failureMessage ?? 'Connectivity test failed',
      httpStatus: httpStatus,
      duration: connectionDuration,
    );
  }

  @override
  String toString() {
    if (success) {
      return 'ConnectivityTest OK ip=$resolvedIp '
          'dns=${dnsLookupDuration?.inMilliseconds}ms '
          'connect=${connectionDuration?.inMilliseconds}ms '
          'status=$httpStatus';
    }
    return 'ConnectivityTest FAILED stage=$failureStage '
        'message=$failureMessage ip=$resolvedIp '
        'dns=${dnsLookupDuration?.inMilliseconds}ms '
        'status=$httpStatus';
  }

  static String _stageReason(String? stage) {
    return switch (stage) {
      'dns' => 'DNS Failure',
      'tcp' => 'Connection refused',
      'tls' => 'SSL/TLS Certificate Error',
      'http' => 'HTTP Error',
      'timeout' => 'Server Timeout',
      _ => 'Network Error',
    };
  }
}

/// In-memory diagnostics state for the debug screen.
class DiagnosticsStore {
  DiagnosticsStore._();

  static final DiagnosticsStore instance = DiagnosticsStore._();

  String? lastApiCall;
  NetworkErrorDetails? lastError;
  ConnectivityTestResult? lastConnectivityTest;
  DateTime? lastConnectivityTestAt;
  bool? networkReachable;
  bool? backendReachable;

  void recordApiCall({
    required String method,
    required String url,
    required int? statusCode,
    required Duration duration,
  }) {
    lastApiCall =
        '$method $url → ${statusCode ?? 'error'} (${duration.inMilliseconds}ms)';
  }

  void recordError(NetworkErrorDetails error) {
    lastError = error;
  }

  void recordConnectivityTest(ConnectivityTestResult result) {
    lastConnectivityTest = result;
    lastConnectivityTestAt = DateTime.now();
    backendReachable = result.success;
  }

  void setNetworkReachable(bool reachable) {
    networkReachable = reachable;
  }

  void clear() {
    lastApiCall = null;
    lastError = null;
    lastConnectivityTest = null;
    lastConnectivityTestAt = null;
    networkReachable = null;
    backendReachable = null;
  }
}
