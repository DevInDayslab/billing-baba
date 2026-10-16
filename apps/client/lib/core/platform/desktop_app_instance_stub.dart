/// Non-IO platforms (web): every launch is treated as the primary instance.
abstract final class DesktopAppInstance {
  static bool get isPrimary => true;

  static Future<void> register() async {}

  static Future<void> release() async {}
}
