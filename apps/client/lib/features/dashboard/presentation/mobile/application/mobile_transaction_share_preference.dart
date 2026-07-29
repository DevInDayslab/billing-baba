import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// How a transaction is shared from the mobile home feed.
enum MobileTransactionShareFormat { image, pdf }

extension MobileTransactionShareFormatStorage on MobileTransactionShareFormat {
  String get storageValue => name;

  static MobileTransactionShareFormat? fromStorage(String? value) {
    return switch (value) {
      'image' => MobileTransactionShareFormat.image,
      'pdf' => MobileTransactionShareFormat.pdf,
      _ => null,
    };
  }
}

const _preferenceKey = 'mobile_default_transaction_share_format';

/// Persists the default share format chosen from the Share transaction sheet.
final mobileTransactionSharePreferenceProvider =
    AsyncNotifierProvider<
      MobileTransactionSharePreferenceNotifier,
      MobileTransactionShareFormat?
    >(MobileTransactionSharePreferenceNotifier.new);

class MobileTransactionSharePreferenceNotifier
    extends AsyncNotifier<MobileTransactionShareFormat?> {
  @override
  Future<MobileTransactionShareFormat?> build() async {
    final prefs = await SharedPreferences.getInstance();
    return MobileTransactionShareFormatStorage.fromStorage(
      prefs.getString(_preferenceKey),
    );
  }

  Future<void> setDefault(MobileTransactionShareFormat format) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_preferenceKey, format.storageValue);
    state = AsyncData(format);
  }
}
