import 'dart:io' show Platform;

import 'package:billing_baba/core/layout/dashboard_layout.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

/// Applies desktop window constraints (minimum size) on macOS, Windows, and Linux.
Future<void> configureDesktopWindow() async {
  if (kIsWeb) return;
  if (!Platform.isMacOS && !Platform.isWindows && !Platform.isLinux) return;

  await windowManager.ensureInitialized();

  await windowManager.setMinimumSize(
    const Size(
      DashboardLayout.minimumWindowWidth,
      DashboardLayout.minimumWindowHeight,
    ),
  );
}
