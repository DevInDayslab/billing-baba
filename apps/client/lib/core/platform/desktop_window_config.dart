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

class _ResolvedWindowLayout {
  const _ResolvedWindowLayout({
    required this.initialSize,
    required this.minimumSize,
    this.origin,
  });

  final Size initialSize;
  final Size minimumSize;
  final Offset? origin;
}

/// Configures the desktop window on macOS, Windows, and Linux.
///
/// Opens maximized within the monitor work area (title bar and window controls
/// stay visible). Users can restore and resize afterward.
Future<void> configureDesktopWindow() async {
  if (kIsWeb) return;
  if (!AppPlatform.current.isDesktop) return;

  await windowManager.ensureInitialized();

  final layout = await _resolveWindowLayout();

  final windowOptions = WindowOptions(
    size: layout.initialSize,
    minimumSize: layout.minimumSize,
    center: layout.origin == null,
    titleBarStyle: TitleBarStyle.normal,
    windowButtonVisibility: true,
  );

  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    if (layout.origin != null) {
      await windowManager.setPosition(layout.origin!);
    }
    await windowManager.focus();
  });

  // `waitUntilReadyToShow` applies [WindowOptions] after the ready callback.
  await windowManager.setFullScreen(false);
  await windowManager.maximize();
}

/// Re-applies maximize on the first frame if startup sizing raced the engine.
Future<void> ensureDesktopWindowMaximized() async {
  if (kIsWeb) return;
  if (!AppPlatform.current.isDesktop) return;

  try {
    if (await windowManager.isFullScreen()) {
      await windowManager.setFullScreen(false);
    }
    if (!await windowManager.isMaximized()) {
      await windowManager.maximize();
    }
  } on Object catch (error, stackTrace) {
    debugPrint('desktop_window_config: maximize retry failed: $error');
    debugPrint('$stackTrace');
  }
}

Future<_ResolvedWindowLayout> _resolveWindowLayout() async {
  try {
    final display = await screenRetriever.getPrimaryDisplay();
    final workArea = display.visibleSize ?? display.size;

    if (workArea.width <= 0 || workArea.height <= 0) {
      return const _ResolvedWindowLayout(
        initialSize: _minimumWindowSize,
        minimumSize: _minimumWindowSize,
      );
    }

    final minimumSize = Size(
      _minimumWindowSize.width.clamp(0, workArea.width),
      _minimumWindowSize.height.clamp(0, workArea.height),
    );

    return _ResolvedWindowLayout(
      initialSize: Size(workArea.width, workArea.height),
      minimumSize: minimumSize,
      origin: display.visiblePosition,
    );
  } on Object catch (error, stackTrace) {
    debugPrint('desktop_window_config: screen size lookup failed: $error');
    debugPrint('$stackTrace');
    return const _ResolvedWindowLayout(
      initialSize: _minimumWindowSize,
      minimumSize: _minimumWindowSize,
    );
  }
}
