/// URLs opened on phones (QR, SMS) must not point at the dev machine.
abstract final class PublicWebsiteUrl {
  static const defaultUrl = 'https://billingbaba.com';

  static String resolve(String websiteUrl) {
    final trimmed = websiteUrl.trim();
    if (trimmed.isEmpty) return defaultUrl;

    final uri = Uri.tryParse(trimmed);
    if (uri == null || !uri.hasScheme) return defaultUrl;

    final host = uri.host.toLowerCase();
    if (_isLocalDevHost(host)) return defaultUrl;

    return trimmed.replaceAll(RegExp(r'/+$'), '');
  }

  static bool _isLocalDevHost(String host) {
    return host == 'localhost' ||
        host == '127.0.0.1' ||
        host == '[::1]' ||
        host.endsWith('.local');
  }
}
