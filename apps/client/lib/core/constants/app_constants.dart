/// Application-wide constants that do not vary by environment.
abstract final class AppConstants {
  static const appVersion = '1.0.0';
  static const connectTimeout = Duration(seconds: 30);
  static const receiveTimeout = Duration(seconds: 30);
}
