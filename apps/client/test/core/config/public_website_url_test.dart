import 'package:billing_baba/core/config/public_website_url.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PublicWebsiteUrl.resolve', () {
    test('uses configured URL when publicly reachable', () {
      expect(
        PublicWebsiteUrl.resolve('https://billingbaba.com/'),
        'https://billingbaba.com',
      );
      expect(
        PublicWebsiteUrl.resolve('https://staging.example.com'),
        'https://staging.example.com',
      );
    });

    test('falls back when host is local dev', () {
      expect(
        PublicWebsiteUrl.resolve('http://localhost:5173'),
        PublicWebsiteUrl.defaultUrl,
      );
      expect(
        PublicWebsiteUrl.resolve('http://127.0.0.1:8080'),
        PublicWebsiteUrl.defaultUrl,
      );
    });
  });
}
