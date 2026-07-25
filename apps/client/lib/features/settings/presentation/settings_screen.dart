import 'package:billing_baba/core/widgets/adaptive_page.dart';
import './desktop/settings_screen.dart';
import './mobile/settings_screen.dart';
import 'package:flutter/widgets.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AdaptivePage(
      desktop: const DesktopSettingsScreen(),
      mobile: const MobileSettingsScreen(),
    );
  }
}
