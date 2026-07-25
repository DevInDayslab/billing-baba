import 'package:billing_baba/core/widgets/adaptive_page.dart';
import './desktop/print_settings_screen.dart';
import './mobile/print_settings_screen.dart';
import 'package:flutter/widgets.dart';

class PrintSettingsScreen extends StatelessWidget {
  const PrintSettingsScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AdaptivePage(
      desktop: const DesktopPrintSettingsScreen(),
      mobile: const MobilePrintSettingsScreen(),
    );
  }
}
