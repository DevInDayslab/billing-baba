import 'package:billing_baba/core/platform/app_platform.dart';
import 'package:billing_baba/shared/layout/dashboard_layout.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

const _desktopWindowSize = Size(
  DashboardLayout.minimumWindowWidth,
  DashboardLayout.minimumWindowHeight,
);

/// Configures the desktop window on macOS, Windows, and Linux.
///
/// Applies the minimum size constraint, then maximizes and shows the window
/// once it is ready so launch uses the full available workspace without
/// entering true fullscreen.
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
    // Maximize before show/focus to avoid a medium-sized flash on launch.
    await windowManager.maximize();
    await windowManager.show();
    await windowManager.focus();
  });
}
