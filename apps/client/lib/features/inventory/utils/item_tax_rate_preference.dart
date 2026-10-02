import 'package:shared_preferences/shared_preferences.dart';

/// Pinned default GST label for new items (Add Item), per business.
abstract final class ItemTaxRatePreference {
  static String _key(String businessId) =>
      'item_pinned_default_tax_rate_$businessId';

  static Future<String?> readPinned(String businessId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key(businessId));
  }

  static Future<void> writePinned(String businessId, String taxRateLabel) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key(businessId), taxRateLabel);
  }

  static Future<void> clearPinned(String businessId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key(businessId));
  }
}
