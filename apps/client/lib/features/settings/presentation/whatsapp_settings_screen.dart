import 'package:billing_baba/core/widgets/adaptive_page.dart';
import './desktop/whatsapp_settings_screen.dart';
import './mobile/whatsapp_settings_screen.dart';
import 'package:flutter/widgets.dart';

class WhatsAppSettingsScreen extends StatelessWidget {
  const WhatsAppSettingsScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AdaptivePage(
      desktop: const DesktopWhatsAppSettingsScreen(),
      mobile: const MobileWhatsAppSettingsScreen(),
    );
  }
}
