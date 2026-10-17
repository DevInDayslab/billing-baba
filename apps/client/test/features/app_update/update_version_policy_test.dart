import 'package:billing_baba/features/app_update/domain/update_version_policy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('isRemoteReleaseNewer', () {
    test('newer semver with lower build', () {
      expect(
        isRemoteReleaseNewer(
          remoteVersion: '1.0.1',
          remoteBuild: 1,
          currentVersion: '1.0.0',
          currentBuild: 2,
        ),
        isTrue,
      );
    });

    test('same semver with higher build', () {
      expect(
        isRemoteReleaseNewer(
          remoteVersion: '1.0.0',
          remoteBuild: 3,
          currentVersion: '1.0.0',
          currentBuild: 2,
        ),
        isTrue,
      );
    });

    test('not newer when semver and build are equal or lower', () {
      expect(
        isRemoteReleaseNewer(
          remoteVersion: '1.0.0',
          remoteBuild: 2,
          currentVersion: '1.0.0',
          currentBuild: 2,
        ),
        isFalse,
      );
      expect(
        isRemoteReleaseNewer(
          remoteVersion: '1.0.0',
          remoteBuild: 1,
          currentVersion: '1.0.0',
          currentBuild: 2,
        ),
        isFalse,
      );
      expect(
        isRemoteReleaseNewer(
          remoteVersion: '0.9.0',
          remoteBuild: 1,
          currentVersion: '1.0.0',
          currentBuild: 2,
        ),
        isFalse,
      );
    });

    test('higher build even when semver is lower', () {
      expect(
        isRemoteReleaseNewer(
          remoteVersion: '1.0.0',
          remoteBuild: 5,
          currentVersion: '1.0.1',
          currentBuild: 1,
        ),
        isTrue,
      );
    });
  });
}
