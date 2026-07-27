import 'dart:async';

import 'package:billing_baba/app.dart';
import 'package:billing_baba/core/config/app_config.dart';
import 'package:billing_baba/core/logging/device_info_collector.dart';
import 'package:billing_baba/core/logging/logging_service.dart';
import 'package:billing_baba/core/platform/desktop_window_config.dart';
import 'package:billing_baba/core/providers/storage_service_provider.dart';
import 'package:billing_baba/features/auth/services/otp_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

Future<void> main() async {
  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      await configureDesktopWindow();
      GoogleFonts.config.allowRuntimeFetching = false;

      await dotenv.load();
      await AppConfig.initialize();
      await LoggingService.instance.initialize();

      AppConfig.logStartupConfig();
      await _logStartupDiagnostics();

      _installCrashHandlers();

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
        } else {
          LoggingService.instance.warn(
            'MSG91 OTP widget skipped — unsupported platform',
          );
        }
      } else {
        LoggingService.instance.warn(
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
    },
    (error, stack) {
      LoggingService.instance.error('Uncaught zone error', error, stack);
    },
  );
}

Future<void> _logStartupDiagnostics() async {
  if (!AppConfig.consoleVerbose) return;

  try {
    final deviceInfo = await DeviceInfoCollector.collect();
    await LoggingService.instance.logStartupBanner(
      configLines: [
        'Version: ${deviceInfo.buildVersion.split('+').first}',
        ...AppConfig.startupConfigLines(),
      ],
      deviceLines: deviceInfo.toLogLines(),
    );
  } on Object catch (e, st) {
    LoggingService.instance.error('Startup diagnostics failed', e, st);
  }
}

void _installCrashHandlers() {
  FlutterError.onError = (details) {
    LoggingService.instance.error(
      'FlutterError: ${details.exceptionAsString()}',
      details.exception,
      details.stack,
    );
    FlutterError.presentError(details);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    LoggingService.instance.error('Uncaught exception', error, stack);
    return true;
  };
}
