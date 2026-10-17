import 'package:billing_baba/features/app_update/domain/app_update_info.dart';
import 'package:flutter_test/flutter_test.dart';

import 'update_test_helpers.dart';

void main() {
  group('AppUpdateInfo.fromJson', () {
    test('parses valid manifest', () {
      final info = AppUpdateInfo.fromJson(manifestJson());
      expect(info.latestVersion, '1.0.1');
      expect(info.latestBuild, 2);
      expect(info.minSupportedBuild, 1);
      expect(info.forceUpdate, isFalse);
      expect(info.publishedAt, isNotNull);
    });

    test('ignores unknown fields', () {
      final json = manifestJson();
      json['extra_field'] = 'ignored';
      final info = AppUpdateInfo.fromJson(json);
      expect(info.latestVersion, '1.0.1');
    });

    final requiredStringFields = [
      'latest_version',
      'installer_url',
      'sha256',
      'release_notes',
    ];

    for (final field in requiredStringFields) {
      test('throws when $field is missing', () {
        final json = manifestJson();
        json.remove(field);
        expect(() => AppUpdateInfo.fromJson(json), throwsFormatException);
      });
    }

    test('throws when latest_version is empty', () {
      final json = manifestJson();
      json['latest_version'] = '   ';
      expect(() => AppUpdateInfo.fromJson(json), throwsFormatException);
    });

    test('throws when force_update is wrong type', () {
      final json = manifestJson();
      json['force_update'] = 'yes';
      expect(() => AppUpdateInfo.fromJson(json), throwsFormatException);
    });

    test('throws when latest_build is wrong type', () {
      final json = manifestJson();
      json['latest_build'] = 'two';
      expect(() => AppUpdateInfo.fromJson(json), throwsFormatException);
    });

    test('throws when published_at is invalid', () {
      final json = manifestJson();
      json['published_at'] = 123;
      expect(() => AppUpdateInfo.fromJson(json), throwsFormatException);
    });
  });
}
