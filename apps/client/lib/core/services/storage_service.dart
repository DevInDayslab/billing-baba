import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Local and secure storage abstraction.
///
/// On macOS, [readSecure]/[writeSecure] use [SharedPreferences] instead of the
/// Keychain. Sandboxed desktop builds without a signed keychain access group
/// fail with `PlatformException(-34018)` when using [FlutterSecureStorage].
class StorageService {
  StorageService({this.preferences, FlutterSecureStorage? secureStorage})
    : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  static const _secureKeyPrefix = 'secure__';

  SharedPreferences? preferences;
  final FlutterSecureStorage _secureStorage;

  bool get _usePreferencesForSecureStorage => !kIsWeb && Platform.isMacOS;

  Future<void> init() async {
    preferences ??= await SharedPreferences.getInstance();
  }

  Future<String?> readSecure(String key) async {
    if (_usePreferencesForSecureStorage) {
      await init();
      return preferences?.getString('$_secureKeyPrefix$key');
    }
    return _secureStorage.read(key: key);
  }

  Future<void> writeSecure(String key, String value) async {
    if (_usePreferencesForSecureStorage) {
      await init();
      await preferences?.setString('$_secureKeyPrefix$key', value);
      return;
    }
    await _secureStorage.write(key: key, value: value);
  }

  Future<void> deleteSecure(String key) async {
    if (_usePreferencesForSecureStorage) {
      await init();
      await preferences?.remove('$_secureKeyPrefix$key');
      return;
    }
    await _secureStorage.delete(key: key);
  }

  String? read(String key) => preferences?.getString(key);

  Future<void> write(String key, String value) async {
    await preferences?.setString(key, value);
  }

  Future<void> remove(String key) async {
    await preferences?.remove(key);
  }

  Set<String> get preferenceKeys =>
      Set<String>.unmodifiable(preferences?.getKeys() ?? const {});
}
