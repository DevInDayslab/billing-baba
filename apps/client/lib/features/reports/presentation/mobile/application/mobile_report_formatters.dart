import 'package:intl/intl.dart';

final _mobileReportMetaDateFormat = DateFormat('dd MMM, yy');
final _mobileReportMetaTimeFormat = DateFormat('hh:mm a');

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
  final format = DateFormat('dd/MM/yyyy');
  return '${format.format(start)} TO ${format.format(end)}';
}
