import 'package:billing_baba/features/settings/presentation/desktop/settings_screen.dart';
import 'package:billing_baba/features/settings/presentation/mobile/settings_screen.dart';
import 'package:billing_baba/shared/widgets/adaptive_page.dart';
import 'package:flutter/widgets.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const AdaptivePage(
      desktop: DesktopSettingsScreen(),
      mobile: MobileSettingsScreen(),
    );
  }
}
