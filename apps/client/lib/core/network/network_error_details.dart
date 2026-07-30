/// Structured network error for UI display and diagnostics.
class NetworkErrorDetails {
  const NetworkErrorDetails({
    required this.title,
    required this.reason,
    required this.details,
    this.host,
    this.httpStatus,
    this.duration,
    this.originalException,
  });

  final String title;
  final String reason;
  final String? host;
  final String details;
  final int? httpStatus;
  final Duration? duration;
  final Object? originalException;

  String get userMessage => title;

  String get summaryLines {
    final buffer = StringBuffer()..writeln(title);
    buffer.writeln('Reason: $reason');
    if (host != null && host!.isNotEmpty) {
      buffer.writeln('Host: $host');
    }
    buffer.write('Details: $details');
    if (httpStatus != null) {
      buffer.write('\nHTTP Status: $httpStatus');
    }
    if (duration != null) {
      buffer.write('\nDuration: ${duration!.inMilliseconds}ms');
    }
    return buffer.toString();
  }

  @override
  String toString() => summaryLines;
}
