import 'package:billing_baba/features/business/application/business_service.dart';
import 'package:billing_baba/features/settings/application/general_settings_provider.dart';
import 'package:billing_baba/shared/business/business_currency_options.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

NumberFormat businessAmountNumberFormat({
  required String currencyCode,
  required int decimalPlaces,
}) {
  final symbol = BusinessCurrencyOptions.symbolFor(currencyCode);
  return NumberFormat.currency(
    locale: 'en_IN',
    symbol: symbol,
    decimalDigits: decimalPlaces.clamp(0, 4),
    name: currencyCode,
  );
}

final businessCurrencyCodeProvider = Provider<String>((ref) {
  return ref.watch(businessProfileProvider).asData?.value?.currency ?? 'INR';
});

final businessAmountFormatterProvider = Provider<NumberFormat>((ref) {
  final code = ref.watch(businessCurrencyCodeProvider);
  final decimals = ref.watch(amountDecimalPlacesProvider);
  return businessAmountNumberFormat(
    currencyCode: code,
    decimalPlaces: decimals,
  );
});

String formatBusinessAmount(Ref ref, double amount) {
  return ref.read(businessAmountFormatterProvider).format(amount);
}

String formatBusinessAmountWith(
  double amount, {
  required String currencyCode,
  required int decimalPlaces,
}) {
  return businessAmountNumberFormat(
    currencyCode: currencyCode,
    decimalPlaces: decimalPlaces,
  ).format(amount);
}
