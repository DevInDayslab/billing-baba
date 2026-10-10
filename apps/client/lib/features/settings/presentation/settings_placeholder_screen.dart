import 'package:billing_baba/features/settings/presentation/desktop/desktop_settings_placeholder_screen.dart';
import 'package:billing_baba/features/settings/presentation/mobile/widgets/mobile_settings_placeholder_body.dart';
import 'package:billing_baba/shared/widgets/adaptive_page.dart';
import 'package:flutter/material.dart';

class SettingsPlaceholderScreen extends StatelessWidget {
  const SettingsPlaceholderScreen({
    required this.title,
    super.key,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return AdaptivePage(
      desktop: DesktopSettingsPlaceholderScreen(title: title),
      mobile: MobileSettingsPlaceholderBody(title: title),
    );
  }
}
