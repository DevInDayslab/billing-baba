import 'package:billing_baba/features/auth/services/otp_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
  });

  group('OtpService.isSdkSupported', () {
    test('is true on Android, iOS, macOS, and Windows', () {
      final otp = OtpService();
      for (final platform in [
        TargetPlatform.android,
        TargetPlatform.iOS,
        TargetPlatform.macOS,
        TargetPlatform.windows,
      ]) {
        debugDefaultTargetPlatformOverride = platform;
        expect(
          otp.isSdkSupported,
          isTrue,
          reason: 'OTP must be supported on $platform',
        );
      }
    });

    test('is false on Linux (and Fuchsia)', () {
      final otp = OtpService();
      for (final platform in [
        TargetPlatform.linux,
        TargetPlatform.fuchsia,
      ]) {
        debugDefaultTargetPlatformOverride = platform;
        expect(
          otp.isSdkSupported,
          isFalse,
          reason: 'OTP is not enabled on $platform',
        );
      }
    });
  });
}
