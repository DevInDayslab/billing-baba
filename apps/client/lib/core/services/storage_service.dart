import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Local and secure storage abstraction.
class StorageService {
  StorageService({this.preferences, FlutterSecureStorage? secureStorage})
    : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  SharedPreferences? preferences;
  final FlutterSecureStorage _secureStorage;

  Future<void> init() async {
    preferences ??= await SharedPreferences.getInstance();
  }

  Future<String?> readSecure(String key) => _secureStorage.read(key: key);

  Future<void> writeSecure(String key, String value) =>
      _secureStorage.write(key: key, value: value);

  String? read(String key) => preferences?.getString(key);

  Future<void> write(String key, String value) async {
    await preferences?.setString(key, value);
  }
}
