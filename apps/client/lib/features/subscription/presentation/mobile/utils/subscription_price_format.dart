import 'package:intl/intl.dart';

final subscriptionPriceFormat = NumberFormat('#,##0.##', 'en_IN');

String formatSubscriptionPrice(double amount) =>
    '₹${subscriptionPriceFormat.format(amount)}';
