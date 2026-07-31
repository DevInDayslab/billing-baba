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
/// Applies the minimum size constraint, then maximizes (not fullscreen) and
/// shows the window once it is ready. Maximize keeps the native title bar and
/// window controls visible, which avoids cropping on Windows.
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
    await windowManager.maximize();
    await windowManager.show();
    await windowManager.focus();
  });
}
