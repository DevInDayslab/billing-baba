import 'dart:io';

import 'package:flutter/services.dart';

const _transparentWebViewChannel = MethodChannel(
  'billing_baba/transparent_webview',
);

/// macOS WKWebView does not support transparent backgrounds via webview_flutter.
/// Walk the native view tree and disable drawsBackground on embedded WKWebViews.
Future<void> enableMacOSWebViewTransparency() async {
  if (!Platform.isMacOS) {
    return;
  }

  for (var attempt = 0; attempt < 6; attempt++) {
    await Future<void>.delayed(Duration(milliseconds: 80 * (attempt + 1)));
    try {
      await _transparentWebViewChannel.invokeMethod<void>(
        'makeWebViewsTransparent',
      );
    } on Object {
      // Retry until the platform view is mounted in the native hierarchy.
    }
  }
}
