/// Application-wide constants that do not vary by environment.
abstract final class AppConstants {
  static const connectTimeout = Duration(seconds: 30);
  static const receiveTimeout = Duration(seconds: 30);

  /// Vision/OCR parse calls can take up to ~90s on the server.
  static const documentParseTimeout = Duration(seconds: 120);
}
