import 'package:intl/intl.dart';

final _mobileReportMetaDateFormat = DateFormat('dd MMM, yy');
final _mobileReportMetaTimeFormat = DateFormat('hh:mm a');
final _uuidLike = RegExp(
  r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
);

String formatMobileReportMetaDateTime(DateTime dateTime) {
  final date = _mobileReportMetaDateFormat.format(dateTime).toUpperCase();
  final time = _mobileReportMetaTimeFormat.format(dateTime).toLowerCase();
  return '$date • $time';
}

String formatMobileReportDueDate(DateTime? date) {
  if (date == null) return '-';
  return _mobileReportMetaDateFormat.format(date).toUpperCase();
}

String formatMobileReportDateRange(DateTime start, DateTime end) {
  final format = DateFormat('dd/MM/yy');
  return '${format.format(start)} – ${format.format(end)}';
}

/// Builds a compact reference label, shortening UUID-like ids for narrow layouts.
String formatMobileReportReference(String prefix, String refNo) {
  final trimmedPrefix = prefix.trim();
  final shortRef = _shortenRefToken(refNo.trim());
  if (trimmedPrefix.isEmpty) return shortRef;
  if (shortRef.isEmpty) return trimmedPrefix;
  return '$trimmedPrefix $shortRef';
}

/// Shortens an already-built reference string (e.g. `CASH <uuid>`).
String shortenMobileReportReference(String reference) {
  final trimmed = reference.trim();
  if (trimmed.isEmpty) return trimmed;

  final space = trimmed.lastIndexOf(' ');
  if (space <= 0 || space >= trimmed.length - 1) {
    return _shortenRefToken(trimmed);
  }

  final prefix = trimmed.substring(0, space);
  final refNo = trimmed.substring(space + 1);
  return formatMobileReportReference(prefix, refNo);
}

String _shortenRefToken(String token) {
  if (token.isEmpty) return token;
  if (_uuidLike.hasMatch(token)) {
    return '${token.substring(0, 8)}…';
  }
  if (token.length > 18) {
    return '${token.substring(0, 14)}…';
  }
  return token;
}
