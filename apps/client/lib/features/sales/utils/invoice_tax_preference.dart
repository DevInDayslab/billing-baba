import 'package:billing_baba/features/business/models/commerce_settings_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists the most recently selected invoice line GST rate per business.
abstract final class InvoiceTaxPreference {
  static String _key(String businessId) =>
      'invoice_recent_tax_rate_$businessId';

  static Future<double?> readRecentRate(String businessId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_key(businessId));
  }

  static Future<void> writeRecentRate(
    String businessId,
    double taxPercent,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    if (taxPercent <= 0) {
      await prefs.remove(_key(businessId));
      return;
    }
    await prefs.setDouble(_key(businessId), taxPercent);
  }

  /// Recent line selection wins over the business default from commerce settings.
  static Future<double?> resolveFallbackTaxPercent({
    required String businessId,
    required CommerceSettingsModel commerceSettings,
  }) async {
    final recent = await readRecentRate(businessId);
    if (recent != null && recent > 0) return recent;

    final defaultTax = commerceSettings.defaultInvoiceTaxPercent;
    if (defaultTax != null && defaultTax > 0) return defaultTax;

    return null;
  }
}
