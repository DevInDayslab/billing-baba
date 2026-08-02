import 'package:billing_baba/core/platform/app_platform.dart';
import 'package:billing_baba/shared/layout/dashboard_layout.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:screen_retriever/screen_retriever.dart';
import 'package:window_manager/window_manager.dart';

const _minimumWindowSize = Size(
  DashboardLayout.minimumWindowWidth,
  DashboardLayout.minimumWindowHeight,
);

/// Configures the desktop window on macOS, Windows, and Linux.
///
/// Opens centered at a ratio of the monitor work area (not maximized) so
/// title-bar controls and the Windows taskbar stay visible. Minimum size is
/// capped to the work area so maximize works on 768px-tall screens.
Future<void> configureDesktopWindow() async {
  if (kIsWeb) return;
  if (!AppPlatform.current.isDesktop) return;

  await windowManager.ensureInitialized();

  final (initialSize, minimumSize) = await _resolveWindowSizes();

  final windowOptions = WindowOptions(
    size: initialSize,
    minimumSize: minimumSize,
    center: true,
    titleBarStyle: TitleBarStyle.normal,
    windowButtonVisibility: true,
  );

  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });
}

/// Returns `(initialSize, minimumSize)` from work-area ratios, with pixel floors.
Future<(Size initialSize, Size minimumSize)> _resolveWindowSizes() async {
  try {
    final display = await screenRetriever.getPrimaryDisplay();
    final workArea = display.visibleSize ?? display.size;

    if (workArea.width <= 0 || workArea.height <= 0) {
      return (_minimumWindowSize, _minimumWindowSize);
    }

    final minimumSize = Size(
      _minimumWindowSize.width.clamp(0, workArea.width),
      _minimumWindowSize.height.clamp(0, workArea.height),
    );

    final initialSize = Size(
      (workArea.width * DashboardLayout.defaultWindowWidthRatio).clamp(
        minimumSize.width,
        workArea.width,
      ),
      (workArea.height * DashboardLayout.defaultWindowHeightRatio).clamp(
        minimumSize.height,
        workArea.height,
      ),
    );

    return (initialSize, minimumSize);
  } on Object catch (error, stackTrace) {
    debugPrint('desktop_window_config: screen size lookup failed: $error');
    debugPrint('$stackTrace');
    return (_minimumWindowSize, _minimumWindowSize);
  }
}
