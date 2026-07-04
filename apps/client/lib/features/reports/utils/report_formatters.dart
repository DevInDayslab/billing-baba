import 'package:intl/intl.dart';

final reportCurrencyFormat = NumberFormat.currency(
  locale: 'en_IN',
  symbol: '₹ ',
  decimalDigits: 2,
);

final reportCurrencyFormatCompact = NumberFormat.currency(
  locale: 'en_IN',
  symbol: '₹',
  decimalDigits: 0,
);

final reportDateFormat = DateFormat('dd/MM/yyyy');

String formatReportCurrency(double amount) => reportCurrencyFormat.format(amount);

String formatReportCurrencyCompact(double amount) =>
    reportCurrencyFormatCompact.format(amount);

String formatReportDate(DateTime date) => reportDateFormat.format(date);
