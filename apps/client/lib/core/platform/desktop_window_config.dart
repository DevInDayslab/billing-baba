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
/// Applies the minimum size constraint, then enters true fullscreen and shows
/// the window once it is ready.
Future<void> configureDesktopWindow() async {
  if (kIsWeb) return;
  if (!AppPlatform.current.isDesktop) return;

  await windowManager.ensureInitialized();

  const windowOptions = WindowOptions(
    size: _desktopWindowSize,
    minimumSize: _desktopWindowSize,
    center: true,
    fullScreen: true,
  );

  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    // True fullscreen (not maximize) — native fullscreen on macOS/Windows/Linux.
    await windowManager.setFullScreen(true);
    await windowManager.show();
    await windowManager.focus();
  });
}
