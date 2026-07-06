import 'package:billing_baba/app.dart';
import 'package:billing_baba/core/config/app_config.dart';
import 'package:billing_baba/core/providers/storage_service_provider.dart';
import 'package:billing_baba/features/auth/services/otp_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  await dotenv.load();

  AppConfig.logStartupConfig();

  final widgetId =
      dotenv.env['MSG91_WIDGET_ID'] ?? dotenv.env['MSG91_MOBILE_WIDGET_ID'];
  final widgetAuthToken =
      dotenv.env['MSG91_WIDGET_AUTH_TOKEN'] ??
      dotenv.env['MSG91_MOBILE_WIDGET_TOKEN'] ??
      dotenv.env['MSG91_AUTH_TOKEN'];
  if (widgetId != null &&
      widgetId.isNotEmpty &&
      widgetAuthToken != null &&
      widgetAuthToken.isNotEmpty) {
    final otpService = OtpService();
    if (otpService.isSdkSupported) {
      OtpService.initializeWidget(
        widgetId: widgetId,
        authToken: widgetAuthToken,
      );
    } else if (kDebugMode) {
      debugPrint('MSG91 OTP widget skipped — unsupported platform');
    }
  } else if (kDebugMode) {
    debugPrint(
      'MSG91 OTP widget not initialized — set MSG91_WIDGET_ID and '
      'MSG91_WIDGET_AUTH_TOKEN in .env',
    );
  }

  final container = ProviderContainer();
  await container.read(storageServiceProvider.future);

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const BillingBabaApp(),
    ),
  );
}
