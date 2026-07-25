import 'package:billing_baba/core/widgets/adaptive_page.dart';
import 'package:billing_baba/features/settings/presentation/desktop/whatsapp_settings_screen.dart';
import 'package:billing_baba/features/settings/presentation/mobile/whatsapp_settings_screen.dart';
import 'package:flutter/widgets.dart';

class WhatsAppSettingsScreen extends StatelessWidget {
  const WhatsAppSettingsScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const AdaptivePage(
      desktop: DesktopWhatsAppSettingsScreen(),
      mobile: MobileWhatsAppSettingsScreen(),
    );
  }
}
