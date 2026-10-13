import 'package:billing_baba/features/settings/presentation/desktop/desktop_settings_layout.dart';
import 'package:billing_baba/shared/widgets/adaptive_page.dart';
import 'package:flutter/widgets.dart';

/// Wraps a settings section for desktop with the shared left nav panel.
Widget settingsDesktopRoute(Widget child) {
  return AdaptivePage(
    desktop: DesktopSettingsLayout(child: child),
    mobile: child,
  );
}
