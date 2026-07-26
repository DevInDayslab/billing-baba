import 'package:billing_baba/shared/layout/dashboard_layout.dart';
import 'package:billing_baba/core/platform/app_platform.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

const _desktopWindowSize = Size(
  DashboardLayout.minimumWindowWidth,
  DashboardLayout.minimumWindowHeight,
);

/// Applies desktop window constraints (minimum size) on macOS, Windows, and Linux.
Future<void> configureDesktopWindow() async {
  if (kIsWeb) return;
  if (!AppPlatform.current.isDesktop) return;

  await windowManager.ensureInitialized();

  const windowOptions = WindowOptions(
    size: _desktopWindowSize,
    minimumSize: _desktopWindowSize,
    center: true,
  );

  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
  });
}
