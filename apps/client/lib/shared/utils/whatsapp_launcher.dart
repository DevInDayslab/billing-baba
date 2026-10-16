import 'package:url_launcher/url_launcher.dart';

/// Opens WhatsApp Desktop, mobile app, or Web with a pre-filled message.
abstract final class WhatsAppLauncher {
  /// E.164-style digits without `+` (e.g. `919876543210` for India).
  static String? digitsForWaMe(String normalizedPhone) {
    final digits = normalizedPhone.replaceAll(RegExp(r'\D'), '');
    if (digits.length == 10) return '91$digits';
    if (digits.length == 12 && digits.startsWith('91')) return digits;
    if (digits.length >= 11) return digits;
    return null;
  }

  static Future<bool> openChat({
    required String message,
    String? waMePhoneDigits,
  }) async {
    final text = Uri.encodeComponent(message);
    final uris = <Uri>[];

    if (waMePhoneDigits != null && waMePhoneDigits.isNotEmpty) {
      uris.add(
        Uri.parse('whatsapp://send?phone=$waMePhoneDigits&text=$text'),
      );
      uris.add(Uri.parse('https://wa.me/$waMePhoneDigits?text=$text'));
    }

    uris.add(Uri.parse('whatsapp://send?text=$text'));
    uris.add(Uri.parse('https://web.whatsapp.com/send?text=$text'));

    for (final uri in uris) {
      if (await canLaunchUrl(uri)) {
        return launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
    return false;
  }
}
