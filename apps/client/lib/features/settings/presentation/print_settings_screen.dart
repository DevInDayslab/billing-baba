import 'package:billing_baba/features/settings/presentation/desktop/print_settings_screen.dart';
import 'package:billing_baba/features/settings/presentation/mobile/print_settings_screen.dart';
import 'package:billing_baba/shared/widgets/adaptive_page.dart';
import 'package:flutter/widgets.dart';

class PrintSettingsScreen extends StatelessWidget {
  const PrintSettingsScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const AdaptivePage(
      // Same body as the legacy Settings → Print tab (inside desktop shell).
      desktop: DesktopPrintSettingsScreen(embedded: true),
      mobile: MobilePrintSettingsScreen(),
    );
  }
}
